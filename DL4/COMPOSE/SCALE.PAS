
const
   chromatic_scale = 'cdefgabC';
   chromatic_freq: array[1..8] of real =
      (523.25, 587.33, 659.26, 698.46, 783.99, 880.0, 987.77, 1046.5);

var
   i: integer;
   scale: string[20];
   n: integer;
   r,m: real;
   ri,mi: boolean;
   hits: string[128];

begin
 scale := chromatic_scale;
 writeln ('note      mult      ratio       n');
 for n := 1 to 10000 do
 begin
   if (n mod 100) =0 then write(n:5,#13);

   hits := '';
   for i := 2 to 7 do
   begin
      m := chromatic_freq[i]/chromatic_freq[1]*int(n);
      r := chromatic_freq[1]/chromatic_freq[i]*int(n+n);

      mi := (m-int(m)) <= 0.02;
      ri := (r-int(r)) <= 0.02;

      if (mi or ri) then
      begin
         hits := hits + scale[i]+'* ';
         if length(hits) > 6 then
         begin
            write (scale[i]:3,m:11:4,r:11:4,n:8);
            if mi then write(' Mult   ');
            if ri then write(' Ratio  ');
            writeln(hits);
         end;
      end;
   end;
 end;
end.
