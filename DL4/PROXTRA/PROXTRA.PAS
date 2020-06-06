
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ProExtract - Extract files from one ARC archive to another
 *
 * Copyright 1988 Samuel H. Smith
 *
 *)

{$v-}
{$m 8000,0,0}
{$D+,L+}
{$r-,s-}

uses DosMem, MdosIO, Tools;

const
   whoami =            'ProExtract v2.9 03-01-89 (C) 1989 S.H.Smith';

   arcmarc =           26;    { special archive marker }
   arcver =            10;    { max archive header version code }
   fnlen =             12;    { file name length - 1 }

type
   fntype =            array [0.. fnlen] of char;

   heads =             record
         name:               fntype;
         size:               longint;
         date:               word;
         time:               word;
         crc:                word;
         length:             longint;
   end;

var
   arcname:       filenames;
   scratcharc:    filenames;
   pattern:       filenames;

   arcfile:       dos_handle;
   arc_eof:       boolean;

   hdrver:        integer;
   hdr:           heads;
   extname:       string20;
   extcount:      integer;


   (* ------------------------------------------------------------- *)
   procedure bread(var buf; size: word);
   var
      c: char absolute buf;
   begin
      arc_eof := (dos_read(arcfile,c,size) <> size);
   end;


   (* ------------------------------------------------------------- *)
   procedure get_arc(var c: integer);
   var
      ch: char;
   begin
      if arc_eof then
         ch := ^Z
      else
         arc_eof := (dos_read(arcfile,ch,sizeof(ch)) <> sizeof(ch));
      c := ord(ch);
   end;


   (* ------------------------------------------------------------- *)
   function read_header: boolean;
                              { read a file header from the archive file }
                              { false = eof found; true = header found }
   var
      name:    fntype;
      try:     integer;
      c:       integer;

   begin
      if arc_eof then
         exit;
      read_header := false;

      try := 300;
      get_arc(c);
      while (c <> arcmarc) and (try > 0) do
      begin
         get_arc(c);
         dec(try);
      end;

      get_arc(hdrver);
      if (try = 0) or (hdrver < 0) then
      begin
         {$i-} writeln('This is not a valid archive!'); {$i+}
         exit;
      end;

      if hdrver = 0 then         { special end of file marker }
         exit;

      if hdrver > arcver then
      begin
         bread(name,fnlen);
         {$i-} writeln('I don''t know how to handle this archive format!'); {$i+}
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
   procedure xtract_member;
      (* extract the current member into a scratch file *)

   const
      bufmax = $1000;  {maximum buffer size in bytes}
   var
      ifd:     dos_handle;
      ofd:     dos_handle;
      buf:     ^byte;
      n,w:     word;
      ver:     byte;
      fsize:   longint;

   begin

      {$i-} writeln(extname:12,' extracted from ',
         remove_path(arcname),' to ',remove_path(scratcharc),'.'); {$i+}

      (* create SCRATCH archive if needed, otherwise position for append *)
      if dos_exists(scratcharc) then
      begin
         ofd := dos_open(scratcharc,open_update);
         dos_lseek(ofd,-2,seek_end);               {rewrite eof header}
      end
      else
      begin
         {$i-} writeln('Created: ',remove_path(scratcharc)); {$i+}
         ofd := dos_create(scratcharc);           {else create file if needed}
      end;

      if ofd = dos_error then
      begin
         dos_close(ifd);
         exit;
      end;

      inc(extcount);

      (* write the header for this new member *)
      ver := arcmarc;
      dos_write(ofd,ver,1);

      ver := hdrver;
      dos_write(ofd,ver,1);
      dos_write(ofd,hdr,sizeof(hdr));


      (* copy the member file to the scratchfile *)
      fsize := hdr.size;
      dos_getmem(buf,bufmax);

      repeat
         if fsize > bufmax then
            n := bufmax
         else
            n := fsize;
         fsize := fsize - n;

         n := dos_read(arcfile,buf^,n);

         dos_write(ofd,buf^,n);
         w := dos_regs.ax;
      until w < bufmax;


      (* write an eof marker (header with method=0) *)
      ver := arcmarc;
      dos_write(ofd,ver,1);

      ver := 0;
      dos_write(ofd,ver,1);
      dos_close(ofd);

      if n <> w then
         dos_unlink(scratcharc);

      dos_freemem(buf);
   end;


   (* ------------------------------------------------------------- *)
      { extract and view text files in the archive - main entry }
   procedure process_pattern;
   begin
      arcfile := dos_open(arcname,open_read);
      arc_eof := arcfile = dos_error;
      if arc_eof then
         exit;

      while read_header do
      begin

      (* skip the file if it does not match the selection wildcard *)
         format_name (hdr.name, extname);
         if wildcard_match(pattern,extname) then
            xtract_member
         else
            dos_lseek(arcfile,hdr.size,seek_cur);
      end;

      dos_close(arcfile);
   end;


(* ------------------------------------------------------------- *)
var
   i: integer;
begin

{$i-}
   writeln;
   writeln(whoami);

   if paramcount < 3 then
   begin
      writeln;
      writeln('Usage: proxtra INFILE.arc OUTFILE.arc MEMBER ... MEMBER');
      halt;
   end;

   arcname := paramstr(1);
   stoupper(arcname);
   scratcharc := paramstr(2);
   stoupper(scratcharc);
   extcount := 0;

   if arcname = scratcharc then
   begin
      writeln('Input and output archives must be different!');
      halt;
   end;

   for i := 3 to paramcount do
   begin
      pattern := paramstr(i);
      stoupper(pattern);
      process_pattern;
   end;

   writeln(extcount,' file(s) extracted.');
end.

