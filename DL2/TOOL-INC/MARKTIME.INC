
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

procedure mark_time(var long: longint);
   {report time in clock ticks since midnight}
var
   words:   record
               l,h: word;
            end   absolute long;
   reg:     registers;
   
begin
   reg.ah := 0;  {get time of day}
   intr($1a,reg);
   words.l := reg.dx;
   words.h := reg.cx;
end;


