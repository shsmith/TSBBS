
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * KitInit - initialization unit for ProKit system (3-1-89)
 *
 *)

{$i prodef.inc}

unit KitInit;

interface

   Uses
     MiniCrt,
     Tools,
     MDosio,
     OpenShare,
     Debugs,
     ProData,
     ProBye,
     ProSysf,
     ProRoot,
     ProUtil,
     ProUtil2;

   procedure init;
   procedure init_standalone;
   procedure uninit;
   procedure close_down_door(messages: boolean);

   var
      local_testing:  boolean;

implementation


   { I probye.inc}      (* automatic logoff *)

   (* ------------------------------------------------------------------- *)
   procedure load_config_file;
      (* load the configuration file *)
   var
      fd:    text;
      temp:  string;

   begin
      (* load and interpret the configuration file *)
      getdir(0,home_dir);
      bios_comm := false;

      if config_file <> 'NONE' then
      begin
         assignText(fd,config_file);
         {$i-} reset(fd); {$i+}
         ok := ioresult = 0;
         if not ok then
            file_missing(10000);

         readln(fd,temp);
         stoupper(temp);

         if (temp[1] <> 'I'{nterrupt}) and (temp[1] <> 'H'{andshake}) then
            bios_comm := true;

         close(fd);
      end;
   end;


   (* ------------------------------------------------------------------- *)
   procedure init_standalone;
      (* initialize for stand-alone testing (without PCBoard) *)
   begin
      {create a "fake" pcboard.sys record}
      option := o_logok; 
      getdir(0,home_dir);
      baudrate := 'Local';
      username := 'SYSOP';
      first_name := 'SYSOP';

      fill_chars(pcbsys.time_logged,system_time,5);
      pcbsys.alarm := '-1';
      pcbsys.usernum := 1;
      pcbsys.time_credit := 0;
      graphics := false;

      pcbsys.time_on := get_mins;
      pcbsys.time_limit := 120;
      pcbsys.time_limit := 120;
      pcbsys.time_added := 0;
      pcbsys.time_credit := 0;
      pcbsys.prev_used := 0;
      pcbsys.curconf := user.curconf;
      pcbsys.graphics := 'N';
      fill_chars(pcbsys.name,username,sizeof(pcbsys.name));

      load_pcbdat_file;
      {load_cnames_file;}
      load_user_rec;
      {user.pagelen := 22;}

      {switch to color/graphics mode if pcbsetup says you login
       locally in graphics mode}
      if pcbsetup.local_graphics then
      begin
         graphics := true;
         pcbsys.graphics := 'Y';
      end;

      par := '@SYSDATE@ (@SYSTIME@) ';
      if pcbsetup.under_network then
         par := par + '($NODE$)';
      make_raw_log_entry(par+' SYSOP (Local) '+progname+' '+paramstr(0));
   end;


   (* ------------------------------------------------------------------- *)
   procedure init;
      (* set things up so nothing goes crazy during initialization *)
      (* note -- some inits are done in the body of ProLib *)
   begin
      progname := name_only(paramstr(1));
      install_error_handler;

      if paramcount < 2 then
      begin
         writeln;
         writeln('Usage:   ',progname,' CONFIG_FILE SYSTEM_DIR [LOCAL]');
         writeln('Example: prokit prokit.cnf c:\pcb2 LOCAL');
         usage(' Invalid command parameters');
      end;

      local_testing := paramstr(paramcount) = 'LOCAL';

   (* get things ready to go *)
      if local_testing then
         init_standalone
      else
      begin
         load_pcbsys_file;
         load_pcbdat_file;
         load_config_file;
         load_user_rec;
      end;

      NormalVideo;
      init_com;
      check_carrier_loss;
      init_status_display;

      cnf.playpen_dir := home_dir;
      build_scratchnames;
      setdebug := debugging;

      if setdebug then
         open_capture;
   
      cmdline := '';
      par := '';
      allow_flagging := false;

      if setdebug then 
         writeln(dbfd,system_date,' ',system_time,' (',baudrate,') ',username);

      {checking for an event adjusts for pending events}
      if event_run_needed(event_possible) then ;
   end;


   (* ------------------------------------------------------------------- *)
   procedure close_down_door(messages: boolean);
   begin
      if messages then
      begin
         newline;
         pdispln('$GRAY$<ProKIT '+version_number+' (C) 1992 S.H.Smith; The Tool Shop (818) 891-6780>$WHITE$');
         newline;
      end;

   (* update system files *)
      if not local_testing then
      begin
         if not dump_user then
         begin
            if messages then
               displn('Returning to system.  Please wait...');
         end
         else

      (* hang up on the user if he has said 'goodbye' *)
         begin
            good_bye;
            drop_carrier;
            if event_pending or pcbsetup.recycle_offhook then
               force_offhook;
         end;
      end;

      save_user_rec;

      if local_testing then
         delete_status_display
      else
      begin
         if dump_user then
            save_offline_pcbsys_file
         else
            save_pcbsys_file;
      end;


   (* remove interrupt handlers and recycle to external protocol or
      back into pcboard *)
      uninit_com;

      close_capture;
      halt(0);
   end;

   procedure uninit;
   begin
      if local_testing then
         logoff_log_entry(time_used);
      close_down_door(true);
   end;

end.

