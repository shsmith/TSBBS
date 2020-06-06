
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * LzhTV - text view utility/door for LHARC-format .LZH files
 *
 *)

{$I prodef.inc}
{$M 5000,0,0}  {minstack,minheap,maxheap}
{$D+}          {Global debug information}
{$L+}          {Local debug information}

program LzhTV;

Uses
   Dos, DosMem, MiniCrt, Mdosio, Tools, CInput;

const
   version = 'LzhTV:  LZH Text Viewer v1.2 of 04-22-90;  (C) 1990 S.H.Smith';


(* ----------------------------------------------------------- *)
(*
 * file layout declarations
 *
 *)

type
   lharc_header_rec = record
      header_length:       byte;                {0=end of file}
      header_check:        byte;                {checksum of remaining bytes}
      compression_type:    array[1..5] of char; {'-lh0-'=store '-lh1-'=LZHuf}
      compressed_size:     longint;
      original_size:       longint;
      file_time:           word;
      file_date:           word;
      file_attributes:     word;
      file_name_length:    byte;
      file_name:           string[65];
      crc16:               word;
   end;


(* ----------------------------------------------------------- *)
(*
 * input file variables
 *
 *)

const
   uinbufsize = 512;    {input buffer size}
var
   fileeof:       boolean;
   infd:          dos_handle;
   infn:          dos_filename;
   inbuf:         array[1..uinbufsize] of byte;
   inpos:         integer;
   incnt:         integer;

   header:        lharc_header_rec;


(* ----------------------------------------------------------- *)
(*
 * output stream variables
 *
 *)

const
   obufsize = 4096;     (* output buffer size; should be 4096 *)
   lookahead = 60;      (* lookahead buffer size *)
   THRESHOLD = 2;
   max_binary =   50;   {non-printing count before binary file trigger}
   max_linelen =  200;  {line length before binary file triggered}

   maxlines: integer = 500;
                        {maximum lines per session}

var
   outbuf:        array[0..obufsize] of byte; {for rle look-back}
   outpos:        longint;                 {absolute position in outfile}

   lson:    array[0..obufsize+1] of integer;
   rson:    array[0..obufsize+257] of integer;
   dad:     array[0..obufsize+1] of integer;

   uoutbuf:       string[max_linelen];    {disp line buffer}
   binary_count:  integer;                {non-text chars so far}


(* ----------------------------------------------------------- *)
(*
 * other working storage
 *
 *)

var
   expand_files:        boolean;
   header_present:      boolean;
   default_pattern:     string20;
   pattern:             string20;
   action:              string20;



(* ----------------------------------------------------
 *
 *    file input/output handlers
 *
 *)

procedure skip_rest;
begin
   dos_lseek(infd,header.compressed_size-incnt,seek_cur);
   fileeof := true;
   header.compressed_size := 0;
   incnt := 0;
end;

procedure skip_csize;
begin
   incnt := 0;
   skip_rest;
end;

procedure ReadByte(var x: byte);
begin
   if incnt = 0 then
   begin
      if header.compressed_size = 0 then
      begin
         fileeof := true;
         exit;
      end;

      inpos := sizeof(inbuf);
      if inpos > header.compressed_size then
         inpos := header.compressed_size;
      incnt := dos_read(infd,inbuf,inpos);

      inpos := 1;
      dec(header.compressed_size,incnt);
   end;

   x := inbuf[inpos];
   inc(inpos);
   dec(incnt);
end;


(* ------------------------------------------------------------- *)
procedure OutByte (c: integer);
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
   outbuf[outpos mod obufsize] := c;
   inc(outpos);

(********
if c = 13 then
else if c = 10 then begin
if nomore then skip_rest else newline;
end else write(chr(c));
exit;
********)

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

   13: ;

   26: begin
          flushbuf;
          skip_rest;         {jump to nomore mode on ^z}
       end;

   8,9,32..255:
       begin
          if length(uoutbuf) >= max_linelen then
          begin
             flushbuf;
             if header.compressed_size > 10 then
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
         if header.compressed_size > 10 then
            not_text;
      end;
   end;

end;


(* ---------------------------------------------------------- *)

{$i unlzh.inc}    {lzh expander}


(* ---------------------------------------------------------- *)
(*
 * This procedure displays the text contents of a specified archive
 * file.  The filename must be fully specified and verified.
 *
 *)

procedure viewfile;
var
   b: byte;

begin
   newline;
   {default_color;}
   binary_count := 0;
   getbuf := 0;
   getlen := 0;
   incnt := 0;
   outpos := 0;
   uoutbuf := '';
   fileeof := false;

   if header.compression_type = '-lh0-' then
      while (not fileeof) and (not dump_user) do
      begin
         ReadByte(b);
         OutByte(b);
      end
   else

   if header.compression_type = '-lh1-' then
      UnLZHuf
   else

      displn('Unknown compression method.');

   if nomore=false then
      newline;
   linenum := 1;
end;


(* ---------------------------------------------------------- *)
procedure _itoa(i: integer; var sp);
var
   s: array[1..2] of char absolute sp;
begin
   s[1] := chr( (i div 10) + ord('0'));
   s[2] := chr( (i mod 10) + ord('0'));
end;

function format_date(date: word): string8;
const
   s:       string8 = 'mm-dd-yy';
begin
   _itoa(((date shr 9) and 127)+80, s[7]);
   _itoa( (date shr 5) and 15,  s[1]);
   _itoa( (date      ) and 31,  s[4]);
   format_date := s;
