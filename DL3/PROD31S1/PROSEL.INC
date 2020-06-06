
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
 * PCB ProDOOR select and verify files to transfer, accept upload
 *             descriptions and create the transfer batchfile
 *
 * (3-1-89)
 *
 *)

procedure select_names;
   (* input a list of files to be transferred.
      verify each file as proper for the selected protocol *)

var
   name:       filenames;
   desc:       string;
   scount:     integer;
   checkok:    boolean;
   playspace:  integer;
   ulspace:    integer;
   needname:   boolean;


   (* ----------------------------------------------------------- *)
   procedure initiate_selection;
   begin
      transfer.count := 0;
      transize := 0;
      scount := pro_files;
      needname := scount > 0;
      checkok := true;

      (* display the selected protocol *)
      newline;
      case pro_mode of
         TX:  dWHITE('Download ');
         RX:  dWHITE('Upload ');
      end;

      displn(pro_title+'.');
   
      playspace := disk_space(cnf.playpen_dir[1]) - 32;

      (* verify conference placement of uploads *)
      if (pro_mode = RX) then
      begin
         if pcbsys.curconf <> 0 then
         begin
            {drop to main board if this conference has no file areas}
            if upload_dir = '' then
               select_main_board
            else
   
            if cmdline = '' then
            begin
               newline;
               get_defyn('Keep upload inside conference:',true);
               if (par[1] = 'N') then
                  select_main_board;
            end;

            newline;
         end;

         {cancel upload if no upload directories are defined}
         if upload_dir = '' then
         begin;
            protocol := 0; {cancel upload attempt}
            exit;
         end;
   
         (* verify that there is enough space for uploading *)
         ulspace := disk_space(upload_dir[1]) - 32;
         par5 := ulspace;
         dCYAN('@INCONF@ upload dir has $5W$k free');
   
         (* check playpen dir, report it also if less than upload drive *)
         par5 := playspace;
         if playspace < ulspace then
            pdisp(', $5W$k max per transfer');
         displn('.');
   
         (* abort transfer if not enough space *)
         if ulspace < pcbsetup.min_upload_free then
         begin
            make_log_entry('Insufficient disk space for uploading!',true);
            protocol := 0; {cancel upload attempt}
            exit;
         end;
      end;
   
      if download_k_allowed > 10000 then
         k_left := 10000
      else
         k_left := download_k_allowed;

      if is_wild(pro_command) and (k_left > playspace) then
         k_left := playspace;
       mins_left := minutes_left;


      if pro_files = 0 then
         scount := max_files;

      if cmdline = '' then
      begin
         newline;
         dGREEN('Wildcards are Okay, '+dotpak+' is assumed.');
         newline;

         (* give instructions for multi-file transfers *)
         if pro_files <> 1 then
         begin
            par5 := scount;
            pdispln('Enter up to $5W$ filespecs.  End the list with a blank line.');

            (* on batch transfers, the file list is not needed (files=0).
               ask for the max-files files just so the user can specify
               anyway, if he wants to.  *)
            if pro_files = 0 then
            begin
               newline;
               dRED('You have requested a batch upload.'); newline;
               displn('Press (Enter) now if you want ProDoor to determine filenames automatically.');
               displn('(You risk file duplication when you skip filename entry)');
            end;
         end;
      end;


      (* insert scratchfile/mailfile into command line if it exists *)
      name := '';

      if (pro_mode = TX) then
      begin
         if pending_flags <> '' then
         begin
            par := pending_flags;
            delete_trailing_spaces(par);
            unget_par;
         end;
      end;
   end;


   (* ----------------------------------------------------------- *)
   procedure get_description;
      (* prompt for an upload description unless filespec is wildcard *)
   begin

      (* don't ask for a description on wildcard uploads; these will be
         processed after the transfer when the actual file list is known *)
      if is_wild(name) then
      begin
         desc := '<wild>';
         exit;
      end;

      (* keep prompting for a description until a valid one is entered, or
         carrier is lost *)
      newline;
      par3 := name;
      dGREEN('Please enter a description of ($3$).');
      displn('  (Enter) alone to end.');
      displn('Begin description with (/) to make upload ''Private''.');
      get_upload_description('?',desc);
   end;


   (* ----------------------------------------------------------- *)
   procedure prompt_for_selection;
   begin
      (* prompt for a file if nothing on command stack *)
      newline;

      if pro_mode = TX then
      begin
         dYELLOW('(');
         dRED(itoa(k_left)+'k, ');
         dGREEN(itoa(mins_left)+' min. left');
         dYELLOW(') ');
      end;

      dYELLOW('Filespec');
      par5 := transfer.count+1;
      if pro_files <> 1 then
         pdisp(' $5W$');
      disp(': ');

      no_hotkeys;
      line_input(cmdline,sizeof(cmdline)-1,true,true);

      spaces(3);
      checkok := true;
   end;
   

   (* ----------------------------------------------------------- *)
   procedure process_selection;
   var
      i: integer;

   begin
      get_nextpar;
      stoupper(par);
      name := par;

      if (name = '') or                             (* check for end-of-list *)
         ((name[1] = '*') and (name[2] = '*')) then (* or dsz signon *)
         name := '.';
         
      (* check for end-of-list condition *)
      if length(name) = 1 then
         case name[1] of
            'A',           {abort transfer}
            'G',           {goodbye after transfer}
            'Q',           {quickly start transfer}

            'S':  begin    {start transfer}
                     unget_par;
                     name[1] := '.';
                  end;
         end; 
     
      if name[1] = '.' then
      begin
         newline;
         exit;
      end;
      

      (* format the input into a proper filename specification,
         adding .PAK extention is needed *)

      name := remove_path(name);
      if posc('.',name) = 0 then
         name := name + dotpak;

      (* once a name is given it is no longer to begin transfer
         without a valid name *)
      needname := true;

      (* see if the filename is OK for this protocol
         (present for download, not-present for uploads) *)

      if checkok then
      begin
         dYELLOW('Checking ... ');
         newline;
         checkok := false;
      end;
      
      if not ok_name(name) then
         exit;

      (* get upload descriptions if possible *)
      if pro_mode = RX then
      begin
         get_description;
         if desc = '' then
            exit;                 {cancel upload on blank descrip}

         cons_path(name,cnf.playpen_dir,name);
         inc(transfer.count);
         savestr(transfer.entry[transfer.count], name);
         savestr(descr.entry[transfer.count], desc);
      end;

   end;

   
(* ----------------------------------------------------------- *)
begin
   (* no names needed if there is no protocol selection *)
   if protocol < 1 then
      exit;

   initiate_selection;
   if protocol < 1 then    {in case of insufficient upload space}
      exit;

   (* prompt for each filename in the transfer *)
   repeat
      if cmdline = '' then
         prompt_for_selection;

      process_selection;

{writeln('transfer.count=',transfer.count,' scount=',scount,' profiles=',pro_files,' name=',name);}
   until (transfer.count >= scount) or (name[1] = '.') or dump_user;

   (* cancel transfer if no names provided, but some were needed *)
   if needname and (transfer.count = 0) then
      protocol := 0;
end;

