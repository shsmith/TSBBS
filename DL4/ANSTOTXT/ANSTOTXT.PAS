
(*
 * anstotxt - filter to convert IBM ansii+ascii graphics into pure text
 *
 * shs 9/25/85 (rev 5/10/87 s.h.smith)
 *
 *)

program anstotxt;

{$g5120,p20480,d-,c-,r-,u-}

var
   c: char;
   i: integer;


procedure writetxt;
begin
   case c of
      '»','¼','È','É','Ë','Ê',
      'Õ','Ô','¾','¸','À','¿',
      'Ú','Ù':    write('+');  {corners}

      'Í':        write('=');
      'Ä':        write('-');  {horizontal lines}

      '¶','Ç','Ì','Ã',
      '´','¹','º','Ý',
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

      if c = #27 then
      begin
         read(c);

         if c = '[' then
         begin
            i := 0;

            read(c);
            while (c >= '0') and (c <= '9') or (c = ';') do
            begin
               if c = ';' then
                  i := 0
               else
                  i := i * 10 + ord(c) - ord('0');
               read(c);
            end;

            case c of
               'C':  while (i > 0) do   {expand tabs}
                     begin
                        write(' ');
                        i := i-1;
                     end;

               'J':  writeln;           {skip a line on clear-functions}

               'm':  ;                  {ignore color changes}

               else  begin
                        write('<esc>[',i,c);
                     end;
            end;
         end
         else

         begin
            write(#27);
            writetxt;
         end;
      end

      else
         writetxt;
   end;

end.


