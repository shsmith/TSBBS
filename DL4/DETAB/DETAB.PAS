
{$g10240,p1024,d-,c-}

var
   i:  integer;
   c:  char;

begin
   i := 0;
   while not eof do
   begin
      read(c);
      case c of
         ^I:  begin
                 write(' ');
                 i := i + 1;
                 while (i mod 8) <> 0 do
                 begin
                    i := i + 1;
                    write(' ');
                 end;
              end;

         ^J:  begin
                 writeln;
                 i := 0;
              end;

         else begin
                 write(c);
                 i := i + 1;
              end;
      end;
   end;

end.
