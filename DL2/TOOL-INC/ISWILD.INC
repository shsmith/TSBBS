
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

function is_wild(filename: anystring): boolean;
var
   i: integer;
begin

   for i := 1 to length(filename) do
      case filename[i] of
         '?','*':
            begin
               is_wild := true;
               exit;
            end;
      end;

   is_wild := false;
end;

