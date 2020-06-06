
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

{$i q:\tinc\prodef.inc}
{$d+,l+}
{$r-}

unit Tools;

interface

   uses Dos, MDosIO, debugs;

   {$I Q:\tinc\anystring.inc}  (* general string declaration *)
   {$I Q:\tinc\givetime.int}   (* give up time under doubledos *)
   {$I Q:\tinc\ftoa.int}       (* float to ascii conversion *)
   {$I Q:\tinc\atof.int}       (* ascii to float conversion *)
   {$I Q:\tinc\atoi.int}       (* ascii to integer conversion *)
   {$I Q:\tinc\itoa1.int}      (* integer to ascii conversion *)
   {$I Q:\tinc\stof.int}       (* basic single to floating conversion *)
   {$I Q:\tinc\dtof.int}       (* basic double to floating conversion *)
   {$I Q:\tinc\stoa.int}       (* single to ascii conversion *)
   {$I Q:\tinc\itoh.int}       (* integer to hex conversion *)
   {$I Q:\tinc\itou.int}       (* integer to unsigned-real conversion *)
   {$I Q:\tinc\ltor.int}       (* long-integer to real conversion *)
   {$I Q:\tinc\rempath.int}    (* remove/manipulate filename paths *)
   {$I Q:\tinc\iswild.int}     (* is a filename a wildcard? *)
   {$I Q:\tinc\stoupper.int}   (* map string to upper case *)
   {$I Q:\tinc\stolower.int}   (* map string to lower case *)
   {$I Q:\tinc\capstr.int}     (* make string into 'Caps Format' *)
   {$I Q:\tinc\filesize.int}   (* get size of a file *)
   {$I Q:\tinc\pattern.int}    (* wildcard filename pattern comparison *)
   {$I Q:\tinc\sysdate2.int}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I Q:\tinc\gettime.int}    (* get system time in seconds *)
   {$I Q:\tinc\delay.int}      (* delay function based on give-up-time and gettime *)
   {$I Q:\tinc\delspace.int}   (* delete all spaces from a string *)
   {$I Q:\tinc\replstr.int}    (* perform string replacements *)
   {$I Q:\tinc\getenv.int}     (* get environment variables *)
   {$I Q:\tinc\varstr.int}     (* variable allocation string library *)
   {$I Q:\tinc\getfile3.int}   (* expand wildcard file lists *)
   {$I Q:\tinc\ljust.int}      (* left justify strings *)
   {$I Q:\tinc\bitmap.int}     (* manipulate bit maps *)
   {$I Q:\tinc\flags.int}      (* manipulate bit flags *)
   {$I Q:\tinc\appendc.int}    (* append character to string *)
   {$I Q:\tinc\diskspac.int}   (* get disk free space; allows >32meg *)
   {$I Q:\tinc\qwrite.int}     (* quick screen write *)
   {$I Q:\tinc\bakfile.int}    (* rename file to .BAK *)
   {$I Q:\tinc\bline.int}      (* fast string compares *)
   {$I Q:\tinc\cpos.int}       (* character position in string *)
   {$I Q:\tinc\jday.int}       (* convert m/d/y to julian date *)


implementation
   uses OpenShare;

   {$I Q:\tinc\givetime.inc}   (* give up time under doubledos *)
   {$I Q:\tinc\ftoa.inc}       (* float to ascii conversion *)
   {$I Q:\tinc\atof.inc}       (* ascii to float conversion *)
   {$I Q:\tinc\atoi.inc}       (* ascii to integer conversion *)
   {$I Q:\tinc\itoa1.inc}      (* integer to ascii conversion *)
   {$I Q:\tinc\stof.inc}       (* basic single to floating conversion *)
   {$I Q:\tinc\stoa.inc}       (* single to ascii conversion *)
   {$I Q:\tinc\dtof.inc}       (* basic double to floating conversion *)
   {$I Q:\tinc\itoh.inc}       (* integer to hex conversion *)
   {$I Q:\tinc\itou.inc}       (* integer to unsigned-real conversion *)
   {$I Q:\tinc\ltor.inc}       (* long-integer to real conversion *)
   {$I Q:\tinc\rempath.inc}    (* remove/manipulate filename paths *)
   {$I Q:\tinc\iswild.inc}     (* is a filename a wildcard? *)
   {$I Q:\tinc\stoupper.inc}   (* map string to upper case *)
   {$I Q:\tinc\stolower.inc}   (* map string to lower case *)
   {$I Q:\tinc\capstr.inc}     (* make string into 'Caps Format' *)
   {$I Q:\tinc\filesize.inc}   (* get size of a file *)
   {$I Q:\tinc\pattern.inc}    (* wildcard filename pattern comparison *)
   {$I Q:\tinc\getfile3.inc}   (* expand wildcard file lists *)
   {$I Q:\tinc\sysdate2.inc}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I Q:\tinc\gettime.inc}    (* get system time in seconds *)
   {$I Q:\tinc\delay.inc}      (* delay function based on give-up-time and gettime *)
   {$I Q:\tinc\delspace.inc}   (* delete all spaces from a string *)
   {$I Q:\tinc\replstr.inc}    (* perform string replacements *)
   {$I Q:\tinc\getenv.inc}     (* get environment variables *)
   {$I Q:\tinc\varstr.inc}     (* variable allocation string library *)
   {$I Q:\tinc\ljust.inc}      (* left justify strings *)
   {$I Q:\tinc\bitmap.inc}     (* manipulate bit maps *)
   {$I Q:\tinc\flags.inc}      (* manipulate bit flags *)
   {$I Q:\tinc\appendc.inc}    (* append character to string *)
   {$I Q:\tinc\diskspac.inc}   (* get disk free space; allows >32meg *)
   {$I Q:\tinc\qwrite.inc}     (* quick screen write *)
   {$I Q:\tinc\bakfile.inc}    (* rename file to .BAK *)
   {$I Q:\tinc\bline.inc}      (* fast string compares *)
   {$I Q:\tinc\cpos.inc}       (* character position in string *)
   {$I Q:\tinc\jday.inc}       (* convert m/d/y to julian date *)

begin
   fillchar(filetable,sizeof(filetable),0);
end.

