
(*
 * magic - this is a D1 program that checks the 'magic'
 *         quality of a series of numbers
 *)

 program check_for_magic;
 var
   N:        integer;
   Odd:      boolean;
   terms:    byte;
   i:        integer;


 procedure NextTerm;
   procedure CheckOdd;
   begin
      if (N mod 2 = 0) then
         odd := false
      else
         odd := true
   end;

   procedure DownStep;
   begin
      N := N / 2
   end;

   procedure UpStep;
   begin
      N := 3 * N + 1
   end;


 begin                        { NextTerm }
   CheckOdd;

   if Odd then
      UpStep
   else
      DownStep
 end;



 procedure check_magic_N;
 begin                        { main program }
   writeln('Checking magic quality for:');
   writeln(N);
   terms := 0;

   while N > 1 do
   begin
      WriteLn(N);
      nextterm;
      terms := terms + 1;
   end;

   writeln('Magic terms:');
   writeln(terms);
   writeln(' ');
 end;


begin {main}

   writeln('Magic quality checker!');

   for i := 2 to 200 do
   begin
      n := i;
      check_magic_n;
   end;

   writeln('Goodbye!');

end.
