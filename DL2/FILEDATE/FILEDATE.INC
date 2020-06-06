
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
 * Return the modification date of a file as a real.
 * This real will always be larger for later file dates.
 *
 * The returned date, if printed with writeln(date:11:4) will give
 * the following format:
 *        yymmdd.hhmm
 *
 *)

function filedate (filename:      anystring): real;
var
   DirInfo:     SearchRec;
   Stamp:       DateTime;

begin
   FindFirst(filename,$21,DirInfo);
   if (DosError <> 0) then
      filedate := 0
   else

   begin
      UnpackTime(DirInfo.time, Stamp);
      filedate := int(Stamp.Year)  *10000.0 +
                  int(Stamp.Month) *100.0 +
                  int(Stamp.Day) +
                  int(Stamp.Hour)  / 100.0 +
                  int(Stamp.Min)   / 10000.0 +
                  int(Stamp.Sec)   / 1000000.0;
   end;

end;

