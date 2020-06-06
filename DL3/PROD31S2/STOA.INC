
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

function stoa(s: single): string10;
begin
   stoa := ftoa( stof(s), 0,0 );
end;

function dtoa(d: double): string10;
begin
   dtoa := ftoa( dtof(d), 0,0 );
end;


