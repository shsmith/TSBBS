
(*
 * cnfmt - format output of cndump
 * s.h.smith, 22-sep-93
 *
 *)

const
   colwidth = 19;
   numcol = 4;

var
   line: string;
   col:  integer;

begin
   col := 1;
   while not eof do
   begin
      readln(line);

      if line = '' then
      begin
         if col > 1 then
            writeln;
         writeln;
         col := 1;
      end
      else

      if pos(':',line) > 0 then
      begin
         writeln(line);
         col := 1;
      end
      else

      if col > numcol then
      begin
         writeln;
         write(copy(line,1,4),' ',copy(line,5,255));
         write('':colwidth-length(line));
         col := 2;
      end

      else
      begin
         write(copy(line,1,4),' ',copy(line,5,255));
         if col < numcol then
            write('':colwidth-length(line));
         inc(col);
      end;
   end;

end.

