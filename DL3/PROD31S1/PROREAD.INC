
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
 * PCB ProDOOR read message module (3-1-89)
 *
 *)


(* ----------------------------------------------------------- *)
procedure protect_message;
   {set the message to receiver-only}
begin
   header.StatusCode := '*';
   save_message_header;
end;


(* ----------------------------------------------------------- *)
procedure unprotect_message;
   {set the message to public}
begin
   header.StatusCode := ' ';
   fill_chars(header.Password, '', sizeof(header.Password));
   save_message_header;
end;


(* ---------------------------------------------------------- *)
procedure invert_index;
   {changes sign of index pointer!}
var
   ix:          word;
   ixrec:       single;
begin
   ix := curmsg - basemsg;
   bseek(ixfd,ix);
   bread(ixfd,ixrec);
   ltos(-stol(ixrec),ixrec);
   bseek(ixfd,ix);
   bwrite(ixfd,ixrec);
   bflush(mbfd);
end;


(* ---------------------------------------------------------- *)
procedure kill_message;
   {delete a message}
begin
   if (not kill_allowed) or (not verify_level('K')) then exit;

   invert_index;
   header.status := dead_msg; {set delete flag}
   save_message_header;
   par5 := curmsg;
   make_log_entry('Message Killed: @INCONF@ # $5W$',true);
   load_message(false);
end;


(* ---------------------------------------------------------- *)
procedure unkill_message;
   {undelete a killed message, if possible}
var
   n:       word;
   
begin
   if cmdline = '' then
      get_defen('Message number to UnKill:');

   get_nextpar;
   n := atow(par);
   if (n < basemsg) or (n > lastmsg) then exit;
   
   curmsg := n;
   load_message(true);
   if (msgpos = no_msg) or (header.status <> dead_msg) then
      exit;
      
   {clear delete flag}
   invert_index;
   header.status := live_msg;
   save_message_header;
   
   par5 := curmsg;
   make_log_entry('Message UnKilled: @INCONF@ # $5W$',true);
end;


(* ---------------------------------------------------------- *)
procedure prepare_default(autojoin: boolean);
   (* determine the default for current conditions and set 'par' to this value *)
var
   nextmsg: word;
   
begin
   if autojoin and (nextjoin <> '') then
      par := nextjoin
   else
   
   if (prevcmd[1] = 'T') or (prevcmd[1] = 'Y') then
      par := prevcmd + direction
   else
   
   begin
{     if curmsg < basemsg then
         curmsg := basemsg-1; }
      nextmsg := curmsg;
      
      if direction = '-' then
         if nextmsg > 0 then
            dec(nextmsg)
         else
      else
         inc(nextmsg);

      par := wtoa(nextmsg) + direction;
   end;

end;


(* ---------------------------------------------------------- *)
procedure default_input(autojoin: boolean; prompt,def: string80);
var
   defalt: anystring;

begin
   prepare_default(autojoin);
   defalt := par;
   par4 := defalt;
   prompt_def(prompt, def+'(Enter)=''$4$''? ');

   get_xcmd('PROMAIL.XLT');
   {get_hcmdline;} {command('CDEGJKMNOPQRSUYZ');}
   {select non-stop mode?}
   if cmdline = 'NS' then
   begin
      linenum := -30000;
      cmdline := '';
   end;

   non_stop := linenum < 0;

   {use default if no input is provided}
   if (cmdline = '') or (cmdline[1] = ' ') then
      cmdline := defalt;
      
   nextjoin := '';
end;


(* ----------------------------------------------------------- *)
procedure prepare_autojoin;
var
   n:       integer;
   c:       char;
   pconf:   integer;

begin
   if not conf_info.conf_private_mail then
      set_lastread;
   
   close_conference;
   pconf := pcbsys.curconf;
   n := pcbsys.curconf+1;
   newmsgs := 0;

   while (n <= conf_count) and (newmsgs = 0) and (nomore = false) do
   begin
      disp(CYAN);
      if getflag(extuser.conf[n].flags,ext_scan) and select_conference(n) then
      begin
         par5 := newmsgs;
         pdispln('@INCONF@ has $5W$ new messages.');
      end;
      inc(n);
   end;

   if (newmsgs > 0) then
      nextjoin := 'J '+conf_info.conf_name
   else
      nextjoin := 'QUIT';     {no more messages in any conference}
   
   if select_conference(pconf) then
      open_conference;

   curmsg := priormsg+1;
   load_message(false);
end;


(* ----------------------------------------------------------- *)
procedure display_current_message;
   {load 'curmsg' and display it}
