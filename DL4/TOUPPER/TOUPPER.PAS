
program MAPfiletoUPPERcase(input,output);

{$g2560,p25600}


var c: char;

begin
   while not eof do
   begin
      read(c);
      C := UPCASE(C);
      write(c);
   end;
   flush(output);
end.

