
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


function disk_space(disk: char): word;
   {report space on drive in k bytes}
   {should work even wth partitions over 32meg}
   {dos.diskfree fails on large partitions as of tp5.0}

var
   reg:     registers;
   space:   longint;
   bpcl:    word;

begin
   reg.ah := $36;
   if disk = '\' then
      reg.dl := 0
   else
      reg.dl := ord(upcase(disk))-ord('@');
   msdos(reg);

   if reg.ax = $FFFF then
      space := 0
   else
   begin
      {ax=sectors per cluster, bx=free clusters, cx=bytes per sector}
      space := reg.bx;                 {clusters}
      bpcl := reg.ax * reg.cx;         {bytes per cluster}
      space := (space * bpcl) shr 10;
   end;

{writeln('disk=',disk,' space=',space,' ax=',reg.ax,' bx=',reg.bx,' cx=',reg.cx);}

   if space > $7FFF then
      disk_space := $7FFF
   else
      disk_space := space;
end;


