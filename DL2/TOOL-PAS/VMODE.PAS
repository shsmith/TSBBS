
uses dos,tools;

var
   reg:  registers;
   s:    string;

begin
   if paramcount <> 1 then
   begin
      writeln('usage: vmode VIDEOMODE');
      writeln('       vmode $HEXMODE');

      writeln;
      writeln('VGA video modes');
      writeln('   3     80x25 color text');
      writeln('   7     80X25 mono text');
      writeln('   $12   80x30 color graphics');
      writeln('   $50   80x30 color text');
      writeln('   $51   80x43 color text');
      writeln('   $52   80x60 color text');
      writeln('   $53  132x25 color text 1056x');
      writeln('   $54  132x30 color text 1056x');
      writeln('   $55  132x43 color text 1056x');
      writeln('   $56  132x60 color text 1056x');
      writeln('   $57  132x25 color text 1188x');
      writeln('   $58  132x30 color text 1188x');
      writeln('   $59  132x43 color text 1188x');
      writeln('   $5A  132x60 color text 1188x');
      writeln('   $5B  100x75 color graphics');
      writeln('   $5F  128x48 color graphics');
      writeln('   $61   96x64 color graphics');

      halt;
   end;

   s := paramstr(1);
   if s[1] = '$' then
      reg.ax := htoi(copy(s,2,99))
   else
      reg.ax := atoi(paramstr(1));
   intr($10,reg);
end.

