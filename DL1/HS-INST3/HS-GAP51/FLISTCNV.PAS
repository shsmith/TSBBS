

function trimit (ln: string): string;
var
   i: integer;
   
begin
   
   for i := 1 to length(ln) do
      if ln[i]= #0 then
         ln[i]:= ' ';
   
   while ln[length(ln)] = ' ' do
      dec(ln[0]);
   
   trimit := ln;
end;


type
   thefile = record
         fname:  array[1..12] of char;
         junk1:  char;
         dir:    array[1..25] of char;
         junk2:  array[1..4] of char;
   end;
   
var
   i:    integer;
   cnv:  thefile;
   fd1:  file of thefile;
   fd2:  text;
   
begin
   assign(fd1, 'filelst.dwn');
   reset(fd1);
   assign(fd2, 'filelist');
   rewrite(fd2);
   
   for i := 1 to filesize (fd1) do
   begin
      read(fd1, cnv);
      writeln('[',cnv.dir,'] [', cnv.fname,']');
      writeln(fd2, trimit (cnv.dir), '\', trimit (cnv.fname));
   end;
   
   close(fd2);
   close(fd1);

end.

