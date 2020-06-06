
(*
 * cndump - dump cnames file
 * s.h.smith, 22-sep-93
 *
 *)

const
   lines_per_conf = 33;
   confid_line = 1;
   netid_line = 27;
   seclev_line = 23;

var
   fd:      text;
   idfd:    text;
   confid:  string;
   netid:   string;
   pnetid:  string;
   cnum:    integer;
   i,j:     integer;
   line:    string;
   seclev:  string;
   convert: boolean;

begin
   assign(fd,'cnames');
   reset(fd);

   assign(idfd,'cnames.id');
   {$i-} reset(idfd); {$i+}
   convert := ioresult <> 0;
   if convert then
      rewrite(idfd);

   pnetid := '';
   cnum := 0;

   while not eof(fd) do
   begin
      for i := 1 to lines_per_conf do
      begin
         readln(fd,line);

         for j := 1 to length(line) do
            if line[j] = '\' then
               line[j] := ' ';

         case i of
            confid_line: confid := line;
            netid_line:  netid := line;
            seclev_line: seclev := line;
         end;
      end;

      if convert then
         writeln(idfd,netid)
      else
         readln(idfd,netid);

      if (confid <> '') and (confid <> 'SPARE') and (seclev <> '120') then
      begin
         if netid <> pnetid then
         begin
            if netid <> '' then
            begin
               writeln;
               writeln(netid,':');
            end;
            pnetid := netid;
         end;

         write(cnum:4);
         if seclev = '0' then
            write(' ')
         else
            write('*');
         writeln(confid);
      end;

      inc(cnum);
   end;
   writeln;
   close(fd);
   close(idfd);
end.

