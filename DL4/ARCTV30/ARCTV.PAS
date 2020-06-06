
(*
 * Copyright 1987, 1990 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ArcTV - arcfile text view utility/door
 *
 *)

{$undef ALLOW_EXTRACT}

{$I prodef.inc}

{$M 5000,0,0} {minstack,minheap,maxheap}

{$D+}    {Global debug information}
{$L+}    {Local debug information}

{ $r+,s+}

program ArcTV;

Uses
   Dos, DosMem, MiniCrt, Mdosio, Tools, CInput;

const
   version = 'ArcTV:  ARC Text Viewer v3.0 of 04-22-90;  (C) 1990 S.H.Smith';

{$ifdef ALLOW_EXTRACT}
   whoami      = 'ARCTVX: Archive Text View/Extract';
   memneeded   = 43000;
   scratcharc  = 'SCRATCH.ARC';
   min_scratch_kfree = 32;      {minimum kbytes required on scratch device}
{$else}
   whoami      = 'ARCTV: Archive Text Viewer';
   memneeded   = 33000;
{$endif}


(*
 *
 * Data declarations for the archive text-view functions.
 *
 *)

const
   max_binary = 50;             {non-printing count before binary file trigger}
   max_linelen = 200;           {line length before binary file triggered}
   maxlines: integer = 500;
                                {maximum lines per session}
   uinbufsize = 512;            {input buffer size}

   {table of filetypes to exclude from text view function}
   nexclude = 2;
   exclude:  array[1..nexclude] of string[3] =
        ('EXE', 'COM');

const
   arcmarc =           26;    { special archive marker }
   arcver =            9;     { max archive header version code }
   fnlen =             12;    { file name length - 1 }

type
   fntype =            array [0.. fnlen] of char;

   heads =             record
         name:    fntype;
         size:    longint;
         date:    word;
         time:    word;
         crc:     word;
         length:  longint;
   end;

var
   hdrver:             integer;
   hdr:                heads;
   arcfile:            dos_handle;
   arc_eof:            boolean;
   extname:            string20;
   pattern:            string20;


const
   dle =               $90;

var
   state:              (nohist,inrep);
   fsize:              longint;
   lastc:              integer;

var
   uinbuf:             array[1..uinbufsize] of byte;
   uinpos:             integer;
   uinmax:             integer;
   ufilepos:           longint;
      
   uoutbuf:            string[max_linelen];
   binary_count:       integer;
   header_present:     boolean;

var
   default_pattern:  string20;
   action:           string20;


