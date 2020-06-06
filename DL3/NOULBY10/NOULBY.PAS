
(*
 * NoUlBy - Remove "Uploaded by:" entries from a DIR file
 *
 * Written by Samuel H. Smith, 04-08-89
 *
 *)

{$v-}
uses DOS;

const
   version   = 'NoUlBy 1.0, 04-08-90';
   ulby_prefix = '                               | Uploaded by: ';

var
   infile:  string[65];
   tmpfile: string[65];
   bakfile: string[65];

   ibuf:    array[1..20480] of byte;
   obuf:    array[1..20480] of byte;

(* --------------------------------------------------------- *)
procedure update_dirfile;
var
   ifd:     text;
   ofd:     text;
   line:    string;
   tmp:     string;
   d,n,e:   string[65];

begin
   infile := paramstr(1);
   fsplit(infile,d,n,e);
   tmpfile := d+n+'.tmp';
   bakfile := d+n+'.bak';

   assign(ifd,infile);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open DIR file ',infile);
      halt(99);
   end;

   assign(ofd,tmpfile);
   {$i-} rewrite(ofd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t create tempfile ',tmpfile);
      halt(99);
   end;

   setTextBuf(ifd,ibuf);
   setTextBuf(ofd,obuf);

   repeat
      readln(ifd,line);
      if copy(line,1,length(ulby_prefix)) <> ulby_prefix then
         writeln(ofd,line);
   until eof(ifd);

   close(ifd);
   close(ofd);

   assign(ifd,bakfile);
   {$i-} erase(ifd); {$i+}
   if ioresult <> 0 then ;

   assign(ifd,infile);
   {$i-} rename(ifd,bakfile); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t rename ',infile,' to ',bakfile);
      halt(99);
   end;

   assign(ifd,tmpfile);
   {$i-} rename(ifd,infile); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t rename ',tmpfile,' to ',infile);
      halt(99);
   end;

end;


(* --------------------------------------------------------- *)
begin
   if paramcount <> 1 then
   begin
      writeln;
      writeln(version,';  Copyright 1990 Samuel H. Smith');
      writeln;
      writeln('Usage:    NoUlBy DIRFILENAME');
      writeln('Example:  NoUlBy C:\PCB\MAIN\UPLOAD');
      halt(99);
   end;

   update_dirfile;
end.

