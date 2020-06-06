
const
   maxline = 6;
var
   line: array[1..maxline] of string;
   i,j:  integer;
   n:    integer;

begin
   writeln;
   writeln('Enter ',maxline,' lines of text to be printed:');
   writeln;

   for i := 1 to maxline do
   begin
      write(i,': ');
      readln(line[i]);
   end;

   writeln;
   write('Print how many lables: ');
   readln(n);
   writeln;
   writeln('Printing...');

   assign(output,'prn');
   rewrite(output);
   for i := 1 to n do
      for j := 1 to maxline do
         writeln(line[j]);
end.

