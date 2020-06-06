
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
 * PCB ProDOOR screen and status area management (3-1-89)
 *
 *)

procedure writes(s: string);
begin
   write(s);
end;

procedure writec(c: char);
begin
   writes(c);
end;

procedure writespc;
begin
   writec(' ');
end;

procedure tabto(n: integer);
begin
   if wherex > n then
      gotoxy(n,wherey)
   else
   while wherex < n do
      writespc;
end;


procedure update_status_display (format: status_formats);
   {display current status information on the last 2 lines of the screen}
var
   x,y:  integer;
   n:    integer;

   procedure dline1;
   begin
      writec('(');
      writes(baudrate);
      if pcbsys.errcheck[1] = '-' then
         writec('E');
      writes(') ');

      writes(username);
      writes(' - ');

      writes(user.city);

      tabto(67-length(progname));
      writes(progname);
      writespc;
      writes(pcbsys.time_logged);

      BlinkVideo;
      writec(pcbsys.sysop_next);
      ReverseVideo;

      writes(system_time);
      writespc;
      writeln;
   end;

begin
   status_active := true;

  {a good place to verify that carrier is present}
   check_carrier_loss;

  {save display settings}
   x := wherex;
   y := wherey;
   if y > scroll_line then
      y := scroll_line;

   {open window and prepare for status display}
   FullScreen;
   gotoxy(1,scroll_line+1);
   ReverseVideo;


   {remove display when not enabled}
   if pcbsys.display[1] <> '-' then
   begin
      NormalVideo;
      x:=1; y:=1;
      clrscr;
   end
   else


   {display the help message}
   if (format = help_format) then
   begin
      writes('  Alt-  N=Next  X=Exit  F=File-Out  I=File-In  P=Prt-On   =+/-5min  v'+VERSION_NUMBER);
      tabto(79);
      writeln;
      writes('  F3=Print   F4=Page   F5=Shell   F7=Alarm   F8=Logoff   F9=Display  F10=Chat  ');
   end
   else


   {display the status message}
   begin
      if pcbsetup.under_network then
      begin
         NormalVideo;
         writes(pcbsetup.node_number^);
         writespc;
         ReverseVideo;
      end
      else
         writespc;


{$IFNDEF IN_PROEDIT}
      if format = pgdn_format then
      begin
         writespc;
         writes(user.busphone);
         writes(' /  '+user.phone);
         writes('  E/D: '+user.expdate+'  P/W: '+user.passwd);
         tabto(79);
         writeln;
         writes('  C1: '+user.usercomment+'   C2: '+user.sysopcomment);
         tabto(79);
      end
      else

      if format = pgup_format then
      begin
         writes('      M.........1.........2.........3.........4.........5.........6.........');
         tabto(79);
         writeln;
         writes(' Areas: ');
         for n := 0 to conf_count do
            if getflag(extuser.conf[n].flags,ext_member) then
               writec(chr(n mod 10+ord('0')))
            else
               writespc;
         tabto(79);
      end
      else
{$ENDIF}

      begin {default display}
         dline1;

         if userlevel > 0 then
            write(' (',expdate(user.date),
                  ')  #On=',user.total_calls,
                  '  Sec',user.curconf,
                  '=',userlevel,
                  '  Up=',user.uploads,'/',
                     dtok(user.uptotal),
                  'k  Dn=',user.downloads,'/',
                     dtok(user.downtotal),
                  'k');

         writes('  (');
         if pcbsys.printer[1] = '-' then
            writec('P');
         if pcbsys.page_bell[1] = '-' then
            writec('B');
         if pcbsys.alarm[1] = '-' then
            writec('A');
         writec(')');

         if alt_p then
            writec('P');
         if setdebug then
            writec('F');

         tabto(66);
         writec(curfun);
         writes(' (Home)=Help ');
      end;
   end;


   {restore normal display window}
   NormalVideo;
   SetScrollPoint(scroll_line);
   gotoxy(x,y);
end;


(* ------------------------------------------------------------ *)
procedure init_status_display;
   {prepare the screen for status displays}

begin
   NormalVideo;

   if wherey > scroll_line then
   begin
      writeln;
      writeln;
   end;

   SetScrollPoint(scroll_line);
   gotoxy(1,scroll_line);

   update_status_display(normal_format);
end;


(* ------------------------------------------------------------ *)
procedure transfer_status_display;
   {prepare the status display area for execution of a protocol driver}
begin
   FullScreen;
   gotoxy(68,scroll_line+2);
   BlinkVideo;
   writes('**TRANSFER**');
   NormalVideo;
   writeln;
   status_active := false;
