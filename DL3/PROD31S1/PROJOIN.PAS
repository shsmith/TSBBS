
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
 * PCB ProDOOR ProJoin unit - join, abandon, config, status, ZIPM
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProJoin;

interface

   uses Tools;

   {$I proaband.int}    (* abandon conference *)
   {$I prostat.int}     (* conference status *)
   {$I procreg.int}     (* conference registration *)
   {$I projoin.int}     (* join conference *)
   {$I proarcm.int}     (* archive messages *)
   {$I procap.int}      (* capture mail interface *)


implementation

   uses DosMem, MdosIO, BufIO, ProData, ProRoot, ProMail;

   {$I proaband.inc}    (* abandon conference *)
   {$I prostat.inc}     (* conference status *)
   {$I procreg.inc}     (* conference registration *)
   {$I projoin.inc}     (* join conference *)
   {$I proarcm.inc}     (* archive messages *)
   {$I procap.inc}      (* capture mail *)

end.


