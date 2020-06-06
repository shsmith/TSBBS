
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

{$i prodef.inc}
{$M 8000,12000,12000}   {Stack(min=8), minheap(min=12), maxheap}
                      {IF PACKED, MINHEAP=12; UNPACKED MINHEAP=15!!}


program ProEDIT;

uses MiniCrt,Tools,Mdosio,ProData,  {standard ProDOOR units}
     ProRegL, ProRoot{2},             {special libraries}
     ProJoin, ProRead{2};             {the reader/editor/entry unit}

procedure signon;
begin
   newline;
   displn('ProEdit '+version+';  (C) 1987, 1989 Samuel H. Smith');
   _DREG_(disp);
   newline;
end;

procedure help;
begin
   signon;
   displn('Usage: proedit SYSTEM_DIR OPTIONS INITIAL_CONFERENCE INITIAL_COMMANDS');
   newline;
   displn('SYSTEM_DIR specifies the location of your PCBOARD.DAT file.');
   newline;
   displn('OPTIONS, if present, may be one or more of:  (no spaces)');
   displn('     R        ;do not flag messages as being "read"');
   displn('     U        ;do not update message pointers');
   displn('     Q        ;quickly jump to the last message available');
   newline;
   displn('INITIAL_CONFERENCE specifies the conference to join on entry');
   displn('INITIAL_COMMANDS can be any list of ProEdit commands');
   newline;
   displn('Examples:');
   displn('   proedit c:\pcb RUQ tools');
   displn('   proedit c:\pcb RU 4 Q');
   displn('   proedit c:\pcb Q sysops');
   halt(100);
end;


procedure init;
begin
   clrscr;

   if paramcount < 1 then
      help;

   sys_dir := paramstr(1);
   progname := 'ProEdit';
   option := o_logok;  {disable time limits}
   getdir(0,home_dir);


   {create a "fake" pcboard.sys record to allow mainline prodoor code to work}
   {pcbsys.alarm := '-1';}
   pcbsys.usernum := 1;
   fill_chars(pcbsys.time_logged,system_time,5);
   pcbsys.time_credit := 0;
   pcbsys.connectbps := 'Local';
   pcbsys.time_limit := 120;
   pcbsys.prev_used := 0;
   pcbsys.graphics := 'N';
   pcbsys.curconf := 0;

   bios_comm := true;
   bios_echo := true;
   baudrate := 'Local';
   graphics := false;
   local := true;

   {load pcboard setup file, sysop user rec and put up status lines}
   load_pcbdat_file;
   load_cnames_file;
   load_user_rec;

   (* initialize user record on first entry to door *)
   if user.flags = flag_init then
   begin
      user.dooruse := 0;
      user.scratchnum := 1;
      user.earned_k := 0;
      user.flags := 0;
   end;

   (* check for old format data *)
   if getflag(user.flags,flag_oldfmt) then
      user.flags := 0;

   if pcbsetup.use_realname then
      username := user.name
   else
      username := 'SYSOP';
   delete_trailing_spaces(username);

   fill_chars(pcbsys.name,username,sizeof(pcbsys.name));

   par := username;
   first_name := scan_nextpar(par);

   init_com;
   
   pcbsetup.event_active := false;
   pcbsetup.timeout_minutes := 0;
   {user.pagelen := 22;}

   {switch to color/graphics mode if pcbsetup says you login
    locally in graphics mode}
   if pcbsetup.local_graphics then
   begin
      graphics := true;
      pcbsys.graphics := 'Y';
   end;

   cnf.playpen_dir := home_dir;
   build_scratchnames;
   mailfile := 'MAIL.TXT';

   setdebug := environment_on('PRODEBUG');
   if setdebug then
      open_capture;

   _CREG_('PRODOOR.REG',0);
   init_status_display;

   gotoxy(1,1);
   signon;
end;


(*
 * main program
 *
 *)

var
   p: integer;
   n: integer;
   quick: boolean;

begin
   install_error_handler;
   init;

   {build total command line; allow full command stacking from dos}
   cmdline := paramstr(2);
   stoupper(cmdline);

   {check for read-only preference}
   p := posc('R',cmdline);
   if p > 0 then
   begin
      delete(cmdline,p,1);
      update_read := false;
      displn('''READ'' flagging is OFF.');
   end;

   {check for update preference}
   p := posc('U',cmdline);
   if p > 0 then
   begin
      delete(cmdline,p,1);
      update_user := false;
      displn('User record update is OFF.');
   end;

   {check for quick preference}
   quick := false;
   if cmdline[1] = 'Q' then
   begin
      delete(cmdline,1,1);
      quick := true;
   end;


   {remove initial 'J' if present}
   p := posc('J',cmdline);
   if p = 1 then
      delete(cmdline,p,1);


   {build remainder of command line}
   delete_leading_spaces(cmdline);
   for n := 3 to paramcount do
      cmdline := cmdline + ' ' + paramstr(n);
   stoupper(cmdline);


   {if no valid conference name or number is provided, insert default}
   get_nextpar;
   p := lookup_conference_number(par);
   if p < 0 then
   begin
      unget_par;
      par := itoa(pcbsys.curconf);
   end;


   {in quickstart mode add quick and reverse-read options}
   if quick then
      par := par + ' Q 999999-'
   else
   if cmdline = '' then
      cmdline := 'R S';

   {build the final command-line}
   cmdline := 'J ' + par + ' ' + cmdline;


   {read and edit messages (re-join now builtin to reader)}
   {will use remainder of cmdline as stacked commands}
   displn('Initial command line is: '+cmdline);

   linenum := 1;
   dump_user := false;
   message_reader;

   set_node_status(node_going_down);

   {save last-msg-read pointers for sysop}
   if update_user then
      save_user_rec;

   {clean up screen and exit}
   delete_status_display;

   newline;
   displn('Thanks for using ProEdit!');
   newline;

   default_color;
   close_capture;
   uninit_com;
end.

