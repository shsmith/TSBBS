
(*
 * BankSort - Sort Account Data from Savings Bank Door
 *
 * (C) 1988 Samuel H, Smith (05-Feb-88)
 *
 *)

{$M 5000,40000,65535}  {Stack, minheap, maxheap}

Program SortBankRecords;

const
   version = 'BankSort v1.6, 11-20-88  (C) 1988 Samuel H. Smith';
   maxaccount = 2000;

type
   account_ptr = ^account_rec;
   account_rec = record
      name:     string[25];
      balance:  integer;
      last:     string[40];
   end;

var
   acctfd:      file of account_rec;
   account:     array[1..maxaccount] of account_ptr;
   accounts:    integer;
   i:           integer;
   swapped:     boolean;
   temp:        account_ptr;

begin
   writeln(version);

   if paramcount = 0 then
   begin
      writeln('Usage:   banksort ACCOUNTING_FILE ');
      writeln('Example: banksort bank.dat');
      halt;
   end;

   {load the accounts into memory}
   assign(acctfd,paramstr(1));
   filemode := $42;  {deny none share mode}
   reset(acctfd);
   write('Loading...   ');
   accounts := 0;
   while not eof(acctfd) do
   begin
      inc(accounts);
      new(account[accounts]);
      read(acctfd,account[accounts]^);
   end;
   close(acctfd);
   write(accounts,' accounts.  ');

   {your basic bubble sort}
   write('Sort...  ');
   repeat
      swapped := false;

      for i := 1 to accounts-1 do
         if account[i]^.name > account[i+1]^.name then
         begin
            temp := account[i];
            account[i] := account[i+1];
            account[i+1] := temp;
            swapped := true;
         end
         else

         if account[i]^.name = account[i+1]^.name then
         begin
            inc(account[i]^.balance, account[i+1]^.balance);
            account[i+1]^.name := '*';
            swapped := account[i]^.name <> '*';
            write('!');
         end;

   until not swapped;

   {write out the new bank file}
   write('Save...   ');
   filemode := $42;  {deny none share mode}
   rewrite(acctfd);
   for i := 1 to accounts do
      if account[i]^.name <> '*' then
         write(acctfd,account[i]^);

   close(acctfd);
   writeln;
end.

