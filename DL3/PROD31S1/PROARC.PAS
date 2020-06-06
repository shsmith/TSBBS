
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

{$i prodef.inc}
{$i proovr.inc}

unit ProArc;

interface

   Uses
     Tools,
     MDosIO,
     ProData,
     ProRoot,
     ProTran;

   {$I prolib.int}      (* library disk request *)
   {$I protest.int}     (* test archive *)
   {$I proarc.int}      (* re-archive scratchfile *)

implementation

   {$I prolib.inc}      (* library disk request *)
   {$I protest.inc}     (* test archive *)
   {$I proarc.inc}      (* re-archive scratchfile *)

end.

