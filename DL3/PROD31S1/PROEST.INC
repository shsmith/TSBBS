
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
 * PCB ProDOOR estimate transfer time  (3-1-89)
 *
 *)

procedure estimate_transfer_time;
   (* calculate the estimated time for the transfer and verify that
      the user has enough time left *)
var
   c:          char;
   timeest:    real;

begin
   if (protocol < 1) then
      exit;
(***
   if (pro_files > 0) and (transfer.count = 0) then
   begin
      protocol := 0;
      exit;
   end;
***)

   timeest := estimated_time(transize)+0.1;

   (* report time estimate on downloads *)
   if (pro_mode = TX) and (transfer.count > 1) then
   begin
      newline;
      dGREEN(pro_title);
      displn(' Download Estimate:');
      spaces(3);
      dCYAN(itoa(transfer.count)+' files,  '+
           wtoa(transize div 1024)+'k bytes,  '+
           ftoa(timeest,0,1));
      displn(' minutes');
   end;


   (* give the user a change to change his mind *)
   if length(cmdline) = 0 then
   begin
      newline;
      prompt_def('LAST CHANCE!',
            ' (Enter) or (S)tart, (G)oodbye after transfer, (A)bort? ');
      beep;
      cmdline := '';
      line_input(cmdline,1,true,true);   {no waiting for CR}
      newline;
   end;


   get_nextpar;
   if length(par) = 0 then
      c := 'C'
   else
      c := upcase(par[1]);

   if c = 'A' then
      protocol := 0;

   auto_logoff := (c = 'G') {or (timeest > 45.0)};
end;