(* ------------------------------------------------------------------- *)
function nomore: boolean;
   {check for more output to user; returns true if user doesn't want more}
begin
   check_time_left;
   if dump_user or (linenum >= 2000) then
   begin
      nomore := true;
      exit;
   end;

   nomore := false;
   if linenum < user.pagelen then
      exit;

   {preserve command-line context since the following code "pops up" over
    what ever is running in the foreground}

   display_time(false);
   prompt_def('More:','(Enter) or (Y)es, (N)o, (NS)non-stop? ');
   get_cmdline_raw(56);
   linenum := 1;

   get_nextpar;
   if (par[1] = 'N') or dump_user then
   begin
      if par[2] = 'S' then
         linenum := -30000     {go 30000 lines before stopping again}
      else
      begin
         nomore := true;
         linenum := 2000;   {flag that nomore is in effect}
      end;
   end;
end;



(* ------------------------------------------------------------- *)
(*
 * Processes archive view and extract functions.
 *
 *)


procedure format2(var dest; num: word);
var
   ch: char2 absolute dest;
begin
   ch[1] := chr(ord('0') + num div 10);
   ch[2] := chr(ord('0') + num mod 10);
end;

procedure{function }format_date(dat: word){: anystring};
    (* format archive member date *)
var
   out:  string12;
begin
   out := '00-00-00  ';
   format2(out[1],(dat shr 5) and  15);        {month}
   format2(out[4],(dat      ) and  31);        {day}
   format2(out[7],(dat shr 9) and 127 + 80);   {year}
   {format_date :=} {dGREEN}disp( out );
end;

procedure {function} format_time(tim: word){: anystring};
    (* format archive member time *)
var
   out:  string12;
begin
   out := '00:00:00  ';
   format2(out[1],(tim shr 11) and 31);        {hour}
   format2(out[4],(tim shr  5) and 63);        {minute}
   format2(out[7],(tim shl  1) and 63);        {second}
   {format_time :=} {dCYAN} disp( out);
end;

procedure format_name (var afn; var st: string20);
   (* format archive filename *)
var
   i:  integer;
   fn: char19 absolute afn;

begin
   i := 0;

   while (fn[i+1] <> #0) and (i < 12) do
   begin
      inc(i);
      st[i] := fn[i];
   end;

   st[0] := chr(i);
end;


(* ------------------------------------------------------------- *)

procedure resync;
   (* flush input buffer and force re-synchronization *)
begin
   dos_lseek(arcfile,ufilepos,seek_start);
   uinpos := 0;
end;

procedure skip_rest;
   (* skip to the end of the current archive entry *)
begin
   inc(ufilepos,fsize);
   resync;
   fsize := 0;
end;


(* ------------------------------------------------------------- *)

procedure putc_unp (c:                  integer);
   (* output each character from archive to screen *)

   procedure flushbuf;
   begin
      disp(uoutbuf);
      uoutbuf := '';
   end;

   procedure addchar;
   begin
      inc(uoutbuf[0]);
      uoutbuf[length(uoutbuf)] := chr(c);
   end;

   procedure not_text;
   begin
      newline;
      displn('This is not a text file!');
      skip_rest;
   end;
   
begin

   case c of
   10:  begin
           if linenum < 1000 then
           begin
              flushbuf;
              newline;

              dec(maxlines);
              if (maxlines < 1) and (not dump_user) then
              begin
                  newline;
                  displn('You''ve seen enough.  Please download this file if you want to see more.');
                  dump_user := true;
              end;
           end;

           if nomore or dump_user then
              skip_rest;
        end;

   13:   ;

   26: begin
          flushbuf;
          skip_rest;         {jump to nomore mode on ^z}
       end;

   8,9,32..255:
       begin
          if length(uoutbuf) >= max_linelen then
          begin
             flushbuf;
             if fsize > 10 then
                not_text;
          end;

          if linenum < 1000 then   {stop display on nomore}
             addchar;
       end;

   else
      begin
         if binary_count < max_binary then
            inc(binary_count)
         else
         if fsize > 10 then
            not_text;
      end;
   end;

end;


(* ------------------------------------------------------------- *)

procedure abortme;
   { terminate the program with an error message }
begin
   displn('Abort: Invalid archive');
   arc_eof := true;
end;



(* ------------------------------------------------------------- *)

procedure get_arc(var i: integer);  { read 1 byte from the archive file }
begin
   if arc_eof then
      i := 0
   else
   begin
      if (uinpos < 1) or (uinpos > uinmax) then
      begin
         uinmax := dos_read(arcfile,uinbuf,uinbufsize);
         uinpos := 1;
         if uinmax < 1 then
         begin
            i := 0;
            arc_eof := true;
            exit;
         end;
      end;
      
      i := uinbuf[uinpos];
      inc(uinpos);
      inc(ufilepos);
   end;
end;

procedure bread(var buffer; size: integer);
   {block read from buffered file}
var
   buf:  array[1..maxint] of byte absolute buffer;
   c,i:  integer;
begin
   for i := 1 to size do
   begin
      get_arc(c);
      if arc_eof then 
         exit;
      buf[i] := c;
   end;
end;


(* ------------------------------------------------------------- *)

procedure close_arc;       { close the archive file }
begin
   dos_close(arcfile);
end;


(* ------------------------------------------------------------- *)

procedure putc_unrle (c:                  integer);
begin

   case state of
      nohist:
            if c = dle then
               state := inrep
            else
            begin
               lastc := c;
               putc_unp(c);
            end;

      inrep:
            begin
               if c = 0 then
                  putc_unp(dle)
               else
               begin
                  dec(c);
                  while (c <> 0) do
                  begin
                     putc_unp(lastc);
                     dec(c);
                  end
               end;

               state := nohist;
            end;
   end;
end;


(* ------------------------------------------------------------- *)

procedure getc_unp(var i: integer);
begin
   if fsize = 0 then
      i := -1
   else
   begin
      dec(fsize);
      get_arc(i);
   end;
end;


(********************************************************************)

procedure unsqueeze;

{ definitions for unsqueeze }

const
   error =            -1;
   speof =             256;
   numvals =           256;   { 1 less than the number of values }

type
   nd =                record
         child:              array [0..1] of integer;
   end;

var
   node:               array [0.. numvals] of nd;
   bpos:               integer;
   curin:              integer;
   numnodes:           integer;

   procedure init_usq;        { initialize for unsqueeze }
   var
      i:                integer;

   begin
      bpos := 99;
      bread(numnodes,sizeof(numnodes));
      if (numnodes < 0) or (numnodes > numvals) then
      begin
         abortme;
         exit;
      end;

      node[0].child [0]:=-(speof + 1);
      node[0].child [1]:=-(speof + 1);

      for i := 0 to numnodes - 1 do
      begin
         bread(node [i].child [0], sizeof (integer));
         bread(node [i].child [1], sizeof (integer));
      end;
   end;


(* ------------------------------------------------------------- *)

   procedure getc_usq(var i: integer);
                              { unsqueeze }
   begin
      i := 0;

      while i >= 0 do
      begin
         inc(bpos);

         if bpos > 7 then
         begin
            getc_unp(curin);

            if curin = error then
            begin
               i := error;
               exit;
            end;

            bpos := 0;
            i := node [i].child [1 and curin]
         end
         else
         begin
            curin := curin shr 1;
            i := node [i].child [1 and curin]
         end
      end;

      i := -(i + 1);

      if i = speof then
         i := -1;
   end;

var
   c: integer;
begin
   init_usq;
   getc_usq(c);

   while (c <> -1) and not dump_user do
   begin
      putc_unrle(c);
      getc_usq(c);
   end;
end;


(********************************************************************)

procedure old_uncrunch;

{ definitions for uncrunch }

const
   tabsize =           4096;
   tabsizem1 =         4095;
   no_pred =           -1;
   empty =             -1;

type
   entry =             record
         used:               boolean;
         next:               integer;
         predecessor:        integer;
         follower:           byte;
   end;

   string_tab_rec      = array [0..tabsizem1] of entry;
   stack_rec           = array [0.. tabsizem1] of byte;

var
   sp:                 integer;
   string_tab:         ^string_tab_rec;
   stack:              ^stack_rec;

var
   code_count:         integer;
   code:               integer;
   firstc:             boolean;
   oldcode:            integer;
   finchar:            integer;
   inbuf:              integer;
   outbuf:             integer;
   newhash:            boolean;


(* ------------------------------------------------------------- *)

   function eolist (index:              integer): integer;
   var
      temp:               integer;

   begin
      temp := string_tab^ [index].next;
      while temp <> 0 do
      begin
         index := temp;
         temp := string_tab^ [index].next;
      end;

      eolist := index;
   end;


(* ------------------------------------------------------------- *)

   function hash (pred,
                  foll: integer): integer;
                              { calculate hash value }
                              { thanks to bela lubkin }
   var
      local2:             longint;
      h:                  integer;
      tempnext:           integer;
   begin

      if newhash then
         local2 := longint(pred + foll) * 15073
      else
      begin
         local2 := word( (pred + foll) or $0800) and $FFFF;
         local2 := local2 * local2;
         local2 := (local2 shr 6) and $0FFF;
      end;

      h := local2 mod tabsize;

      if string_tab^ [h].used then
      begin
         h := eolist (h);
         tempnext :=(h + 101) mod tabsize;

         while string_tab^ [tempnext].used do
         begin
            inc(tempnext);
            if tempnext = tabsize then
               tempnext := 0;
         end;

         string_tab^ [h].next := tempnext;
         h := tempnext;
      end;

      hash := h;
   end;


(* ------------------------------------------------------------- *)

   procedure upd_tab (pred,
                      foll:  integer);
   begin
      with string_tab^ [hash (pred, foll)] do
      begin
         used := true;
         next := 0;
         predecessor := pred;
         follower := foll;
      end
   end;


(* ------------------------------------------------------------- *)

   procedure gocode(var i: integer);
   var
      localbuf:           integer;
      returnval:          integer;

   begin

      if inbuf = -1 then
      begin
         getc_unp(localbuf);
         if localbuf = -1 then
         begin
            i := -1;
            exit;
         end;

         localbuf := localbuf and $00ff;

         getc_unp(inbuf);
         if inbuf = -1 then
         begin
            i := -1;
            exit;
         end;

         inbuf := inbuf and $00ff;
         returnval :=((localbuf shl 4) and $0ff0)+((inbuf shr 4) and $000f);
         inbuf := inbuf and $000f
      end
      else

      begin
         getc_unp(localbuf);
         if localbuf = -1 then
         begin
            i := -1;
            exit;
         end;

         localbuf := localbuf and $00ff;
         returnval := localbuf +((inbuf shl 8) and $0f00);
         inbuf := -1;
      end;

      i := returnval;
   end;


(* ------------------------------------------------------------- *)

   procedure push (c:                  integer);
   begin
      stack^[sp] := c;
      inc(sp);

      if sp >= tabsize then
         abortme;
   end;



(* ------------------------------------------------------------- *)

   procedure init_tab;
   var
      i:                  integer;

   begin
      fillchar(string_tab^, sizeof (string_tab^), 0);

      for i := 0 to 255 do
         upd_tab(no_pred, i);

      inbuf := -1;
   end;


(* ------------------------------------------------------------- *)

   procedure init_ucr (i:                  integer);
   begin
      newhash := i = 1;
      sp := 0;
      init_tab;
      code_count := tabsize - 256;
      firstc := true;
   end;


(* ------------------------------------------------------------- *)

   procedure getc_ucr(var i: integer);
   var
      c:                  integer;
      code:               integer;
      newcode:            integer;

   begin

      if firstc then
      begin
         firstc := false;
         gocode(oldcode);
         finchar := string_tab^ [oldcode].follower;
         i := finchar;
         exit;
      end;

      if sp = 0 then
      begin
         gocode(newcode);
         code := newcode;

         if (code = -1) or dump_user then
         begin
            i := -1;
            exit;
         end;

         if not string_tab^ [code].used then
         begin
            code := oldcode;
            push(finchar)
         end;

         while string_tab^ [code].predecessor <> no_pred do
            with string_tab^ [code] do
            begin
               push(follower);
               code := predecessor;
            end;

         finchar := string_tab^ [code].follower;
         push(finchar);

         if code_count <> 0 then
         begin
            upd_tab(oldcode, finchar);
            dec(code_count);
         end;

         oldcode := newcode
      end;

      if sp > 0 then
      begin
         dec(sp);
         i := stack^ [sp]
      end
      else
         i := -1;
   end;


(* ------------------------------------------------------------- *)

{ old_uncrunch }
var
   c: integer;

begin
   dos_getmem(string_tab,sizeof(string_tab^));
   dos_getmem(stack,sizeof(stack^));

   case hdrver of
      5:    begin   {old crunch 1}
               init_ucr(0);
               getc_ucr(c);

               while c <> -1 do
               begin
                  putc_unp(c);
                  getc_ucr(c);
               end;
            end;

      6:    begin  {crunch 2}
               init_ucr(0);
               getc_ucr(c);

               while c <> -1 do
               begin
                  putc_unrle(c);
                  getc_ucr(c);
               end;
            end;

      7:    begin  {new crunch 1}
               init_ucr(1);
               getc_ucr(c);

               while c <> -1 do
               begin
                  putc_unrle(c);
                  getc_ucr(c);
               end;
            end;
   end;

   dos_freemem(string_tab);
   dos_freemem(stack);
end;



(************************************************************)

procedure uncrunch(squash: integer);

{ definitions for dynamic uncrunch }

const
   crunch_bits =       12;
   squash_bits =       13;
   hsize =             8192;
   hsizem1 =           8191;
   init_bits =         9;
   first =             257;
   clear =             256;
   bitsm1 =            12;
   rmask : array [0..8] of byte =
      ($00, $01, $03, $07, $0f, $1f, $3f, $7f, $ff);
   
type
   hsize_array_integer = array [0..hsizem1] of integer;
   hsize_array_byte    = array [0..hsizem1] of byte;

var
   bits,
   n_bits,
   maxcode:            integer;
   buf:                array [0.. bitsm1] of byte;
   clear_flg:          integer;
   free_ent:           integer;
   maxcodemax:         integer;
   offset,
   sizex:              integer;
   firstch:            boolean;

   prefix:             ^hsize_array_integer;
   suffix:             ^hsize_array_byte;
   stack1:             ^hsize_array_byte;

(* ------------------------------------------------------------- *)

   procedure getcode(var res: integer);

   label next;
   var
      code,
      r_off,
      bitsx:              integer;
      bp:                 byte;
      ii:                 integer;

   begin

      if firstch then
      begin
         offset := 0;
         sizex := 0;
         firstch := false;
      end;

      bp := 0;

      if (clear_flg > 0) or (offset >= sizex) or (free_ent > maxcode) then
      begin

         if free_ent > maxcode then
         begin
            inc(n_bits);

            if n_bits = bits then
               maxcode := maxcodemax
            else
               maxcode :=(1 shl n_bits)- 1;
         end;

         if clear_flg > 0 then
         begin
            n_bits := init_bits;
            maxcode :=(1 shl n_bits)- 1;
            clear_flg := 0;
         end;

         for ii := 0 to n_bits - 1 do
         begin
            sizex := ii;
            getc_unp(code);
            if code = -1 then
               goto next
            else
               buf[sizex] := code;
         end;

         inc(sizex);

   next :;
         if sizex <= 0 then
         begin
            res := -1;
            exit;
         end;

         offset := 0;
         sizex :=(sizex shl 3)-(n_bits - 1);
      end;

      r_off := offset;
      bitsx := n_bits;           { get first byte }

      bp := bp +(r_off shr 3);
      r_off := r_off and 7;      { get first parft (low order bits) }
      code := buf [bp] shr r_off;
      inc(bp);
      bitsx := bitsx -(8 - r_off);
      r_off := 8 - r_off;

      if bitsx >= 8 then
      begin
         code := code or (buf [bp] shl r_off);
         inc(bp);
         r_off := r_off + 8;
         bitsx := bitsx - 8;
      end;

      code := code or ((buf [bp] and rmask [bitsx]) shl r_off);
      offset := offset + n_bits;
      res := code;
   end;


(* ------------------------------------------------------------- *)

   procedure decomp (squashflag:         integer);
   label next;
   var
      stackp,
      finchar:            integer;
      code,
      oldcode,
      incode:             integer;

   begin                         { init var }
      if squashflag = 0 then
         bits := crunch_bits
      else
         bits := squash_bits;

      if firstch then
         maxcodemax := 1 shl bits;

      if squashflag = 0 then
      begin
         getc_unp(code);
         if code <> bits then
         begin
            abortme;
            exit;
         end;
      end;

      clear_flg := 0;
      n_bits := init_bits;
      maxcode :=(1 shl n_bits)- 1;

      for code := 255 downto 0 do
      begin
         prefix^[code]:= 0;
         suffix^[code]:= code;
      end;

      free_ent := first;
      getcode(oldcode);
      finchar := oldcode;

      if oldcode = -1 then
         exit;

      if squashflag = 0 then
         putc_unrle(finchar)
      else
         putc_unp(finchar);

      stackp := 0;
      getcode(code);

      while (code > -1) and not dump_user do
      begin
         if code = clear then
         begin
            for code := 255 downto 0 do
               prefix^[code]:= 0;

            clear_flg := 1;
            free_ent := first - 1;
            getcode(code);

            if code = -1 then
               goto next;
         end;

   next:
         incode := code;

         if code >= free_ent then
         begin
            stack1^[stackp]:= finchar;
            inc(stackp);
            code := oldcode;
         end;

         while (code >= 256) do
         begin
            stack1^[stackp]:= suffix^ [code];
            inc(stackp);
            code := prefix^ [code];
         end;

         finchar := suffix^ [code];
         stack1^[stackp]:= finchar;
         inc(stackp);

         repeat
            dec(stackp);
            if squashflag = 0 then
               putc_unrle(stack1^ [stackp])
            else
               putc_unp(stack1^ [stackp]);
         until stackp <= 0;

         code := free_ent;

         if code < maxcodemax then
         begin
            prefix^[code]:= oldcode;
            suffix^[code]:= finchar;
            free_ent := code + 1;
         end;

         oldcode := incode;
         getcode(code);
      end;
   end;

(* ------------------------------------------------------------- *)

begin
   {allocate heap storage}

   dos_getmem(prefix,sizeof(prefix^));
   dos_getmem(stack1,sizeof(stack1^));
   dos_getmem(suffix,sizeof(suffix^));

   firstch := true;
   decomp(squash);

   {release heap storage}
   dos_freemem(prefix);
   dos_freemem(suffix);
   dos_freemem(stack1);
end;

(**************************************************************)


procedure viewfile;
var
   c:                  integer;
   filestart:          longint;

begin
   {default_color;}
   
   binary_count := 0;
   uoutbuf := '';
   fsize := hdr.size;
   state := nohist;
   filestart := ufilepos;

   case hdrver of
      1, 2: begin   {store 1, store 2}
               getc_unp(c);
               while c <> -1 do
               begin
                  putc_unp(c);
                  getc_unp(c);
               end
            end;

      3:    begin  {packed}
               getc_unp(c);
               while c <> -1 do
               begin
                  putc_unrle(c);
                  getc_unp(c);
               end;
            end;

      4:    unsqueeze;

      5..7: old_uncrunch;

      8:    uncrunch(0);  {new crunch 2}

      9:    uncrunch(1);  {squash}

      else  displn('I dont know how to unpack this file.');
   end;

   newline;

   {rewind to start of viewed file}
   ufilepos := filestart;
   resync;
end;


(* ------------------------------------------------------------- *)

{$IFDEF ALLOW_EXTRACT}

   procedure xtract;
      (* extract the current member into a scratch file *)

   const
      bufmax = $F000;  {maximum buffer size in bytes}
      extra = $1000;   {extra heap to leave free}
   var
      bufsize: word;   {actual buffer size}
      ifd:     dos_handle;
      ofd:     dos_handle;
      buf:     ^byte;
      n,w:     word;
      ver:     byte;

   begin

      (* see if enough RAM space is free for copy buffer *)
      bufsize := bufmax;
      if bufsize > maxavail-extra then
         bufsize := maxavail-extra;
         
      if bufsize < extra then
      begin
         {displn('?ram');}
         exit;
      end;


      (* create SCRATCH archive if needed, otherwise position for append *)
      if dos_exists(scratcharc) then
      begin
         ofd := dos_open(scratcharc,open_update);
         dos_lseek(ofd,-2,seek_end);               {rewrite eof header}
      end
      else
         ofd := dos_create(scratcharc);           {else create file if needed}

      if ofd = dos_error then
      begin
         {displn('?create');}
         exit;
      end;


      (* write the header for this new member *)
      ver := arcmarc;
      dos_write(ofd,ver,1);
      ver := hdrver;
      dos_write(ofd,ver,1);
      dos_write(ofd,hdr,sizeof(hdr));


      (* copy the member file to the scratchfile *)
      fsize := hdr.size;
      dos_getmem(buf,bufsize);

      resync;

      repeat
         if fsize > bufsize then
            n := bufsize
         else
            n := fsize;
         fsize := fsize - n;

         n := dos_read(arcfile,buf^,n);
         inc(ufilepos,n);

         dos_write(ofd,buf^,n);
         w := dos_regs.ax;
      until w < bufsize;


      (* write an eof marker (header with method=0) *)
      ver := arcmarc;
      dos_write(ofd,ver,1);
      ver := 0;
      dos_write(ofd,ver,1);
      dos_close(ofd);

      if n <> w then
      begin
         {displn('?write');}
         dos_unlink(scratcharc);
      end;

      dos_freemem(buf);
      resync;
   end;

{$ENDIF}


(* ------------------------------------------------------------- *)

procedure describe;
   (* print a verbose description of the current archive header *)

begin
   if not header_present then
   begin
      newline;
    {$IFDEF ALLOW_EXTRACT}
      displn(' File Name    Length    Date      Time    (Enter) or (S)kip, (V)iew, (X)tract');
      displn ('-----------   ------   ------    ------   -----------------------------------');
    {$ELSE}
      displn(' File Name    Length    Date      Time    (Enter) or (S)kip, (V)iew');
      displn ('-----------   ------   ------    ------   -------------------------');
    {$ENDIF}

      header_present := true;
   end;

   {dMAGENTA} disp(ljust(extname,12));
   {dRED}     disp(ftoa(hdr.length,8,0));
   spaces(2);
   format_date(hdr.date);
   format_time(hdr.time);
end;


(* ------------------------------------------------------------- *)

function read_header: boolean;
                           { read a file header from the archive file }
                           { false = eof found; true = header found }
var
   name:               fntype;
   try:                integer;
   c:                  integer;

begin
   read_header := false;

   if arc_eof or dump_user then
      exit;

   resync;
   try := 100;
   get_arc(c);
   while (c <> arcmarc) and (try > 0) do
   begin
      get_arc(c);
      dec(try);
   end;

   get_arc(hdrver);
   if (try = 0) or (hdrver < 0) then
   begin
      abortme;
      exit;
   end;

   if hdrver = 0 then         { special end of file marker }
      exit;

   if hdrver > arcver then
   begin
      bread(name,fnlen);
      abortme;
      exit;
   end;

   if hdrver = 1 then
   begin
      bread(hdr,sizeof(heads)-sizeof(longint));
      hdrver := 2;
      hdr.length := hdr.size;
   end
   else
      bread(hdr,sizeof(heads));

   read_header := true;
end;


(* ------------------------------------------------------------- *)
procedure view_archive_text(arcname: anystring);



(* ------------------------------------------------------------- *)

procedure open_arc;        { open the archive file for input processing }

begin
   arcfile := dos_open(arcname,open_read);
   arc_eof := arcfile = dos_error;
   ufilepos := 0;
   uinpos := 0;
end;


(* ------------------------------------------------------------- *)

procedure process_file;
var
   ext:      string20;
   i:        integer;
   istext:   boolean;
   done:     boolean;

begin

(* skip the file if it does not match the selection wildcard *)
   format_name (hdr.name, extname);
   if not wildcard_match(pattern,extname) then
   begin
      inc(ufilepos,hdr.size);
      resync;
      exit;
   end;

(* find out if it is a non-text file based on extention *)
   ext := ext_only(extname);
   istext := true;
   for i := 1 to nexclude do
      if copy(ext,1,length(exclude[i])) = exclude[i] then
         istext := false;

(* ask user what to do with the file *)
   repeat
      set_function(fun_arcview);
      describe;
      {dYELLOW} disp('Action? ');
      action := 'S';
      input(action,1);
      stoupper(action);
      done := false;

      case action[1] of
      'Y','V','D':                (* view/display file *)
         if verify_level(fun_textview) then
         begin
            if istext then
            begin
               displn(' [View]');
               newline;

               linenum := 1;
               viewfile;        (* view file and rewind to see it again *)

               header_present := false;
               newline;
            {  make_log_entry('View archive member ('+extname
                                        +') from ('+remove_path(arcname)
                                        +')',true); }
               done := false;
            end
            else
               displn(' [Not a textfile!]');
         end;

    {$IFDEF ALLOW_EXTRACT}
      'X','E':                  (* extract to scratch.arc *)
         if verify_level(fun_xtract) then
         begin
            if arcname = scratcharc then
               displn(' [Cant!]')
            else
            begin
               disp(' [Extract]');
               xtract;
               newline;
             { make_log_entry('Extract archive member ('+extname
                                        +') from ('+remove_path(arcname)
                                        +')',true); }
               done := true;
            end;
         end;
    {$ENDIF}

      'S':                      (* skip to next entry *)
         begin
            displn(' [Skip]');
            inc(ufilepos,hdr.size);
            resync;
            done := true;
         end;

      'Q':                      (* quit, skip rest of arc *)
         begin
            displn(' [Quit]');
            arc_eof := true;
            done := true;
         end;

      else
          {$IFDEF ALLOW_EXTRACT}
            displn(' [Type Q, S, V or X!]');
          {$ELSE}
            displn(' [Type Q, S, or V!]');
          {$ENDIF}
      end;

   until done or dump_user;

end;

(* ------------------------------------------------------------- *)

   { extract and view text files in the archive - main entry }
   
begin
   default_pattern := '*.*';

   repeat
      newline;
      if length(cmdline) = 0 then
      begin
         disp{dWHITE}(remove_path(arcname));

{$IFDEF ALLOW_EXTRACT}
         get_def(': Extract/view member filespec:',
                     enter_eq+default_pattern+'? ');
{$ELSE}
         get_def(': View member filespec:',
                     enter_eq+default_pattern+'? ');
{$ENDIF}
      end;
      
      get_nextpar;
      pattern := par;
            
      stoupper(pattern);
      if length(pattern) = 0 then
         pattern := default_pattern;
      if (pattern = 'none') or (pattern = 'Q') or dump_user then
         exit;
   
      open_arc;
      if arc_eof then
         exit;
   
      header_present := false;
      while read_header do
         process_file;
   
      close_arc;
      
      default_pattern := 'none';
   until action[1] = 'Q';
end;

{ $R+}


(* ----------------------------------------------------- *)
procedure view_archive_contents(arcname: anystring);

type
   (* layout of ARC file headers *)
   arc_header_rec = record
      method:   byte;
      name:     char12;
      flag2:    byte;
      length:   longint;
      date:     integer;
      time:     integer;
      crc:      integer;
      size:     longint;
   end;

var
   hdr:     arc_header_rec;
   fname:   string13;
   fd:      dos_handle;
   n:       integer;
   flag:    byte;

const
   maxmethod = 12;
   methods:  array[0..maxmethod] of string[11] =
             ('0',
              '  Stored   ','  Stored   ','  Packed   ',' Squeezed  ',
              ' crunched  ',' crunched  ',' Crunched  ',' Crunched  ',
              ' Squashed  ','  pack10   ','  pack11   ','  pack12   ');


   procedure find_header;
      (* find the next archive member header, skipping bytes until
         the header flag byte is found *)
   var
      count: integer;
   begin
      count := 100;

      repeat
         n := dos_read(fd,flag,1);
         dec(count);
      until (flag = $1a) or (n <> 1) or (count < 1);

      n := dos_read(fd,hdr,sizeof(hdr));
      if hdr.method = 1 then
      begin
         dos_lseek(fd,-4,seek_cur);
         hdr.size := hdr.length;
      end;
   end;

begin
   fd := dos_open(arcname,open_read);
   if fd = dos_error then
      exit;

   newline;
   displn(' File Name    Length    Method   Size Now     Date      Time    CRC');
   displn('-----------   ------    ------   --------    ------    ------   ---');

   find_header;
   while (hdr.method > 0) and (nomore = false) do
   begin
      format_name(hdr.name,fname);

      (* make sure it's an archive *)
      if (n <> sizeof(hdr)) or (flag <> $1a) or
         (hdr.method > maxmethod) then
      begin
         dos_close(fd);
         make_log_entry('Error in archive',true);
         exit;
      end;

      (* report the archive entry *)
      disp(ljust(fname,12));
      disp(ftoa(hdr.size,8,0));
      spaces(2);
      disp(methods[hdr.method]);
      disp(ftoa(hdr.length,8,0));
      spaces(3);
      format_date(hdr.date);
      format_time(hdr.time);
      displn(itoh(hdr.crc));
      
      (* get the next header *)
      dos_lseek(fd,hdr.length,seek_cur);
      find_header;
   end;

   newline;
   dos_close(fd);
end;


(* ----------------------------------------------------- *)
procedure view_arcfile(name: filenames);
var
   mem:    longint;
begin
   linenum := 1;
   cmdline := '';
   view_archive_contents(name);

{$IFDEF ALLOW_EXTRACT}
   get_def('Extract or View files in this archive:','(Enter)=yes? ');
{$ELSE}
   get_def('View text files in this archive:','(Enter)=yes? ');
{$ENDIF}

   (* process text viewing if desired *)
   get_nextpar;
   if par[1] <> 'N' then
   begin
      mem := memneeded - dos_maxavail;
      if mem > 0 then
         displn(ltoa(mem)+' more bytes of RAM needed to allow text viewing!')
      else
         view_archive_text(name);
   end;
end;


(*
 * main program
 *
 *)

var
   i:    integer;
   par:  anystring;
   n:    integer;

begin
   SetScrollPoint(23);
   gotoxy(1,23);
   linenum := 1;

   if paramcount = 0 then
   begin
      displn(version);
{     newline;
      displn('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
      newline;  }

      displn('Usage:  arctv [-Pport] [-Tminutes] [-Llines] [-Mlines] FILE[.arc]');

{     newline;
      displn('-Pn   enables com port COMn and monitors carrier');
      displn('-Tn   allows user to stay in program for n minutes');
      displn('-Ln   sets lines per screen');
      displn('-Mn   sets maximum lines per session');
}
      halt;
   end;

   for i := 1 to paramcount do
   begin
      par := paramstr(i);
      n := atoi(copy(par,3,5));

      if par[1] = '-' then
         case upcase(par[2]) of
            'P':  opencom(n);
            'T':  tlimit := n;      {time limit}
            'L':  user.pagelen := n;
            'M':  maxlines := n;
         end
      else

      begin
        if pos('.',par) = 0 then
            par := par + '.ARC';

        if dos_exists(par) then
            view_arcfile(par)
        else
            displn('File not found: '+par);
      end;
   end;

   newline;
   displn(version);
   closecom;
end.

