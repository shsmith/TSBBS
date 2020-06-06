
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
 * i_to_ur - converts an unsigned integer into an unsigned real
 *
 *)
function i_to_ur(i: integer): real;  {integer to unsigned-real conversion}
var
   u: word absolute i;
begin
   i_to_ur := u;
end;


(*
 * ur_to_i - converts an unsigned real into an integer
 *
 *)
function ur_to_i(v: real): integer;  {unsigned-real to integer conversion}
var
   i: integer;
   u: word absolute i;
begin
   u := trunc(v) and $FFFF;
   ur_to_i := i;
end;


