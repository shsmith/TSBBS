
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
 * PCB ProDOOR file interfaces for PCBoard files (3-1-89)
 *
 *)

procedure load_pcbsys_file;
   (* load pcboard.sys and tinker with some fields *)
var
   fd:   dos_handle;
   i:    integer;

begin
   fd := dos_open(sysfile_path,open_read);
   if fd = dos_error then
      file_missing;

   i := dos_read(fd,pcbsys,sizeof(pcbsys));
   dos_close(fd);

   if (pcbsys.name[1] <= ' ') or       {qwikmail compatibility}
      (pcbsys.usernum = $2020) or
      (pcbsys.usernum = $312D) then   {in case of goodbye or carrier loss}
   begin
      writeln('User not logged in or Invalid PCBOARD.SYS!');
      if (option = o_none) or (option = o_nosignon) or (option = o_result) then
         dos_unlink(doorfile_path);
      delay(2000);
      halt(0);
   end;

   local := (pcbsys.connectbps[1] = 'L');
   baudrate := pcbsys.connectbps;
   delete_trailing_spaces(baudrate);

   graphics := (pcbsys.graphics = 'Y');
   first_name := pcbsys.firstname;
   delete_trailing_spaces(first_name);
   language := pcbsys.slanguage;
   delete_trailing_spaces(language);
end;


(* ------------------------------------------------------------ *)
procedure load_conf(n: integer);
   (* load conf_info for the specified conference *)
var
   fd:   dos_handle;
   r:    word;
begin
   fd := dos_open(confinfo_file,open_update);
   if fd = dos_error then
      file_missing;

   dos_rseek(fd,n,sizeof(conf_info),seek_start);
   r := dos_read(fd,conf_info,sizeof(conf_info));
   dos_close(fd);
end;


(* ------------------------------------------------------------ *)
procedure save_extuser;
   (* save user extended conference record and update user rec in ram *)
var
   fd: dos_handle;

begin
{writeln('SAVE EXTUSER: WRITE EXTUSER, THEN UPDATE USERS; rec=',user.extrarec);}

   (* save the extra conferences record *)
   fd := dos_open(extuser_file,open_update);
   if fd <> dos_error then
   begin
      write_extrec(fd);
      dos_close(fd);
   end;

   (* update user record from conference table *)
   save_extrec;
end;


