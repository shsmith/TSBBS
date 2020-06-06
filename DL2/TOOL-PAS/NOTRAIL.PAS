
var
   ibuf,obuf: array[1..20480] of char;
   line: string;
begin
   settextbuf(input,ibuf);
   settextbuf(output,obuf);
   while not eof do 
   begin
      readln(line);
      while line[length(line)] = ' ' do
         dec(line[0]);
      writeln(line);
   end;
end.
