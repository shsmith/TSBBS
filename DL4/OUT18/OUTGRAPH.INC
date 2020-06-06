

(*
 * outline - a simple "outline" oriented document generator
 *
 * outgraph.inc - this module contains the procedures
 *                for generating graphic outputs.
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)

var
   reg: regpack;

procedure printc(ch: char);  {print character, 3x faster than dos}
begin
   reg.ax := ord (ch);
   reg.dx := 0;
   intr(23, reg);
end;


procedure code_graph(var fd: textfile;
                     name:   anystring);    {generate printer codes for the
                                             current contents of graphics
                                             memory.   output codes to the
                                             specified file.}
type
   graph_image = record
      evenpart:  record
         case integer of
            1:  (image:  array[1..512] of array[1..16] of byte);
            2:  (pixel:  array[0..99] of array[1..80] of byte);
         end;

      oddpart:  record
         case integer of
            1:  (image:  array[1..512] of array[1..16] of byte);
            2:  (pixel:  array[0..99] of array[1..80] of byte);
         end;
   end;


var
   cga:      graph_image;
   gfd:      file of graph_image;
   b:        byte;
   o:        byte;
   x,y:      integer;
   grafcols: integer;

   procedure flip_out(b: byte);    {flip over high and low order bits in a char and
                                    output it twice to the output file}
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

      printc(chr(o));
      printc(chr(o));
   end;


begin
   assign(gfd,name);
   reset(gfd);
   read(gfd,cga);
   close(gfd);

   for x := 80 downto 1 do
   begin
      grafcols := 400;
      write(fd,'         ',#27,'K',chr(lo(grafcols)),chr(hi(grafcols)));
                                    { select single density graphics on an
                                      IBM compatible printer, and reserve
                                      graph columns for one line of print }

      flush(fd);

      for y := 0 to 99 do
      begin
         flip_out(cga.evenpart.pixel[y][x]);
         flip_out(cga.oddpart.pixel[y][x]);
                           {flip bits and output them as printer codes for
                            the even and odd parts of graphic memory}
      end;

      write(fd,#27,'1');   {set line spacing so lines will touch}
      writeln(fd);
      write(fd,#27,'2');   {restore to default line spacing}

      if keypressed then
         exit;
   end;

end;



procedure print_graph_file(var fd:     textfile;
                           line:       anystring;
                           indent:     integer;
                           var lines:  integer);    {print a graph image file
                                                     on the printer and
                                                     adjust line counter}
var
   name:   anystring;
   i:      integer;

begin

   name := locate_file(copy(line, 2, 255));

   if (prnfile <> 'CON') then
   begin
      gotoxy(10,wherey);
      disp('Graph: '+name);
      clreol;
   end;


   if file_exists(name) then
   begin

      if lineout <> '' then      {flush last reformatted line}
      begin
         writeln(fd, '':indent, lineout);
         lines := lines + 1;
         lineout := '';
      end;

      if (prnfile = 'PRN') and (addr(fd) <> addr(nullfd)) then
         code_graph(fd,name);    {code the graph into printer codes unless
                             output is to the screen}

      writeln(fd);
      lines := lines + 47;    {graphs take 47 lines on the printer}
   end

   else
      writeln(fd, '*** Graphics Include file not found: ', line);
end;

