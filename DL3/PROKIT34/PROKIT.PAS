
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ProKit.PAS - demo program for the ProKit system (3-1-89)
 *
 *)

{!!!IMPORTANT!!! F5 WON'T WORK WITHOUT THE FOLLOWING LINE}
{$M 9000,18000,18000}  {Stack, minheap, maxheap}
{$S-,R-}
{$L+,D+}


Program ProKit_demo;

{$i prokit.inc}    {include standard 'uses' statement}


(* ---------------------------------------------------------------- *)
procedure display_info;
begin
   Pdispln('$WHITE$');
   pdispln(first_name+', here is your User information:$GREEN$');
   displn('   Current date   = '+system_date+' '+system_time);
   displn('   Full name      = '+username);
   displn('   Phone numbers  = '+user.busphone + ' / ' + user.phone);
   displn('   City           = '+user.city);
   displn('   Security level = '+itoa(userlevel));
   displn('   Baud rate      = '+baudrate);

   displn('   Last call date = '+user.date+' '+user.time+
           ', Used = '+itoa(user.lastused)+
           '/'+itoa(pcbsys.prev_used));

   displn('   Conference     = '+conf_info.conf_name+' ('+
                  itoa(pcbsys.curconf)+'/'+
                  itoa(user.curconf)+'/'+
                  itoa(current_conf)+')');

   displn('   TimeOn (mins)  = '+itoa(pcbsys.time_on)+
           ', Now = '+itoa(get_mins));

   displn('   Minutes left   = '+itoa(minutes_left)+
           ', Used = '+itoa(time_used)+
           ', Last = '+itoa(user.lastused)+
           ', Credit = '+itoa(pcbsys.time_credit)+
           ', Limit = '+itoa(pcbsys.time_limit)+
           ', Added = '+itoa(pcbsys.time_added));

   displn('   Event schedule = '+itoa(minutes_before_event)+' minutes');

   displn('   Downloads      = '+itoa(user.downloads)+
            ', Total = '+dtok(user.downtotal)+
            ', Today = '+dtok(user.downbytes)+
            ', Allowed = '+wtoa(download_k_allowed)+'k');

   displn('   Uploads        = '+itoa(user.uploads)+
            ', Total = '+dtok(user.uptotal)+
            ', Earned = '+wtoa(user.earned_k));

   disp  ('   Expert mode    = ');
   if expert then displn('ON') else displn('OFF');

   disp  ('   Graphics       = ');
   if graphics then displn('ON') else displn('OFF');

   displn('   Packed flags   = '+itoa(user.pcbflags));
   displn('   User.inf ptr   = '+ltoa(user.userinf_ptr));
   displn('   Curconfh       = '+wtoa(user.curconfh));

   force_enter;
end;



(* ---------------------------------------------------------------- *)
procedure take_chance;
var
   thinking_of:  anystring;

begin
   {think of a number - based on the time of day}
   thinking_of := itoa(random(9));

   {check for a stacked response- prompt if not}
   if length(cmdline) = 0 then
   begin
      pdispln('$CYAN$I''m thinking of a number from 0 to 9.   If you guess the');
      displn('number, you will be given an extra 10 minutes online.  If you');
      displn('get it wrong, your time will be reduced by 2 minutes.');
      newline;
      pdisp('$YELLOW$What''s your guess? ');
      get_cmdline;
      newline;
   end;

   {get the input and process it}
   get_nextpar;
   if par = thinking_of then
   begin
      pdispln('$GREEN$That''s right!  You get a 10 minute bonus!');
      adjust_time_allowed(10 * 60);
   end
   else

   begin
      pdispln('$BLUE$Wrong!  You lose 2 minutes!  I was thinking of '+thinking_of+'.');
      adjust_time_allowed(-120);
   end;

end;



(* ---------------------------------------------------------------- *)
procedure test_pattern;
var
   i:     integer;
   start: longint;

begin
   flush_com;
   start := lget_ms;
   for i := 1 to 40 do
      displn('(1234567890-abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789)');
   flush_com;
   displn('Speed = '+ftoa(3160000.0 / int(lget_ms - start),0,1)+' char/sec');
end;


(* ---------------------------------------------------------------- *)
procedure ansi_demo;
var
   x,y: integer;

begin
   if not graphics then
   begin
      displn('You must be in GRAPHICS mode to run this demo.');
      displn('Use the (M) command from the main board.');
      exit;
   end;

   pdisp('$GREEN$');
   clear_screen;

   for y := 2 to 21 do
   begin
      position(1,y);  dispc('³');
      position(79,y); dispc('³');
   end;

   position(2,1);
   for x := 2 to 78 do
      dispc('Ä');

   position(2,22);
   for x := 2 to 78 do
      dispc('Ä');

   position(1,1);   dispc('Ú');
   position(79,1);  dispc('¿');
   position(1,22);  dispc('À');
   position(79,22); dispc('Ù');

   position(30,10);  pdisp('$RED$ P r o   K i t ');
   position(12,12);  pdisp('$YELLOW$ This is only a SMALL sample of what ProKit can do! ');
   position(30,18);  pdisp('$WHITE$Press (Enter): ');
   get_cmdline;

   cmdline := '';
   clear_screen;
end;


(* ---------------------------------------------------------------- *)
procedure menu;
begin
   newline;
   pdispln('$GRAY$ProKit DEMO - Based on ProKit '+version);
   newline;

   display_file('prokit.m');  {uses prokit.mg in graphics mode}
   force_enter;
   newline;

   {main command loop}
   repeat

      {prompt for input only if there is not a stacked command pending}
      if length(cmdline) = 0 then
      begin
         newline;
         pdispln('$WHITE$'+  'Main menu:');
         pdispln('$RED$'+    ' (I)  Display system information');
         pdispln('$GREEN$'+  ' (C)  Take a chance for more time online');
         pdispln('$MAGENTA$'+' (T)  Display a test pattern, calculate speed');
         pdispln('$CYAN$'+   ' (A)  Ansi graphics demo');
         pdispln('$RED$' +   ' (G)  Goodbye, hang up');
         pdispln('$BLUE$'+   ' (Q)  Return to PCBoard');
         newline;

         repeat
            display_time_left;
            pdisp('$YELLOW$Command? ');
            get_cmdline;              {get cmdline, map to upper case}
            newline;
         until dump_user or (length(cmdline) > 0);
      end;

      if dump_user then exit;   {leave menu if carrier lost}
      get_nextpar;              {scan next parameter from cmdline into par}

      {process commands}
      case par[1] of
         'I':   display_info;
         'C':   take_chance;
         'T':   test_pattern;
         'A':   ansi_demo;

         'G':   begin
                   dump_user := true;
                   option := o_logoff;
                end;

         'Q':   exit;

         else   pdispln('$MAGENTA$('+par+') is not allowed!  Try again:');
      end;

   until dump_user;

end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}
   progname := 'Demo';        {program name on status line}

   (* the next 4 statements are optional.  If included, they will
      enlarge your EXE file by about 10K, but they will enable access to
      the CONFINFO file as well as to the caller_count function and
      @NUMCALLS@ macro. *)

   load_cnames_file;          {locate or create CONFINFO file}

   load_conf(0);              {locate main message file, enables @NUMCALLS@}
   mainfn := conf_info.conf_msgfile;

   load_conf(current_conf);   {load current conference into conf_info}

   (* perform door functions *)
   display_info;
   menu;                      {insert your code here}

   uninit;   {must be last - closes com port and updates database}
end.

