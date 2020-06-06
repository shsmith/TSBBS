
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

(*--------------------------------------------------------
 *   map string to lower case (tpas 4.0)  3-1-89
 *
 *)

{$F+} procedure stolower(var st: string); {$F-}
begin

   Inline(
     $C4/$7E/$06/           {   les di,[bp]6         ;es:di -> st[0]}
     $26/                   {   es:}
     $8A/$0D/               {   mov cl,[di]          ;cl = length}
     $FE/$C1/               {   inc cl}

                            {next:}
     $47/                   {   inc di}
     $FE/$C9/               {   dec cl}
     $74/$12/               {   jz ends}

     $26/                   {   es:}
     $8A/$05/               {   mov al,[di]}
     $3C/$41/               {   cmp al,'A'}
     $72/$F4/               {   jb next}
     $3C/$5A/               {   cmp al,'Z'}
     $77/$F0/               {   ja next}

     $04/$20/               {   add al,' '}
     $26/                   {   es:}
     $88/$05/               {   mov [di],al}
     $EB/$E9);              {   jmp next}

                            {ends:}
end;

