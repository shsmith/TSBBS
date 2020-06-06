
(*
 * randwel - select random welcome screens for PCBoard and most other
 *           BBS programs.
 *
 * Copyright 1992 Samuel H. Smith.
 *
 *)

{$M 8000,8000,8000}

uses dos;

const
   config_file = 'RANDWEL.CFG';
   version = 'v1.0 of 3/27/92';
   max_rand = 200;

var
   fd:         text;
   destfile:   string;
   srcfile:    array[1..max_rand] of string[65];
   count:      integer;
   r:          integer;
   command:    string;

procedure usage(msg: string);
begin
   writeln;
   writeln('RANDWEL - Random welcome selection utility  ',version);
   writeln('Copyright 1992 Samuel H. Smith');
   writeln;
   writeln('Error:   ',msg);
   writeln;
   writeln('Usage:   randwel CONFIG_FILE');
   writeln('Example: randwel randwel.cfg');
   halt;
end;

begin
   randomize;
   if paramcount <> 1 then
      usage('No configuration file specified');

   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      usage('Can''t open configuration file: '+paramstr(1));

   readln(fd,destfile);
   count := 0;
   while not eof(fd) do
   begin
      if count < max_rand then
         inc(count);
      readln(fd,srcfile[count]);
   end;
   close(fd);

   r := random(count)+1;
   command := 'copy '+srcfile[r]+' '+destfile+' >nul';
   writeln(command);
   exec(getenv('COMSPEC'),'/c '+command);
end.

