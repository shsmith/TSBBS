
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
 * centers a string around a given width
 *
 *)

procedure center (var str:       anystring;
                  width:         integer);
var
   front:         integer;
   back:          integer;

begin

   if length (str)> width then
      str[0]:= chr (width);

   back := width - length (str);
   front := back div 2;
   back := back - front;

   while front > 0 do
   begin
      str := ' ' + str;
      front := front - 1;
   end;

   while back > 0 do
   begin
      str := str + ' ';
      back := back - 1;
   end;
end;

