
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
 * byteflag.inc - Library to manipulate flag bits in a byte
 *
 *)

(* --------------------------------------------------------- *)
function getbbit(bits: byte; bitval: byte): boolean;
   {return true/false for specified is set}
begin
   getbbit := (bits and bitval) <> 0;
end;

(* --------------------------------------------------------- *)
procedure setbbit(var bits: byte; bitval: byte; value: boolean);
   {set the specified bit in a bitmap}
begin
   if value then
      bits := bits or bitval
   else
      bits := bits and (255 - bitval);
end;


