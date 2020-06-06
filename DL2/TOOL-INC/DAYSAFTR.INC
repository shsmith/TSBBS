
(* --------------------------------------------------------- *)
procedure determine_last_date(days: integer);
   (* determine first_date as n days before today *)
var
   year:    word;
   month:   word;
   day:     word;
   dow:     word;

   procedure itoa2(i: integer; var sp);
   var
      s: array[1..2] of char absolute sp;
   begin
      s[1] := chr( (i div 10) + ord('0'));
      s[2] := chr( (i mod 10) + ord('0'));
   end;


const
   monthdays:  array[1..12] of integer =
      (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

begin
   { get today's date from DOS }
   GetDate(year,month,day,dow);
   year := year - 1900;

   { advance N days }
   while (days > 0) do
   begin
      dec(days);

      if (day < monthdays[month]) then
         inc(day)
      else

      if (month < 12) then
      begin
         inc(month);
         day := 1;
      end
      else

      begin
         inc(year);
         month := 1;
         day := 1;
      end;
   end;

   { format the date for comparison }
 { itoa2(year,firstdate[1]);
   itoa2(month,firstdate[3]);
   itoa2(day,firstdate[5]); }

   writeln('Final date is ',month,'-',day,'-',year);
end;




