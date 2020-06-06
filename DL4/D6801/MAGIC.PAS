
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
   seen:     array[1..maxint] of boolean;
   maxterm:  integer;
   maxn:     integer;
   magics:   integer;


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
      N := N div 2;
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
   if seen[n] then
      exit;

   terms := 0;

   repeat
      seen[n] := true;
      magics := magics + 1;
      nextterm;
      terms := terms + 1;
   until (n <= 1) or seen[n];

{   write(#13,i:0);   }
 end;


begin {main}

   clrscr;
   writeln('Magic quality checker!');

   for i := 1 to maxint do
      seen[i] := false;

   magics  := 0;
   maxterm := 0;
   maxn    := 0;

   for i := 1 to maxint do
   begin
      n := i;
      check_magic_n;
      if terms > maxterm then
      begin
         maxterm := terms;
         maxn    := n;
         writeln(#13,i:0,' has ',terms:0,' terms:  A new record!!!!!!!!!!');
      end;
   end;

   writeln;
   writeln('There are ',magics:0,' magic numbers from 1..',maxint:0);
   writeln('Goodbye!');

end.
