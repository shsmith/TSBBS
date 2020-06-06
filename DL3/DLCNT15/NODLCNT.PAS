
(*
 * NODLCNT - Remove "Download Count:" entries from a DIR file
 *
 * Written by Samuel H. Smith, 10-14-93
 *
 *)

{$v-}
uses DOS, Qread;

const
   version   = 'NODLCNT 1.0, 10-14-93';
   dlcnt_prefix = '                               | Download Count: ';

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
      qreadln(ifd,line,sizeof(line));
      if copy(line,1,length(dlcnt_prefix)) <> dlcnt_prefix then
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
      writeln(version,';  Copyright 1993 Samuel H. Smith');
      writeln;
      writeln('Usage:    NODLCNT DIRFILENAME');
      writeln('Example:  NODLCNT C:\PCB\MAIN\UPLOAD');
      halt(99);
   end;

   update_dirfile;
end.

