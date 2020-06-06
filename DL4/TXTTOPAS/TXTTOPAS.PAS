
(*
 * txttopas - text to pascal conversion program
 *
 * this filter reads a text file and converts it into the
 * pascal statements needed to cause the text to be displayed
 * on the screen.
 *
 * created: 7/29/85 shs
 *
 *)

{$p1024,g1024}

program text_to_pascal (input, output);

const
   maxlength = 128;
   indentation = 6;

type
   anystring = string[maxlength];

var
   inbuf:   anystring;
   i:       integer;



procedure trim_trailing_spaces;
begin
   i := length(inbuf);
   while (i > 0) and (inbuf[i] = ' ') do
   begin
      inbuf[0] := pred(inbuf[0]);
      i := pred(i);
   end;
end;


begin {main}
   while not eof(input) do
   begin
      readln(input, inbuf);
      trim_trailing_spaces;
      if length(inbuf) > 0 then
      begin
         write(' ':indentation,'writeln(''');
         for i := 1 to length(inbuf) do
            if inbuf[i] = '''' then
               write('''','''')
            else
               write(inbuf[i]);
         writeln(''');');
      end
      else
         writeln(' ':indentation,'writeln;');
   end;
end.


