
var
   i:  integer;
   j:  integer;

begin
   j := 1;
   for i := 0 to 255 do
   if not (i in [10,13,7,8,9,26{,32..127}]) then
   begin
      write(i:3,'=',chr(i));
      if (j mod 13) = 0 then
      begin
         writeln;
         j := 0;
      end
      else
         write(' ');
      j := j + 1;
   end;

end.
