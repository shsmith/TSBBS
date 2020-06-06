
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

procedure disp(m: string);
begin
   write(stdout,m);
   flush(stdout);
   if not local then 
      transmit_data(m);
end;

procedure displn(m: longstring);
   {private version of procomm.inc's displn; needed here because of
    tp4's scoping rules}
begin
   disp(m);
   if not local then
      transmit_data(^M^J);
   writeln;
end;

