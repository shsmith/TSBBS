
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
 * PCB ProDOOR ProMail unit - message base handler (3-1-89)
 *
 *)

{$i prodef.inc}
{$i proovr.inc}
{$d+,l+}
unit ProMail;

interface

   uses Tools, BufIO, ProData;

   {$I promail.int}


implementation

   uses Dos, DosMem, MdosIO, ProRoot;

   {$i promail.inc}     (* read messages *)

begin
   search_key := '';
   block := nil;
   lines := nil;
end.

