
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
 * PCB ProDOOR ProEnter - Message Entry and Edit module
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProEnter;

interface

   uses Tools, ProData;

   {$I proenter.int}
   {$i proedit.int}     (* edit existing message *)


implementation

   uses Dos, MdosIO, BufIO, ProRegL, ProRoot, ProJoin, ProVis, ProMail;

   {$i proenter.inc}    (* enter new messages *)
   {$i proedit.inc}     (* edit existing message *)

end.

