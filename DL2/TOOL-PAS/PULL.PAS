
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 *)

{$D+}    {Global debug information}
{$L+}    {Local debug information}
{$R-}

unit PULL;

interface
   uses DOS, CRT;

   {$i \tinc\getkey.int}
   {$i \tinc\popup.int}
   {$i \tinc\border.int}
   {$i \tinc\fmtreal.int}
   {$i \tinc\pull.int}
   {$i \tinc\top.int}
   {$i \tinc\toputil.int}

implementation
   {$i \tinc\getkey.inc}
   {$i \tinc\popup.inc}
   {$i \tinc\border.inc}
   {$i \tinc\fmtreal.inc}
   {$i \tinc\pull.inc}
   {$i \tinc\top.inc}
   {$i \tinc\toputil.inc}

end.

