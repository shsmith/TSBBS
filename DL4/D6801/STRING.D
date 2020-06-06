
program string_test;

var
   c:        char(40);

 procedure CharTest;
 begin
    writeln('CharTest:');
    c := 'c';
    c := 'hello, world';
    writeln(c);
 end;


begin

   writeln('hello, world!');
   chartest;

end.
