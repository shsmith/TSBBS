
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
 * QRead - Quick ReadLn Unit for Strings
 *
 * Written by Samuel Smith, 19-Nov-88
 *
 *)

{$S-,R-}
{$D+,L+}

unit QRead;

interface

   procedure qReadLn( var fd: text;       {text file to read from}
                      var dest: string;   {destination string}
                      maxlen: word );     {sizeof dest string}


implementation

   {$L qread.obj}
   procedure qReadLn( var fd: text;       {text file to read from}
                      var dest: string;   {destination string}
                      maxlen: word );     {sizeof dest string}
   external;

end.