begin
   {find position in file and read the message}
   load_message(false);

   {check for ^K key}
   if linenum >= 2000 then
   begin
      linenum := 0;
      newline;
      {displn('Aborted!');}
      search_key := '';
      prevcmd := 'R';
      cmdline := '';
      exit;
   end;

   {display message and read it}
   if msgpos <> no_msg then
   begin
      display_loaded_message;
      exit;
   end;

   {no message found - either terminate search or perform autojoin}
   newline;
   linenum := 1;  {cancel non-stop}
      
   if search_key <> '' then
   begin
(****************
      if priormsg = curmsg then
         displn('No more messages to search.')
      else
*****************)
         displn('Not found.');

      search_key := '';          {cancel search}
      prevcmd := 'R';
      curmsg := priormsg;
      load_message(false);
   end
   else
   
   begin
      par5 := basemsg;
      par6 := lastmsg;
      dMAGENTA('Active message numbers are $5W$-$6W$');
      displn('.');
      displn('Use (J +) or (J -) to change conferences.');
   
      if direction = '+' then    
         prepare_autojoin;       {find next conference}

      if curmsg > lastmsg then
         direction := '-'
      else
      if curmsg < basemsg then
         direction := '+';
   end;
end;


(* ---------------------------------------------------------- *)
procedure switch_conference;
   {switch conferences while in the message reader}
begin
   if not verify_level('J') then exit;  

   {leave current conference}
   close_conference;
   free_mail;

   {enter new conference}
   join_conference;

   {activate conference mail files}
   alloc_mail;
   open_conference;

   direction := '-';
   load_message(false);
   curmsg := stol(lastread^);
   direction := '+';
end;


(* ---------------------------------------------------------- *)
procedure search_next {(par: string2)};
begin
   if pprevcmd[1] <> par[1] then
      priormsg := curmsg;

   if locate_next_personal then
      display_current_message
   else
      newline;
end;


(* ---------------------------------------------------------- *)
function copy_message: boolean;   {returns true if successful}
   {copy current message to a different conference}
var
   n:     integer;
   pconf: integer;
   pmsg:  word;

begin
   copy_message := false;

   load_message(false);
   if msgpos = no_msg then
      exit;

   if cmdline = '' then
      get_defn('Copy this message to what conference:','(M)ain, ');

   get_nextpar;
   if (par = '') or dump_user then exit;
   n := lookup_conference_number(par);
   if (n < 0) then exit;

   {leave current conference}
   newline;
   pconf := pcbsys.curconf;
   pmsg := curmsg;
   close_conference;

   {enter the destination conference}
   if select_conference(n) then
   begin
      {copy the message to end of current conference}
      zeros(header.ReferTo);
      open_conference;
      save_message(duplicate_message);
      close_conference;
      copy_message := true;
   end;

   {return to original context}
   if select_conference(pconf) then
      open_conference;

   curmsg := pmsg;
   load_message(false);
end;


(* ----------------------------------------------------------- *)
procedure set_since;
begin
   curmsg := stol(lastread^);
   if curmsg > lastmsg then
   begin
      ltos(lastmsg,lastread^);
      curmsg := lastmsg;
   end;
end;


(* ----------------------------------------------------------- *)
procedure decode_msgnum;
   (* decodes message number specifications, handles default direction,
      sets par='/' is message display is called for; otherwise
      leaves par unchanged *)
var
   par1:       char;
   explicit:   boolean;
   
begin

   {change current direction}
   case par[length(par)] of
      '+','*': 
           begin
              direction := '+';
              dec(par[0]);
              explicit := true;
           end;

      '-': begin
              direction := '-';
              dec(par[0]);
              explicit := true;
           end;
   
      else explicit := false;
   end;

   {use default direction when in non-stop mode}
   if par = '' then
      par[1] := direction;
        
   {process the cmdline}
   par1 := '/';
   case par[1] of

      '+','-': begin
                  direction := par[1];
                  advance;
               end;

      '0'..'9':
               begin
                  curmsg := atow(par);
                  if not explicit then
                     if curmsg >= lastmsg then
                        direction := '-';
               end;

      'R':     if par[2] = 'M' then
                  curmsg := memorymsg
               else
                  par1 := par[1];
               
      'S':     if par[2] = 'C' then
                  par1 := par[1]
               else
                  set_since;
               
      else     par1 := par[1];
   end;

   par[1] := par1;

end;


