
(*
 * cunique - filter to pass only unique lines, with count of duplicates
 *
 * assumes that input is sorted
 * so that duplicates will be adjacent
 *
 * shs 29-aug-85 (rev 26-may-87)
 *
 *)

{$g1024,p10240,c-,d-}


procedure usage;
begin
   writeln(con,'Cunique v2.0, LAST_UPDATE');
   writeln(con);
   writeln(con,'Usage:  cunique <infile >outfile');
   writeln(con,'  or    cunique <infile >outfile FIRST_COL LENGTH');
   halt;
end;


var
   line, pline:  string[255];
   lines:        integer;
   cnt:          integer;
   first:        integer;
   len:          integer;
   k:            integer;

begin
   if paramcount = 0 then
   begin
      first := 1;
      len := 255;
   end
   else

   if paramcount = 2 then
   begin
      val(paramstr(1),first,k);
      if k <> 0 then usage;
      val(paramstr(2),len,k);
      if k <> 0 then usage;
   end
   else
      usage;

   lines := 0;
   pline := '\\\';

   while not eof do
   begin
      cnt := 0;
      repeat
         cnt := cnt + 1;
         readln(line);
      until (copy(line,first,len) <> copy(pline,first,len)) or eof;

      if cnt > 1 then
         writeln(' (',cnt,' times)')
      else
         writeln;
      write(line);

      lines := lines + 1;
      pline := line;
   end;

   writeln;

   writeln(con,lines,' unique lines');
end.
