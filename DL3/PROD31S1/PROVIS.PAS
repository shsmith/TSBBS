
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
 * PCB ProDOOR ProVis - Visual Edit module
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProVis;

interface

   uses Tools, ProData;

   {$i provis.int}      (* visual edit mode *)

implementation

   uses Dos, MiniCRT, MdosIO, BufIO, ProRegL, ProRoot,
        ProJoin, ProEnter, ProMail;

   {$i provis.inc}      (* visual edit mode *)

end.

