
(*
 * DirC - DIR file concatenation utility
 *
 * Written by Samuel H. Smith, 5-17-91
 *
 *)

var
   infd:    text;
   inbuf:   array[1..10000] of char;
   outfd:   text;
   outbuf:  array[1..20000] of char;

   line:    string;
   p:       integer;

   mode:    (concat, expand);

procedure usage;
begin
   writeln('usage: dirc -concat INFILE OUTFILE');
   writeln(' or    dirc -expand INFILE OUTFILE');
   halt(1);
end;

procedure concat_file;
begin
   readln(infd,line);
   repeat
      if line <> '' then
      begin
         p := pos('.',line);
         if (p > 1) and (p < 10) and (line[23] = ' ') and (line[26] = '-') then
         begin
            writeln(outfd,line);
            repeat
               if eof(infd) then
                  line := ''
               else
                  readln(infd,line);
               p := pos('|',line);
               if p > 0 then
                  writeln(outfd,line);
            until p = 0;
            writeln(outfd);
         end
         else
            readln(infd,line);
      end
      else
         readln(infd,line);
   until eof(infd);
end;

procedure expand_file;
begin
   while not eof(infd) do
   begin
      readln(infd,line);
      if line <> '' then
         writeln(outfd,line);
   end;
end;

begin
   if paramcount <> 3 then
      usage;

   line := paramstr(1);
   if line[1] <> '-' then
      usage;

   case upcase(line[2]) of
      'C':  mode := concat;
      'E':  mode := expand;
      else  usage;
   end;

   assign(infd,paramstr(2));
   reset(infd);
   settextbuf(infd,inbuf);

   assign(outfd,paramstr(3));
   rewrite(outfd);
   settextbuf(outfd,outbuf);

   if mode = concat then
      concat_file
   else
   if mode = expand then
      expand_file
   else
      usage;

   close(infd);
   close(outfd);

end.

