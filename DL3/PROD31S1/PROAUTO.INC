
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
 * PCB ProDOOR module for automatic log off after transfer (3-1-89)
 *
 *)

procedure automatic_logoff;
   (* process the automatic logoff request; give the user a chance
      to change his mind *)
var
   c:        char;
   secs:     integer;

begin
   {newline;}
   beep;
   flush_com;

   {dispose keyahead}
   while key_ready and not dump_user do
      c := get_key;

   secs := 11;
   c := #255;
   repeat
      dec(secs);
      dispc(^M);
      par5 := secs;
      prompt_def('Last chance!  Automatic logoff in $5W$ seconds.  Abort:',enter_eq_yes);
      c := upcase(time_key(1000));
   until (secs <= 0) or dump_user or (c <> #255);

   default_color;

   if (c = 'N') or (c = #255) then
   begin
      displn('no');
      protocol := logging_off;
      create_door;
      good_bye;
      {delete_status_display;}
   end
   else
      displn('yes');
end;

