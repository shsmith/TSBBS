
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

var
   reg: registers;

procedure printc(s: anystring);  {print character, 3x faster than dos}
var
   i: integer;
begin
   for i := 1 to ORD(s[0]) do
   begin
      reg.ax := ord (s[i]);
      reg.dx := 0;
      intr(23, reg);
   end;
end;


