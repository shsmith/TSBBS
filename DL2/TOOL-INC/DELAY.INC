
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

procedure delay(ms: longint);
   (* delay for a specified number of miliseconds; give up time while
      delaying *)
var
   finish:  longint;
   start:   longint;
   now:     longint;

begin
   start := lget_ms;
   finish := start + ms;

   repeat
      give_up_time;
      now := lget_ms;
   until (now > finish) or    {time elapsed}
         (now < start);       {midnight rolover!}
end;


