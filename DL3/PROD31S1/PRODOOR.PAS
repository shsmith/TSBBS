
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

{$i prodef.inc}
{$i proovr.inc}

{$ifdef OVERLAY}
   {$M 7000,22000,22000}
{$else}
   {$M 7000,8000,8000}     {Stack(min=22), minheap(min=4), maxheap}
{$endif}                 {IF PACKED, MINHEAP=4; UNPACKED MINHEAP=15!!}


program ProDOOR;

Uses
{$ifdef OVERLAY}
  ProOvr,       {overlay initialization}
{$endif}

  ProSysF,
  MdosIO,       {low-level dos file functions}
  MiniCrt,      {bios based crt driver}
  Tools,        {various tool-inc library functions}
  ProData,      {global data}
  ProRoot,      {root support functions for doors}

{$ifdef OVERLAY}
  ProMail,      {mail overlay}
  ProRead,
  ProJoin,
  ProEnter,
  ProVis,
  ProView,      {arcview overlay}
  ProScan,
  ProArc,
  ProDir,
  ProBlt,
  ProOpen,
{$endif}
  
  ProRegL,
  ProLog,       {transfer logging, automatic logoff}
  ProTran,      {transfer control and file selection}
  ProBye,
  ProMenu;

{$ifdef OVERLAY}
   {$O ProSysF}
   {$O ProMail}
   {$O ProRead}
   {$O ProJoin}
   {$O ProEnter}
   {$O ProVis}
   {$O ProView}
   {$O ProScan}
   {$O ProArc}
   {$O ProDir}
   {$O ProBlt}
   {$O ProRegL}
   {$O ProLog}
   {$O ProTran}
   {$O ProOpen}
   {$O ProBye}
   {$O ProMenu}
{$endif}


(* ------------------------------------------------------------------- *)
procedure init;
   (* set things up so nothing goes crazy during initialization *)
   (* note -- some inits are done in the body of ProLib *)
begin
   install_error_handler;
   NormalVideo;

   if paramcount = 0 then
      usage('Missing parameters:  <configfile> <systemdir>');

   load_pcbsys_file;
   load_pcbdat_file;
   load_cnames_file;
   load_config_file;

   init_com;
   check_carrier_loss;

   load_user_rec;
   init_status_display;

   build_scratchnames;

   setdebug := environment_on('PRODEBUG');
   if setdebug then
      open_capture;

   prepare_protocol_table;
   build_download_list;

   {checking for an event adjusts for pending events}
   if event_run_needed(event_possible) then ;


   {initialize user record on first entry to door}  
   if getflag(user.flags,flag_init) then
   begin
      user.dooruse := 0;
      user.scratchnum := 1;
      user.earned_k := 0;
      setflag(user.flags,flag_init,false);
      build_scratchnames;
   end;

   {check for old format data}
   if getflag(user.flags,flag_oldfmt) then
      user.flags := 0;

   if user.earned_k > 65000 then    {clean up after earlier bugs}
      user.earned_k := 0;

   _CREG_('PRODOOR.REG',0);
end;


(* ------------------------------------------------------------------- *)
procedure check_playpen;
   (* verify that the playpen is empty; warn SYSOP that there is trouble
      if playpen has files in it *)
begin
   cons_path(par,cnf.playpen_dir,'*.*');
   getfiles(par, filetable, filecount);

   if filecount <> 0 then
   begin
      newline;
      make_log_entry('WARNING:  PLAYPEN "'+cnf.playpen_dir+'" IS NOT EMPTY!!!',true);
      while filecount > 0 do
      begin
         make_log_entry('          FILE='+filetable[filecount]^,true);
         dec(filecount);
      end;
      displn('PLEASE TELL SYSOP!  (POSSIBLE CONFIGURATION ERROR)'^G^G^G);
      force_enter;
   end;
end;


(* ------------------------------------------------------------------- *)
procedure signon;
begin
   if setdebug then 
      writeln(dbfd,system_date,' ',system_time,' (',baudrate,') ',username);

   newline;
   displn(WHITE);
   displn('ProDoor '+version+';  Copyright (C) 1987, 1989 Samuel H. Smith');
   _DREG_(disp);
   if not _REG_ then delay(5000);

   {setflag(user.flags,flag_expert,user.expert = 'Y');}

   (* welcome user first time into door *)
   if user.dooruse < 255 then
      inc(user.dooruse);
   if (user.dooruse <= 1) then      {display welcome first time}
   begin
      linenum := 1;
      display_file(newuser_file);
      force_enter;
   end;

   linenum := 1;
   display_file(signon_file);

   view_profile;
   wait_for_enter;

   (* remind user of mail waiting *)
   if getflag(user.flags,flag_hasmail) then
   begin
      display_file(usermail_file);
      wait_for_enter;
   end;
end;


(*
 * main program
 *
 *)

begin

(* perform basic initialization *)
   init;
   if local then
      bios_echo := true;

(* check for automatic logoff *)
   if option = o_logoff then
      automatic_logoff;

(* check for normal prompting or initial execution *)
   if (paramcount in [2,3]) and (protocol <> logging_off) then
   begin
      dos_unlink(doorfile_path);

      if option = o_none then
      begin
         signon;
         clean_scratch;
         check_playpen;
      end
      else

      begin
         if option = o_result then   {disp results of an outside function}
            display_resultfile;

         linenum := 3;               {in case of transfer, before menu}
         wait_for_enter;

         autoflag_scratch;           {flag scratch/zipm files for dl}
      end;

      option := o_none;

      (* refuse to load door if insufficient space *)
(**********
      if disk_space(sys_dir[1]) < 10 then
      begin
         displn('Sorry, insufficient disk space for proper DOOR operation!');
         protocol := aborted;
      end
      else
*******)

      (* prompt for protocols and name lists until a valid transfer
         has been specified, or the user requests exit to pcboard *)
      repeat
         main_menu;
         select_names;
         estimate_transfer_time;
      until (protocol <> 0) or dump_user;

      (* create the door batchfile to either recycle pcboard or run
         the external protocol *)
      create_door;

      (* force logoff if needed *)
      if dump_user or (protocol = logging_off) then
         good_bye;
   end
   else

(* check for end-of-transfer logging execution *)
   if paramcount = 5 then
      log_file_transfer;


(* update system files *)
   save_user_rec;
   save_pcbsys_file;


(* hang up on the user if he has said 'goodbye' *)
   if protocol = logging_off then
   begin
      drop_carrier;
      save_offline_pcbsys_file;

      if event_pending or pcbsetup.recycle_offhook then
         force_offhook;
   end;


(* remove status display when leaving the door or recycling *)
   if (protocol < 1) or (paramcount = 5) then
      {delete_status_display}
   else
      transfer_status_display;

   default_color;

(* remove interrupt handlers and recycle to external protocol or
   back into pcboard *)
   uninit_com;

   close_capture;
   halt(0);
end.

