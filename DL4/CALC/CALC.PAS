
(*
 * calc - simple rpn calculator.   works on command line or
 *        with interactive inputs.  based on rpn calculator
 *        package for unit conversions.
 *
 * author: s.h.smith, 17-mar-86 (rev. 20-aug-87)
 *
 *)

type
   anystring = string[128];

var
   i:      integer;
   value:  real;
   form:   anystring;


procedure MISC_fatal_error(message: anystring);
begin
   writeln('Error: ',message);
   halt;
end;


{$I \shs\tools\rpncalc.inc}



procedure hexdigit(d: integer);
begin
   d := d and $0f;
   if d > 9 then
      d := d + 7;
   write(chr(d+ord('0')));
end;


function real_to_int(r: real): integer;
var
   i: integer;
   t: integer;

begin
   t := 0;

   while (r > 32767.0) and (t < 10000) do
   begin
      r := r - 65536.0;
      t := t + 1;
   end;

   while (r < -32767.0) and (t < 10000) do
   begin
      r := r + 65536.0;
      t := t + 1;
   end;

   if r = 32768.0 then
      i := $8000
   else
      i := trunc(r);

   real_to_int := i;
end;



procedure writeval(v: real);
var
   c:  char;
   i:  integer;
   n:  integer;
   vh: real;
   vl: real;
   b:  string[80];
   b1: string[80];

begin
   str(v:40:19,b);

   b1 := '';
   for i := 1 to 17 do         {insert commas}
      if (i mod 3) = 0 then
         if b[i+2] <> ' ' then
            b1 := b1 + copy(b,i,3) + ',';
   b := b1 + copy(b,18,33);

   while b[1] = ' ' do          {remove leading spaces}
      b := copy(b,2,length(b));

   while (b[length(b)] = '0') and (b[length(b)-1] <> '.') do
      b[0] := pred(b[0]);       {remove trailing zeros}

   write('   decimal ',b,'':18-length(b));

   vh := int(v / 65536.0);
   vl := v - vh*65536.0;

   write('   hex ');

   if (vh <> 0) then
   begin
      n := real_to_int(vh);
      hexdigit(n shr 12);
      hexdigit(n shr 8);
      hexdigit(n shr 4);
      hexdigit(n);
      write(' ');
   end;

   n := real_to_int(vl);
   hexdigit(n shr 12);
   hexdigit(n shr 8);
   hexdigit(n shr 4);
   hexdigit(n);
   writeln;

end;


begin {main}

   if paramcount = 0 then
   begin
      writeln('RPN Calculator.   Enter a blank line to exit.');
      value := 0.0;
      repeat
         write('Formula: ');
         readln(form);
         if form <> '' then
         begin
            value := MISC_rpn_calc(value,form);
            writeVAL(value);
         end;
      until (form = '');
      writeln('End calc');
   end
   else

   begin
      form := '';
      for i := 1 to paramcount do
         form := form + paramstr(i) + ' ';

      value := 0;
      value := MISC_rpn_calc(value,form);
      writeVAL(value);
   end;

   flush(output);
end.

