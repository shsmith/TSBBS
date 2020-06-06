
var
   fd:   file of byte;
   b:    byte;
   buf:  array[1..maxint] of char;

begin
   assign(fd,paramstr(1));
   reset(fd);
   settextbuf(output,buf);

   while not eof(fd) do
   begin
      read(fd,b);
      writeln(b);
   end;
   close(fd);

   flush(output);
end.

