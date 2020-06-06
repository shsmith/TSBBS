
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
{$r-}

unit Tools;

interface

   uses Dos, MDosIO, debugs;

   {$I R:\tinc\anystring.inc}  (* general string declaration *)
   {$I R:\tinc\givetime.int}   (* give up time under doubledos *)
   {$I R:\tinc\ftoa.int}       (* float to ascii conversion *)
   {$I R:\tinc\atof.int}       (* ascii to float conversion *)
   {$I R:\tinc\atoi.int}       (* ascii to integer conversion *)
   {$I R:\tinc\itoa1.int}      (* integer to ascii conversion *)
   {$I R:\tinc\stof.int}       (* basic single to floating conversion *)
   {$I R:\tinc\dtof.int}       (* basic double to floating conversion *)
   {$I R:\tinc\stoa.int}       (* single to ascii conversion *)
   {$I R:\tinc\itoh.int}       (* integer to hex conversion *)
   {$I R:\tinc\itou.int}       (* integer to unsigned-real conversion *)
   {$I R:\tinc\ltor.int}       (* long-integer to real conversion *)
   {$I R:\tinc\rempath.int}    (* remove/manipulate filename paths *)
   {$I R:\tinc\iswild.int}     (* is a filename a wildcard? *)
   {$I R:\tinc\stoupper.int}   (* map string to upper case *)
   {$I R:\tinc\stolower.int}   (* map string to lower case *)
   {$I R:\tinc\capstr.int}     (* make string into 'Caps Format' *)
   {$I R:\tinc\filesize.int}   (* get size of a file *)
   {$I R:\tinc\pattern.int}    (* wildcard filename pattern comparison *)
   {$I R:\tinc\sysdate2.int}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I R:\tinc\gettime.int}    (* get system time in seconds *)
   {$I R:\tinc\delay.int}      (* delay function based on give-up-time and gettime *)
   {$I R:\tinc\delspace.int}   (* delete all spaces from a string *)
   {$I R:\tinc\replstr.int}    (* perform string replacements *)
   {$I R:\tinc\getenv.int}     (* get environment variables *)
   {$I R:\tinc\varstr.int}     (* variable allocation string library *)
   {$I R:\tinc\getfile3.int}   (* expand wildcard file lists *)
   {$I R:\tinc\ljust.int}      (* left justify strings *)
   {$I R:\tinc\bitmap.int}     (* manipulate bit maps *)
   {$I R:\tinc\flags.int}      (* manipulate bit flags *)
   {$I R:\tinc\appendc.int}    (* append character to string *)
   {$I R:\tinc\diskspac.int}   (* get disk free space; allows >32meg *)
   {$I R:\tinc\qwrite.int}     (* quick screen write *)
   {$I R:\tinc\bakfile.int}    (* rename file to .BAK *)
   {$I R:\tinc\bline.int}      (* fast string compares *)
   {$I R:\tinc\cpos.int}       (* character position in string *)
   {$I R:\tinc\jday.int}       (* convert m/d/y to julian date *)


implementation
   uses OpenShare;

   {$I R:\tinc\givetime.inc}   (* give up time under doubledos *)
   {$I R:\tinc\ftoa.inc}       (* float to ascii conversion *)
   {$I R:\tinc\atof.inc}       (* ascii to float conversion *)
   {$I R:\tinc\atoi.inc}       (* ascii to integer conversion *)
   {$I R:\tinc\itoa1.inc}      (* integer to ascii conversion *)
   {$I R:\tinc\stof.inc}       (* basic single to floating conversion *)
   {$I R:\tinc\stoa.inc}       (* single to ascii conversion *)
   {$I R:\tinc\dtof.inc}       (* basic double to floating conversion *)
   {$I R:\tinc\itoh.inc}       (* integer to hex conversion *)
   {$I R:\tinc\itou.inc}       (* integer to unsigned-real conversion *)
   {$I R:\tinc\ltor.inc}       (* long-integer to real conversion *)
   {$I R:\tinc\rempath.inc}    (* remove/manipulate filename paths *)
   {$I R:\tinc\iswild.inc}     (* is a filename a wildcard? *)
   {$I R:\tinc\stoupper.inc}   (* map string to upper case *)
   {$I R:\tinc\stolower.inc}   (* map string to lower case *)
   {$I R:\tinc\capstr.inc}     (* make string into 'Caps Format' *)
   {$I R:\tinc\filesize.inc}   (* get size of a file *)
   {$I R:\tinc\pattern.inc}    (* wildcard filename pattern comparison *)
   {$I R:\tinc\getfile3.inc}   (* expand wildcard file lists *)
   {$I R:\tinc\sysdate2.inc}   (* get system time string formats, mm-dd-yy & hh:mm *)
   {$I R:\tinc\gettime.inc}    (* get system time in seconds *)
   {$I R:\tinc\delay.inc}      (* delay function based on give-up-time and gettime *)
   {$I R:\tinc\delspace.inc}   (* delete all spaces from a string *)
   {$I R:\tinc\replstr.inc}    (* perform string replacements *)
   {$I R:\tinc\getenv.inc}     (* get environment variables *)
   {$I R:\tinc\varstr.inc}     (* variable allocation string library *)
   {$I R:\tinc\ljust.inc}      (* left justify strings *)
   {$I R:\tinc\bitmap.inc}     (* manipulate bit maps *)
   {$I R:\tinc\flags.inc}      (* manipulate bit flags *)
   {$I R:\tinc\appendc.inc}    (* append character to string *)
   {$I R:\tinc\diskspac.inc}   (* get disk free space; allows >32meg *)
   {$I R:\tinc\qwrite.inc}     (* quick screen write *)
   {$I R:\tinc\bakfile.inc}    (* rename file to .BAK *)
   {$I R:\tinc\bline.inc}      (* fast string compares *)
   {$I R:\tinc\cpos.inc}       (* character position in string *)
   {$I R:\tinc\jday.inc}       (* convert m/d/y to julian date *)

begin
   fillchar(filetable,sizeof(filetable),0);
end.

