
program mathtest;

var
   v:    integer(2);
   b:    integer(1);
   i:    integer(2);
   msg:  char(10);

begin
   writeln('for ... to test');
   for i := 1 to 10 do
      writeln(i);

   writeln('for .. downto test');
   for b := 99 downto 90 do
      writeln(b);

   writeln('repeat ... until v=99 test');
   repeat
      readln(v);
      writeln('math test: v*2, -5, /5, +5');
      writeln(v*2);
      writeln(v-5);
      writeln(v/5);
      writeln(v+5);
   until (v = 99);

   writeln('end tests');
   v := 12345;
   writeln(v);

end.
