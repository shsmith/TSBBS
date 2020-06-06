
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
 * Top level unit for the Tool Shop Tools Library
 *
 *)

{$i prodef.inc}
{$d+,l+}

unit Tools;

interface

   uses Dos, MDosIO;

   {$I \tinc\anystring.inc}  (* general string declaration *)
   {$I \tinc\givetime.int}   (* give up time under doubledos *)
   {$I \tinc\ftoa.int}       (* float to ascii conversion *)
   {$I \tinc\atof.int}       (* ascii to float conversion *)
   {$I \tinc\atoi.int}       (* ascii to integer conversion *)
   {$I \tinc\itoa1.int}      (* integer to ascii conversion *)
   {$I \tinc\stof.int}       (* basic single to floating conversion *)
   {$I \tinc\dtof.int}       (* basic double to floating conversion *)
   {$I \tinc\stoa.int}       (* single to ascii conversion *)
   {$I \tinc\itoh.int}       (* integer to hex conversion *)
   {$I \tinc\itou.int}       (* integer to unsigned-real conversion *)
   {$I \tinc\ltor.int}       (* long-integer to real conversion *)
   {$I \tinc\rempath.int}    (* remove/manipulate filename paths *)
   {$I \tinc\iswild.int}     (* is a filename a wildcard? *)
   {$I \tinc\stoupper.int}   (* map string to upper case *)
   {$I \tinc\stolower.int}   (* map string to lower case *)
   {$I \tinc\capstr.int}     (* make string into 'Caps Format' *)
   {$I \tinc\filesize.int}   (* get size of a file *)
   {$I \tinc\pattern.int}    (* wildcard filename pattern comparison *)
   {$I \tinc\sysdate2.int}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I \tinc\gettime.int}    (* get system time in seconds *)
   {$I \tinc\delay.int}      (* delay function based on give-up-time and gettime *)
   {$I \tinc\delspace.int}   (* delete all spaces from a string *)
   {$I \tinc\replstr.int}    (* perform string replacements *)
   {$I \tinc\getenv.int}     (* get environment variables *)
   {$I \tinc\varstr.int}     (* variable allocation string library *)
   {$I \tinc\getfile3.int}   (* expand wildcard file lists *)
   {$I \tinc\ljust.int}      (* left justify strings *)
   {$I \tinc\bitmap.int}     (* manipulate bit maps *)
   {$I \tinc\flags.int}      (* manipulate bit flags *)
   {$I \tinc\appendc.int}    (* append character to string *)
   {$I \tinc\diskspac.int}   (* get disk free space; allows >32meg *)
   {$I \tinc\qwrite.int}     (* quick screen write *)


implementation
   uses MiniCRT, OpenShare;

   {$I \tinc\givetime.inc}   (* give up time under doubledos *)
   {$I \tinc\ftoa.inc}       (* float to ascii conversion *)
   {$I \tinc\atof.inc}       (* ascii to float conversion *)
   {$I \tinc\atoi.inc}       (* ascii to integer conversion *)
   {$I \tinc\itoa1.inc}      (* integer to ascii conversion *)
   {$I \tinc\stof.inc}       (* basic single to floating conversion *)
   {$I \tinc\stoa.inc}       (* single to ascii conversion *)
   {$I \tinc\dtof.inc}       (* basic double to floating conversion *)
   {$I \tinc\itoh.inc}       (* integer to hex conversion *)
   {$I \tinc\itou.inc}       (* integer to unsigned-real conversion *)
   {$I \tinc\ltor.inc}       (* long-integer to real conversion *)
   {$I \tinc\rempath.inc}    (* remove/manipulate filename paths *)
   {$I \tinc\iswild.inc}     (* is a filename a wildcard? *)
   {$I \tinc\stoupper.inc}   (* map string to upper case *)
   {$I \tinc\stolower.inc}   (* map string to lower case *)
   {$I \tinc\capstr.inc}     (* make string into 'Caps Format' *)
   {$I \tinc\filesize.inc}   (* get size of a file *)
   {$I \tinc\pattern.inc}    (* wildcard filename pattern comparison *)
   {$I \tinc\getfile3.inc}   (* expand wildcard file lists *)
   {$I \tinc\sysdate2.inc}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I \tinc\gettime.inc}    (* get system time in seconds *)
   {$I \tinc\delay.inc}      (* delay function based on give-up-time and gettime *)
   {$I \tinc\delspace.inc}   (* delete all spaces from a string *)
   {$I \tinc\replstr.inc}    (* perform string replacements *)
   {$I \tinc\getenv.inc}     (* get environment variables *)
   {$I \tinc\varstr.inc}     (* variable allocation string library *)
   {$I \tinc\ljust.inc}      (* left justify strings *)
   {$I \tinc\bitmap.inc}     (* manipulate bit maps *)
   {$I \tinc\flags.inc}      (* manipulate bit flags *)
   {$I \tinc\appendc.inc}    (* append character to string *)
   {$I \tinc\diskspac.inc}   (* get disk free space; allows >32meg *)
   {$I \tinc\qwrite.inc}     (* quick screen write *)

begin
   fillchar(filetable,sizeof(filetable),0);
end.

