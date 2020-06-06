
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


(* ---------------------------------------------------------- *)
function sysopfun_allowed: boolean;
   {is user allowed to modify the current message? (sysop functions)}
begin
   sysopfun_allowed := (userlevel >= 100) and check_level(fun_unkill);
end;


(* ---------------------------------------------------------- *)
function message_allowed: boolean;
   {is user allowed to see the current message?}
begin
   message_allowed := (not privatep) or tomep or frommep or sysopfun_allowed;
end;


(* ---------------------------------------------------------- *)
function meets_criteria: boolean;
   {does the current message meet the search criteria?}
const
   click: integer = 0;
var
   i:     integer;

   function check(what: anystring): boolean;
   begin
      stoupper(what);
      if pos(search_key,what) > 0 then
      begin
         meets_criteria := true;
         check := true;
      end
      else
         check := false;
   end;

begin

   if (search_key = '') or nomore then
   begin
      meets_criteria := true;
      exit;
   end;

   if check(Subject)        then exit;
   if check(WhoTo)          then exit;
   if check(header.WhoFrom) then exit;

   for i := 1 to linecnt do
      if check(lines^[i]) then exit;

   meets_criteria := false;
   inc(click);
   if (click mod 4) = 0 then
      dGREEN('.');
end;


(* ---------------------------------------------------------- *)
procedure display_header;
   {display the message header}
var
   num:  string8;
   ref:  string8;
   dat:  string8;

begin
   if linenum >= 2000 then exit;

   dMAGENTA('Date: ');
   disp(header.Date);
   disp(' ('+header.Time+')   ');

   disp(rjust(conf_info.conf_name,10));
   disp(' Number: ');
   num := stoa(header.Number);
   if num[1] <> '0' then
      disp(num);
   if header.echoflag = 'E' then
      disp(' (Echo)');
   newline;

   dYELLOW('  To: '+WhoTo);

   ref := stoa(header.ReferTo);
   par3 := ref;
   if ref[1] <> '0' then
      pdisp('     Refer#: $3$');
   newline;

   dGREEN('From: ');
   disp(header.WhoFrom);

   disp('       Read: ');
   if readp then
   begin
      dat := stoa(header.ReadDate);
      if length(dat) < 6 then
         disp('YES')
      else
         disp(expdate(dat)+' ('+header.ReadTime+')');
   end
   else
      disp('NO');

   if header.HasReplys = 'R' then
      disp(' (Has Replies)');

   newline;

   if (num <> '0') and lookup_info then
   begin
      get_user_info(fromUser,header.WhoFrom);
      if fromUser.name[1] <> ' ' then
      begin
         dRED('City: ');
         disp(fromUser.city);
         disp('     Last On: ');
         disp(expdate(fromUser.date)+' ('+fromUser.time+')');
         newline;
      end;
   end
   else
      fillchar(fromUser,sizeof(fromUser),' ');

   dCYAN('Subj: '+Subject);

   if privatep then
      disp('     Status: RECEIVER ONLY')
   else
   if groupp then
      disp('     Status: GROUP PASSWORD');
   newline;

end;


(* ---------------------------------------------------------- *)
procedure display_text;
   {display text lines in the current message}
var
   i:    integer;
   m:    integer;
   line: anystring;
   str:  string80;
   pw:   string[12];
   pwc:  char12;

begin

   {verify group password if needed}
   if groupp and (not sysopfun_allowed) then
   begin
      if message_capture then exit;
      dYELLOW('Enter group password: ');

      pw := '';
      line_input(pw,12,false,false);
      newline;

      if pw = '' then
         exit;

      stoupper(pw);
      fill_chars(pwc,pw,sizeof(pwc));
      if pwc <> header.password then
         exit;
   end;
   
   {display actual message text}
   newline;

   for i := 1 to linecnt do
   if message_capture or (nomore = false) then
   begin

      line := lines^[i];
      {if substitute then}
         prepare_line(line);

      if search_key = '' then
         m := 0
      else
      begin
         str := line;
         stoupper(str);
         m := pos(search_key,str);
      end;

      if m = 0 then
      begin
         default_color;
         displn(line);
      end
      else
      begin
         dGRAY(copy(line,1,m-1));
         dRED(search_key);
         dGRAY(copy(line,m+length(search_key),80));
         newline;
      end;
   end;
