

(*
 * overview - display a file as an "overview" by filtering out
 *            all lines indented past a given level
 *
 * shs 16-oct-85
 *
 *)

{$g2048,p128,u-,c-,d-}

program overview(input,output);

var
   line:  string[255];
   level: integer;
   ind:   integer;

begin

   if paramcount <> 1 then
   begin
      writeln(con,'Usage:  overview INDENTATIONLEVEL <INFILE >OUTFILE');
      halt;
   end;

   val(paramstr(1),level,ind);
   level := level + 1;

   while not eof do
   begin
      readln(input,line);
      if (line[1] <> ^L) and (length(line) > 1) then
      begin

         ind := 1;
         while (ind < length(line)) and
               (line[ind] = ' ') do
                  ind := ind + 1;

         if ind <= level then
         begin
            writeln(output);
            write(output,line);   {output a new line}
            flush(output);
         end;

         if keypressed then
         begin
            read(kbd,line[1]);
            if line[1] = ^C then
            begin
               write(con,'*** ^C');
               halt;
            end;
         end;
      end;
   end;

   writeln(output);
end.


