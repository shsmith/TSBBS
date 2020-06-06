
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
 * function key and other keyboard entry definition
 * shs (rev. 12-nov-87)
 *
 *)


function getkey: char;
var
   key: char;

begin
   key := crt.readkey;

   if (key = #0) then
   begin
      key := crt.readkey;
      key := chr( lo( ord( key )+ 142 ));
                              {convert function keys to 201..210}
   end;

   getkey := key;
end;

