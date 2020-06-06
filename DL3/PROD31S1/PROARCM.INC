
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
 * PCB ProDOOR module to archive captured messages for download. (3-1-89)
 *
 *)

procedure capture_conference(n: integer);
   (* capture the messages in a selected conference *)
var
   pcount: integer;
   
begin
   if (linenum >= 2000) then           {^K abort}
      exit;
   if (cap_count >= max_capcount) or (select_conference(n) = false) then
      exit;
      
   dGREEN(conf_info.conf_name);
   make_log_entry('@INCONF@ Conference Joined.',false);

   writeln(mailfd,^M^J^M^J#255'** Mail Area: ',conf_info.conf_name);
   pcount := cap_count;
      
   alloc_mail;
   open_conference;
   direction := '+';
   if curmsg > 1 then      {avoid re-scanning last read in ARCM}
      advance;

   repeat
      dispc('.');
      
      {find position in file and read the message}
      advance;
      capture_current_message;
      write(mailfd,#255);

   until dump_user or                     {time expired, carrier lost}
         (msgpos = no_msg) or             {last message available}
         (cap_count >= max_capcount) or   {too many messages}
         (linenum >= 2000);               {^K abort}

   newline;
   close_conference;
   free_mail;

   {make_log_entry(itoa(cap_count-pcount)+msgs_captured,false);}
end;


(* ---------------------------------------------------------- *)
procedure capture_new_mail;
   (* capture all new mail (CALLED ONLY FROM MAIN MENU) *)
var
   pconf: integer;
   n:     integer;   
   tm:    longint;

begin
   if (not verify_level(fun_arcmail)) or
      (not flag_warning(false)) then exit;

   if dos_exists(mailarc) then
   begin
      displn('WARNING: If you continue, the previous ZIPM results may be lost!!');
      cmdline := '';
      force_enter;
   end;
   
   if length(cmdline) = 0 then
   begin
      par := pcbsetup.conference_menu^;
      linenum := 0;
      display_file(par);
   end;


(* list conferences, scan new messages and select conferences to capture *)
   repeat
      if length(cmdline) = 0 then
      begin
         newline;
         get_defn('Conference(s) to Capture:','(N)ews, (Y)our, (A)ll, ');
      end;
   
      get_nextpar;
      if (length(par) = 0) or dump_user then
         exit;
         
      if (length(par) = 1) and ((par[1] = 'N') or (par[1] = 'Y')) then
      begin
         display_conference_status(par[1]);
         par := 'N';
      end
      else

   until (length(par) <> 1) or (par[1] <> 'N');

(* process the selected conferences *)
   pconf := pcbsys.curconf;
   lookup_info := false;      {speed up message loading}
   linenum := -30000;         {force non-stop mode}

   save_pointers(oldptrfile);
   open_mail_capture;
   buffer_mail_capture;
   {tm := lget_time;}

   write(mailfd,^M^J#255'** ProDoor Mail Capture - Created: ',
                           system_date,' ',system_time,
                ^M^J#255'** System: ',pcbsetup.system_name^);
   
   if (length(par) = 1) and (par[1] = 'A') then
      for n := 0 to conf_count do
      begin
         if getflag(extuser.conf[n].flags,ext_scan) then
            capture_conference(n);
      end
   else
      repeat
         n := lookup_conference_number(par);
         if n >= 0 then
            capture_conference(n);
         get_nextpar;
      until (length(par) = 0) or dump_user;
      

   writeln(mailfd,^M^J#255'** Messages Captured: ',cap_count);

   close_mail_capture;
   newline;
   {displn('[elapsed time = '+ltoa(lget_time-tm)+']');}

   if cap_count >= max_capcount then
      displn('There are too many new messages!  Get the rest next time.');

   par5 := cap_count;
   make_log_entry('$5W$ messages captured.',true);
   newline;

   if select_conference(pconf) then ;

(* archive the result *)
   if cap_count > 0 then
   begin
      make_log_entry('ZIPM executed.',false);
      display_file(arcm_help_file);

      protocol := outside_batch;
      par1 := 'proarcm '+result_path+' '+mailarc+' '+mailfile;

      (* arrange for new pointers to be installed after packet download *)
      save_pointers(newptrfile);
   end;

(* reset pointers to original values in case arcm download fails *)
   load_pointers(oldptrfile);
end;

