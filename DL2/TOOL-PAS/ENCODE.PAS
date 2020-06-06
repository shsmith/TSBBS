
var
   fd:   file of byte;
   b:    byte;
   sz:   word;

function hex(w: word): string;   {integer to hex conversion}
var
   h:   string;

   procedure digit(ix: integer; ii: word);
   begin
      ii := ii and 15;
      if ii > 9 then 
         ii := ii + 7;
      h[ix] := chr(ii + ord('0'));
   end;

begin
   h[0] := chr(2);
   digit(1,w shr 4);
   digit(2,w);
   hex := h;
end;

function hex2(w: word): string;
begin
   hex2 := hex(w div 255) + hex(w and 255);
end;

procedure owrite(s: string);
var
   i: integer;

begin
   for i := 1 to length(s) do
   begin
      write(s[i]);
   end;
end;

begin
   assign(fd,paramstr(1));
   reset(fd);

   sz := 0;
   while not eof(fd) do
   begin
      if sz mod 8 = 0 then
         owrite(^M^J'E '+hex2(sz+$100)+^M^J);
      read(fd,b);
      owrite(hex(b)+' ');
      inc(sz);
   end;
   close(fd);

   owrite(^M^J^M^J);
   owrite('R CX'^M^J);
   owrite(hex2(sz)+^M^J);
   owrite('N FILE.OUT'^M^J);
   owrite('W 0100'^M^J);
   owrite('Q'^M^J);
end.

