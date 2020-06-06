
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
 * PCB ProDOOR create the transfer batchfile (3-1-89)
 *
 *)

procedure create_door;
   (* create the door batchfile to perform the actual file transfer *)
var
   door:       text;
   doorcmd:    string;
   copy_down:  boolean;
   

   procedure dwrite(what: anystring);
   begin
      write(door,what);
   end;

   procedure dwriteln(what: anystring);
   begin
      check_command_line(what);
      writeln(door,what);
   end;

   procedure cdto(dir: filenames);
   begin
      if dir[2] = ':' then
         dir := copy(dir,1,2) + ^M^J'cd ' + dir
      else
         dir := 'cd '+ dir;
      dwriteln(dir);
   end;

   procedure cd_sysdir;
   begin
      cdto(sys_dir);
   end;

   procedure cd_homedir;
   begin
      cdto(home_dir);
   end;

   procedure cd_playpen;
   begin
      cdto(cnf.playpen_dir);
   end;

   procedure gencall;
   begin
      cd_homedir;
      doorcmd := comspec + ' /c ' + par1;
      prepare_line(doorcmd);
      dwriteln(doorcmd);
   end;

   procedure logtrans(option: char);
   begin
      cd_homedir;
      dwriteln('prons');

      par1 := 'proutest '+result_path+' '+cnf.playpen_dir+' '+pcbsys.scomport;
      if not copy_down then
         gencall;

      dwrite('prodoor '+config_file+' '+sys_dir+' '+option);
      if auto_logoff then
         dwrite('G');
      dwriteln(' '+itoa(protocol)+' '+ltoa(lget_time));
   end;


   procedure perform_transfer;
       (* write code to the door batch to perform the transfer,
          copy files into playpen before transfer if command contains
          a '*.*', otherwise don't copy. *)
   var
      i:           integer;
      count:       integer;
            
   begin
      set_node_status('T');   {transferring a file}
      save_name_list;

      dWHITE(pro_title);

      case pro_mode of
         TX:
            begin
               disp(' send');
               count := transfer.count;
            end;
              
         RX:
            begin
               disp(' receive');
               count := transfer.count;
(***
               if pro_files <> 1 then
                  dec(count);       {omit *.* at end of list}
***)
            end;
      end;

      cd_homedir;
      dwriteln('prons');
      cd_playpen;

      if count > 0 then
         disp(' of');

      copy_down := (pro_mode = TX) and is_wild(pro_command);

      (* copy the selected files into the playpen *)
      for i := 1 to count do
      begin
         space;
         dMAGENTA(remove_path(transfer.entry[i]^));
         if copy_down then
            copy_file( transfer.entry[i]^,
                       cnf.playpen_dir + '\' +
                       remove_path(transfer.entry[i]^));
      end;
      dwriteln('');


      (* perform the file transfer on all selected files *)
      doorcmd := pro_command;
      if (not copy_down) and (pro_files > 0) and (posc('@',doorcmd) = 0) then
         for i := 1 to count do
            doorcmd := doorcmd + ' ' + transfer.entry[i]^;
      dwriteln(doorcmd);
      
      (* write door command to check for an aborted file transfer *)
      dwriteln('if errorlevel 1 goto door$error');

      (* process errorlevel 0 exits *)
      logtrans(o_logok);
      dwriteln('goto recycle$door');

      (* process non-0 error levels *)
      dwriteln(^M^J':door$error');
      logtrans(o_logerr);

      dwriteln(^M^J':recycle$door');
      cd_sysdir;
      dwrite('door ');
      if auto_logoff then
         dwriteln(o_logoff)
      else
         dwriteln(o_nosignon);

      dWHITE(' ready!');
      newline;
      dGRAY('Type (Ctrl-X) several times to abort.');
      newline;
   end;


begin  {create_door}

   dos_unlink(doorlog_path);
   dos_unlink(result_path);
   newline;

   assign(door,doorfile_path);
   {$i-} rewrite(door); {$i+}
   if ioresult <> 0 then file_missing;

   (* say goodbye when user is hanging up *)
   if dump_user or (protocol = logging_off) then
   begin
      display_file(closing_door_file);
      cd_sysdir;
      dwriteln('if exist event.bat event'^M^J'%1');
   end
   else

   (* display a message and close when no protocol selection was made *)
   if protocol = aborted then
   begin
      display_file(closing_door_file);
      displn(WHITE);
      displn('Returning to system.  Please wait ...');
      cd_sysdir;
      dwriteln('%1');
   end
   else

   (* copy door script and re-load DOOR for open-door function *)
   if protocol = opening_door then
   begin
      set_node_status(node_in_door);
      display_file(closing_door_file);
      displn(WHITE);
      par3 := par1;
      pdispln('Loading $3$.  Please wait ...');
      cd_sysdir;
      dwriteln('copy '+par1+' door.bat >nul'^M^J'door'^M^J'%1');
   end
   else

   (* create script for outsize batchfile function *)
   if protocol = outside_batch then
   begin

      dWHITE('Processing your request.  Please wait ...');
      newline;
      gencall;
      cd_sysdir;
      dwriteln('door '+o_result);
      delete_status_display;
   end

   (* create special door file to perform file transfers *)
   else
      perform_transfer;

   close(door);
end;


