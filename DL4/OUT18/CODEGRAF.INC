
procedure code_graph(var fd: text);
type
   halfcga = array [0..99] of array [1..80] of byte;
var
   cgae:     halfcga absolute $ba00:0;
   cgao:     halfcga absolute $b800:0;
   b:        byte;
   o:        byte;
   x,y:      integer;
   grafcols: integer;


   procedure flip;   {flip over high and low order bits in a char}
   begin
      o := 0;
      if (b and $01) <> 0 then o := o + $80;
      if (b and $02) <> 0 then o := o + $40;
      if (b and $04) <> 0 then o := o + $20;
      if (b and $08) <> 0 then o := o + $10;
      if (b and $10) <> 0 then o := o + $08;
      if (b and $20) <> 0 then o := o + $04;
      if (b and $40) <> 0 then o := o + $02;
      if (b and $80) <> 0 then o := o + $01;
   end;


begin
   for x := 80 downto 1 do
   begin
      grafcols := 400;
      write(fd,#27,'K',chr(lo(grafcols)),chr(hi(grafcols)));
                                    { select single density graphics on an
                                      IBM compatible printer, and reserve
                                      graph columns for one line of print }
      for y := 0 to 99 do
      begin
         b := cgao[y][x]; flip; write(fd,chr(o),chr(o));
         b := cgae[y][x]; flip; write(fd,chr(o),chr(o));
      end;

      write(fd,#27,'1');   {set line spacing so lines will touch}
      writeln(fd);
      write(fd,#27,'2');   {restore to default line spacing}

      if keypressed then
         exit;
   end;

end;

