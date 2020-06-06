
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

procedure translate_char(var c: char;
                         fromlist, tolist: string);
var
   i: integer;
begin
   for i := 1 to length(fromlist) do
      if c = fromlist[i] then
      begin
         c := tolist[i];
         exit;
      end;
end;
