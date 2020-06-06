
(*
 * wc - word counting filter
 *
 *)

{$g10240,p128,c-,u-,r+}

var
   lines:     integer;
   words:     real;
   bytes:     real;
   sentences: integer;
   buf:       string[255];
   i:         integer;

begin
   lines := 0;
   bytes := 0;
   words := 0;
   sentences := 0;

   while not eof do
   begin
      readln(buf);
      buf := ' ' + buf;
      bytes := bytes + int(length(buf));
      lines := lines + 1;
      for i := 1 to length(buf)-1 do
      begin
         case buf[i] of
            '.','?',':':   sentences := sentences + 1;
            ' ':           if buf[i+1] <> ' ' then
                              words := words + 1;
         end;
      end;

      if (lines mod 1000) = 0 then
         write(con,lines:6,    ' lines',#13);

   end;

   writeln(lines:6,    ' lines');
   writeln(bytes:6:0,  ' characters');
   writeln(words:6:0,  ' words');
   writeln(sentences:6,' sentences');
end.
