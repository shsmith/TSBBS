
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
 * PCB ProDOOR enter message module for ProMail unit (3-1-89)
 *
 *)


procedure put_msgtext(s: string80);
begin
   move(s[1], raw^[maxpos+1], length(s));
   inc(maxpos,length(s));
end;
procedure put_msgc(c: char);
begin
   put_msgtext(c);
end;
procedure put_endline;
begin
   put_msgc(endline);
end;
procedure put_msgspace;
begin
   put_msgc(' ');
end;

(* ---------------------------------------------------------- *)
procedure save_text(mode: message_entry_modes);
   {convert the text into PCBoard's block format and write it to the file}
var
   i:         integer;

begin
   {convert the lines into a block of bytes}
   maxpos := 0;
   for i := 1 to linecnt do
   begin
      if (not substitute) and (mode <> duplicate_message) then
         remove_variables(lines^[i]);
      put_msgtext(lines^[i]);
      put_endline;
   end;

   if (not environment_on('NOVIA')) and (mode <> duplicate_message) then
   begin
      put_msgtext('---');
      put_endline;
      put_msgtext(' * Via ');
      put_msgtext(progname);
      put_msgspace;
      put_msgtext(version_number);
      if _REG_ then
         put_msgc('R');
      put_msgspace;
      put_msgtext(GetEnv('TAGLINE'));
      put_endline;
   end;
   
   while (maxpos and 127) <> 0 do
      put_msgspace;

   txtblocks := maxpos div 128;
   header.blocks := txtblocks+1;

   bseekeof(mbfd);
   msgpos := btell(mbfd);
   bwrite(mbfd,header);
   for i := 1 to txtblocks do
      bwrite(mbfd,block^[i]);
end;


(* ---------------------------------------------------------- *)
procedure save_index;
var
   ixrec:       single;
begin
   ltos(msgpos+1,ixrec);
   bseek(ixfd,lastmsg - basemsg);
   bwrite(ixfd,ixrec);
end;


(* ---------------------------------------------------------- *)
procedure lock_msgfile;
   {lock the message file and grab a new message number}
var 
   trys:    integer;

begin
   trys := 0;

   while true do
   begin
      reopen_messagebase;
      bseek(mbfd,0);
      bread(mbfd,mheader);
      lastmsg := stol(mheader.himsg);
      basemsg := stol(mheader.lowmsg);

      if (mheader.lockflag[1] = ' ') or
         (trys = pcbsetup.network_timeout) then
      begin
         mheader.lockflag := 'LOCKED';
         inc(lastmsg);
         ltos(lastmsg,mheader.himsg);
         ltos(lastmsg,header.number);
         incs(mheader.msgcnt,1);

         if basemsg = 0 then
            basemsg := lastmsg;
         ltos(basemsg,mheader.lowmsg);

         bseek(mbfd,0);
         bwrite(mbfd,mheader);
         exit;
      end;

      displn('Network Delay - Message File Busy');
      delay(2000);
      inc(trys);
   end;

end;


(* ---------------------------------------------------------- *)
procedure unlock_msgfile;
begin
   mheader.lockflag := '      ';
   bseek(mbfd,0);
   bwrite(mbfd,mheader);
   reopen_messagebase;
end;


(* ---------------------------------------------------------- *)
procedure save_message(mode: message_entry_modes);
begin
   if (linecnt = 1) and (length(lines^[1]) = 0) then
      exit;

   lock_msgfile;

   if mode = comment_message then
      par := 'Comment Left: '
   else
   if mode = duplicate_message then
      par := 'Message Copy: '
   else
      par := 'Message Left: ';
   par5 := lastmsg;
   make_log_entry(par+'@INCONF@ # $5W$',true);

   save_text(mode);
   save_index;

   unlock_msgfile;


   {flag the receivers user record so he will be notified when
    he enters the door again}
   get_user_info(fromUser,WhoTo);
   if fromUser.name[1] <> ' ' then
   begin
      setflag(FromUser.flags,flag_hasmail,true);
      fromUser.mailconf := pcbsys.curconf;
      put_user_rec(fromUser,user_ix.urec);
   end;


   {set the 'has replys' flag of the original message}
   if (mode = reply_message) or (mode = reply_originator) then
   begin
      load_message(false);
      if (msgpos <> no_msg) then
      begin
         header.HasReplys := 'R';
         save_message_header;
      end;
   end;

end;


(* ---------------------------------------------------------- *)
procedure enter_header(mode: message_entry_modes);
begin

(* determine who the message is addressed to and provide the default subject *)
   zeros(header.ReferTo);
   header.HasReplys := ' ';

   newline;
   disp_margin(23,sizeof(whoto));
   no_hotkeys;

   if (mode = reply_message) or (mode = reply_originator) then
   begin
      header.ReferTo := header.Number;
      if mode = reply_message then
         header.WhoTo := header.WhoFrom;
      disp('                   To:  ');
      displn(header.WhoTo);
      cmdline := header.Subject;    {default to original subject}
   end
   else

   if mode = comment_message then
   begin
      header.WhoTo := sysop25;
      displn('                   To:  SYSOP');
      cmdline := '';    {no default subject}
   end
   else

   begin
      get_def('     To:','(Enter)=''ALL''? ');
      if cmdline = '' then
         cmdline := 'ALL';

      fill_chars(header.WhoTo, cmdline, sizeof(header.WhoTo));
      cmdline := '';    {no default subject}
   end;


(* convert @user@ to ALL if not sysop *)
   if (header.WhoTo[1] = '@') and (userlevel < 100) then
      header.WhoTo := all25;


(* verify that destination user record exists;
   flag waiting mail if it does *)

   get_user_info(fromUser,header.WhoTo);
   if (header.WhoTo <> all25) and
      (header.WhoTo[1] <> '@') and
      (fromUser.name[1] = ' ') then
   begin
      if (mode <> reply_message) and (mode <> reply_originator) and
         (pcbsetup.validate_to) then
         begin
            beep;
            displn('Warning: Name not found in USERS file!');
         end;
   end;

   header.WhoFrom := pcbsys.name;


(* enter the subject - cmdline is already set to default *)

   delete_trailing_spaces(cmdline);
   prompt_def('Subject:','(Blank)=abort? ');
   line_input(cmdline,sizeof(header.Subject),true,true);
   newline;
   if cmdline[1] >= 'a' then
      stoupper(cmdline);
   remove_variables(cmdline);
      
   fill_chars(header.Subject,cmdline,sizeof(header.Subject));
   Subject := header.Subject;
   if length(cmdline) = 0 then
      exit;


(* determine message security *)

   fill_chars(header.Password, '', sizeof(header.Password));
   header.StatusCode := ' ';

   if (conf_info.conf_private_mail) or
      (mode = comment_message) then
      cmdline[1] := 'R'
   else
   
   if header.WhoTo = all25 then
      cmdline[1] := ' '
   else   
      get_defnh('             Security:?','(R)eceiver only, ');
   
   if cmdline[1] = 'R' then
   begin
      if (mode <> comment_message) and (not verify_level(fun_private)) then
      begin
         header.Subject[1] := ' ';
         exit;
      end;

      if (mode = comment_message) then
         header.StatusCode := '~'
      else
         header.StatusCode := '*';
   end;

   header.EchoFlag := ' ';
   if conf_info.conf_echo_mail then
   begin
      get_defyn('Echo to Other Systems:?',true);
      if par[1] <> 'N' then
         header.EchoFlag := 'E';
   end;

(* fill in the remaining fields *)

   zeros(header.number);
   fillchar(header.filler,sizeof(header.filler),' ');
   fill_chars(header.Date, system_date, sizeof(header.Date));
   fill_chars(header.Time, system_time, sizeof(header.Time));
   header.status := live_msg;
   WhoTo := header.WhoTo;
end;


(* ---------------------------------------------------------- *)
procedure show_margins;
   {display the standard margin ruler line}
begin
   disp_margin(3,msgmaxlen);
end;


(* ---------------------------------------------------------- *)
procedure show_line_number(n: integer);
begin
   if n < 10 then
      space;
   dCYAN(itoa(n)+': ');
end;


(* ---------------------------------------------------------- *)
procedure continue_entry;
   {append lines}
var
   i: integer;
   buf: anystring;

begin
   show_margins;

   {backup if current line is blank}
   buf := lines^[linecnt];

   {process each line allowed, leave room for signature lines}
   while (linecnt <= pcbsetup.msg_lines) do
   begin
      show_line_number(linecnt);
      no_hotkeys;
      line_input(buf,73,true,true);

      {end of entry?}
      if ((not alt_i) and (length(buf) = 0)) or dump_user then
      begin
         lines^[linecnt] := '';
         newline;
         exit;
      end;

      {need to wordwrap?  delete partial word and start it on the next line}
      prepare_word_wrap(buf,i,msgmaxlen);

      {move the partial word to the start of the next line}
      lines^[linecnt] := copy(buf,1,i-1);
      buf := copy(buf,i+1,msgmaxlen);

      inc(linecnt);
      lines^[linecnt] := '';
   end;
end;


(* ---------------------------------------------------------- *)
procedure edit_line;
   {edit a single line}
var
   n:      byte;
   p:      integer;
   oldstr: anystring;
   newstr: anystring;

begin
   n := linecnt;
   get_int('Edit Line number:',n);
   if (n=0) or (n > linecnt) or dump_user then exit;

   repeat
      newline;
      show_margins;
      show_line_number(n);
      default_color;
      displn(lines^[n]);
      newline;

      prompt_def('Enter: ','(Old;New), (Enter)=''No change''');
      newline;
      disp('? ');
      oldstr := '';
      newstr := '';

      line_input(oldstr,msgmaxlen,true,true);
      newline;
      if dump_user or (length(oldstr) = 0) then exit;

      p := posc(';',oldstr);
      if p > 0 then
      begin
         newstr := copy(oldstr,p+1,99);
         oldstr := copy(oldstr,1,p-1);

         p := pos(oldstr,lines^[n]);
         if p > 0 then
            lines^[n] := copy(lines^[n], 1,p-1) + newstr +
                         copy(lines^[n], p+length(oldstr),99);
      end;

   until true=false;
end;


(* ----------------------------------------------------------- *)
procedure insert_line(contents: string);
   {open a new line at the cursor}
var
   i: integer;
begin
   for i := pcbsetup.msg_lines downto cline+1 do
      lines^[i] := lines^[i-1];
   lines^[cline] := contents;

   if cline < linecnt then
      inc(linecnt);
   if cline > linecnt then
      linecnt := cline;
end;


(* ---------------------------------------------------------- *)
procedure insert_text;
   {insert a line}
var
   n: byte;

begin
   n := 0;
   get_int('Insert before Line number:',n);
   if (n=0) or (n > linecnt) or dump_user then exit;

   newline;
   show_margins;
   show_line_number(n);
   par := '';
   line_input(par,msgmaxlen,true,true);
   newline;

   inc(linecnt);
   cline := n;
   insert_line(par);
end;


(* ----------------------------------------------------------- *)
procedure delete_line;
   {delete the line at the cursor}
var
   i: integer;
begin
   for i := cline to pcbsetup.msg_lines do
      lines^[i] := lines^[i+1];
   lines^[pcbsetup.msg_lines] := '';

   if (cline <= linecnt) and (linecnt > 1) then
      dec(linecnt);
end;


(* ---------------------------------------------------------- *)
procedure delete_text;
   {delete a line}
var
   n,i: byte;

begin
   n := 0;
   get_int('Delete Line number:',n);
   if (n=0) or (n > linecnt) or dump_user then exit;

   show_line_number(n);
   default_color;
   displn(lines^[n]);
   newline;
   cmdline[1] := 'N';
   get_defyn('Delete this line:',false);
   if par[1] <> 'Y' then exit;

   displn('Deleted.');
   cline := n;
   delete_line;
end;


(* ----------------------------------------------------------- *)
procedure quote_from_original;
var
   fline:   byte;
   lline:   byte;
   nline:   byte;
   i:       integer;

begin
   if have_city then
      fline := 8
   else
      fline := 7;
   get_int('Starting line number for quote:',fline);
   if (fline=0) or (fline > 110) or dump_user then exit;

   lline := fline+1;
   get_int('Ending line number:',lline);
   if (lline < fline) or (lline > 110) then exit;

   nline := lline-fline+1;

   openfile(mailfile);
   if not ok then
      exit;

   {find the first line to quote}
   while (not endfile) and (fline > 1) do
   begin
      dec(fline);
      getaline(par,msgmaxlen);
   end;

   {move cursor if in the middle of a line}
   if length(lines^[cline]) > 0 then
   begin
      inc(cline);
      insert_line('');
   end;

   {quote the specified number or lines}
   while (not endfile) and (nline > 0) and (cline < pcbsetup.msg_lines) do
   begin
      dec(nline);
      getaline(par,msgmaxlen); {truncates at 71}
      if posc('>',par) < 4 then
         par := '>' + par;
      insert_line(par);
      inc(cline);
   end;

   closefile;
end;


(* ----------------------------------------------------------- *)
procedure display_original;
begin
   display_file_raw(mailfile,number_lines);

   newline;
(***
   get_defyn('Quote from the original message:',false);
   if par[1] = 'Y' then
      quote_from_original;
****)

   quote_from_original;
end;


(* ---------------------------------------------------------- *)
procedure list_message;
   {list all text lines in the current message - edit mode}
var
   i: integer;
begin
   newline;
   decode_status;
   display_header;
   newline;
   show_margins;

   for i := 1 to linecnt do
   if nomore = false then
   begin
      show_line_number(i);
      if (not substitute) then
         remove_variables(lines^[i]);
      dGRAY(lines^[i]);
      newline;
   end;
end;


(* ---------------------------------------------------------- *)
procedure count_lines;
   {count the active lines in the message; set linecnt}
begin
   linecnt := pcbsetup.msg_lines;
   while (linecnt > 1) and (length(lines^[linecnt]) = 0) do
      dec(linecnt);
end;


(* ---------------------------------------------------------- *)
procedure enter_message(mode: message_entry_modes);

var
   i: integer;
label
   save, leave;

begin
   set_node_status('E');   {entering a message}

   {verify that message entry mode is allowed}
   case mode of
      reply_originator,
      reply_message:    par := fun_reply {+ ' REPLY'};
      comment_message:  par := 'C';
      else              par := 'E';
   end;

   if not verify_level(par[1]) then exit;


   {capture current message for 'original/quote' functions}
   open_mail_capture;
   capture_current_message;
   close_mail_capture;
   have_city := fromUser.city[1] <> ' ';


   {initialize new message}
   enter_header(mode);
   if header.subject[1] = ' ' then
      goto leave;

   if pcbsetup.msg_lines > 97 then
      pcbsetup.msg_lines := 97;
   linecnt := 1;
   fillchar(lines^,sizeof(lines^),0);


   {initial text entry, default based on graphics mode}
   get_defyn('    Use Visual Editor:?',true{graphics});

   if par[1] <> 'N' then
      visual_edit
   else

   begin
      displn(GREEN);
      par5 := pcbsetup.msg_lines;
      pdispln('    Enter your text. (Enter) alone to end. (72 chars/line, $5W$ lines maximum)');
      continue_entry;
   end;


   {main editing command loop}
   repeat
      displn(YELLOW);
      displn('A)bort, C)ont, D)el, E)dit, I)ns, L)ist, O)rig, Q)uote, S)ave, V)isual');

      repeat
         dYELLOW('Message Entry Command? ');
         get_hcmdline; {command('');}
         get_nextpar;
      until length(par) > 0;

      newline;
      count_lines;
      cline := linecnt;

      if dump_user then
         if cline > 4 then
            goto save
         else
            goto leave;

      case par[1] of

         'A':  begin
                  get_defyn('Abort message entry:',false);
                  if par[1] = 'Y' then
                  begin
                     make_log_entry('Text entry aborted ...',true);
                     goto leave;
                  end;
               end;

         'C':  continue_entry;

         'D':  delete_text;

         'E':  edit_line;

         'I':  insert_text;

         'L':  list_message;

         'O':  display_original;

         'Q':  quote_from_original;

         'S':  goto save;

         'V':  visual_edit;

         '?':  display_file(enter_help_file);

         else not_understood;
      end;

   until true = false;

save:
   save_message(mode);
leave:
   dos_unlink(mailfile);

end;

