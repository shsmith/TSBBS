
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

(*------------------------------------------
 *
 * strip_leading_spaces
 *    remove all leading spaces from a string
 *
 *)

procedure strip_leading_spaces(var str: anystring);
var                           
   p: integer;

begin
   p := 1;
   while (str[p] = ' ') and (p < ord(str[0])) do
      p := succ(p);

   if p > 1 then
      delete(str,1,p-1);
end;


(*------------------------------------------
 *
 * strip_trailing_spaces
 *    remove all text after the first space in a string
 *
 *)

procedure strip_trailing_spaces(var str: anystring);
var
   posit:  integer;
begin
   posit := cpos(' ',str);
   if posit > 0 then
      str[0] := chr(posit-1);     {remove trailing spaces and comments}
end;

