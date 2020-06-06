
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

function tolower(s: anystring): anystring;
var
   i: integer;

begin

   for i := 1 to length(s) do
      if (s[i] >= 'A') and (s[i] <= 'Z') then
         s[i] := chr( ord(s[i]) + 32 );

   tolower := s;
end;
