
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
 * given a valid filename, returns modification date and time
 * formatted as a string:  dd-mmm-yy hh:mm
 *
 *)

function get_file_date (filename:      anystring): anystring;
const
   month : array [1..12] of string[3]
           = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
   DirInfo:     SearchRec;
   Stamp:       DateTime;

   function strval (i: integer): string;
   begin
      strval := chr(((i div 10) mod 10) + ord('0')) +
                chr((i mod 10) + ord('0'));
   end;

begin
   FindFirst(filename,$21,DirInfo);
   if (DosError <> 0) then
      get_file_date := 'No such file'
   else

   begin
      UnpackTime(DirInfo.time, Stamp);
      get_file_date := strval(Stamp.Day) + '-' +
                       month[Stamp.Month] + '-' +
                       strval(Stamp.Year) + ' ' +
                       strval(Stamp.Hour) + ':' +
                       strval(Stamp.Min);
   end;
end;

