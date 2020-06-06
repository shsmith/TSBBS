
(*
 * test program for D1 compiler
 *
 * this program tests each major control type
 *
 *)

 program test_d_logic;
 var
   N:        integer;
   Odd:      boolean;
   b:        byte;


 procedure Repeatest;
 begin
    writeln('Repeatest:');
    writeln(b);
    n := 1;
    repeat
       n := n + 2;
       b := b + 1;
    until n > 10;
    b := b - 10;
 end;

 procedure ForTest;
 begin
    writeln('ForTest:');
    for n := 1 to 4 do
       writeln(n*10);

    for b := 20 downto 5 do
       Repeatest;
 end;

procedure IfTest;
begin
   writeln('IfTest:');
   if (N mod 2 = 0) then
      odd := false
   else
      odd := true;

   if odd then
      writeln('odd')
   else
      writeln('even');
end;

procedure whiletest;
begin
   writeln('WhileTest:');
   n := 3;
   while N >= 1 do
   begin
      WriteLn(N);
      iftest;
      n := n - 1;
   end;
 end;



begin
   writeln('---begin tests---');
   WhileTest;
   ForTest;
   writeln('---end tests---');
end.
