
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

(*
 * return the string equivelant of an integer value
 * with leading zeroes for a minimum width of 2
 *
 *)

function itoa (int:           integer): anystring;
var
   tstr:          anystring;

begin
   str(int, tstr);

   if length (tstr)= 1 then
      itoa := '0' + tstr
   else
      itoa := tstr;
end;


