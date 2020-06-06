
(*
 * ProLOT.PAS - Lottery Door for the ProKit system
 *
 * (C) 1988 Samuel H, Smith (02-Feb-88)
 *
 *)

{$M 10000,10000,10000}  {Stack, minheap, maxheap}


Program Lottery;

{$i prokit.inc}    {include standard 'uses' statement}

const
   version = '(ProLot v1.9á, 04-07-90)';

var
   fd:       text;
   driver:   string;   {driver type; taken care of automatically}
   bltname:  string;   {winner bulletin filename}
   pot:      real;     {how many minutes in the jackpot}
   plays:    real;     {how many tickets have been sold}
   house:    real;     {fraction of time payed to deduct for the house}
   odds:     real;     {odds against each ticket winning}
   winner:   string;   {last winner information}
   histname: string;   {winner history file}
   rigged:   boolean;  {is the game rigged to lose?  (set after a win)}



(* ---------------------------------------------------------------- *)
procedure load_info;
   {load the latest information about the lottery game}
begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd,driver);
   readln(fd,bltname);
   readln(fd,pot);
   readln(fd,plays);
   readln(fd,house);
   readln(fd,odds);
   readln(fd,winner);
   readln(fd,histname);
   close(fd);
end;


(* ---------------------------------------------------------------- *)
procedure save_info;
   {save the latest information about the lottery game}
begin
   assignText(fd,config_file);
   rewrite(fd);
   writeln(fd,driver);
   writeln(fd,bltname);
   writeln(fd,pot:0:1);
   writeln(fd,plays:0:0);
   writeln(fd,house:0:2);
   writeln(fd,odds:0:0);
   writeln(fd,winner);
   writeln(fd,histname);
   writeln(fd);
   writeln(fd,'--------------------------');
   writeln(fd,'Configuration file format:');
   writeln(fd);
   writeln(fd,'line 1 = Driver type (HANDSHAKE, INTERRUPT, BIOS, PCBTRAP)');
   writeln(fd,'line 2 = Lottery status bulletin filename');
   writeln(fd,'line 3 = Number of minutes currently in the pot');
   writeln(fd,'line 4 = Number of tickets sold so far');
   writeln(fd,'line 5 = Fraction of time taken aside for sysop');
   writeln(fd,'line 6 = Odds against winning (higher numbers give higher jackpots)');
   writeln(fd,'line 7 = Information about the last winner');
   writeln(fd,'line 8 = Lottery winner history bulletin filename');
   close(fd);
end;


(* ---------------------------------------------------------------- *)
procedure process_bet(num: integer);
var
   payoff:      real;
   roll:        real;
   i:           integer;
   ready:       longint;

begin
   if dump_user then exit;
   pdisp('$GREEN$Ticket #'+ljust(itoa(num),3)+': ');

   plays := plays + 1.0;
   pot := pot + 1.0-house;    {add to pot, but keep some for the house}
   adjust_time_allowed(-60);  {charge 1 minute}

   flush_com;
   ready := lget_ms + 500;
   repeat
      roll := int((random-0.5)*odds);
   until lget_ms >= ready;

   if (roll = 0) and not rigged then
   begin
      rigged := true;  {only allow 1 win per session}
      payoff := int(pot * (1.0-house));

      (* prevent withdrawals before an upcoming event *)
      if (pcbsetup.slide_event = false) and event_run_needed(event_possible) then
         displn('You MUST be off the system by '+pcbsetup.event_time+' due to a scheduled event.');
      
      adjust_time_allowed(trunc(payoff*60.0));
      pot := pot - payoff;

      disp(^G^G);
      displn(aRED+'Is a winner!  You win '+ftoa(payoff,0,0)+' minutes!');

      winner := 'The last winner was '+username+', who won '+ftoa(payoff,0,0)+
                ' minutes on '+system_date + ' ' + system_time + '.';

      make_log_entry('Lottery winner!  Granted '+ftoa(payoff,0,0)+' minutes.',false);

      assignText(fd,histname);
      if dos_exists(histname) then
         append(fd)
      else
      begin
         rewrite(fd);
         writeln(fd);
         writeln(fd,'Lottery winners since '+system_date+'.');
         writeln(fd);
      end;

      writeln(fd,username,' won '+ftoa(payoff,0,0)+
                 ' minutes on '+system_date+' '+system_time+'.');
      close(fd);
   end
   else
      displn(aBLUE+'is a loser.');

end;


(* ---------------------------------------------------------------- *)
procedure play;
   {main play procedure}
var
   i:   integer;
   buy: integer;

begin
   rigged := false;

   displn(aWHITE);
   displn('Welcome to the ProKit lottery!   '+version);
   displn(aRED);
   displn('The odds are '+ftoa(odds,0,0)+':1.  Sysop keeps '+ftoa(house*100,0,0)+'% of the take.');
   displn(aGREEN);
   displn(winner);

   newline;
   pdisp('$YELLOW$Do you want to see a list of lottery winners: (Enter)=yes? ');
   get_cmdline;
   if cmdline[1] <> 'N' then
      display_file(histname);

   repeat
      displn(aWHITE);
      displn('A total of '+ftoa(plays,0,0)+' tickets have been sold.');
      displn('The jackpot now contains '+ftoa(pot,0,0)+' minutes.');
      displn('Tickets cost 1 minute each.');
      newline;

      display_time_left;
      pdisp('$YELLOW$How many would you like to buy: (0 to quit)? ');
      get_cmdline;              {get cmdline, map to upper case}
      newline;

      buy := atoi(cmdline);
      if buy > minutes_left then
         displn('You don''t have that much time!')
      else

      for i := 1 to buy do
         process_bet(i);

   until dump_user or (cmdline = '0') or (minutes_left < 2);

   if not dump_user and (minutes_left < 2) then
   begin
      dump_user := true;
      option := o_logoff;
   end;
   
   newline;
   displn('Thanks for playing the ProKit lottery!  Come back soon...');
end;


(* ---------------------------------------------------------------- *)
procedure generate_blt;
   {generate a lottery status bulletin}
begin
   assignText(fd,bltname);
   rewrite(fd);
   writeln(fd);
   writeln(fd,'ProKit Lottery Statistics!   '+version);
   writeln(fd);
   writeln(fd,winner);
   writeln(fd,'The odds are '+ftoa(odds,0,0)+':1.  Sysop keeps '+ftoa(house*100,0,0)+'% of the take.');
   writeln(fd,'A total of '+ftoa(plays,0,0)+' tickets have been sold.');
   writeln(fd,'The jackpot now contains '+ftoa(pot,0,0)+' minutes.');
   writeln(fd);
   close(fd);
end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}

   progname := 'Lottery';   {program name on status line}
   load_info;               {load info from config file}
   play;                    {insert your code here}
   save_info;               {save latest info}
   generate_blt;            {generate a lottery status bulletin}

   uninit;   {must be last - closes com port and updates database}
end.

