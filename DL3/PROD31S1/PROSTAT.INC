
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
 * PCB ProDOOR conference status display (3-1-89)
 *
 *)

procedure tally_conference;
var
   last:    single;

begin
   last := lastread^;      {don't change master lastread pointer}
   lastread := @last;
   newmsgs := 0;
   yourmsgs := 0;
   direction := '+';

   while (not dump_user) and (linenum < 2000) do
   begin
{writeln('curmsg=',curmsg);}
      advance;
      check_message(false);
      if msgpos = no_msg then
         exit;

      if message_allowed then
      begin
         if tomep then
            inc(yourmsgs);
         inc(newmsgs);
{writeln('-- is # ',newmsgs,' tome=',tomep); }
      end;
   end;
end;


procedure display_conference_status(func: char);
   {display status of all conferences; optionally exclude those
    with no new messages in them}
var
   pconf:   integer;
   n:       integer;
   first:   integer;
   last:    word;
   scan:    boolean;

begin
   if not verify_level('J') then exit;

   get_nextpar;
   if length(par) = 0 then
      first := 0
   else
      first  := lookup_conference_number(par);
   if first < 0 then
      exit;

   default_color;
   newline;
   displn('Auto        Conference  Messages     New    Last Msg  High Msg   Active');
   displn('Scan  Num      Name      To You   Messages    Read     Number   Messages');
   displn('----  ---   ----------  --------  --------  --------  --------  --------');

   pconf := pcbsys.curconf;
   alloc_mail;

   for n := first to conf_count do
   if nomore=false then
   begin

      if select_conference(n) then
      begin
         inc(curmsg);   {because select_conf decs---??}
         last := curmsg;

         scan := getflag(extuser.conf[n].flags,ext_scan);
         if scan then
            dWHITE  (' Yes   ')
         else
            dMAGENTA('  No   ');

         dGREEN  (ljust(wtoa(pcbsys.curconf),5));
         disp    (ljust(conf_info.conf_name,14));

         if scan then
         begin
            open_conference;
            tally_conference;
            close_conference;
         end
         else
            yourmsgs := -1;

         if (func = 'S') or
            ((func = 'N') and (newmsgs > 0)) or
            ((func = 'Y') and (yourmsgs > 0)) then
         begin
            if yourmsgs = -1 then
               dBLUE('N/A       ')
            else
               dWHITE(ljust(itoa(yourmsgs),10));      {personal messages}

            dYELLOW (ljust(wtoa(newmsgs),10));        {new messages}
            dCYAN   (ljust(wtoa(last),10));           {last read}
            dRED    (ljust(wtoa(lastmsg),10));        {high message number}
            dMAGENTA(stoa(mheader.msgcnt));           {active messages}
            newline;
         end
         else
            disp(^M);
      end;
   end;
   
   free_mail;
   spaces(30);
   disp(^M);

   if select_conference(pconf) then ;
   wait_for_enter;
end;

