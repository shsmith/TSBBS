
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
 *
 *)

function itoa (int: integer): string8;
var
   tstr: string8;
begin
   str(int, tstr);
   itoa := tstr;
end;

function ltoa (int: longint): string8;
var
   tstr: string8;
begin
   str(int, tstr);
   ltoa := tstr;
end;

function wtoa (w: word): string8;
var
   tstr: string8;
begin
   str(w, tstr);
   wtoa := tstr;
end;

