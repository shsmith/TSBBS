
(*
 * nocmt - filter to remove ASMGEN comments from a file
 *
 * shs 3-dec-86
 *
 *)

{$p1024,g10240}

var
   line: string[255];
   i:    integer;

begin
   while not eof do
   begin
      readln(line);
      for i := 1 to length(line) do
         if (line[i] = ';') and (line[i+5] = ' ') then
            line[0] := chr(i-1);

      writeln(line);
   end;

end.

