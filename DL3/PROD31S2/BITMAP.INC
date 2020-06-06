
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
 * bitmap.inc - Library to BitMap manipulation functions
 *
 *)

(* --------------------------------------------------------- *)
function getbit(map: bitmap; bitnum: bitnumber): boolean;
   {return true/false for specified bit 0..39 in a bitmap}
var
   byteno:  integer;
   bitno:   integer;
begin
   byteno := bitnum shr 3;    {0..4}
   bitno  := bitnum mod 8;    {0..7}
   getbit := odd(map.bits[byteno] shr bitno);
end;

(* --------------------------------------------------------- *)
procedure setbit(var map: bitmap; bitnum: bitnumber; value: boolean);
   {set the specified bit in a bitmap}
var
   byteno:  integer;
   bitno:   integer;
begin
   byteno := bitnum shr 3;    {0..4}
   bitno  := bitnum mod 8;    {0..7}
   if value then
      map.bits[byteno] := map.bits[byteno] or (1 shl bitno)
   else
      map.bits[byteno] := map.bits[byteno] and (255 - (1 shl bitno));
end;

