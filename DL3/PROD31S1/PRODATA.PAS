
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
 * PCB ProDOOR data declaration module (3-1-89)
 *
 *)

{$i prodef.inc}

unit ProData;

interface

uses Dos, Tools;

const 
   progname:         string[20] = 'ProDoor';
   whoami:           string[12] = 'ProDoor (tm)';

   version_number:   string[4]  = '3.1';
   version_const                = '3.1 of 10-08-89' {for PCB 14.x};
   version:          string[37] = version_const;

   aborted = -99;            (* protocol code for aborted transfers *)
   opening_door = -88;       (* protocol code for opening another door *)
   logging_off = -77;        (* protocol code for logoff/hangup *)
   outside_batch = -87;      (* protocol code to access outside batch files *)

   max_efficiency = 200;     (* highest transfer efficiency before a
                                transaction is considered premature (in
                                case of protocols that compress) *)

   default_peffic = 0.90;    {default protocol efficiency}

   ansi_reset:       string[4] = #27'[0m';    {ansi to reset attributes}


{$i profname.dcl}          {file name constant declarations}


{option codes}
   o_none    = '-';   {normal startup}
   o_nosignon= 'N';   {recycle, no signon}
   o_result  = 'R';   {recycle with result message (TEST, REARC, etc)}
   o_logok   = 'K';   {log normal transfer}
   o_logerr  = 'E';   {log error transfer}
   o_logoff  = 'G';   {automatic logoff}


type
   scan_modes = (by_date,       {for [N]ew files }
                 by_keyword,    {for [Z]ippy scan}
                 by_name);      {for [L]ocate    }


{$I proconf.dcl}     {configuration file declarations}

{$I extuser.dcl}     {extended user file declarations}

{$I proint.dcl}      {pcboard 14.0 interface declarations}


