
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
 * reverse_string - return a string with all characters reversed
 *
 *)

function reverse_string(str: anystring): anystring;
var
   i: integer;
   r: anystring;
begin
   r := '';
   for i := length(str) downto 1 do
      r := r + str[i];

   reverse_string := r;
end;

