
{$g512,p80,d-}

type
   anystring = string[128];

var
   line: anystring;
   c:    char;
   i:    integer;

begin
   while (not eof) and (not keypressed) do
   begin
      readln(line);
      if line = '' then writeln
      else
      begin
         c := copy(line,1,1);
         line := copy(line,2,128);
         case c of
            '1':      write(^L);
            '+':      write(#13);
            '-':      begin writeln; writeln; end;
            else      writeln;
         end;
         write(line);
         flush(output);
      end;
   end;

end.
