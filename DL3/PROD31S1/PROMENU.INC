
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
 * PCB ProDOOR main user interface        (3-1-89)
 * The Main Menu and Command prompt loop
 *
 *)

procedure main_menu;
   (* this is the main prompting loop,
      exits with 'protocol' set for next action *)
var
   c: char;

const
   none = '~';

begin
   cmdline := '';
   newline;

   while true do
   begin
      set_function(fun_idle);
      set_node_status(pcbsys.nodechat);   {unavailable for chat - stub}

      if (length(cmdline) = 0) or (cmdline[1] = none) then
      begin
         linenum := 1;
         if (not expert) and (length(cmdline) = 0) then
            display_file(main_menu_file);

         display_time_left;
         pdisp('[@INCONF@] Command? ');
         get_xcmd('PROMAIN.XLT');

         {get_hcmdline;} {command('DEFGJKLNOPQRSTUVYZ');}
      end;
      
      protocol := aborted;
      if dump_user then exit;

      (* give quick instructions if nothing typed. *)
      get_nextpar;
      if length(par) = 0 then    (* ask again if nothing typed *)
         par[1] := none;         (* force "invalid command" message *)

      (* process commands *)
      case par[1] of

         'A':  abandon_conference;

         'B':  if verify_level('B') then 
                  read_bulletins;

         'D':  if par[2] = 'O' then
                  do_open
               else
                  get_protocol(TX);

         'C',
         'E':  if par[2] = 'H' then
                  node_chat
               else
               begin
                  unget_par;
                  message_reader;
               end;

         'F':  if par[2] = 'L' then
                  flag_files
               else
               if par[2] = 'V' then
                  view_archive(true)
               else
               if verify_level('F') then
                  file_directories;

         'G':  if verify_level('G') then
                  protocol := logging_off;

         'H':  hotkey_toggle;

         '?':  begin
                  display_file(protocol_help_file);
                  wait_for_enter;
               end;

         'J':  if verify_level('J') then 
                  join_conference;

         'L':  if par[2] = 'I' then
                  request_library
               else
                  dir_scan(by_name);

         'M':  mode_toggle;

         'N':  if par[2] = 'E' then
               begin
                  newline;
                  display_conference_news;
                  wait_for_enter;
               end
               else
               if par[2] = 'O' then
                  node_chat
               else
                  dir_scan(by_date);

         'O':  if par[2] = 'P' then
                  do_open
               else
                  operator_page;

         'P':  get_int('Page length:',user.pagelen);

         'Q':  if par[2] = 'U' then
               begin
                  if verify_level('P') and flag_warning(true) then
                  begin
                     protocol := aborted;
                     exit;
                  end;
               end
               else
               begin
                  unget_par;
                  message_reader;
               end;

         'R':  if par[2] = 'Z' then    {rz}
                  cmdline := 'U Z S'
               else
               if par[4] = 'A' then    {repack}
                  rearc_scratchfile
               else
               
               begin                   {r, re, reply, ru}
                  unget_par;
                  message_reader;
               end;

         'S':  if par[2] = 'C' then
                  scan_toggle
               {else
                  script_menu};

         'T':  if par[2] = 'E' then
                  test_archive
               else
               if par[2] = 'S' then
               begin
                  unget_par;
                  message_reader;
               end
               else
                  display_protocol_table;

         'U':  get_protocol(RX);

         'V':  begin
                  if length(par) = 1 then
                     view_profile
                  else
                     view_archive(false);  {no listing for VQ, VX, etc}
                  cmdline := '';
                  wait_for_enter;
               end;

         'W':  write_user_info;

         'X':  expert_toggle;

         'Y':  begin
                  cmdline := 'R Y';
                  message_reader;               
               end;
               
         'Z':  if par[2] = 'I' then
                  capture_new_mail
               else
                  dir_scan(by_keyword);

         '1':  sysop_view_log;

         '9':  sysop_remote;


         '*':  displn(^X^X^X^X^X^X);  {in case DSZ is sending messages}

         '<','>','"':
              begin
                  if par[1] = '"' then
                     pdispln(cmdline)
                  else
                     make_log_entry(cmdline,par[1]='>');
                  cmdline := '';
               end;

(*********
         '$':  begin
                  writeln('  name = ',conf_info.conf_name);
                  write  ('  private_ul = ',conf_info.conf_private_ul);
                  write  ('  private_mail = ',conf_info.conf_private_mail);
                  writeln('  echo_mail = ',conf_info.conf_echo_mail);
                  write  ('  addsec = ',conf_info.conf_addsec);
                  write  ('  addtime = ',conf_info.conf_addtime);
                  writeln('  msgblocks = ',conf_info.conf_msgblocks);
                  writeln('  msgfile = ',conf_info.conf_msgfile);
                  write  ('  public_uplist = ',conf_info.conf_public_uplist);
                  writeln('  updir = ',conf_info.conf_updir);
                  write  ('  private_uplist = ',conf_info.conf_private_uplist);
                  writeln('  private_updir = ',conf_info.conf_private_updir);
                  writeln('  newsfile = ',conf_info.conf_newsfile);
                  write  ('  doormenu = ',conf_info.conf_doormenu);
                  writeln('  doorinfo = ',conf_info.conf_doorinfo);
                  write  ('  bltmenu = ',conf_info.conf_bltmenu);
                  writeln('  bltinfo = ',conf_info.conf_bltinfo);
                  write  ('  dirs = ',conf_dirs);
                  writeln('  dirmenu = ',conf_info.conf_dirmenu);
                  writeln('  dirinfo = ',conf_info.conf_dirinfo);
                  write  ('  dlpaths = ',conf_dlpaths);
                  writeln('  dlinfo = ',conf_info.conf_dlinfo);
                  writeln('  public = ',conf_info.conf_public);
                  displn('  Port open BPS: '+pcbsys.openbps);
                  displn('    Connect BPS: '+pcbsys.connectbps);
                  displn('Error free link: '+pcbsys.errcheck);
                  displn(' Using COM port: '+pcbsys.scomport);
               end;
*******)

         '/':  ;

         none: cmdline := none;    {prevent another menu}

         else  not_understood;
      end;

      (* exit now if a valid protocol has been selected *)
      case protocol of
         1 .. 99:
            if (pro_mode = TX) or flag_warning(false) then
               exit;

         -88 .. -22:
            if flag_warning(false) then
               exit;
      end;

      if cmdline[1] <> none then
         newline;
   end;

end;