(* ---------------------------------------------------------- *)
procedure zip_search;
begin

   if search_key <> '' then
   begin
      search_key := '';
      exit;
   end;
   
   if cmdline = '' then
      get_defen('Search keyword:');
   if cmdline = '' then
      exit;
         
   search_key := cmdline;
   delete_trailing_spaces(search_key);
   stoupper(search_key);
   priormsg := curmsg;
   zip_active := true;
   
   prevcmd := 'Z';
   default_input(false,'Zip scan from:','(+/-)(NS), ');
   get_nextpar;

   decode_msgnum;
   display_current_message;
end;


(* ---------------------------------------------------------- *)
procedure quick_scan;
   {quick message summary}
var
   pmsg:    word;
   pdirec:  char;
   subj:    string30;
   first:   string;
   extend:  boolean;
   i:       integer;
   yours:   boolean;
   alls:    boolean;

begin
   if not verify_level('Q') then exit;  

   extend := par[2] <> 'Q';
   pmsg := curmsg;
   pdirec := direction;
   yours := false;
   alls := false;

   if cmdline = '' then
      default_input(false,'Quick scan from:','(+/-)(NS), (Y)our, (YA)ll, ');

   {detect trailing + or - and set direction and msgnum}
   get_nextpar;

   case par[1] of
      'Q':  begin
               cmdline := 'QU'; {displn('Use QU for quit!');}
               exit;
            end;

      'Y':  begin
               yours := true;
               alls := par[2] = 'A';
            end;
   else
      decode_msgnum;
   end;
      
   newline;
   dWHITE('Msg#   Ref#     Date  To              From            Subject');

   repeat
      load_message(false);
   
      if (msgpos <> no_msg) and
         (tomep or frommep or (not yours) or (toallp and alls)) then
      begin
         subj := header.Subject;
         delete_trailing_spaces(subj);

         newline;
         if nomore = false then
         begin
            dMAGENTA(ljust(stoa(header.Number),7));
            if stol(header.ReferTo) = 0 then
               spaces(6)
            else
               dRED (ljust(stoa(header.ReferTo),6));
            dWHITE(header.StatusCode);
            dispc(header.HasReplys);

            space;
            dCYAN   (copy(header.Date,   1, 5)); space;
            dYELLOW (copy(header.WhoTo,  1,15)); space;
            dGREEN  (copy(header.WhoFrom,1,15)); space;
            dGRAY   (subj);

            if extend then
            begin
               first := block^[1].body;
               prepare_line(first);
               first[0] := #79;
               for i := 1 to 79 do
                  if first[i] = endline then
                     first[i] := '/';
               newline;
               default_color;
               if nomore = false then
                  displn(first);
            end;
         end;
      end;

      advance;
   until (msgpos = no_msg) or nomore;

   cmdline := '';
   linenum := 1;  {cancel non-stop}
   newline;

   curmsg := pmsg;
   direction := pdirec;
   load_message(false);
end;


(* ----------------------------------------------------------- *)
procedure direct_reply;
begin
   while true do
   begin
      if cmdline = '' then
         get_defen('Reply to Message:');

      get_nextpar;
      if dump_user or (par = '') then
         exit;

      decode_msgnum;
      load_message(false);
      enter_message(reply_message);
   end;
end;


(* ----------------------------------------------------------- *)
procedure find_userinfo;
begin
   if (not sysopfun_allowed) or (pcbsys.usernum > 1) then exit;
                     
   if (header.WhoFrom = sysop25) or frommep then
      get_user_info(fromUser,header.WhoTo)
   else
      get_user_info(fromUser,header.WhoFrom);

   if fromUser.name[1] = ' ' then
      exit;

   newline;
   displn(fromUser.name+'  '+fromUser.city+
          '  PW='+FromUser.passwd+
          '  E/D='+FromUser.expdate);

   displn('D='+FromUser.busphone+
          '  V='+FromUser.phone+
          '  LD='+expdate(FromUser.date)+
          '  TO='+itoa(FromUser.total_calls));

   displn('Sec='+itoa(FromUser.level)+
          '  UP='+itoa(FromUser.uploads)+'/'+ dtok(FromUser.uptotal)+
          'k  DN='+itoa(FromUser.downloads)+'/'+ dtok(FromUser.downtotal)+'k');

   displn('C1='+FromUser.usercomment+'  C2='+FromUser.sysopcomment);

   newline;
   get_int('New security level:',FromUser.level);

   put_user_rec(fromUser,user_ix.urec);
end;


