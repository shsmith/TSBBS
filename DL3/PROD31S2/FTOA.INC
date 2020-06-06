
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
 * convert floating to ascii
 *
 *)

function ftoa(f: real; width,dec: integer): string20;
var
   buf: string20;
begin
   str(f:width:dec,buf);
   ftoa := buf;
end;


