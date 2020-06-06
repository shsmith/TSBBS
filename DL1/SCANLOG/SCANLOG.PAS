
(*
 * scanlog - scan a DSZLOG file and return errorlevels to indicate
 *
 * samuel h. smith, 4-15-93 (revised 5-7-93)
 *
 *)

procedure usage;
begin
   writeln('Usage:');
   writeln('   scanlog LOGFILE -I');
   writeln('     Sets ERRORLEVEL to the number of completed Incoming files');
   writeln;
   writeln('   scanlog LOGFILE -O');
   writeln('     Sets ERRORLEVEL to the number of completed Outgoing files');
   writeln;
   writeln('   scanlog LOGFILE -R');
   writeln('     Sets ERRORLEVEL to the number of aborted incoming files');
   writeln;
   writeln('   scanlog LOGFILE -T');
   writeln('     Sets ERRORLEVEL to the number of aborted outgoing files');
   halt(0);
end;

var
   mode:    char;
   level:   integer;

   txok:    integer;
   txerr:   integer;
   rxok:    integer;
   rxerr:   integer;

   fd:      text;
   line:    string;

begin
   if paramcount <> 2 then
      usage;

   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Error: cannot open logfile: ',paramstr(1));
      writeln('ERRORLEVEL set to 255');
      halt(255);
   end;

   line := paramstr(2);
   if line[1] = '-' then
      delete(line,1,1);
   mode := upcase(line[1]);

   case mode of
      'T','R','I','O':  ;
      else
         writeln('Invalid option specified: -',mode);
         usage;
   end;

   while not eof(fd) do
   begin
      readln(fd,line);

      if length(line) > 60 then
         case line[1] of
            'L','E':
               inc(rxerr);
            'l','e':
               inc(txerr);
            'a'..'z':
               inc(txok);
            'A'..'Z':
               inc(rxok);
         end;
   end;

   close(fd);

   writeln( rxok:3,' successful incoming files (-I)');
   writeln( txok:3,' successful outgoing files (-O)');
   writeln(rxerr:3,' aborted incoming files    (-R)');
   writeln(txerr:3,' aborted outgoing files    (-T)');

   level := 0;
   case mode of
      'I':  level := rxok;
      'O':  level := txok;
      'R':  level := rxerr;
      'T':  level := txerr;
   end;

   writeln('ERRORLEVEL set to ',level);
   halt(level);
end.

