
(*
 * BankList - List Account Data from Savings Bank Door
 *
 * (C) 1988 Samuel H, Smith (05-Feb-88)
 *
 *)

{$M 12000,40000,40000}  {Stack, minheap, maxheap}

Program ListBankRecords;

const
   version = 'BankList v1.6, 11-20-88  (C) 1988 Samuel H. Smith';

type
   account_rec = record
      name:     string[25];
      balance:  integer;
      last:     string[40];
   end;

var
   acctfd:              file of account_rec;
   account:             account_rec;
   sum:                 longint;
   n:                   word;

begin
   if paramcount = 0 then
   begin
      writeln(version);
      writeln('Usage:   banklist ACCOUNTING_FILE >LISTING_FILE');
      writeln('Example: banklist bank.dat >\pcb\gen\blt14');
      halt;
   end;

   assign(acctfd,paramstr(1));
   filemode := $42;  {deny none share mode}
   reset(acctfd);

   writeln;
   writeln('Account Name            Balance            Last Transaction');
   writeln;

   n := 0;
   sum := 0;
   while not eof(acctfd) do
   begin
      read(acctfd,account);

      if account.name <> '*' then
      begin
         inc(n);
         sum := sum + longint(account.balance);
         writeln(account.name,' ':26-length(account.name),
                 account.balance:3,'      ',
                 account.last);
      end;
   end;

   writeln;
   writeln('There are ',n,' active accounts.');
   if n <> 0 then
      writeln('Average balance is ',sum div n,' minutes.');
   writeln('Total savings of ',sum,' minutes.');

   close(acctfd);
end.

