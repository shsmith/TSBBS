
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
 * bsort.inc - generic bubble sort
 *
 * #define SORT_COUNT      number of items to sort
 * #define SORT_REVERSED   returns true if %1 > %1+1
 * #define SORT_SWAP       exchange %1 and %1+1
 *
 *)

procedure sort;
var
   i: integer;
   swapped: boolean;
begin
   repeat
      swapped := false;
      for i := 1 to SORT_COUNT do
         if SORT_REVERSED(i) then
         begin
            SORT_SWAP(i);
            swapped := true;
         end;
   until not swapped;
end;




