
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
 * sysdate - library to return system date and time (3-1-89)
 *
 *)

function system_date: string20;
const
   month : array [1..12] of string[3]
           = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
   reg:           registers;

   function strval (i: integer): string2;
   begin
      strval := chr(((i div 10) mod 10) + ord('0')) +
                chr((i mod 10) + ord('0'));
   end;

begin
   reg.ax := $2a00;
   msdos(reg);
   system_date := strval(lo(reg.dx)) + '-' +
                  month[hi(reg.dx)] + '-' +
                  strval(reg.cx-1900);
end;


function system_time: string10;
var
   reg:       registers;
   hh,mm,ss:  string[2];

begin
   reg.ax := $2c00;
   msdos(reg);
   str(hi(reg.cx),hh);  if length(hh) = 1 then hh := '0' + hh;
   str(lo(reg.cx),mm);  if length(mm) = 1 then mm := '0' + mm;
   str(hi(reg.dx),ss);  if length(ss) = 1 then ss := '0' + ss;
   system_time := hh + ':' + mm + ':' + ss;
end;
