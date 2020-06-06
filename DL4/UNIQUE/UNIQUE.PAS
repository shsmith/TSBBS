
(*
 * unique - filter to pass only unique lines
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
   writeln(con,'Unique v2.0, LAST_UPDATE');
   writeln(con);
   writeln(con,'Usage:  unique <infile >outfile');
   writeln(con,'  or    unique <infile >outfile FIRST_COL LENGTH');
   writeln(con);
end;

var
   line, pline:  string[255];
   lines:        integer;
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
   pline := '///';

   while not eof do
   begin
      repeat
         readln(line);
      until (copy(line,first,len) <> copy(pline,first,len)) or eof;

      if not eof then
      begin
         writeln(line);
         lines := lines + 1;
      end;

      pline := line;
   end;

   writeln(con,lines,' unique lines');
end.