end;


(* ------------------------------------------------------------ *)
procedure delete_status_display;
   {completely remove status display from the screen}
begin
   FullScreen;
   gotoxy(1,scroll_line+2);  clreol;
   gotoxy(1,scroll_line+1);  clreol;
   gotoxy(1,scroll_line);
   status_active := false;
end;


(* ------------------------------------------------------------ *)
procedure shell_to_dos;
   {allow the sysop to drop to DOS for a moment}
begin
   FullScreen;
   ClrScr;
   newline;
   newline;
   make_log_entry('Sysop exited to DOS at @SYSTIME@',true);
   flush_com;

   writeln;
   writeln('Type EXIT to return to ',progname);
   
   exec(comspec,'');
   chdir(home_dir);

   clrscr;
   linenum := 1;
   newline;
   newline;
   make_log_entry('Sysop back from DOS at @SYSTIME@',true);
   newline;

   force_new_prompt;
end;


(* ------------------------------------------------------------ *)
procedure redirect_input;
   {alt-i function; redirect input from a file}
begin
   if alt_i then
   begin
      alt_i := false;
      close(alti_fd);
      exit;
   end;

   newline;
   no_hotkeys;
   popup_cmdline('Input from what file:',enter_eq_none);
   if length(cmdline) = 0 then exit;

   if dos_exists(cmdline) then
   begin
      assignText(alti_fd,cmdline);
      {$i-} reset(alti_fd); {$i+}
      alt_i := (ioresult = 0);
   end;

   cmdline := '';
end;



(* ------------------------------------------------------------ *)
procedure toggle(var v: char2);
   {toggle a variable and update status display accordingly}
begin
   if v[1] = '-' then
      v := ' 0'
   else
      v := '-1';
end;

procedure flag(var v: char;  flag: char);
   {toggle the sysop_next flag and update status display accordingly}
begin
   if v = flag then
      v := ' '
   else
      v := flag;
end;


(* ------------------------------------------------------------ *)
procedure dispatch_function_key(c: char);
   {sysop function key dispatch}
begin

   case c of
(***
      'K',                                      {LeftArrow}
      'M',                                      {RightArrow}
      ';',                                      {F1}
      '<',                                      {F2}
      '@':  ;                                   {F6}
***)

      '=':  toggle(pcbsys.printer);             {F3}
      '>':  toggle(pcbsys.page_bell);           {F4}
      '?':  shell_to_dos;                       {F5}
      'A':  toggle(pcbsys.alarm);               {F7}

      'B':  begin
               make_log_entry('Automatic Disconnect Completed!',false);
               display_file(dump_user_message);
               dump_user := true;               {F8}
            end;

      'C':  toggle(pcbsys.display);             {F9}

      'D':  begin                               {F10}
               chat_mode;
               force_new_prompt;
            end;

      'H':  adjust_time_allowed(300);           {UpArrow}
      'P':  adjust_time_allowed(-300);          {DownArrow}

      '0':  begin
{$ifdef OVERLAY}
               write('[A',dos_maxavail,
                     '/B',OvrGetBuf,
                     '/R',OvrGetRetry,
                     '/T',OvrTrapCount,
                     '/L',OvrLoadCount,']');
{$endif}
               writeln(ofs(c),'/',maxavail);    {Alt-B, debug}
            end;

      #33:  if setdebug then                    {Alt-F}
               close_capture
            else
               open_capture;

      #23:  redirect_input;                     {Alt-I}

      '2':  begin                               {Alt-M}
               node_status_display;
               force_new_prompt;
            end;

      '1':  flag(pcbsys.sysop_next,'N');        {Alt-N}

      #25:  begin
               alt_p := not alt_p;              {Alt-P}
               if alt_p then
               begin
                  graphics := false;
                  pcbsys.graphics := 'N';
               end;
            end;

      '-':  flag(pcbsys.sysop_next,'X');        {Alt-X}

      #84..#94:                                 {shift/F1..F10}
            pending_keys := pcbsetup.macro_string[ord(c)-83]^ + ^M;
   end;

   {refresh proper status display after all functions}
   case c of
      'I':  update_status_display(pgup_format); {PgUp}
      'Q':  update_status_display(pgdn_format); {PgDn}
      'G':  update_status_display(help_format); {Home}
      else  update_status_display(normal_format);
   end;
end;


(* ------------------------------------------------------------ *)
procedure process_function_keys;
   {sysop function key handler}
begin
   dispatch_function_key(readkey);
end;


