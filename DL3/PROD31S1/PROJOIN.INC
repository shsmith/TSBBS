
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
 * PCB ProDOOR join conference (3-1-89)
 *
 *)

procedure display_conference_news;
begin
   if linenum > 1 then
      linenum := 1;
   display_file(conf_info.conf_newsfile);
   newline;
end;


procedure find_next_conf(var n: integer; direction: integer);
var
   cn: integer;
begin
   cn := pcbsys.curconf + direction;
   while (cn <= conf_count) and (cn > 0) do
   begin
      if getflag(extuser.conf[cn].flags,ext_scan) then
      begin
         n := cn;
         exit;
      end;
      cn := cn + direction;
   end;
end;


function lookup_conference_number(name: string10): integer;
   {lookup conference by name or number; return <0 if invalid}
var
   i:    integer;
   conf: string10;
   fd:   buffered_file;
   n:    word;

begin
   bopen(fd,confinfo_file,10,sizeof(conf_info));
   if berr then
      file_missing;

   stoupper(name);
   i := -1;
   repeat
      inc(i);
      bread(fd,conf_info);
      conf := conf_info.conf_name;
      stoupper(conf);
   until (conf = name) or (i >= conf_count);

   bclose(fd);
   load_conf(user.curconf);

   if conf = name then
   begin
      lookup_conference_number := i;
      exit;
   end;

   case name[1] of
      'M':  i := 0;  {main}

      '+':  find_next_conf(i,1);

      '-':  find_next_conf(i,-1);

      '.':  i := pcbsys.curconf;

      '0'..'9':
            i := atoi(name);
      else
            i := -1;
   end;

   if (i < 0) or (i > conf_count) then
   begin
      i := -1;
      par3 := name;
      if length(name) > 0 then
         pdispln('($3$) is an invalid conference name.');
   end;

   lookup_conference_number := i;
end;

   
procedure join_conference;
var
   n:       integer;
   pconf:   integer;
   addtime: integer;
   allowed: real;
   
begin
   (* verify that there are conferences available *)
   if conf_count = 0 then
   begin
      not_available;
      exit;
   end;

   if length(cmdline) = 0 then
   begin
      par := pcbsetup.conference_menu^;
      linenum := 1;
      display_file(par);
   end;

   repeat
      if length(cmdline) = 0 then
      begin
         newline;
         get_defn('Conference:', '(+/-), (A)config, (N)ew, (S)tats, (Y)our, ');
      end;
   
      get_nextpar;
      if par = 'J' then
         get_nextpar;
      if length(par) = 0 then
         exit;
         
      if (length(par) = 1)
         and ((par[1] = 'S') or (par[1] = 'N') or (par[1] = 'Y')) then
      begin
         display_conference_status(par[1]);
         par := 'S';
      end
      else
      
      if (length(par) = 1) and (par[1] = 'A') then
      begin
         conference_registration;
         exit;
      end;
   until par <> 'S';
      
   n := lookup_conference_number(par);

   if n = 0 then
      select_main_board
   else

   begin
      if dump_user or (n < 0) then
         exit;
      pconf := pcbsys.curconf;

      if select_conference(n) = false then
      begin
         par5 := n;
         make_log_entry('You are not registered in Conference $5W$!',true);
         exit;
      end;

      (* abandon current conference *)
      if pconf <> 0 then
      begin
         load_conf(pconf);
         userlevel := userlevel - conf_info.conf_addsec;
         load_conf(user.curconf);
      end;

      (* enter the new conference *)
      userlevel := userlevel + conf_info.conf_addsec;

      newline;
      make_log_entry('@INCONF@ Conference Joined.',true);
   end;

{$IFNDEF IN_PROEDIT}
   build_download_list;
{$ENDIF}
   {newline;}


   (* give added-time up to that of the most-added for any
      single conference (added-times do not combine) *)
   addtime := conf_info.conf_addtime;

   if addtime > pcbsys.time_added then
      pcbsys.time_added := addtime;

   {checking for an event adjusts for pending events}
   if event_run_needed(event_possible) then ;


   (* check for quick join option *)
   if cmdline[1] = 'Q' then
      get_nextpar;
   if pcbsetup.disable_quick then
      par := '';

   (* display news the first time a conference is joined *)
   if not getflag(extuser.conf[n].flags,ext_joined) then
   begin
      setflag(extuser.conf[n].flags,ext_joined,true);
{$IFNDEF IN_PROEDIT}
      if ((length(par) = 0) or (par[1] <> 'Q')) then
         if (not pcbsetup.new_news) or file_is_new(conf_info.conf_newsfile) then
            display_conference_news;
{$ENDIF}
   end;

   if file_is_new(conf_info.conf_bltmenu) then
      pdispln('@INCONF@ bulletins updated since last call.');

   display_conference_info;   
   wait_for_enter;
end;