end;


(* ----------------------------------------------------------- *)
procedure display_loaded_message;
begin
   newline;
   if not message_capture then
   begin

      if getflag(user.flags,flag_hotkeys) and (linenum > 0) then
      begin
         clear_screen;
         update_status_display(normal_format);
         linenum := 1;
      end;

      if tomep then beep;
   end;

   display_header;
   display_text;
   set_read_flag;
end;


(* ---------------------------------------------------------- *)
procedure get_text;
   {convert PCBoard's block format text into normal text lines}
var
   n:       integer;
const
   c:       char = '?';
   tline:   string80 = '';
   rawp:    integer = 0;

begin
   {convert them into lines of text}
   {fillchar(lines^,sizeof(lines^),0);}
   txtblocks := header.blocks-1;
   if (txtblocks <= 0) or (txtblocks > maxblocks) then
      txtblocks := 1;

   {convert them into lines of text}
   maxpos := txtblocks*blksiz;
   for n := 1 to txtblocks do
      bread(mbfd,block^[n]);
   linecnt := 0;
   tline := '';
   rawp := 1;

   while rawp <= maxpos do
   begin

      {grab next char from buffer}
(*************
      c := raw^[rawp];
      inc(rawp);

      while (rawp < maxpos) and (c <> endline) do
      begin
         if length(tline) < 80 then
            inc(tline[0]);
         tline[length(tline)] := c;

         {grab next char from buffer}
         c := raw^[rawp];
         inc(rawp);
      end;
***********)

Inline(
                         {;}
                         {; (C)1989 Samuel H. Smith; ALL RIGHTS RESERVED.}
                         {; GETTEXT.ASM - Part of GET_TEXT procedure in PROMAIL.INC}
                         {;}
  $8B/$0E/>maxpos/       {        mov cx,[>maxpos]        ;cx=maxpos}
  $8B/$36/>rawp/         {        mov si,[>rawp]          ;si=rawp}
  $C4/$1E/>raw/          {        les bx,[>raw]           ;es:bx=raw^}
  $30/$E4/               {        xor ah,ah}
  $A0/>tline/            {        mov al,[>tline]         ;di=length(tline)}
  $89/$C7/               {        mov di,ax}
  $26/                   {        es:}
  $8A/$40/$FF/           {        mov al,[si+bx-1]        ;c := raw[rawp]}
  $29/$F1/               {        sub cx,si               ;cx=remaining chars in buffer}
  $46/                   {        inc si                  ;rawp++}
  $E3/$15/               {        jcxz break              ;special case-- last char in buf}
                         {top:}
  $3C/<$e3/              {        cmp al,<$e3             ;end on endline}
  $74/$11/               {        jz break}
  $83/$FF/$50/           {        cmp di,80               ;line full?}
  $7D/$01/               {        jge linefull}
  $47/                   {        inc di                  }
                         {linefull:}
  $88/$85/>tline/        {        mov [di+>tline],al      ;line := line + c}
  $26/                   {        es:}
  $8A/$40/$FF/           {        mov al,[si+bx-1]        ;c := raw[rawp++]}
  $46/                   {        inc si}
  $E2/$EB/               {        loop top                ;continue until end of buffer}
                         {                                ;or endline is seen}
                         {break:}
  $A2/>c/                {        mov [>c],al             ;move registers back into ram}
  $89/$36/>rawp/         {        mov [>rawp],si}
  $89/$F8/               {        mov ax,di}
  $A2/>tline);           {        mov [>tline],al}


      {end of line seen - store the line}
      case c of
         endline:
            begin
               if linecnt < maxlines then
                  inc(linecnt);
               lines^[linecnt] := tline;
               tline := '';
            end;

         else
            begin
               {append the byte to the buffer (this hack goes faster than +c) }
               if length(tline) < 80 then
                  inc(tline[0]);
               tline[length(tline)] := c;
            end;
      end;
   end;
end;



(* ---------------------------------------------------------- *)
procedure load_message(killed: boolean);
   {locate proper message, read message header and text}
var
   n:       integer;

begin
   if (direction = '+') and (curmsg < basemsg) then
      curmsg := basemsg
   else
   if (direction = '-') and (curmsg > lastmsg) then 
      curmsg := lastmsg;

   while true do
   begin
      check_message(killed);
      if msgpos = no_msg then
         exit;

      if ((header.status = dead_msg) and not killed) then
      else

      if not message_allowed then
      else

      begin
         get_text;
         if linenum >= 2000 then
            exit;

         if meets_criteria then
         begin
            if not zip_active then
               search_key := '';
            exit;
         end;
      end;

      advance;
   end;
end;


(* ----------------------------------------------------------- *)
procedure save_message_header;
begin
   bseek(mbfd,msgpos);
   bwrite(mbfd,header);
   bflush(mbfd);
end;


(* ----------------------------------------------------------- *)
procedure set_lastread;
   {set the lastread pointer}
var
   ix: integer;
begin
   if curmsg > lastmsg then 
      curmsg := lastmsg;

   if update_user and (curmsg > stol(lastread^)) then
      ltos(curmsg, lastread^);

   ix := curmsg-threadbase;
   {writeln('threadseen: ix=',ix,' curmsg=',curmsg,' sub=',Subject);}
   if (ix > 0) and (ix <= maxthread) then
      threadseen^[ix] := true;
end;


(* ----------------------------------------------------------- *)
procedure set_read_flag;
   {flag that the message has been read, if needed}
begin
   set_lastread;

   if tomep then
      setflag(user.flags,flag_hasmail,false);   {clear mail-waiting flag}

   if tomep or toallp then
   begin
      case header.StatusCode of
         '*':  header.StatusCode := '+';
         '~':  header.StatusCode := '`';
         '#':  header.StatusCode := '$';
         '%':  header.StatusCode := '^';
         ' ':  header.StatusCode := '-';
         else  exit;    {don't change read date on re-reads}
      end;

      fill_chars(header.ReadTime,system_time,5);
      ltos(atol(todays_date_yymmdd),header.ReadDate);

      if update_read then
         save_message_header;
   end;
end;


(* ---------------------------------------------------------- *)
procedure decode_status;
   {decode the message status}
begin
   case header.StatusCode of
      '*','+', '~','`', '#','$':
         privatep := true;
      else
         privatep := false;
   end;
   
   case header.StatusCode of
      '+','`','$','^','-':
         readp := true;
      else
         readp := false;
   end;

   case header.StatusCode of
      '!','#','$':
         groupp := true;
      else
         groupp := false;
   end;

   toallp   := WhoTo  = all25;

   tomep    := ((WhoTo = sysop25) and (pcbsys.usernum = 1)) or
               (WhoTo = user.name);

   frommep  := header.WhoFrom = user.name;

   kill_allowed := (tomep and (header.WhoTo[1] <> '@')) or
                   frommep or sysopfun_allowed;
end;


(* ---------------------------------------------------------- *)
procedure advance;
   {advance by 1 message in the current direction}
begin
   if direction = '-' then
      dec(curmsg)
   else
      inc(curmsg);
end;


(* ---------------------------------------------------------- *)
procedure get_index(killed: boolean);
   {get file position nearest to requested message number}
var
   ix:          word;
   ixrec:       single;
   n:           integer;
   pos:         longint;

begin

   repeat
      if (curmsg < basemsg) then
      begin
         curmsg := basemsg;
         msgpos := no_msg;
         exit;
      end;

      {going past end-- check for new messages from alternate nodes}
      if (curmsg > lastmsg) then
      begin
         bseek(mbfd,0);
         bread(mbfd,mheader);
         lastmsg := stol(mheader.himsg);

         if curmsg > lastmsg then
         begin
            curmsg := lastmsg;
            msgpos := no_msg;
            exit;
         end
         else
         begin
            newline;
            displn('New messages left by alternate node.');
         end;
      end;

      ix := curmsg - basemsg;
      bseek(ixfd,ix);
      bread(ixfd,ixrec);

      pos := stol(ixrec);
      if killed then 
         pos := abs(pos);

      pos := pos-1;
      if pos < 0 then
      begin
         msgpos := no_msg;
         advance;
      end
      else
         msgpos := trunc(pos);

   until msgpos <> no_msg;
end;


(* ---------------------------------------------------------- *)
procedure check_message(killed: boolean);
var
   line: anystring;

begin
   get_index(killed);
   if msgpos = no_msg then
      exit;

   bseek(mbfd,msgpos);
   bread(mbfd,header);

   {check for mismatch between index and message file}
   if curmsg <> stol(header.Number) then
   begin
      make_log_entry('Repack needed - Invalid Index: expected='+
                             wtoa(curmsg)+' found='+stoa(header.number),true);
      msgpos := no_msg;
      exit;
   end;

   line := header.WhoTo;
   {if substitute then}
      prepare_line(line);
   fill_chars(WhoTo,line,sizeof(WhoTo));

   line := header.Subject;
   {if substitute then}
      prepare_line(line);
   fill_chars(Subject,line,sizeof(Subject));

   decode_status;
end;



(* ---------------------------------------------------------- *)
function select_conference(conf: integer): boolean;
   {select current conference; load header record and set pointers;
    return FALSE if conference not allowed or not available}
var
   c:    char;
   n:    integer;
   fd:   buffered_file;
   ccon: integer;

begin
   select_conference := false;

   load_conf(conf);

   {clean up after old versions of the file format}
   if ord(extuser.fixed.lockreg) > 1 then
      extuser.fixed.lockreg := false;

   {automatically enroll user in public conferences}
   if not getflag(extuser.conf[conf].flags,ext_member) then
   if not extuser.fixed.lockreg then
   begin
      if conf_info.conf_public or
        ((conf_info.conf_minsec > 0) and
         (userlevel >= conf_info.conf_minsec)) then
      begin
         setflag(extuser.conf[conf].flags,ext_member+ext_scan,true);
       { make_log_entry('Auto Register: @INCONF@',false); }
      end;
   end;

   {disable access if not a member or not a valid conference}
   if (not getflag(extuser.conf[conf].flags,ext_member)) or
      (length(conf_info.conf_msgfile) < 5) or (conf_info.conf_name = '') then
   begin
      load_conf(pcbsys.curconf);
      exit;
   end;

{if setdebug then
writeln(dbfd,'[select: conf=',conf,' selectedfile=',selectedfile,']');}
      
   selectedfile := conf_info.conf_msgfile;
   bopen(fd,selectedfile,1,sizeof(message_rec));
   if berr then
      exit;
   bread(fd,mheader);
   bclose(fd);
   
   pcbsys.curconf := conf;
   user.curconf := conf;
   lastread := @extuser.conf[conf].lastread;
   basemsg := stol(mheader.lowmsg);
   lastmsg := stol(mheader.himsg);
   curmsg := stol(lastread^);

   if curmsg > lastmsg then
      curmsg := lastmsg;

   newmsgs := lastmsg-curmsg;

   if curmsg > 1 then
      dec(curmsg);
   
{writeln('[base=',basemsg,' lastmsg=',lastmsg,' lastread=',lastread^,']');}

   select_conference := true;
end;


(* ---------------------------------------------------------- *)
procedure display_conference_info;
   {display current conference pointers}
begin     
   force_enter2;
   disp(GREEN);

   par5 := newmsgs;  pdispln('New Message Numbers: $5W$');
   par8 := lastread^;pdispln('Last Message Read:   $8S$');
   par5 := lastmsg;  pdispln('High Message Number: $5W$');
   par8 := mheader.msgcnt;
                     pdispln('Active Messages:     $8S$');
end;


(* ---------------------------------------------------------- *)
procedure open_conference;
   {open selected conference file}
begin
   {disable substitution if required wanted}
   substitute := (pos('/NOSUBS',set_pcb) = 0) or sysopfun_allowed;

   {establish new messagebase file and allocate buffers for it}
   if curmsg < basemsg then
      curmsg := basemsg-1;
   memorymsg := curmsg;
   priormsg := curmsg;
   messagebase_file := selectedfile;
   
   {clear thread memory}
   fillchar(threadseen^,sizeof(threadseen^),0);
   if curmsg > (maxthread div 2) then
      threadbase := curmsg-(maxthread div 2)
   else
      threadbase := 0;

{if setdebug then
writeln(dbfd,'[open: conf=',pcbsys.curconf,' file=',selectedfile,']');}

   {open the index and message base files}
   bopen(ixfd,messagebase_file + '.NDX',maxixbuf,sizeof(single));
   if berr then file_missing;

   bopen(mbfd,messagebase_file,maxinbuf,sizeof(message_rec));
   if berr then file_missing;
end;


(* ---------------------------------------------------------- *)
procedure reopen_messagebase;
   {reset the messagebase file in case of size change}
begin
   bclose(mbfd);
   bopen(mbfd,messagebase_file,maxinbuf,sizeof(message_rec));
   if berr then file_missing;
   bflush(ixfd);
end;


(* ---------------------------------------------------------- *)
procedure close_conference;
   {close the active conference}
begin
(***
if setdebug then
writeln(dbfd,'[close: conf=',pcbsys.curconf,']');
***)
   bclose(ixfd);
   bclose(mbfd);
end;


(* ---------------------------------------------------------- *)
procedure alloc_mail;
begin
{if setdebug then writeln(dbfd,'[alloc mail]');}
   dos_getmem(block,sizeof(block^));
   dos_getmem(lines,sizeof(lines^));
   dos_getmem(threadseen,sizeof(threadseen^));
   threadbase := 0;
end;

procedure free_mail;
begin
{if setdebug then writeln(dbfd,'[free mail]');}
   dos_freemem(threadseen);
   dos_freemem(lines);
   dos_freemem(block);
end;


(* ---------------------------------------------------------- *)
function unread_message: boolean;
var
   ix: integer;
begin
   ix := curmsg-threadbase;
   unread_message := (ix < 1) or (ix > maxthread) or (not threadseen^[ix]);
end;


(* ---------------------------------------------------------- *)
function locate_next_personal {(par: string2)}: boolean;
   {used for thread, y and ya searches according to contents of par}
var
   temp:    anystring;
   subj:    char25;
   tome:    boolean;
   toall:   boolean;
   n:       integer;

begin
   locate_next_personal := false;
   tome  := par[1] = 'Y';
   toall := par[2] = 'A';

   cmdline := '';

   subj := Subject;
   disp('Searching ...');

   if curmsg < basemsg then
      curmsg := basemsg;

   n := 0;
   while (not dump_user) and (linenum < 2000) do
   begin
      inc(n);
      if (n mod 10) = 0 then disp('.');

      advance;
      check_message(false);

      if msgpos = no_msg then
      begin
         {revert to head of thread}
         displn(' Not found.');
         curmsg := priormsg;

         if tome then
         begin
            prevcmd := '?';
            locate_next_personal := false;
            exit;
         end;

         repeat
            inc(n);
            if (n mod 10) = 0 then disp('.');
            advance;
            check_message(false);
{writeln('msgpos=',msgpos,' unread=',unread_message,' subject=',Subject);}

            if (msgpos <> no_msg) and message_allowed and unread_message then
            begin
               subj := Subject;
               temp := subj;
               delete_trailing_spaces(temp);
               disp(^M);
               disp('Next thread: ');
               disp(temp+' ...');
               priormsg := curmsg;
               {okay to display this message}
               locate_next_personal := true;
               newline;
               exit;
            end;
         until (msgpos = no_msg) or (linenum >= 2000) or dump_user;

         prevcmd := '?';
         locate_next_personal := false; {(msgpos <> no_msg) and message_allowed;}
         exit;
      end;


      if message_allowed then

         if (toall      and toallp) or
            (tome       and tomep) or
            ((not tome) and (subj = Subject)) then

         if unread_message then
         begin
            {okay to display this message}
            locate_next_personal := true;
            newline;
            exit;
         end;
   end;
end;

