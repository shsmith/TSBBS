
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
 * exists - return true if a file exists
 *
 * shs 14-feb-86, (rev. 21-Dec-87)
 *
 *)

function exists(name: filenames): boolean;
var
   DirInfo:     SearchRec;

begin
   dos_name := name;
   FindFirst(name,$21,DirInfo);
   if (DosError <> 0) then
      exists := false
   else
      exists := true;
end;
