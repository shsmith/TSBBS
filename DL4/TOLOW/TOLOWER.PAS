
program ampfiletolowercase(input,output);

{$g2560,p25600,c-,d-,r-}


var
   c:      char;
   offset: integer;

begin
   offset := ord('z') - ord('Z');

   while not eof do
   begin
      read(c);
      if (c >= 'A') and (c <= 'Z') then
         c := chr(ord(c) + offset);
      write(c);
   end;
end.

