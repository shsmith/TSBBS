
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

procedure delete_spaces(var line: string);
var
   p: integer;
begin
   p := cpos(' ',line);
   while p > 0 do
   begin
      delete(line,p,1);
      p := cpos(' ',line);
   end;
end;

procedure delete_trailing_spaces(var line: string);
begin
   while (length(line) > 0) and (line[length(line)] <= ' ') do
      dec(line[0]);
end;

procedure delete_leading_spaces(var line: string);
begin
   while (length(line) > 0) and (line[1] <= ' ') do
      delete(line,1,1);
end;
