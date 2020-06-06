

(*
 * gtable - graph table
 *
 * This program produces a strip-chart style graph from a table
 * of data (such as that produced by ptable)
 *
 * s.h.smith, 29-apr-87
 *
 * file format:
 *   table title
 *   variable count
 *   title1
 *   title...
 *   title1
 *   var1 var2 ... varn
 *   ...
 *   var1 var2 ... varn
 *
 *)

{$r+}

{$i anystring.inc}
{$i atof.inc}
{$i plotlib.inc}

const
   maxnvar = 16;

type
   table = array[1..maxnvar] of real;

var
   nvar:      integer;
   title:     anystring;
   subtitle:  anystring;
   varname:   array[1..maxnvar] of anystring;
   enable:    string[maxnvar];

   line:   anystring;
   fd:     text[10240];
   val:    table;
   prev:   table;
   scale:  table;
   i:      integer;
   x:      integer;
   y:      real;

procedure find_means;
begin
   reset(fd);
   readln(fd,title);
   readln(fd,nvar);
   for i := 1 to nvar do
      readln(fd,varname[i]);

   for i := 1 to nvar do
      prev[i]:=0;

   x := 0;
   while not seekeof(fd) do
   begin
      x := x + 1;
      for i := 1 to nvar do
      begin
         read(fd,y);
         prev[i] := prev[i] + y;
      end;
   end;

   close(fd);

   for i := 1 to nvar do
   begin
      scale[i] := prev[i] / int(x);
      if scale[i] = 0 then
         scale[i] := 1;
   end;
end;


procedure find_scales;
begin
   minx:=0;    maxx:=x;
   miny:=999;  maxy:=0;
   x := 0;

   reset(fd);
   readln(fd,title);
   readln(fd,nvar);
   for i := 1 to nvar do
      readln(fd,varname[i]);

   while not seekeof(fd) do
   begin
      x := x + 1;
      for i := 1 to nvar do
      begin
         read(fd,y);
         y := 100.0 * y / scale[i];
         if y > maxy then maxy := y;
         if y <> 0 then if y < miny then miny := y;
      end;
   end;

   close(fd);
end;



procedure display_graph;
var
   tick:  integer;
begin
   border;
   gotoxy(1,1);
   write(paramstr(1),' ',title,' -- ',subtitle);
   gotoxy(1,2);

   for i := 1 to nvar do
   if enable[i] <> 'N' then
      write(i,'-',copy(varname[i],1,12),' ');

   x := 0;
   reset(fd);
   readln(fd,title);
   readln(fd,nvar);
   for i := 1 to nvar do
      readln(fd,varname[i]);

   while (x < minx-1) and (not seekeof(fd)) do
   begin
      x := x + 1;
      for i := 1 to nvar do
         read(fd,y);
   end;

   for i := 1 to nvar do
   begin
      read(fd,y);
      val[i] := 100.0 * y / scale[i];
   end;

   tick := trunc(maxx/10);
   if tick < 1 then
      tick := 1;

   while (not seekeof(fd)) and (x <= maxx) and (not keypressed) do
   begin
      x := x + 1;
      prev := val;

      for i := 1 to nvar do
      begin
         read(fd,y);
         val[i] := 100.0 * y / scale[i];

         if enable[i] <> 'N' then
         begin
            connect(x-1,prev[i], x,val[i]);

            if ((x-i-i) mod tick) = 0 then
               marker(x,val[i],i);
         end;
      end;
   end;

   close(fd);
end;

procedure set_enable;
begin
   for i := 1 to nvar do
   begin
      gotoxy(1,24);
      write('Enable [',i,'-',varname[i],']? ');
      while wherex < 78 do write(' ');
      read(kbd,enable[i]);
      if upcase(enable[i]) <> 'Y' then
         enable[i] := 'N';
   end;
   enable[0] := chr(nvar);
end;


procedure load_settings;
var
   fd: text;
begin
   assign(fd,'gtab.set');
   {$i-} reset(fd); {$i+}
   if ioresult = 0 then
   begin
      readln(fd,enable);
      readln(fd,minx);
      readln(fd,maxx);
      readln(fd,miny);
      readln(fd,maxy);
      readln(fd,title);
      close(fd);
   end;
end;

procedure store_settings;
var
   fd: text;
begin
   assign(fd,'gtab.set');
   rewrite(fd);
   writeln(fd,enable);
   writeln(fd,minx);
   writeln(fd,maxx);
   writeln(fd,miny);
   writeln(fd,maxy);
   writeln(fd,title);
   close(fd);
end;


var
   c: char;

begin
   if paramcount <>1 then
   begin
      writeln('usage: gtable FILE ');
      halt;
   end;

   assign(fd,paramstr(1));
   find_means;
   find_scales;
   subtitle := '';
   enable := 'NNYNYNYYNNNNNNNNNNNNNNNNNNNNNNN';
   load_settings;

   repeat
      display_graph;

      repeat
         gotoxy(1,23);
         writeln('0-quit 1-y_scale 2-x_scale 3-traces 4-store 5-load ;-title <enter>-replot:  ');
         while wherex < 78 do write(' ');
         writeln;
         while wherex < 78 do write(' ');
         gotoxy(1,24);
         read(kbd,c);

         case upcase(c) of
            '1':  begin
                  write('  new miny: ');
                  readln(miny);
                  write('  new maxy: ');
                  read(maxy);
               end;

            '2':  begin
                  write('  new minx: ');
                  readln(minx);
                  write('  new maxx: ');
                  read(maxx);
               end;

            '3':  set_enable;

            '4':  store_settings;

            '5':  load_settings;

            ';':  begin
                  write('  new subtitle: ');
                  readln(subtitle);
               end;

         end;

      until (c = ^M) or (c = '0');

   until c = '0';

   textmode;
end.

