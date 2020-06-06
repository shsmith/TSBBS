
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

procedure replace_string( var line: longstring; oldstr, newstr: string65);
   (* perform string replacement if possible *)
var
   k: integer;
   max: integer;
begin
   max := 10;
   k := pos(oldstr,line);
   while (k <> 0) and (max > 0) do
   begin
      line := copy(line,1,k-1) + newstr + copy(line,k+length(oldstr),255);
      k := pos(oldstr,line);
      dec(max);
   end;
end;

