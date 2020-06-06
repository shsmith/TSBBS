
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
 * ltor - long integer to real conversion, s.h.smith, 24-jul-87 (12-01-88)
 *
 *)

function ltor(long: long_int): real;
var
   l: longint absolute long;
begin
   ltor := l;
end;


procedure rtol(r: real;
               var long: long_int);
var
   l: longint absolute long;
begin
   l := trunc(r);
end;