(* ----------------------------------------------------------- *)
procedure mail_command;
begin
   {use default command in non-stop mode}
   if non_stop and (linenum < 0) then
   begin
      prepare_default(true);
      cmdline := par;
      exit;
   end;

   non_stop := false;
   if nomore=false then
      newline;
   if not expert then
      display_file(mail_menu_file);
   par3 := search_key;
   if search_key <> '' then
      pdispln('Zip search for ($3$), (Enter)=Continue search, (Z)=Quit search.');

   display_time(false);
   default_input(true,'[@INCONF@] Mail Command:','');
end;


(* ---------------------------------------------------------- *)
procedure displayz;
begin
   if cmdline = '' then
      display_current_message;
end;


(* ----------------------------------------------------------- *)
procedure move_message;
begin
   if copy_message then
      kill_message;
   displayz;
end;


(* ----------------------------------------------------------- *)
procedure read_messages;
begin
   if not verify_level('R') then exit;

   lookup_info := environment_on('CITY');
   prevcmd := 'R';
   nextjoin := '';
   search_key := '';
   cap_count := 0;

   direction := '-';
   load_message(false);
   curmsg := stol(lastread^);
   direction := '+';

   repeat
      set_function('R');
      set_node_status(pcbsys.nodechat);   {unavailable for chat - stub}

      {ask for input when needed}
      if cmdline = '' then
         mail_command;

      {detect trailing + or - and set direction and msgnum}
      get_nextpar;
      decode_msgnum;

      pprevcmd := prevcmd;
      prevcmd := par;
{writeln('par=[',par,']');}

      {process the cmdline}
      case par[1] of

{public commands}
         'A':     begin
                     par := '0';
                     unget_par;
                     switch_conference;
                  end;
                  
         'E':     if (par[2] = 'D') and sysopfun_allowed then
                     edit_header
                  else
                     enter_message(new_message);

         'H':     hotkey_toggle;

         'J':     switch_conference;

         'K':     begin
                     kill_message;
                     displayz;
                     prevcmd := pprevcmd;
                  end;

         'L':     ltos(curmsg,lastread^);
         
         'N':     if par[2] = 'O' then
                     node_chat
                  else
                     exit;

         'Q':     if par[2] = 'U' then
                     exit
                  else
                     quick_scan;

         'R':     if par[2] = 'E' then
                  begin
                     if par[3] = 'P' then
                        direct_reply
                     else
                        enter_message(reply_message);
                     prevcmd := pprevcmd;
                  end
                  else

                  if par[2] = 'O' then
                  begin
                     enter_message(reply_originator);
                     prevcmd := pprevcmd;
                  end
                  else

                  if par[2] = 'R' then
                  begin
                     curmsg := stol(header.ReferTo);
                     display_current_message;
                  end
                  else

                  if (par[2] = 'U') {and sysopfun_allowed} then
                     snoop_toggle;

         'T':     if par[2] = 'S' then
                     zip_search
                  else
                     search_next{(par='T')};

         'X':     expert_toggle;
         
         'Y':     search_next {(par='Y' or 'YA')};

         'Z':     if par[2] = 'I' then
                  begin
{$IFNDEF IN_PROEDIT}
                     unget_par;
                     exit;           {let main menu handle this}
{$ENDIF}
                  end
                  else
                     zip_search;

         '/':     display_current_message; {redisplay}

{sysop commands}
         'C':     if (par[2] = 'O') and sysopfun_allowed then
                  begin                   {copy}
                     if copy_message then;
                     prevcmd := pprevcmd;
                  end
                  else                    {chat}
                  if par[2] = 'H' then
                     node_chat
                  else
                     enter_message(comment_message);

         'F':     find_userinfo;

         'M':     if par[2] = 'G' then
                     mode_toggle
                  else
                  if (par[2] = 'O') and sysopfun_allowed then
                     if par[3] = 'V' then
                     begin
                        move_message;
                        prevcmd := pprevcmd;
                     end
                     else
                        edit_message
                  else
                     memorymsg := curmsg;
         
         'P':     if sysopfun_allowed then
                  begin
                     protect_message;
                     displayz;
                     prevcmd := pprevcmd;
                  end;
                    
         'S':     if par[2] = 'C' then
                     scan_toggle;

         'U':     if sysopfun_allowed then
                  begin
                     if par[3] = 'K' then
                        unkill_message
                     else
                     begin
                        unprotect_message;
                        displayz;
                        prevcmd := pprevcmd;
                     end;
                  end;

{main menu commands}
{$IFDEF IN_PROEDIT}
         'G':     exit;
{$ELSE}
         'B','D','G','O','V':
                  begin
                     unget_par;
                     exit;
                  end;
{$ENDIF}
                     
         '?':     display_file(mail_help_file);

         else     not_understood;
      end;

   until dump_user;
end;


