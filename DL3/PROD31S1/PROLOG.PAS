
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

unit ProLog;

interface

Uses
   Dos,
   DosMem,
   MdosIO,
   Tools,
   OpenShare,
   ProData,
   ProRoot,
   ProTran,
   ProSysf,
   ProBye;

   {$I prologio.int}    {log file updates}
   {$i prologft.int}
   {$i proauto.int}

implementation

   {$I prologio.inc}    {log file updates}
   {$I prologft.inc}    {log file transfers}
   {$I proauto.inc}     {automatic logoff handler}

end.

