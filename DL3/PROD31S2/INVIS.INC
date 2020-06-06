
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
 * this function can be called to determine if "SLOW" mode displays are
 * required.  it should be called before each window OPEN/CLOSE action.
 *
 * it is SAFE to call and always returns FALSE when doubledos is not used.
 *
 *)
function invisible: boolean;   {is this the invisible program under doubledos?}
var
   reg:  registers;
begin
   reg.ax := $e400;   {doubledos return program status}
   msdos(reg);
   invisible := (lo(reg.ax) = 2);
end;

