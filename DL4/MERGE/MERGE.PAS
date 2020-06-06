
(*
 * merge - merge two sorted lists
 *
 * S.H.Smith, 26-may-87
 *
 *)

var
   fd1,
   fd2,
   ofd:      text[10240];

   line1,
   line2:    string[255];

   key1,
   key2:     string[255];

   col:      integer;
   i:        integer;

begin
   if paramcount <> 4 then
   begin
      writeln('usage:  merge KEYCOL INFILE1 INFILE2 OUTFILE');
      halt;
   end;

   val(paramstr(1),col,i);
   if i <> 0 then
      writeln('Invalid key column number');

   assign(fd1,paramstr(2));
   reset(fd1);
   assign(fd2,paramstr(3));
   reset(fd2);
   assign(ofd,paramstr(4));
   rewrite(ofd);

   readln(fd1,line1);
   key1 := copy(line1,col,255);
   readln(fd2,line2);
   key2 := copy(line2,col,255);

   while (not eof(fd1)) and (not eof(fd2)) do
      if key1 >= key2 then
      begin
         writeln(ofd,line2);
         readln(fd2,line2);
         key2 := copy(line2,col,255);
      end
      else
      begin
         writeln(ofd,line1);
         readln(fd1,line1);
         key1 := copy(line1,col,255);
      end;

   while not eof(fd1) do
      begin
         writeln(ofd,line1);
         readln(fd1,line1);
         key1 := copy(line1,col,255);
      end;

   while not eof(fd2) do
      begin
         writeln(ofd,line2);
         readln(fd2,line2);
         key2 := copy(line2,col,255);
      end;

   close(fd1);
   close(fd2);
   close(ofd);
end.
