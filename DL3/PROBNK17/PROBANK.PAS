
(*
 * ProBank.PAS - Savings Bank Door for the ProKit system
 *
 * (C) 1988 Samuel H, Smith (05-Feb-88)
 *
 *)

{$M 12000,10000,10000}  {Stack, minheap, maxheap}
{$V-}                   {Relax string rules}

Program SavingsBank;

{$i prokit.inc}    {include standard 'uses' statement}

const
   version = 'ProBank v1.7á, 04-17-90 (C)1990 S.H.Smith';

type
   account_rec = record
      name:     string[25];
      balance:  integer;
      last:     string[40];
   end;


var
   driver:              string;   {driver type; taken care of automatically}
   acctname:            string;   {accounting data file name}
   maxbalance:          integer;  {largest balance allowed by sysop}
   welcome_file:        string;   {welcome message file}
   menu_file:           string;   {main menu file}
   new_account_file:    string;   {opening new account message}
   close_file:          string;   {closing door message}

   acctfd:              buffered_file;
   account:             account_rec;
   acctnum:             integer;  {record number in accounting file}


(* ---------------------------------------------------------------- *)
procedure load_info;
   {load the latest configuration file}
var
   fd: text;
begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd,driver);
   readln(fd,acctname);
   readln(fd,maxbalance);
   readln(fd,welcome_file);
   readln(fd,menu_file);
   readln(fd,new_account_file);
   readln(fd,close_file);
   close(fd);
end;



(* ---------------------------------------------------------------- *)
procedure open_account;
   {load user information from the accounting file, open new account if needed}
var
   dead: word;
begin
   {create a new accounting file if needed}
   if not dos_exists(acctname) then
      bcreate(acctname);

   {search the file for this user's name}
   bopen(acctfd,acctname,100,sizeof(account));
   dead := 0;
   while not berr do
   begin
      acctnum := btell(acctfd);
      bread(acctfd,account);

      {user found; exit with account rec and acctnum filled in}
      if account.name = username then
      begin
         bclose(acctfd);
         exit;
      end;

      {keep track of the last 'dead' account so it can be reused}
      if account.name = '*' then
         dead := acctnum;
   end;

   {create a new entry in the accounting file for this user}
   display_file(new_account_file);

   if dead = 0 then
      acctnum := btell(acctfd)        {append new record}
   else
      acctnum := dead;                  {reuse highest dead record}

   fillchar(account,sizeof(account),' ');
   account.name := username;
   account.balance := 0;
   account.last := system_date + ' ' + system_time + ' - New account';
   bwrite(acctfd,account);
   bclose(acctfd);
end;


(* ---------------------------------------------------------------- *)
procedure post_account;
   {update the accounting file with the current data}
begin
   bopen(acctfd,acctname,1,sizeof(account));
   bseek(acctfd,acctnum);
   bwrite(acctfd,account);
   bclose(acctfd);
end;


(* ---------------------------------------------------------------- *)
procedure deposit;
   {deposit some time in the account}
var
   amount: integer;
begin
   if length(cmdline) = 0 then
   begin
      pdisp('$YELLOW$Deposit how many minutes? ');
      get_cmdline;              {get cmdline, map to upper case}
      newline;
   end;

   amount := atoi(cmdline);
   if amount < 1 then
      exit;

   if amount > minutes_left then
      amount := minutes_left;

   if amount > maxbalance-account.balance then
   begin
      amount := maxbalance-account.balance;
      pdispln('$RED$You have reached the maximum account balance!');
   end;

   if amount > 0 then
   begin
      account.last := system_date + ' ' + system_time+ ' - Deposited '+itoa(amount)+' minutes';
      inc(account.balance,amount);
      adjust_time_allowed(trunc(-60.0*amount));
   end;

   if minutes_left <= 1 then
   begin
      dump_user := true;
      option := o_logoff;
   end;

end;


(* ---------------------------------------------------------------- *)
procedure withdraw;
   {withdraw some time from the account}
var
   amount: integer;
begin
   if account.balance < 1 then
   begin
      pdispln('$RED$You must be kidding!');
      exit;
   end;

   (* prevent withdrawals before an upcoming event *)
   if (pcbsetup.slide_event = false) then
      if minutes_left+account.balance >= minutes_before_event then
         pdispln('$RED$You MUST be off the system by '+pcbsetup.event_time+' due to a scheduled event!');
   
   if length(cmdline) = 0 then
   begin
      pdisp('$YELLOW$Withdraw how many minutes? ');
      get_cmdline;              {get cmdline, map to upper case}
      newline;
   end;

   amount := atoi(cmdline);
   if amount < 1 then
      exit
   else
   if amount > account.balance then
      displn('That would overdraw your account!')
   else
   if (amount + minutes_left) >= minutes_before_event then
      displn('That would delay the system event!')
   else
   begin
      account.last := system_date + ' ' + system_time+ ' - Withdrew '+cmdline+' minutes';
      dec(account.balance,amount);
      adjust_time_allowed(trunc(60.0*amount));
   end;
end;


(* ---------------------------------------------------------------- *)
procedure kill_account;
   {kill the current account}
begin
   displn('Account killed: '+account.name);
   account.name := '*';
end;


(* ---------------------------------------------------------------- *)
procedure switch_user;
   {change your user name (sysop maintenaince function)}
begin
   if (user.level < 110) then
      exit;
      
   post_account;
   disp('Switch to what user name? ');
   cmdline := account.name;
   line_input(cmdline,26,true,false);
   stoupper(cmdline);
   username := cmdline;
   open_account;
end;


(* ---------------------------------------------------------------- *)
procedure main_menu;
   {main procedure}
begin

   repeat
      newline;
      pdispln('$GREEN$Account number:   '+itoa(acctnum)+'  For '+username);

      displn('Current balance:  '+itoa(account.balance)+' minutes  ('+
                     itoa(maxbalance)+' maximum)');

      displn('Last transaction: '+account.last);

      display_file(menu_file);

      if (user.level >= 110) then
         displn('Sysop functions:  (K)ill, (S)elect user.');

      display_time_left;
      disp('ProBank Command? ');

      get_cmdline;              {get cmdline, map to upper case}
      newline;

      get_nextpar;
      if length(par) > 0 then
         case par[1] of
            'D': deposit;
            'W': withdraw;
            'K': kill_account;
            'S': switch_user;

            'Q': exit;

            'G': begin
                    dump_user := true;
                    option := o_logoff;
                 end;
         end;

   until dump_user or (minutes_left < 1);

   displn('Your balance is now '+itoa(account.balance)+' minutes.');
end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}

   progname := 'ProBank';   {program name on status line, must be 7 characters}
   load_info;               {load info from config file}

   newline;
   displn(version);
   newline;
   display_file(welcome_file);

   open_account;
   main_menu;              
   post_account;

   display_file(close_file);

   uninit;   {must be last - closes com port and updates database}
end.

