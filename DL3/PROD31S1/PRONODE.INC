
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
 * PCB ProDOOR - node status display (3-1-89)
 *
 *)

procedure set_node_status(newcode: char);
var
   fd:   dos_handle;
   rec:  usernet_rec;
   n:    integer;
   node: integer;
const
   pcode: char = #0;

begin

{$IFNDEF IN_PROEDIT}
   if (not pcbsetup.under_network) or (pcode = newcode) then
      exit;

   pcode := newcode;
   node := atoi(pcbsetup.node_number^) - 1;
   fillchar(rec,sizeof(rec),' ');

   if dos_exists(pcbsetup.usernet_path^) then
      fd := dos_open(pcbsetup.usernet_path^,open_update)
   else
      fd := dos_create(pcbsetup.usernet_path^);
   if fd = dos_error then
      exit;

   {initialize entire file if needed}
   dos_lseek(fd,0,seek_end);
   n := dos_tell div sizeof(rec);
   while n < node do
   begin
      dos_write(fd,rec,sizeof(rec));
      inc(n);
   end;

   dos_rseek(fd,node,sizeof(rec),seek_start);
   n := dos_read (fd,rec,sizeof(rec));

   {initialize node record if needed}
   if (newcode = node_going_down) then
      fillchar(rec,sizeof(rec),' ')
   else

   if (rec.status[1] <> node_dropping_2dos) or
      (newcode = node_no_caller) then
   begin
      fillchar(rec,sizeof(rec),' ');
      fill_chars(rec.nodeno,pcbsetup.node_number^,sizeof(rec.nodeno));
      if newcode <> ' ' then
      begin
         rec.status[1] := newcode;
         rec.name := pcbsys.name;
         rec.city := user.city;
      end;
   end;

   dos_rseek(fd,node,sizeof(rec),seek_start);
   dos_write(fd,rec,sizeof(rec));
   dos_close(fd);
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure node_status_display;
var
   fd:   buffered_file;
   rec:  usernet_rec;
   node: integer;
   n:    integer;

const
   stat_msg:   array[303..314] of string20 = (
                  'No Caller this Node',
                  'Available for Chat',
                  'Out of Code in Door',
                  'Auto Logoff Pending',
                  'Chat Request Sent',
                  'Unavailable for Chat',
                  'Transferring a File',
                  'Entering a Message',
                  'Chatting with Group',
                  'Drop to DOS Pending',
                  'Chatting with Node ',
                  'Waiting for Node');

begin
   bopen(fd,pcbsetup.usernet_path^,20,sizeof(rec));
   if berr then
      exit;

   newline;
   displn('Node          Status                     Caller');
   displn('----   ---------------------   -------------------------');

   bread(fd,rec);
   while not berr do
   begin

      if (rec.nodeno[1] <> ' ') and (nomore = false) then
      begin
         space;
         dRED(rec.nodeno);
         spaces(4);

         case rec.status[1] of
            node_no_caller:      n := 303; {par := 'No Caller this Node';}
            node_available:      n := 304; {par := 'Available for Chat';}
            node_in_door:        n := 305; {par := 'Out of Code in Door';}
            node_logoff_pending: n := 306; {par := 'Auto Logoff Pending';}
            node_chat_request:   n := 307; {par := 'Chat Request Sent';}
            node_unavailable:    n := 308; {par := 'Unavailable for Chat';}
            node_transfer:       n := 309; {par := 'Transferring a File';}
            node_entering_msg:   n := 310; {par := 'Entering a Message';}
            node_group_chat:     n := 311; {par := 'Chatting with Group';}
            node_dropping_2dos:  n := 312; {par := 'Drop to DOS Pending';}
          { '0'..'9':            n := 314;  par := 'Waiting for Node';}
            else                 n := 313; {par := 'Chatting'  with Node '+rec.status;}
         end;

         dGREEN(ljust(stat_msg[n]{get_pcbtext(n)}{par},21));
         spaces(3);

         par := rec.name;
         delete_trailing_spaces(par);
         dCYAN(par);

         par := rec.city;
         delete_trailing_spaces(par);
         if par[1] <> ' ' then
            disp(' - '+par);

         clear_eol;
         newline;
      end;

      bread(fd,rec);
   end;

   bclose(fd);
end;


(* ------------------------------------------------------------ *)
procedure node_chat;
begin
   if not verify_level(fun_nodechat) then exit;

   (* verify that there is a library definition file *)
   if not pcbsetup.under_network  then
   begin
      not_available;
      exit;
   end;

   node_status_display;
   wait_for_enter;

   {stubbed}
end;


(* ------------------------------------------------------------ *)
procedure check_chat_request;
var
   fd:      buffered_file;
   rec:     usernet_rec;
   n:       integer;
   cnode:   integer;
   name:    anystring;
   ctime:   longint;

const
   ptime:   longint = 0;

begin

{$IFNDEF IN_PROEDIT}
   if (not pcbsetup.under_network) or (not chat_poll) then exit;

   {see if it's time to check again}
   ctime := lget_time;
   if ctime < ptime then
      inc(ctime,86400);
   if ctime < ptime+pcbsetup.chat_delay then
      exit;
   ptime := ctime;

   bopen(fd,pcbsetup.usernet_path^,20,sizeof(rec));
   if berr then
      exit;

   {disp('%'^H);}
   cnode := atoi(pcbsetup.node_number^);

   bread(fd,rec);
   while not berr do
   begin
      if (rec.nodeno[1] <> ' ') and
         (cnode = atoi(rec.status)) then
      begin
         name := rec.name;
         delete_trailing_spaces(name);

         erase_prompt(0);
         {newline;}
         par3 := name;
         par5 := btell(fd);
         dRED('($3$) on node ($5W$) wants to CHAT with you!');
         beep;
         newline;
         display_file(chat_request_file);

         chat_poll := false;  {only print message once}
         force_new_prompt;
      end;

      bread(fd,rec);
   end;

   bclose(fd);
   {disp(' '^H);}

{$ENDIF}

end;

                   
