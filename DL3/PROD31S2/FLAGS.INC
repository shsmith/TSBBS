
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
 * flags.inc - Library to manipulate flag bits in a byte
 *
 *)

(* --------------------------------------------------------- *)
function getflag(flag: byte; bitval: byte): boolean;
   {return true/false for specified is set}
begin
   getflag := (flag and bitval) <> 0;
end;

(* --------------------------------------------------------- *)
procedure setflag(var flag: byte; bitval: byte; value: boolean);
   {set the specified bit in a flagbyte}
begin
   if value then
      flag := flag or bitval
   else
      flag := flag and (255 - bitval);
end;

(* --------------------------------------------------------- *)
function toggleflag(var flag: byte; bitval: byte): boolean;
   {toggle the specified bit and return new setting}
var
   value:  boolean;
begin
   value := not getflag(flag,bitval);
   setflag(flag,bitval,value);
   toggleflag := value;
end;

