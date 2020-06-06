
(*
 * doctopas - convert a simple document format into the
 *            corresponding pascal source code
 *
 * S.H.Smith, 13-Nov-86
 *
 *)

{$p5120,g512}

type
   anystring = string[128];

var
   line: anystring;
   proc: anystring;
   i:    integer;

begin

   while not eof do
   begin
      readln(line);

      if copy(line,1,10) = 'Procedure:' then
      begin
         proc := copy(line,12,99);

         writeln('(**)');
         writeln('(*');
         writeln(' * Procedure: ',proc);
         writeln(' *');

         readln(line);
         writeln(' * Purpose:   ',copy(line,12,99));

         readln(line);
         while copy(line,1,9) <> 'procedure' do
         begin
            writeln(' * ',line);
            readln(line);
         end;

         writeln(' * Example:   ',proc);
         writeln(' *');
         writeln(' * Inputs:    .');
         writeln(' * Outputs:   .');
         writeln(' * Errors:    .');
         writeln(' *)');
         writeln;

         writeln('procedure ',proc,';');
      end
      else

      if copy(line,1,5) = 'begin' then
      begin
         writeln(line);
      end
      else

      if copy(line,1,3) = 'end' then
      begin
         writeln('end; {' + proc + '}');
      end
      else

      if line <> '' then
      begin
         writeln('(*| ',line,'':70-length(line),' |*)');
      end

      else
         writeln(line);
   end;

end.

