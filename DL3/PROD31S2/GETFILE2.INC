
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
 * getfile2 - file list processing library (simplified version)
 *
 * This module will change a wildcard list of files into a
 * sorted file name list.
 *
 * Samuel H. Smith, rev. 25-oct-87
 *
 *)

procedure getfiles (pattern:       filestring;
                    var fdir:      filearray;
                    var num:       integer);
var
   DirInfo:       SearchRec;
   curdir:        filestring;

begin
   curdir := path_only(pattern);
   num := 0;

   FindFirst(pattern,$21,DirInfo);
   while (DosError = 0) and (num < maxnumfiles) do
   begin
      inc(num);
      fdir[num] := curdir + DirInfo.name;
      FindNext(DirInfo);
   end;

{writeln('getfiles [',pattern,'] cd=',curdir,' num=',num);}

end;                     {getfiles}

