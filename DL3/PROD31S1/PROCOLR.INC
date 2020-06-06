
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
 * PCB ProDOOR display colorizer library (3-1-89)
 *
 *)


procedure displn_dir(var line: longstring);
   {display a directory line in fake color}
var
   isdir:   boolean;
   i:       integer;

begin
   isdir := false;

   case line[1] of
      '0'..'9','A'..'Z','a'..'z':
         if (line[21] >= '0') and (line[21] <= '9') then
            isdir := true;

      ' ':
         begin
            i := posc('|',line);
            if i > 0 then
               line[i] := ' ';
            isdir := (i > 31);
         end;
   end;

   if isdir then
   begin
      dMAGENTA(copy(line,1,13));
      dGREEN  (copy(line,14,9));
      dRED    (copy(line,23,10));
      default_color;
      disp    (copy(line,33,255));
   end
   else
      dWHITE(line);

   newline;
end;

