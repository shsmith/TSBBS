
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
 * filesize.inc - utility library to return the size of a file in bytes.
 *                returns 0 if the file does not exist
 *
 * shs 14-feb-86, (rev. 21-Dec-87)
 *
 *)

function file_size(name: string65): longint;
var
   DirInfo:     SearchRec;

begin
   FindFirst(name,$21,DirInfo);
   if (DosError <> 0) then
      file_size := 0
   else
      file_size := DirInfo.size;
end;

