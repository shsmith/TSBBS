
(*
 * sample - this is a simple test program for the D1 Compiler
 *
 *)

 program D1_sample;
 var
   N:        integer;
   Odd:      boolean;


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



 begin                        { main program }
   ReadLn(N);

   while N > 1 do
   begin
      WriteLn(N);
      nextterm;
   end;
 end.
