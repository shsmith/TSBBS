
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


(* ----------------------------------------------------- *)
procedure write_user_info;
var
   temp: char12;

begin
   if not verify_level('W') then exit;

   newline;
   fillchar(temp,sizeof(temp),' ');
   get_chars('Please enter your current password for verification: ',
            temp,sizeof(user.passwd),false);
   cmdline := '';
   if dump_user or (temp = '') then
      exit;

   if (user.passwd <> temp) then
   begin
      displn('Wrong password entered!');
      exit;
   end;

   newline;
   displn('Note: Press <ENTER> to keep original information without change!');
   newline;
   get_chars('   New Password (One word!)',
            user.passwd,sizeof(user.passwd),true);

   newline;

   if not pcbsetup.only_pwchange then
   begin
      get_chars(get_pcbtext(265) {'City and State calling from'},
            user.city,sizeof(user.city),true);

      newline;
      get_chars(get_pcbtext(113) {'Business or data phone # is'},
            user.busphone,sizeof(user.busphone),true);

      newline;
      get_chars(get_pcbtext(114) {'   Home or voice phone # is'},
            user.phone,sizeof(user.phone),true);

      newline;
      get_chars(get_pcbtext(2),
            user.usercomment,sizeof(user.usercomment),true);
   end;

   newline;
   make_log_entry('Registration Information Updated.',true);
   cmdline := '';
end;


 
