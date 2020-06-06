
(*
 * indent - filter to indent all lines in a stream by a given
 *          number of spaces
 *
 * also trims all non-essential white space
 *
 * shs 17-oct-85
 *
 *)

{$g1024,p10240,c-,d-}

var
   line:  string[255];
   i:     integer;
   ind:   integer;
   code:  integer;


begin
   if paramcount <> 1 then
   begin
      writeln(con,'Usage:  indent <INFILE >OUTFILE SPACES');
      halt;
   end;

   val(paramstr(1),ind,code);

   while not eof do
   begin
      readln(line);
      i := length(line);
      while (i > 0) and (line[i] = ' ') do
         i := i - 1;
      line[0] := chr(i);

      if i > 0 then
         write('':ind);

      writeln(line);

      if keypressed then
         exit;
   end;

end.

