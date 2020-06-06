
(*
 * Copyright 1987, 1992 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

{!!!IMPORTANT!!! F5 WON'T WORK WITHOUT THE FOLLOWING LINE}
{$M 9000,18000,18000}  {Stack, minheap, maxheap}
{$S-,R-}
{$L+,D+}
{$V-}

Program earnings_bank_door;

Uses
   Dos,
   MiniCrt,    {BIOS-only crt functions}
   OpenShare,  {Shared text files}
   MdosIO,     {Dos-level random access files}
   BufIO,      {Buffered record i/o}
   qRead,      {Quick string qReadLn procedure}
   Tools,      {Various utilities}
   ProBye,
   ProData,    {ProDoor/pcboard data}
   ProRoot,    {ProKit main support library}
   ProSysf,    {ProKit Status display, function keys, system functions}
   ProScan,    {File display and colorization}
   ProUtil,    {ProKit utility library #1}
   ProUtil2,   {proKit utility library #2}
   KitInit;    {ProKit initialization/deinit}

const
   door_version = 'Earned K Bytes Banking Door 1.2 (09-26-92)';

type
   bank_rec = record
      name1:   char25;
      balance: longint;
      spare:   char35;
   end;

var
   bankfd:  buffered_file;
   bankrec: bank_rec;
   bankrn:  longint;

const
   bankfile = 'EARNBANK.DAT';


(* ---------------------------------------------------------------- *)
procedure locate_account;
begin
   if not dos_exists(bankfile) then
   begin
      bcreate(bankfile);
      make_log_entry('New banking database file created!',true);
   end;

   pdispln('$YELLOW$Searching for '+username+' in EarnBank file ...');
   bopen(bankfd,bankfile,50,sizeof(bankrec));
   fillchar(bankrec,sizeof(bankrec),0);

   bankrn := 0;
   bread(bankfd,bankrec);
   while not berr do
   begin
      if (bankrec.name1 = pcbsys.name) then
      begin
         displn('Your EarnBank records are stored in account #'+ltoa(bankrn+1)+'!');
         exit;
      end;
      inc(bankrn);
      bread(bankfd,bankrec);
   end;

   displn(username+' not found!');
   displn('A new EarnBank account #'+ltoa(bankrn+1)+' will now be created...');

   fillchar(bankrec,sizeof(bankrec),0);
   bankrec.name1 := pcbsys.name;
   bseek(bankfd,bankrn);
   bwrite(bankfd,bankrec);
end;

(* ---------------------------------------------------------------- *)
procedure update_account;
begin
   bseek(bankfd,bankrn);
   bwrite(bankfd,bankrec);
   pdispln('$YELLOW$EarnBank account #'+ltoa(bankrn+1)+' updated!');
   displn('Current K bytes in bank = '+ltoa(bankrec.balance));
end;

(* ---------------------------------------------------------------- *)
procedure load_config;
var
   fd:   text;

begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd);
   close(fd);
end;


(* ---------------------------------------------------------------- *)
procedure do_deposit;
var
   max_amt: longint;
   amt:     longint;
   i:       integer;
begin
   max_amt := user.earned_k;
   if max_amt = 0 then
   begin
      displn('No K Bytes available to deposit!');
      exit;
   end;

   if length(cmdline) = 0 then
      get_def('K Bytes to deposit, up to '+ltoa(max_amt)+': ',enter_eq_none);

   get_nextpar;
   if (par <> '') and (par[1] >= '0') and (par[1] <= '9') then
   begin
      val(par,amt,i);
      if (amt > 0) and (amt <= max_amt) then
      begin
         bankrec.balance := bankrec.balance + amt;
         user.earned_k := user.earned_k - amt;
         displn(ltoa(amt)+' K Bytes added to EarnBank account!');
      end
      else
         displn('Invalid amount!  Must be between 1 and '+ltoa(max_amt)+'!');
   end;

end;

(* ---------------------------------------------------------------- *)
procedure do_withdrawal;
var
   max_amt: longint;
   amt:     longint;
   i:       integer;
begin
   if (bankrec.balance = 0) then
   begin
      displn('No K bytes available to withdraw!');
      displn('You must first deposit before you can withdraw!');
      exit;
   end;

   if (user.earned_k = $FFFF) then
   begin
      displn('You are already at the K byte limit!');
      exit;
   end;

   max_amt := bankrec.balance;
   if max_amt > ($FFFF-user.earned_k) then
      max_amt := $FFFF-user.earned_k;

   if length(cmdline) = 0 then
      get_def('K Bytes to withdraw, up to '+ltoa(max_amt)+': ',enter_eq_none);

   get_nextpar;
   if (par <> '') and (par[1] >= '0') and (par[1] <= '9') then
   begin
      val(par,amt,i);
      if (amt > 0) and (amt <= max_amt) then
      begin
         bankrec.balance := bankrec.balance - amt;
         user.earned_k := user.earned_k + amt;
         displn(ltoa(amt)+' K Bytes taken from EarnBank account!');
      end
      else
         displn('Invalid amount!  Must be between 1 and '+ltoa(max_amt)+'!');
   end;

end;

(* ---------------------------------------------------------------- *)
procedure main;
begin
   load_config;
   cmdline := getenv('PCBDOOR');

   locate_account;

   repeat

      {prompt for input only if there is not a stacked command pending}
      if length(cmdline) = 0 then
      begin
         newline;
         pdispln( '$GRAY$Current K bytes available = '+ltoa(user.earned_k));
         pdispln(       'Current K bytes in bank   = '+ltoa(bankrec.balance));
         newline;
         pdispln('$WHITE$EarnBank Commands: ');
         pdispln('$GREEN$   (D)  Deposit K bytes for later use');
         pdispln(       '   (W)  Withdraw K bytes to use now');
         pdispln(       '   (Q)  Return to BBS');
         newline;

         repeat
            pdisp('$YELLOW$EarnBank Command: $GREEN$(D)eposit, (W)ithdraw, (Q)uit? ');
            get_cmdline;              {get cmdline, map to upper case}
            newline;
         until dump_user or (length(cmdline) > 0);
      end;

      if dump_user then exit;   {leave menu if carrier lost}
      get_nextpar;              {scan next parameter from cmdline into par}

      if par<> '' then
      case par[1] of
         'D':  do_deposit;
         'W':  do_withdrawal;
         'Q':  ;
         else  displn('What?  Please re-enter command!');
      end;
   until (par[1] = 'Q');

   update_account;
   bclose(bankfd);
end;

(* ---------------------------------------------------------------- *)

begin  {main block}
   {clrscr;}

   init;     {must be first - opens com port, loads setup and user data}
   progname := 'EarnBank';        {program name on status line}

   newline;
   pdispln('$GRAY$'+door_version);
   displn('Copyright 1992 Samuel H. Smith');
   newline;

   main;

   uninit;   {must be last - closes com port and updates database}
end.

