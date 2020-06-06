
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
 * PCB ProDOOR - protocol selection user interface (3-1-89)
 *
 *)

procedure get_protocol(modes: transfer_modes);
   (* select protocol based on code letter and transfer mode *)


   procedure list_protocols;
   var
      first: boolean;
      i:     integer;

   begin
      newline;
      first := true;

      for i := 1 to cnf.protocol_count do
      with cnf.protocol_table[i] do
         if mode = modes then
         begin
            if code = user.protocol then
               dRED(' => ')
            else
               spaces(4);
            dWHITE('('+code+') ');

            dCYAN(title^);
            if first then
               spaces(30-length(title^))
            else
               newline;

            first := not first;
         end;

      if not first then
         newline;
      newline;
   end;


   procedure scan_protocol_table;
         (* if entry is too long to be a protocol, assume it is a filename
            and use the user's default protocol instead *)
   var
      i:       integer;
      proto:   char;
   begin
   
      (* if first par is too long to be a protocol, assume it is a filename
         and use the user's default protocol instead *)
      get_nextpar;
      if length(par) > 1 then
      begin
         unget_par;
         par := user.protocol;
      end;

      proto := upcase(par[1]);
      for i := 1 to cnf.protocol_count do
         with cnf.protocol_table[i] do
            if (mode = modes) and (code = proto) then
            begin
               if efree and (pcbsys.errcheck[1] <> '-') then
                  displn('Error correcting modem required!')
               else
                  protocol := i;
            end;

      if proto = '?' then
         {handled elsewhere}
      else

      if protocol = aborted then
         not_available

      else
         user.protocol := proto;  {set default protocol to last-used!}
   end;


begin
   if modes = TX then
      par[1] := 'D'
   else
      par[1] := 'U';
   if not verify_level(par[1]) then
      exit;

   (* abort the transfer if daily download limit will be exceeded *)
   if (modes = TX) and (download_k_allowed <= 0) then
   begin
      make_log_entry('Sorry, you can''t download any more today.',true);
      wait_for_enter;
      exit;
   end;

   (* prevent uploads before an upcoming event *)
   if (modes = RX) and (pcbsetup.slide_event = false) and
      event_run_needed(event_possible) and (minutes_left < 120) then
   begin
      beep;
      par5 := minutes_before_event;
      if pcbsetup.event_noul then
      begin
         pdispln('A system event is scheduled in $5W$ minutes.');
         displn('Sysop has disabled uploads prior to a system event!');
         exit;
      end
      else
         pdispln('WARNING: Your upload will be ABORTED if not finished in $5W$ minutes!');
   end;

   (* repeat until a valid protocol has been selected *)
   repeat

      (* ask user for the protocol letter *)
      if cmdline = '' then
      begin
         list_protocols;
         hotkeys_active := true;
         get_def('Protocol:',enter_eq+user.protocol+'? ');
         if cmdline = '' then
            cmdline := user.protocol;
      end;

      (* search the table for the specified protocol *)
      scan_protocol_table;
   until (protocol <> aborted) or (par[1] = user.protocol) or dump_user;


   (* verify security for batch *)
   if (protocol <> aborted) and (pro_files <> 1) then
   begin
      par := '  BATCH';
      if modes = TX then
         par[1] := fun_batchdl
      else
         par[1] := fun_batchul;

      if not verify_level(par[1]) then
         protocol := aborted;
   end;
end;


