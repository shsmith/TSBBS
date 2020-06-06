

(*
 * page - display and set the display page
 *
 * shs 4-sep-85
 *
 *)

program page (output);


type
  regpack = record
              ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
            end;


  anystring = string[132];


var
   curpage:  integer;
   reg:      regpack;


function current_cpu_page: integer;
begin
   reg.ax := $580;
   intr($10,reg);
   current_cpu_page := lo(reg.bx);
end;

procedure set_cpu_page(cpu: integer);
begin
   reg.ax := $581;
   reg.bx := cpu;
   reg.cx := reg.bx;
   intr($10,reg);
end;


function current_crt_page: integer;
begin
   reg.ax := $580;
   intr($10,reg);
   current_crt_page := hi(reg.bx);
end;

procedure set_crt_page(crt: integer);
begin
   reg.ax := $582;
   reg.bx := crt * 256;
   reg.cx := reg.bx;
   intr($10,reg);
end;

procedure cursor_off;
begin
   reg.ax := $100;
   reg.cx := $0F00;
   intr($10,reg);
end;

procedure cursor_on;
begin
   reg.ax := $100;
   reg.cx := $000F;
   intr($10,reg);
end;


procedure title(s: anystring);
begin
   if curpage = 7 then
      curpage := 6
   else
      curpage := 7;

   set_cpu_page(curpage);
   clrscr;
   writeln(s);
   writeln(copy('======================================',1,length(s)));
   writeln;
end;


function select: char;
var
   c: char;
begin
   writeln;
   write('    Select: ');

   set_crt_page(curpage);
   cursor_on;
   read(kbd,c);
   cursor_off;
   select := c;
end;


procedure init;
begin
   curpage := 7;
   cursor_off;
end;


var
   key: char;

begin
   read(key);
   set_cpu_page(ord(key)-ord('0'));
   read(key);
   set_crt_page(ord(key)-ord('0'));
halt;
   init;
   title('screen 1');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   writeln('   1 - menu option description');
   key := select;

   title('screen 2');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   writeln('  ********  2 - menu option description');
   key := select;

   title('screen 3');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   writeln('   3 - menu option description');
   key := select;

   set_crt_page(7);
   set_cpu_page(7);
   clrscr;
   cursor_on;
end.

