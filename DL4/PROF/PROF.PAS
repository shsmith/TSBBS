{$p10240}

type
   string4 =           string [4];
                              {String of length 4}
function Hex (HexInt:             integer): string4;
                           { Converts an integer into a four character
                             hexadecimal string }

const
   HexCh : array [0..15] of char = '0123456789ABCDEF';

var
   HexHi,
   HexLo:              integer;

begin

   HexHi := Hi (HexInt);
   HexLo := Lo (HexInt);
   Hex := HexCh [HexHi div 16]+ HexCh [HexHi - 16 *(HexHi div 16)]+ HexCh [
         HexLo div 16]+ HexCh [HexLo - 16 *(HexLo div 16)];
end;

type
   sorec = record
      s,o: integer;
   end;

var
   fd:  file of sorec;
   r:   sorec;

begin
   assign(fd,'samples.out');
   reset(fd);
   while not eof(fd) do
   begin
      read(fd,r);
      writeln(hex(r.s),':',hex(r.o));
   end;
   close(fd);
end.                       { End loop over the number of samples }
