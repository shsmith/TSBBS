
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
 * PCB ProDOOR module to log off (goodbye function)      (3-1-89)
 *
 * Updates PCBoard USERs file and logs user off without
 * recycling PCBoard first.
 *
 *)


{$i prodef.inc}
{$i proovr.inc}

unit ProBye;

interface
   uses
     Tools,
     MdosIO,
     ProData,
     ProRoot;

   procedure logoff_log_entry(tused: integer);
   procedure good_bye;



(* ------------------------------------------------------------ *)
implementation

(* ------------------------------------------------------------ *)
procedure logoff_log_entry(tused: integer);
var
   stat:    anystring;
begin
   newline;
   par5 := tused;
   make_log_entry('Minutes Used: $5W$',true);
   newline;

   if not dump_user then
   begin
      dGREEN('Thanks for calling, $FIRST$!');
      newline;
   end;

   default_color;
                        
   (* make a log entry for this caller *)
   if option = o_logoff then
      stat := 'Automatically'
   else
   if dump_user then
      stat := 'Abnormally'
   else
      stat := 'Normally';

   par := '@SYSDATE@ (@SYSTIME@) ';

   if pcbsetup.under_network then
      par := par + '($NODE$)';

   par := par + ' $NAME$ Off ' + stat;
   make_raw_log_entry(par);

   make_raw_log_entry(all_stars);
end;


(* ------------------------------------------------------------ *)
procedure good_bye;
var
   ontime:  integer;
   time_now:integer;
   used:    integer;
   tused:   integer;
   quick:   boolean;
   udate:   char6;

begin
   quick := cmdline[1] = 'Q';

   (* update user record last-call time and date *)
   fill_chars(udate,todays_date_yymmdd,sizeof(udate));
   if udate <> user.date then
   begin
      user.date := udate;
      user.lastused := 0;  {only charge for time since midnight}
   end;

   (* calculate time online *)
   user.time := pcbsys.time_logged;

   ontime := pcbsys.time_on;
   time_now := get_mins;

   tused := time_now - ontime + 1;   {total min. connected, regardless of midnight}

   if time_now < ontime then     {past midnight only count new day's time}
   begin
      ontime := 0;
      inc(tused,1440);
   end;

   used := time_now - ontime + 1;    {number of minutes to charge for today}

   user.lastused := user.lastused + (used - pcbsys.time_credit);


   (* display goodbye messages *)
   linenum := -10000;    {force NS for this file}

   if not quick then
   begin
      par := pcbsetup.logoff_path^;
      display_file_raw(par,remove_semicolons);
   end;

   logoff_log_entry(tused);


   (* start the event if needed *)
   if event_run_needed(event_now) then
   begin
      make_log_entry('Scheduled Event ran at @SYSTIME@',false);
      make_raw_log_entry(all_stars);
      cons_path(cmdline, sys_dir,'EVENT.SYS');
      cons_path(par,     sys_dir,'EVENT.BAT');
      move_file(cmdline,  par);
      event_pending := true;
   end;

{$IFNDEF IN_PROCALL}
   (* arrange for exit to dos if that pcbsetup option was selected *)
   if (pcbsetup.dos_recycle) and (pcbsys.sysop_next = ' ') then
      pcbsys.sysop_next := 'X';
{$ENDIF}

   protocol := logging_off;
end;


end.
