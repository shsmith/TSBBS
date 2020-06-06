
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

unit ProTran;

interface

   Uses
     DosMem, MdosIO, Tools,
     ProData, ProRoot, ProJoin;


   {$I profsec.int}     (* verify file access through FSEC file security *)
   {$I profile.int}     (* file location, directory searching, ok-checking *)

   {$I prosel.int}      (* select and verify files to be transferred *)
   {$i prouldes.int}    (* get upload descriptions *)
   {$I proest.int}      (* estimate transfer time *)
   {$I procreat.int}    (* create $door.bat batch *)
   {$I propro.int}      (* protocol selection *)
   {$I protab.int}      (* protocol table display *)
   {$I profree.int}     (* free d/l file checker *)

implementation

   {$I profsec.inc}     (* verify file access through FSEC file security *)
   {$I profile.inc}     (* file location, directory searching, ok-checking *)

   {$I prosel.inc}      (* select and verify files to be transferred *)
   {$i prouldes.inc}    (* get upload descriptions *)
   {$I proest.inc}      (* estimate transfer time *)
   {$I procreat.inc}    (* create $door.bat batch *)
   {$I propro.inc}      (* protocol selection *)
   {$I protab.inc}      (* protocol table display *)
   {$I profree.inc}     (* free d/l file checker *)

end.

