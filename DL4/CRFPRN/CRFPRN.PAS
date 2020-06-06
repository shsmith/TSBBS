
(*
 * crfprn - print formatting filter for use with pcrf
 *
 * does not output repeated lines;
 * only outputs changed portion of changed lines
 * outputs count of duplicate lines
 *
 * shs 23-aug-85
 *
 *)

{$g10240,p128,d-,c-}

type
   anystring = string[132];

var
   line:   anystring;
   pline:  anystring;
   oline:  anystring;
   dupcnt: integer;
   i:      integer;
   c:      char;


begin
   line := '';
   pline := '<<start>>';
   dupcnt := 1;

   repeat
      oline := pline;
      pline := line;
      if eof then
         line := '<<eof>>'
      else
         repeat
            readln(line);
         until (copy(line,41,40) <> copy(line,1,length(copy(line,41,40))))
               or eof(input);


      (* if lines are the same, then count this as a cuplicate line *)
      if line = pline then
         dupcnt := dupcnt + 1

      else
      begin
         (* output the duplicate count if needed *)
         if dupcnt > 1 then
            write(' (',dupcnt, ' times)');

         writeln;

         if (copy(line,1,40) <> copy(pline,1,40)) then
         begin
            writeln;
            writeln('------------------------------------------------------');
            write(copy(line,1,40));
         end
         else
            write(' ':40);

         write(copy(line,41,40));
         dupcnt := 1;
      end;

      if keypressed then
      begin
         read(kbd,c);
         if c = ^C then halt;
      end;

   until eof;
   writeln;
end.