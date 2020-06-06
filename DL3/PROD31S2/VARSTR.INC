
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
var
   olen: integer;
begin
   if str <> nil then
   begin
      olen := ord(str^[length(str^)+1]);
      if length(str^) <> olen then
      begin
(**
writeln(^G'release: [',str^,'] ',olen,^G^G^G);
**)
         olen := olen div 0; {signal runtime error}
      end;
      
      freemem(str,length(str^)+2);
      str := nil;
   end;
end;


procedure savestr( var tostr: varstring;
                   from:      longstring);
   (* save a regular string in a varstring; new allocation of varstring *)
begin

(*******
saved := saved+length(from)+2;
writeln('avail: ',maxavail:5,
        ' saved: ',saved:5,
        ' ovhd: ',saved+maxavail:5,
        ' save: ',from);
*********)

   releasestr(tostr);
   if maxavail < length(from)+100 then
      {$i-} writeln('out of heap, savestr: [',from,']'); {$i+}

   getmem(tostr, length(from)+2);
   tostr^ := from;
   tostr^[length(from)+1] := chr(length(from));
end;


