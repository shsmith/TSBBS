
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
 * PCB ProDOOR user profile display (3-1-89)
 *
 *)

procedure view_profile;
begin
   displn(GREEN);

(******
   displn('TimeOn (mins)  = '+itoa(pcbsys.time_on)+
           ', Now = '+itoa(get_mins));
   displn('Minutes left   = '+wtoa(minutes_left)+
           ', Used = '+itoa(time_used)+
           ', Credit = '+itoa(pcbsys.time_credit)+
           ', Limit = '+itoa(pcbsys.time_limit)+
           ', Added = '+itoa(pcbsys.time_added));
   displn('Event schedule = '+itoa(minutes_before_event)+' minutes');
   displn('Uploads        = '+itoa(user.uploads)+
           ', Total = '+dtok(user.uptotal)+
           'k, Earned = '+wtoa(user.earned_k)+'k');
   displn('Downloads = '+itoa(user.downloads)+
           ', Total = '+dtok(user.downtotal)+
           'k, Today = '+dtok(user.downbytes)+
           'k, Allowed = '+wtoa(download_k_allowed)+
           'k, Limit = '+wtoa(pcbsys.down_limit)+'k');
   newline;
*******)

 { par3 := dtok(user.downtotal);
   par4 := dtok(user.downbytes); }
   pdispln('Number of Downloads: @DLFILES@ (@DLBYTES@ total, @DAYBYTES@ today)');

 { par5 := user.uploads;
   par3 := dtok(user.uptotal); }
   pdispln('Number of Uploads:   @UPFILES@ (@UPBYTES@ total)');

   par5 := user.earned_k;
   pdispln('Earned K Bytes:      $5W$');

   par5 := download_k_allowed;
   pdispln('Total K Bytes Avail: $5W$');
end;


