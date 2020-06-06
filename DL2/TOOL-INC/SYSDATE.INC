
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

function strval (i: integer): string2;
begin
   strval := chr(((i div 10) mod 10) + ord('0')) +
             chr((i mod 10) + ord('0'));
end;

function system_date: string8;   {format: yy/mm/dd}
begin
   reg.ax := $2a00;
   msdos(reg);
   system_date := strval(reg.cx-1900) + '/' +
                  strval(hi(reg.dx))  + '/' +
                  strval(lo(reg.dx));
end;

function system_time: string8;   {format: hh:mm:ss}
var
   reg:           registers;
begin
   reg.ax := $2c00;
   msdos(reg);
   system_time := strval(hi(reg.cx)) + ':' +
                  strval(lo(reg.cx)) + ':' +
                  strval(hi(reg.dx));
end;