(* ------------------------------------------------------------ *)
procedure load_extuser;
   (* load current user's extended conference record *)
var
   fd:   dos_handle;
   n:    integer;
   last: word;

label
   mismatch;

begin
{writeln('FIND EXTUSER RECORD AND READ IT FROM DISK; rec=',user.extrarec);}

   (* open the extra conferences file; create if needed *)
   if dos_exists(extuser_file) then
   begin
      fd := dos_open(extuser_file,open_update);
      if fd = dos_error then
         file_missing;
      determine_extsize(fd);
   end
   else

   begin
      fd := dos_create(extuser_file);
      if fd = dos_error then
         file_missing;
      fillchar(extuser,sizeof(extuser),0);
      extuser.fixed.extcount := extcount;
      determine_extsize(fd);
      user.extrarec := 0;
      write_extrec(fd);          {create heaer record}
   end;


   dos_lseek(fd,0,seek_end);
   last := dos_tell div extsize;

   (* create extra conference record if needed *)
   if (user.extrarec = $2020) or (user.extrarec >= last) then
   begin

mismatch:
{writeln('[mismatch] rec=',user.extrarec,' name=',extuser.fixed.name);}

      {search for a lost user record if he has an invalid index}
      if (user.extrarec <> $2020) and (last > 0) then
      begin
         user.extrarec := 0;
         repeat
            inc(user.extrarec);
            read_extrec(fd);
         until (user.extrarec = last) or (extuser.fixed.name = user.name);
      end;

      if (user.extrarec >= last) or (user.extrarec = $2020) then
      begin
{writeln('[append] rec=',user.extrarec);}

         (* initialize new extuser information *)
         user.extrarec := last;
         extuser.fixed.name := user.name;
         write_extrec(fd);
      end;
   end;

   (* load extra conference data and update from user record *)
   read_extrec(fd);

   (* verify that name matches - create new record if not.  this happens
      if the proconf.dat file is deleted, since records are created
      in a random order.  this also makes it safe to sort the pcb user
      file, since record numbers DO NOT correspond.  *)
   if extuser.fixed.name <> user.name then
      goto mismatch;

   dos_close(fd);

{writeln('[found] load extuser; rec=',user.extrarec);}

   (* update conference table from user record *)
   load_extrec;

   (* reset extra joined flags on first call of the day *)
   if extuser.fixed.lastdate <> system_date then
   begin
{WRITELN('LOAD_EXTUSER: JOINED FLAGS CLEARED,  LASTDATE=',EXTUSER.FIXED.LASTDATE);}
      fill_chars(extuser.fixed.lastdate,system_date,8);
      for n := min_econf to max_econf do
         setflag(extuser.conf[n].flags,ext_joined,false);

      save_extuser;
      put_user_rec(user,pcbsys.usernum);
   end;
end;


(* ------------------------------------------------------------ *)
procedure get_user_rec(var user: pcb_user_rec; recn: word);
   (* load specified user's record from the user file *)
var
   fd:  dos_handle;
   n:   integer;

begin
   fd := dos_open(pcbsetup.users_path^,open_update);
   if fd = dos_error then
      file_missing;

   dos_rseek(fd,recn-1,sizeof(user),seek_start);
   n := dos_read(fd,user,sizeof(user));
   if n <> sizeof(user) then
      usage('Error reading USER record');

   dos_close(fd);


{writeln('USERS RECORD LOADED FROM DISK; recn=',recn);}
(*******
if setdebug then
begin
  writeln(dbfd,'[get user rec, recn=',recn,' name=',user.name,']');
  for n := 0 to 39 do write(dbfd,n:3,':',stol(user.lastread[n]));
  writeln(dbfd);
end;
*******)

end;


(* ------------------------------------------------------------ *)
procedure get_user_info(var user: pcb_user_rec; name: char25);
   (* search for the specified user name and load it into the buffer *)
var
   ixfd: buffered_file;

begin
   fillchar(user,sizeof(user),' ');
   if (name[1] < 'A') or (name[1] > 'Z') then
      exit;

   cons_path(dos_name,pcbsetup.userix_dir^,'PCBNDX.' + name[1]);
   bopen(ixfd,dos_name,150,sizeof(user_ix));
   if berr then
      exit;

   user_ix.urec := 1;
   user_ix.name := sysop25;
   while (user_ix.name <> name) and (not berr) do
      bread(ixfd,user_ix);
   bclose(ixfd);

   if user_ix.name = name then
      get_user_rec(user,user_ix.urec);
end;


(* ------------------------------------------------------------ *)
procedure load_user_rec;
   (* load current user's record from the user file *)
var
   i: integer;
begin
   get_user_rec(user,pcbsys.usernum);

   if (not pcbsetup.subscription_mode) or
      (user.expdate[1] = '0') or
      (user.expdate >= todays_date_yymmdd) then
         userlevel := user.level
   else
         userlevel := user.explevel;

{$IFNDEF IN_PROKIT}
   load_conf(user.curconf);
   load_extuser;
{$ENDIF}
   
   (* add conference security, if needed *)
   if pcbsys.curconf <> 0 then
      userlevel := userlevel + conf_info.conf_addsec;

   (* determine the user name for status line and message entry *)
   username := pcbsys.name;
   delete_trailing_spaces(username);
end;


(* ------------------------------------------------------------ *)
procedure put_user_rec(var user: pcb_user_rec; recn: word);
   (* store specified user's record from the user file *)
var
   fd:  dos_handle;

begin

{writeln('USERS RECORD WRITTEN TO DISK; recn=',recn);}
(***********
if setdebug then
begin
  writeln(dbfd,'[put user rec, recn=',recn,' name=',user.name,']');
  for fd:= 0 to 39 do write(dbfd,fd:3,':',stol(user.lastread[fd]));
  writeln(dbfd);
end;
**********)

   if (recn < 1) or (recn >= 8000) then
      exit; {hack-- protect against invalid record numbers}

   fd := dos_open(pcbsetup.users_path^,open_update);
   if fd <> dos_error then
   begin
      dos_rseek(fd,recn-1,sizeof(user),seek_start);
      dos_write(fd,user,sizeof(user));
      dos_close(fd);
   end;
end;


(* ------------------------------------------------------------ *)
procedure save_user_rec;
   (* update user's record on disk *)
begin
{writeln('SAVE USER REC: SAVE_EXTUSER THEN PUT_USER_REC');}
   adjust_timing;
   
   (* take away conference security, if needed *)
   if pcbsys.curconf <> 0 then
      userlevel := userlevel - conf_info.conf_addsec;

   (* abandon extended conference before leaving prodoor *)
   if (protocol = opening_door) or (protocol = logging_off) or
      (protocol = aborted) then
   if not environment_on('EXTCONF') then
   begin
      if pcbsys.curconf > max_conf then
      begin
         pcbsys.curconf := 0;
         user.curconf := 0;
      end;
   end;

   (* update user file *)   
{$IFNDEF IN_PROKIT}
   save_extuser;
{$ENDIF}
   put_user_rec(user,pcbsys.usernum);
end;


(* ------------------------------------------------------------ *)
procedure save_pcbsys_file;
   (* update pcboard.sys on disk *)
var
   fd:  dos_handle;

begin
   (* rewrite the pcboard.sys file *)
   fd := dos_create(sysfile_path);
   if fd <> dos_error then
   begin
      dos_write(fd,pcbsys,sizeof(pcbsys));
      dos_close(fd);
   end;
end;


(* ------------------------------------------------------------ *)
procedure save_offline_pcbsys_file;
   (* update pcboard.sys in OFFLINE format, used in GoodBye function *)
begin
   fillchar(pcbsys.offline_filler,sizeof(pcbsys.offline_filler),' ');
   save_pcbsys_file;
end;


(* ------------------------------------------------------------ *)
procedure load_cnames_file;
var
   fd:   dos_handle;
label
   retry;
begin

retry:
   (* use CONFINFO file if present *)
   if dos_exists(confinfo_file) then
   begin
      fd := dos_open(confinfo_file,open_update);
      dos_lseek(fd,0,seek_end);
      conf_count := (dos_tell div sizeof(conf_info)) -1;
      dos_close(fd);
      exit;
   end;

   fd := dos_create(confinfo_file);
   if fd = dos_error then
      file_missing;

   (* read CNAMES and build CONFINFO if needed *)
   openfile(pcbsetup.cnames_path^);
   if not ok then
      file_missing;


   while (not endfile) and (conf_count <= max_econf) do
   begin
      fillchar(conf_info,sizeof(conf_info),0);
      getaline(conf_info.conf_name,sizeof(conf_info.conf_name));

      readflag(conf_info.conf_autojoin);

      skipline;
      readflag(conf_info.conf_private_ul);
      readflag(conf_info.conf_private_mail);
      readflag(conf_info.conf_echo_mail);
      readint(conf_info.conf_addsec);
      readint(conf_info.conf_addtime);                 {minutes}
      readint(conf_info.conf_msgblocks);               {1-32 message blocks; 1024 msgs each}
      getaline(conf_info.conf_msgfile,namesizes);      {conference message base pathname}

      skiplines(2);
      getaline(conf_info.conf_newsfile,namesizes);     {conference news pathname}

      skipline;
      getaline(conf_info.conf_public_uplist,namesizes);{public uploads listing pathname}
      getaline(conf_info.conf_updir,namesizes);        {conference upload dir}

      skipline;
      getaline(conf_info.conf_private_uplist,namesizes); {private uploads listing pathname}
      getaline(conf_info.conf_private_updir,namesizes);  {private uploads directory}

      skipline;
      getaline(conf_info.conf_doormenu,namesizes);     {door menu pathname}
      getaline(conf_info.conf_doorinfo,namesizes);     {door info data pathname}

      skipline;
      getaline(conf_info.conf_bltmenu,namesizes);      {bulletin menu pathname}
      getaline(conf_info.conf_bltinfo,namesizes);      {bulletin info pathname}

      skiplines(4);
      getaline(conf_info.conf_dirmenu,namesizes);      {file area menu pathname}
      getaline(conf_info.conf_dirinfo,namesizes);      {file area info pathname}

      skipline;
      getaline(conf_info.conf_dlinfo,namesizes);       {download path info pathname}

      inc(conf_count);

      conf_info.conf_public :=                        {default public status}
         (conf_count <= length(pcbsetup.public_conferences)) and
         (pcbsetup.public_conferences[conf_count] = 'X');

      dos_write(fd,conf_info,sizeof(conf_info));      {save this conference}
   end;

   closefile;
   dos_close(fd);
   load_conf(user.curconf);
   goto retry;
end;


(* ------------------------------------------------------------ *)
procedure load_pcbdat_file;
   (* load pcboard.dat - pcb14 *)
var
   i:    integer;

   {required_version = '*** PCBoard Version 14.0 data file ***';}
   {                    1........10........20.........30.........'}

begin
   cons_path(dos_name,sys_dir,pcboard_dat_file);
   openfile(dos_name);
   if not ok then
      file_missing;


   (* verify file version for compatibility *)
   getline(par,sizeof(par));
   if (par[21] <> '1') or (par[22] <> '4') then
   begin
      {$i-}write('Warning: not tested with this version of PCBoard!'^M^J); {$i+}
      {writeln('Expected: ', required_version);}
      {delay(1000);}
   end;


   (* load the file *)
   vgetline(pcbsetup.sysop_name);          {sysop display name}
   skipline;                               {local password}
   readflag(pcbsetup.use_realname);        {use real name for sysop?}
   readflag(pcbsetup.local_graphics);      {graphics on in local mode?}

   skiplines(19);
   vgetline(pcbsetup.security_dir);        {security messages location}
   vgetline(pcbsetup.chat_dir);            {node chat files location}
   vgetline(pcbsetup.pcbtext_dir);         {location of pcbtext}
   vgetline(pcbsetup.userix_dir);          {user index location}

   vgetline(pcbsetup.users_path);          {user file pathname}
   vgetline(pcbsetup.caller_path);         {caller log pathname}
   vgetline(pcbsetup.cnames_path);         {cnames file pathname}
   vgetline(pcbsetup.pwrd_path);           {pwrd file pathname}
   vgetline(pcbsetup.fsec_path);           {fsec file pathname}
   vgetline(pcbsetup.upsec_path);          {upsec file pathname}
   vgetline(pcbsetup.tcan_path);           {tcan file pathname}

   vgetline(pcbsetup.welcome_path);        {welcome file pathname}
   vgetline(pcbsetup.newuser_path);        {newuser file pathname}
   vgetline(pcbsetup.closed_path);         {closed file pathname}
   vgetline(pcbsetup.warning_path);        {30 day expiration warning file}
   vgetline(pcbsetup.expired_path);        {expired user message file}

   vgetline(pcbsetup.usernet_path);        {usernet.dat file pathname}
   vgetline(pcbsetup.conference_menu);     {conference menu pathname}

   skiplines(3);
   vgetline(pcbsetup.tranlog_path);        {down/upload transfer log pathname}
   vgetline(pcbsetup.logoff_path);         {logoff message pathname}

   skipline;
   vgetline(pcbsetup.language_path);       {multi-language data file}

   skiplines(3);                           {none}
   if (par[4] = 'E') {or local} then       {comN: port number 0(local), 1-2}
      com_chan := -1
   else
      com_chan := ord(par[4]) - ord('1');

   readword(pcbsetup.initial_speed);       {initial/top modem speed}
   readflag(pcbsetup.lock_speed);          {lock at initial speed}
   vgetline(pcbsetup.modem_initial);       {modem initial command}
   vgetline(pcbsetup.modem_offhook);       {modem off-hook command}
   readflag(disable_CTS_check);            {disable modem rts/cts handshake}
   readflag(pcbsetup.hayesv_modem);        {hayes-v modem}

   skipline;
   readflag(pcbsetup.reset_modem);         {reset modem during recycle?}
   readflag(pcbsetup.recycle_offhook);     {modem offhook during recycle?}

   skiplines(3);
   readflag(pcbsetup.allow_300);           {allow 300 baud connections?}
   getline(pcbsetup.start_300,6);          {starting hh:mm for 300 baud}
   getline(pcbsetup.stop_300,6);           {ending hh:mm for 300 baud}

   skipline;
   readflag(pcbsetup.disable_blanker);     {disable 3 minute clear screen}

   skipline;
   readflag(pcbsetup.disable_filter);      {disable high-bit filter}
   readflag(pcbsetup.disable_quick);       {disable quick logon/join}

   skipline;                               {disable p/w check /return from dos}
   readflag(pcbsetup.multi_lingual);       {multi-lingual operation mode}
   readflag(pcbsetup.only_pwchange);       {allow only password changes?}
   readflag(pcbsetup.closed_board);        {run in closed-board mode?}
   readflag(pcbsetup.disable_graphics);    {disable graphics mode?}
   readflag(pcbsetup.dos_recycle);         {exit to dos after each caller}

   skiplines(2);
   readflag(pcbsetup.subscription_mode);   {enable expired user checks}
   readflag(pcbsetup.allow_esc_codes);     {allow escape codes in messages}

   skipline;
   readflag(pcbsetup.validate_to);         {validate "TO:" in messages}

   skipline;
   readflag(pcbsetup.enforce_time_limit);  {enforce daily time limits?}
   readflag(pcbsetup.new_news);            {display only NEW news files?}

   skipline;
   readint(pcbsetup.timeout_minutes);      {keyboard timeout in minutes}
   readflag(pcbsetup.under_network);       {running multi-node?}
   vgetline(pcbsetup.node_number);         {node number}
   readint(pcbsetup.network_timeout);      {network timeout in seconds}
   readint(pcbsetup.chat_delay);           {node chat delay}

   vgetline(pcbsetup.system_name);         {name of the bbs system}

   skipline;
   getaline(dotpak,sizeof(dotpak));        {default packed file type}

   for i := 1 to 10 do
      vgetline(pcbsetup.macro_string[i]);  {shift-F1 thru F10 macros}

   getaline(pcbsetup.public_conferences,sizeof(pcbsetup.public_conferences));

   skipline;                               {number of conferences}
   conf_count := 0;                        {conf_count set by load_cnames}

   readint(pcbsetup.msg_lines);            {maximum message lines (1-99)}

   vgetline(pcbsetup.ansi_color);          {color for inputs/filedisps}
   vgetline(pcbsetup.ansi_intensity);      {default intensity}
   ansi_colors[ansi_DEFAULT] := pcbsetup.ansi_intensity^ + ';' +
                                pcbsetup.ansi_color^;

   readflag(pcbsetup.event_active);        {is event active?}
   getline(pcbsetup.event_time,8);         {event time hh:mm}
   readint(pcbsetup.event_buffer);         {minutes buffer before event}
   readflag(pcbsetup.event_noul);          {disable uploads before event}
   readflag(pcbsetup.slide_event);         {slide event time if needed}

   skipline;
   readflag(pcbsetup.disable_freecheck);   {disable free space check}
   readint(pcbsetup.printer_num);          {printer port number 1..3}
   readint(pcbsetup.min_upload_free);      {stop uploads if free space less (K)}

   skiplines(28);
   readint(pcbsetup.newuser_level);        {level given to new users}
   skipline;
   closefile;

(* append node number when running under a network *)
   if pcbsetup.under_network then
      vappends(pcbsetup.caller_path,pcbsetup.node_number^);

   if local then
      topcps := 960
   else
      topcps := atow(baudrate) div 10;

   case topcps of
      1920: topcps := 960;
      3840: topcps := 1920;
   end;

{writeln('[baudrate=',baudrate,' topcps=',topcps,']');}

   even_parity := (pcbsys.graphics = '7');
end;


(* ------------------------------------------------------------ *)
procedure build_scratchnames;
   (* build filename for scratch archives, make node-specific *)
begin
   par := itoa(user.scratchnum);
   cons_name(scratchname, cnf.scratch_prefix, par, dotpak);
   cons_path(scratcharc,  cnf.scratch_dir, scratchname);
   cons_path(result_path, cnf.scratch_dir, resultfile);

   cons_name(mailname, cnf.mail_prefix, par, dotpak);
   cons_path(mailarc,  cnf.scratch_dir, mailname);

   cons_name(dos_name, cnf.mail_prefix, par, '.TXT');
   cons_path(mailfile, cnf.scratch_dir{playpen_dir}, dos_name);

   journal_file := GetEnv('CAPFILE');

   if journal_file = '' then
   begin
      journal_file := 'DEBUG';
      if pcbsetup.under_network then
      begin
         par := pcbsetup.node_number^;
         journal_file := journal_file + par;
      end;
      journal_file := journal_file + '.OUT';
   end;
end;


(* ------------------------------------------------------------ *)
procedure high_ascii_filter(var c: char);
   (* this should be compatible with the filter in pcboard 14.0 *)
begin
   if not pcbsetup.disable_filter then
   case ord(c) of
      0..7,
      10..12,
      14..26,
      30,
      128..168,
      224..246,
      251..254,
      255:
        c := #0;
   end;
end;


(* ------------------------------------------------------------ *)
function get_pcbtext(n: integer): anystring;
   (* get a message from the PCBoard PCBTEXT file *)
type
   pcbtext_rec = record
      flag:  char;
      line:  array[1..79] of char;
   end;

var
   fd:   dos_handle;
   rec:  pcbtext_rec;
   str:  anystring absolute rec;
   colr: char;
   i:    integer;
   ok:   boolean;

begin
   cons_path(dos_name,pcbsetup.pcbtext_dir^,'PCBTEXT' + language);
   if not dos_exists(dos_name) then
      dos_name := copy(dos_name,1,length(dos_name)-length(language));

   fd := dos_open(dos_name,open_read);
   if fd = dos_error then
      file_missing;

(* get the message *)
   dos_rseek(fd,n,sizeof(rec),seek_start);
   i := dos_read(fd,rec,sizeof(rec));
   dos_close(fd);

(* remove trailing spaces *)
   colr := rec.flag;
   i := 79;
   while (i > 1) and (rec.line[i] = ' ') do
      i := i - 1;
   str[0] := chr(i);

   get_pcbtext := str;
end;

