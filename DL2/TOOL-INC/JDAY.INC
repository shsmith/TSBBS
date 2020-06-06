(* ------------------------------------------------------------ *)
function jday(day,month,year: word): longint;
var
   c:       longint;
   julian:  longint;
const
   num2 = 146097;
   num1 = 1721119;
begin
   if (month > 2) then
      dec(month,3)
   else
   begin
      inc(month,9);
      dec(year);
   end;

   c := year div 100;
   year := year - 100*c;
   julian :=  (num1*c) div 4;
   julian := julian + (1461*year) div 4;
   julian := julian + (153*month+2) div 5;
   julian := julian + day+num2;
   jday := julian;
end;

