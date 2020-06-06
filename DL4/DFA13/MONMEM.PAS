
(*
 * monmem - monitor a memory location
 *
 * s.h.smith, 18-nov-86
 *
 *)

{$i \shs\tools\regpack.inc}
{$i \shs\tools\givetime.inc}

type
   string2 = string[2];
   string4 = string[4];
   anystring = string[80];

var
   screen_image: array[1..25] of anystring;


procedure displn(s:anystring);
begin
   if screen_image[wherey] <> s then
   begin
      screen_image[wherey] := s;
      write(s);
{     give_up_time; }
   end;
   writeln;
end;


function hex2(b: byte): string2;
   function hex1(b:byte): char;
   begin
      b := b and 15;
      if b > 9 then b := b + 7;
      hex1 := chr(b+ord('0'));
   end;
begin
   hex2 := hex1(b shr 4) + hex1(b);
end;


function hex4(i:integer): string4;
begin
   hex4 := hex2(hi(i)) + hex2(lo(i));
end;



procedure dump_memory(segment,offset: integer);
type
   byte16 = array[1..16] of byte;
   byteptr = ^byte16;
var
   dat: byteptr;
   i:   integer;
   s:   anystring;

begin
   dat := ptr(segment,offset);

   s := hex4(segment)+':'+hex4(offset)+' ';
   for i := 1 to 16 do
      s := s + ' '+hex2(dat^[i]);

   s := s + '  ';
   for i := 1 to 16 do
      case dat^[i] of
         32..255:
            s := s + chr(dat^[i]);
         else
            s := s + '.';
      end;

   displn(s);
end;



procedure dump_range;
var
   segment,offset: integer;
   i:              integer;

begin
   segment := $7995;
   offset := $100;
   for i := 1 to 6 do
   begin
      dump_memory(segment,offset);
      offset := offset + 16;
   end;
end;


procedure init;
var
   i: integer;
begin
   clrscr;
   for i := 1 to 25 do
      screen_image[i] := '';
end;


begin
   init;
   repeat
      gotoxy(1,2);
      dump_range;
      give_up_time;
   until keypressed;
end.