end;

function format_time(time: word): string8;
const
   s:       string8 = 'hh:mm:ss';
begin
   _itoa( (time shr 11) and 31, s[1]);
   _itoa( (time shr  5) and 63, s[4]);
   _itoa( (time shl  1) and 63, s[7]);
   format_time := s;
end;


(* ---------------------------------------------------------- *)
procedure process_file_header;
var
   n:             word;
   fpos:          longint;
   filename:      dos_filename;

begin
   dos_lseek(infd,0,seek_cur);
   fpos := dos_tell;

   while (dump_user = false) do
   begin
      set_function(fun_arcview);

      dos_lseek(infd,fpos,seek_start);
      n := dos_read(infd,header.header_check,sizeof(byte));
      n := dos_read(infd,header.compression_type,sizeof(header.compression_type));
      n := dos_read(infd,header.compressed_size,sizeof(longint));
      n := dos_read(infd,header.original_size,sizeof(longint));
      n := dos_read(infd,header.file_time,sizeof(word));
      n := dos_read(infd,header.file_date,sizeof(word));
      n := dos_read(infd,header.file_attributes,sizeof(word));
      n := dos_read(infd,header.file_name_length,sizeof(byte));
      n := dos_read(infd,header.file_name[1],header.file_name_length);
      n := dos_read(infd,header.crc16,sizeof(word));
      header.file_name[0] := chr(header.file_name_length);
      filename := remove_path(header.file_name);
      stoupper(filename);


      (* exclude the file if outside current pattern *)
      if nomore or (not wildcard_match(pattern,filename)) then
      begin
         skip_csize;
         exit;
      end;

      (* display file information headers if needed *)
      if not header_present then
      begin
         header_present := true;

         newline;
         disp(' File Name    Length   Method     Date      Time');
         if expand_files then disp('    (Enter) or (S)kip, (V)iew');
         newline;

         disp('------------  ------  --------  --------  --------');
         if expand_files then disp('  -------------------------');
         newline;
      end;


      (* display file information *)
      disp(ljust(filename,12)+' '+
           rjust(ltoa(header.original_size),7)+'    '+
           header.compression_type+'   '+
           format_date(header.file_date)+'  '+
           format_time(header.file_time));

      if not expand_files then
      begin
         skip_csize;
         newline;
         exit;
      end;


      (* determine action to perform on this member file *)
      action := 'S';
      disp('  Action? ');
      input(action,1);
      stoupper(action);

      case action[1] of
         'S':
            begin
               displn(' [Skip]');
               skip_csize;
               exit;
            end;

         'V','R':
            begin
               displn(' [View]');
               viewfile;

               header_present := false;
            {  make_log_entry('View archive member ('+extname
                                        +') from ('+remove_path(arcname)
                                        +')',true); }
            end;

         'Q':
            begin
               displn(' [Quit]');
               dos_lseek(infd,0,seek_end);
               exit;
            end;

         else
            displn(' [Type S, V or Q!]');
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure process_headers;
var
   n: integer;

begin
   dos_lseek(infd,0,seek_start);
   header_present := false;

   while (not dump_user) do
   begin
      n := dos_read(infd,header.header_length,sizeof(byte));

      if (header.header_length = 0) or (n = 0) then
         exit
      else

      if header.header_length >= 22 then
         process_file_header
      else

      begin
         displn('Invalid file Header');
         exit;
      end;
   end;

end;


(* ---------------------------------------------------------- *)
procedure select_pattern;
begin
   default_pattern := '*.*';

   while true do
   begin
      newline;
      disp(remove_path(infn));
      get_def(': View member filespec:', enter_eq+default_pattern+'? ');
      
      get_nextpar;
      pattern := par;
      stoupper(pattern);
      if length(pattern) = 0 then
         pattern := default_pattern;

      if (pattern = 'none') or (pattern = 'Q') or dump_user then
         exit;
   
      process_headers;
   
      default_pattern := 'none';
   end;
end;


(* ---------------------------------------------------------- *)
procedure view_file;
begin
   infd := dos_open(infn,open_read);
   if infd = dos_error then
      exit;

   if expand_files then
      select_pattern
   else
   begin
      pattern := '*.*';
      process_headers;
   end;

   dos_close(infd);
end;



(* ---------------------------------------------------------- *)
procedure process_file(name: filenames);
var
   mem:    longint;

begin
   linenum := 1;
   cmdline := '';
   expand_files := false;
   infn := name;
   view_file;

   newline;
   get_def('View text files in this .LZH file:','(Enter)=yes? ');

   (* process text viewing if desired *)
   get_nextpar;
   if par[1] <> 'N' then
   begin
      expand_files := true;
      view_file;
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
   gotoxy(60,24); reverseVideo; disp(' LzhTV ');

   SetScrollPoint(23);
   gotoxy(1,23);  lowVideo;
   linenum := 1;

   if paramcount = 0 then
   begin
      displn(version);
{     newline;
      displn('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
      newline;  }

      displn('Usage:  lzhtv [-Pport] [-Tminutes] [-Llines] [-Mlines] FILE[.lzh]');

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
            'T':  tlimit := n;
            'L':  user.pagelen := n;
            'M':  maxlines := n;
         end
      else

      begin
        if pos('.',par) = 0 then
            par := par + '.LZH';

        if dos_exists(par) then
            process_file(par)
        else
            displn('File not found: '+par);
      end;
   end;

   newline;
   displn(version);
   closecom;
end.

