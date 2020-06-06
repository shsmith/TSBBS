
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
 * ProKit.PAS - demo program for the ProKit system (3-1-89)
 *
 *)

{!!!IMPORTANT!!! F5 WON'T WORK WITHOUT THE FOLLOWING LINE}
{$M 6000,14000,14000}  {Stack, minheap, maxheap}
{$S-,R-}
{$L+,D+}


Program ProKit_demo;

{$i prokit.inc}    {include standard 'uses' statement}



(* ---------------------------------------------------------------- *)
procedure display_info;
begin
   displn(WHITE);
   displn(first_name+', here is your User information:'+GREEN);
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
                  itoa(pcbsys.curconf)+'/'+itoa(user.curconf)+')');

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
            'k, Today = '+dtok(user.downbytes)+
            'k, Allowed = '+wtoa(download_k_allowed)+'k');

   displn('   Uploads        = '+itoa(user.uploads)+
            ', Total = '+dtok(user.uptotal)+
            'k, Earned = '+wtoa(user.earned_k)+
            'k');

   disp  ('   Expert mode    = ');
   if expert then displn('ON') else displn('OFF');

   disp  ('   Graphics       = ');
   if graphics then displn('ON') else displn('OFF');

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
      disp(CYAN);
      displn('I''m thinking of a number from 0 to 9.   If you guess the');
      displn('number, you will be given an extra 10 minutes online.  If you');
      displn('get it wrong, your time will be reduced by 2 minutes.');
      newline;
      disp(YELLOW);
      disp('What''s your guess? ');
      get_cmdline;
      newline;
   end;

   {get the input and process it}
   get_nextpar;
   if par = thinking_of then
   begin
      disp(GREEN);
      displn('That''s right!  You get a 10 minute bonus!');
      adjust_time_allowed(10 * 60);
   end
   else

   begin
      disp(BLUE);
      displn('Wrong!  You lose 2 minutes!  I was thinking of '+thinking_of+'.');
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

   disp(GREEN);
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

   disp(RED);
   position(30,10);  disp(' P r o   K i t ');
   disp(YELLOW);
   position(12,12);  disp(' This is only a SMALL sample of what ProKit can do! ');
   disp(WHITE);
   position(30,18);  disp('Press (Enter): ');
   get_cmdline;

   cmdline := '';
   clear_screen;
end;


(* ---------------------------------------------------------------- *)
procedure menu;
begin
   newline;
   displn(GRAY);
   displn('ProKit DEMO - Based on ProKit '+version);
   newline;
   display_file('prokit.m');  {uses prokit.mg in graphics mode}
   force_enter;
   newline;

   {main command loop}
   repeat

      {prompt for input only if there is not a stacked command pending}
      if length(cmdline) = 0 then
      begin
         displn(WHITE);
         displn('Main menu:');
         displn(RED    +' (I)  Display system information');
         displn(GREEN  +' (C)  Take a chance for more time online');
         displn(MAGENTA+' (T)  Display a test pattern, calculate speed');
         displn(CYAN   +' (A)  Ansi graphics demo');
         displn(RED    +' (G)  Goodbye, hang up');
         displn(BLUE   +' (Q)  Return to PCBoard');
         newline;

         repeat
            display_time_left;
            disp(YELLOW+'Command? ');
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

         else   displn(MAGENTA+'('+par+') is not allowed!  Try again:');
      end;

   until dump_user;

end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}
   progname := 'Demo';        {program name on status line}

   load_cnames_file;          {locate or create CONFINFO file}
   load_conf(user.curconf);   {load current conference into conf_info}

   display_info;
   menu;                      {insert your code here}

   uninit;   {must be last - closes com port and updates database}
end.

