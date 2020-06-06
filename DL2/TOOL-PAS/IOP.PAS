
function itoh(i: longint): string;   {integer to hex conversion}
var
   h:   string;
   w:   word;

   procedure digit(ix: integer; ii: word);
   begin
      ii := ii and 15;
      if ii > 9 then 
         ii := ii + 7;
      h[ix] := chr(ii + ord('0'));
   end;

begin
   w := i and $FFFF;
   h[0] := chr(4);
   digit(1,w shr 12);
   digit(2,w shr 8);
   digit(3,w shr 4);
   digit(4,w);
   itoh := h;   
end;

var
   p: integer;
   d: integer;
   i: integer;
begin
  for p := $280 to $44f do
  begin
    write(itoh(p):5,': ');
    for i := 1 to 14 do
       write(copy(itoh(port[p]),3,2):4);
    writeln;
   end;
end.
