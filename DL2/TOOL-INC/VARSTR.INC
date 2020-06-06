
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
 * varstr.inc - Library to manipulate variable-allocation strings. (3-1-89)
 *
 *)

procedure releasestr( var str:  varstring);
   (* release the memory used by a varstring variable.  variable MUST
      be pre-allocated or the program may crash!!! *)
begin
   if str <> nil then
   begin
      freemem(str,length(str^)+1);
      str := nil;
   end;
end;


procedure savestr( var tostr: varstring;
                   from:      string);
   (* save a regular string in a varstring; new allocation of varstring *)
begin
   releasestr(tostr);
   if maxavail < length(from)+100 then
      {$i-} writeln(debugfd^,'out of heap, savestr: [',from,']'); {$i+}

   getmem(tostr, length(from)+1);
   tostr^ := from;
end;

