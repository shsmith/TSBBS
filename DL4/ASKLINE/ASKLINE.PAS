
(*
 * askline - ask for a line of input and the echo it to standard output
 *
 * this is useful in batch files
 *
 * author: s.h.smith, 13-may-86
 *         revised 21-apr-87, shs
 *
 *)

{$p128,g128,d-}

var
   i:     integer;
   line:  string[128];
   fd:    text;
   name:  string[64];
   prefx: string[128];

begin
   if paramcount = 0 then
   begin
      writeln;
      writeln('Usage:  askline PROMPT [@ OUTFILE PREFIX]');
      writeln;
      writeln('Action: Prompts for user input with PROMPT, reads');
      writeln('        a line of input, echoes the line to standard');
      writeln('        output.   When present, @ OUTFILE PREFIX specifies');
      writeln('        that output be appended to OUTFILE and prefixed by');
      writeln('        specified string.');
      writeln;
      writeln('Examples:');
      writeln('  askline Enter backup set number and comment: @ backup.log');
      writeln('  askline View what archive @ tmp.bat pkarc /v');
      writeln;
      halt(1);
   end;

   writeln;
   name := 'con';
   prefx := '';

   i := 1;
   while (i <= paramcount) and (paramstr(i) <> '@') do
   begin
      write(paramstr(i),' ');
      i := i + 1;
   end;

   if paramstr(i) = '@' then
   begin
      name := paramstr(i+1);
      i := i + 2;
      while (i <= paramcount) and (paramstr(i) <> '@') do
      begin
         prefx := prefx + paramstr(i) + ' ';
         i := i + 1;
      end;
   end;

   writeln;
   write('? ');

   flush(output);
   readln(line);

   if name = 'con' then
      writeln(prefx,line)
   else
   begin
      assign(fd,name);
      {$i-} append(fd); {$i+}
      if ioresult <> 0 then
         rewrite(fd);

      writeln(fd,prefx,line);
      close(fd);
   end;
end.

