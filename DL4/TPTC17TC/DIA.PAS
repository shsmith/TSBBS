uses tp3;

(*
 * hardware diagnostic utility
 * s.h.smith, 13-jan-87
 *
 *)
{$c-}

type
   anystring = string[80];
var
   hardware:  char;

function digit(i: integer): char;
begin
   i := i and 15;
   if i > 9 then i := i + 7;
   digit := chr(i + ord('0'));
end;

function itoh(i: integer): anystring;
begin
   itoh := {digit(i shr 12) + digit(i shr 8) + }
            digit(i shr 4) + digit(i);
end;

function itob(i: integer): anystring;
const
   bits: array[0..15] of anystring =
      ('0000','0001','0010','0011',
       '0100','0101','0110','0111',
       '1000','1001','1010','1011',
       '1100','1101','1110','1111');
begin
   itob := bits[(i shr 4) and 15] + bits[i and 15];
end;

function htoi(h:anystring): integer;
var
   i,j: integer;
begin
   j := 0;
   for i := 1 to length(h) do
      j := j * 16 + pos(upcase(h[i]),'123456789ABCDEF');
   htoi := j;
end;

procedure determine_hardware;
begin
   port[$342] := 6;
   case port[$342] and 7 of
      1:    hardware := 'B';
      7,0:  hardware := 'A';
      else  hardware := 'B';
   end;

   writeln('hardware: rev ',hardware);
end;


procedure readanalog;
var
   h,l: integer;
   s:   anystring;
   d:   char;

begin
   write('display data (y/n/b)? ');
   read(kbd,s[1]);
   d := upcase(s[1]);

   while not keypressed do
   begin
      port[$341] := 0;   {start conversion};
      repeat
        l := port[$342];
      until ((l and $80) = 0) or keypressed;

      l := port[$340];
      h := port[$341];

      case d of
         'Y': write(itoh(h),itoh(l),'    ');
         'B': write(itob(h),itob(l),'    ');
      end;
   end;
end;


procedure readport;
var
   p: integer;
   s: anystring;
   d: integer;

begin
   write('read what port(hex): ');
   readln(s);
   p := htoi(s);

   write('display data(y/n/b)? ');
   read(kbd,s[1]);

   writeln('reading from port $',itoh(hi(p)), itoh(lo(p)));

   if upcase(s[1]) = 'Y' then
   while not keypressed do
      write(itoh(port[p]),'  ')
   else

   if upcase(s[1]) = 'B' then
   while not keypressed do
      write(itob(port[p]),'  ')

   else
      while not keypressed do
         d := port[p];
end;


procedure writetest;
var
   p: integer;
   d: integer;
   d2:integer;
   s: anystring;

begin
   write('write what port(hex): ');
   readln(s);
   p := htoi(s);

   write('write what data(hex): ');
   readln(s);
   d := htoi(s);

   writeln('writing data $',itoh(lo(d)),
           ' to port $',itoh(hi(p)), itoh(lo(p)));

   while not keypressed do
      port[p] := d;
end;



procedure writetoggle;
var
   p: integer;
   d: integer;
   d1: integer;
   s: anystring;
   v: integer;

begin
   write('write toggle to what port(hex): ');
   readln(s);
   p := htoi(s);

   write('toggle from bits(hex): ');
   read(s);
   d := htoi(s);

   write('   to bits(hex): ');
   readln(s);
   d1 := htoi(s);

   writeln('toggle data between $',itoh(d),' and $',itoh(d1),
           ' to port $',itoh(hi(p)), itoh(lo(p)));

   while not keypressed do
   for v := 1 to 5 do
   begin
      port[p] := d;
      port[p] := d1;
   end;
end;


procedure setmux;
var
   m: integer;
begin
   write('what mux channel 0..7: ');
   readln(m);
   port[$342] := m;
end;


procedure pause;
begin
   writeln;
   write('press <enter> to continue');
   readln;
   writeln;
end;

procedure map_ports;
begin
   writeln('DASH8_base_address = $340;');
   writeln('DASH8_data_lo      = $340;   {low data register}');
   writeln('DASH8_data_hi      = $341;   {high data register}');
   writeln('DASH8_start_cmd    = $341;   {start-conversion by writing to this port}');
   writeln('DASH8_op_port      = $342;   {parallel output}');
   writeln('  ANALOG_mux_bits = $07;         {multiplex select bits}');
   writeln('  old_ANALOG_power_supply_enable_bit = $80;');
   writeln('DASH8_ip_port      = $342;   {parallel input}');
   writeln('  hardware_version_mask = $7;');
   writeln('  ANALOG_end_conversion = $80;   {low when conversion is finished}');
   pause;      
end;

var
   cmd: anystring;

begin
 textbackground(0);
 clrscr;

 repeat
   writeln;
   writeln('hardware diagnostic 14-jan-87 (30-apr-87)');
   determine_hardware;

   writeln;
   write('read, write, toggle, analog, mux, ?=map (r/w/t/a/m/?/q)? ');
   read(kbd,cmd[1]);
   writeln(cmd[1]);

   case upcase(cmd[1]) of
      'R':  readport;
      'W':  writetest;
      'T':  writetoggle;
      'A':  readanalog;
      'M':  setmux;
      'Q':  halt;
      '?':  map_ports;
   end;

   if keypressed then
      read(kbd,cmd[1]);

 until true=false;
end.

