
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
 * ljust - macro for left justified strings in writeln format
 *
 *)

function ljust(s: string80; w: integer): string80;
begin
   if w > sizeof(s)-1 then
      w := sizeof(s)-1;
   repeat
      s := s + ' ';
   until length(s) >= w;

   ljust := copy(s,1,w);
end;

function rjust(s: string80; w: integer): string80;
begin
   if w > sizeof(s)-1 then
      w := sizeof(s)-1;
   while length(s) < w do
      s := ' ' + s;
   rjust := s;
end;