var
   ok:                boolean;
   linenum:           integer;

   pcbsetup:          pcbsetup_rec;
   pcbsys:            pcb_sys_rec;

   user:              pcb_user_rec;
   extuser:           extuser_rec;
   conf_info:         pcbconf_rec;
   conf_count:        integer;

   control:           control_table;
   curctl:            sysop_control_rec;
   curstart:          longint;
   curfun:            char;
   last_adjustment:   integer;
         
   topcps:            word;
   baudrate:          string8;
   username:          string30;
   first_name:        string20;
   userlevel:         integer;

   cnf:               config_rec;  {configuration file}

   download_table:    dir_table;   {list of all file dl directories}
   conf_dirs:         integer;    {file areas (not counting U/L dir)}
   conf_dlpaths:      integer;    {number of download paths}

   upload_dir:        filenames;   {location of upload subdirectory}
   upload_list:       filenames;   {path of upload list \pcb\main\dirxx}
   private_dir:       filenames;   {location of private upload subdirectory}
   private_list:      filenames;   {location of sysop's private upload list}

   journal_file:      filenames;   {alt-f or prodebug=ON file}
   scratcharc:        filenames;   {scratch filename for archive extract}
   scratchname:       filenames;   {root of scratch filename}

   mailfile:          filenames;   {captured mail .TXT file}
   mailarc:           filenames;   {captured mail .ARC arcfile}
   mailname:          filenames;   {root of mail arc filename}

   protocol:          integer;     {selected protocol number}

   transfer:          name_table;  {list of filenames to transfer}
   descr:             name_table;  {descriptions of files in current transfer}

   transize:          longint;     {sizes of filenames to transfer}
   files_found:       integer;     {files found by find_file call}
   k_left:            integer;     {kbytes remaining; set by find_file}
   mins_left:         integer;     {minutes remaining; set by find_file}

   home_dir:          filenames;
   comspec:           filenames;

   cmdline:           string;      {current command line}
   par:               string;      {current command parameter}
   parn:              integer;     {atoi of par}
   par1:              anystring;
   par2:              string65;

   par3:              string65;     { $3$}
   par4:              string65;     { $4$}
   par5:              word;         { $5W$}
   par6:              word;         { $6W$}
   par7:              longint;      { $7L$}
   par8:              single;       { $8S$}

   config_file:       filenames;   {filename of configuration file}
   sys_dir:           filenames;   {directory where pcboard.sys is stored}

   alti_fd:           text;
   mailfd:            text;

   doorfile_path:     filenames;
   doorlog_path:      filenames;
   namefile_path:     filenames;
   result_path:       filenames;
   sysfile_path:      filenames;

   pending_keys:      anystring;   {pending function keys}

   pending_flags:     longstring;  {active filename flags}

   extuser_file:      filenames;   {extuser data file}
   confinfo_file:     filenames;   {confinfo data file}

  {nohot_list:        string80;}   {keys that aren't hot}

   set_pcb:           anystring;   {PCB environment settings}

const
   hotkeys_active:    boolean = false;   {hotkeys active next get_cmdline}

   option:            char    = o_none;  {command line option code}
   auto_logoff:       boolean = false;   {logoff after transfer?}

   status_active:     boolean = false;   {is status display active?}

   chat_active:       boolean = false;   {is sysop chat active? (disables
                                          time-left and 3 minute timeouts)}

   event_pending:     boolean = false;   {true if event will run on exit}

   process_fkeys:     boolean = true;    {false to disable sysop keys}

   key_source:        (sysop_key, user_key) = sysop_key;
                                         {set by get_key}

   alt_i:             boolean = false;   {file input in effect?}

   alt_p:             boolean = false;   {printing all display text?}

   allow_flagging:    boolean = true;    {include (F)lag option in MORE prompt}

   dump_user:         boolean = false;   {set by F8, CD loss or time elapsed}

   message_capture:   boolean = false;   {file capture of message display?}
                                            
   update_read:       boolean = true;    {update read flag?}

   update_user:       boolean = true;    {update sysop user record?}

   language:          string[4] = '';


{$i promsgs.dcl}     {common message text}


implementation

begin
   {writeln('prodata init');}

   {clear all records containing varstrings}
   fillchar(pcbsys,sizeof(pcbsys),' ');
   fillchar(user,sizeof(user),0);
   fillchar(extuser,sizeof(extuser),0);
   fillchar(pcbsetup,sizeof(pcbsetup),0);
   fillchar(conf_info,sizeof(conf_info),0);
   fillchar(cnf,sizeof(cnf),0);
   fillchar(download_table,sizeof(download_table),0);
   fillchar(descr,sizeof(descr),0);
   fillchar(transfer,sizeof(transfer),0);

   baudrate := '';
   username := '';
   first_name := '';
   scratcharc := '';
   mailfile := '';
   home_dir := '';
   cmdline := '';
   pending_keys := '';
   pending_flags := '';
   {nohot_list := '';}

 { par1 := '';
   par2 := '';
   upload_dir := '';
   upload_list := '';
   private_dir := '';
   private_list := ''; }
   par3 := '';
   par4 := '';

   {these are all changed later on as the files are loaded in}
   user.pagelen := 0;
   linenum := 0;
   protocol := aborted;
   pcbsys.display := '-1';
   pcbsys.connectbps := 'Local';
   pcbsys.openbps := '19200';


   {initialize the control table}
   for curfun := min_control to max_control do
   begin
      control[curfun].minlevel := 0;
      control[curfun].timefact := 1;
      control[curfun].bytefact := 1;
   end;
   
   curfun := min_control;
   curctl := control[curfun];
   curstart := lget_time;
   
   {get fixed command parameters}
   config_file := paramstr(1);

   sys_dir := paramstr(2);
   if length(sys_dir) = 3 then
      dec(sys_dir[0]);

   par := paramstr(3);
   if length(par) > 0 then
      option := par[1];
   auto_logoff := (length(par) = 2) and (par[2] = 'G');

   savestr(pcbsetup.caller_path,'');
   cons_path(doorfile_path,sys_dir, doorfile);
   cons_path(namefile_path,sys_dir, namefile);
   cons_path(sysfile_path, sys_dir, sysfile);

   doorlog_path := GetEnv('DSZLOG');
   if doorlog_path = '' then
      cons_path(doorlog_path, sys_dir, doorlogfile);

   comspec := GetEnv('COMSPEC');

   extuser_file := GetEnv('EXTUSER');
   if extuser_file = '' then
      extuser_file := 'EXTUSER';

   confinfo_file := GetEnv('CONFINFO');
   if confinfo_file = '' then
      confinfo_file := 'CONFINFO';

   set_pcb := GetEnv('PCB');
   stoupper(set_pcb);
end.

