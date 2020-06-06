
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
 *
 * converts ascii string to an float value
 *
 *)

function atof (asc:           anystring): real;
var
   code:          integer;
   value:         real;

begin
   while copy(asc,1,1) = ' ' do
      delete(asc,1,1);
   val(asc, value, code);
   atof := value;
end;

