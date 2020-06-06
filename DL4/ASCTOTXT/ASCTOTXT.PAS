
(*
 * asctotxt - filter to convert IBM ascii graphics into pure text
 *
 * shs 9/25/85 (rev 5/9/87 s.h.smith)
 *
 *)

program asctotxt;

{$g5120,p20480,d-,c-,r-,u-}

var
   c: char;
   i: integer;



procedure writetxt(c: char);
begin
   case c of
      '»','¼','È','É','Ë',
      '¹','Ê','Ì','Ã','´',
      'Õ','Ô','¾','¸','À',
      'Ú','Ù':    write('+');  {corners}

      'Í':        write('=');
      'Ä':        write('-');  {horizontal lines}

      'º','Ý',
      'Þ','³':    write('|');  {vertical lines}

      '°','±':    write('%');
      '²','Û':    write('#');  {blocks}

      #128..#255: write('.');  {other ibm-ascii chars are lost}

      else        write(c);    {normal characters unchanged}
  end;
end;


begin

   while not eof(input) do
   begin
      read(c);
      writetxt(c);
   end;

end.








