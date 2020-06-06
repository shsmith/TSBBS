
(*
 * remove - filter to remove all lines containing a string
 *
 * shs 29-aug-85
 *
 *)

var
   line:     string[132];
   lines:    integer;
   removed:  integer;
   pattern:  integer;
   matched:  boolean;

begin
   if paramcount = 0 then
   begin
      writeln('usage:  remove STRING1 ... STRINGn <INFILE >OUTFILE');
      writeln('action: deletes all lines containing any of STRINGx from stream');
      halt;
   end;

   lines := 0;
   removed := 0;
   while not eof do
   begin
      readln(line);
      matched := false;
      for pattern := 1 to paramcount do
         if pos(paramstr(pattern),line) > 0 then
            matched := true;

      if matched then
         removed := removed + 1
      else
         writeln(line);

      lines := lines + 1;
   end;

   halt (0);
end.
