
{$c-}

var
  c: char;

begin
   writeln('Press ENTER to end program');
   repeat
      read(kbd,c);
      if (c = #27) and keypressed then
      begin
         read(kbd,c);
         write('ESC-',c,'  ');
         c := chr(ord(c) - ord(';') + 201);
      end
      else

      if c in [' '..'~'] then
         write('"',c,'"    ');

      if c in [#0..#31] then
         write('ctl-',chr( ord(c)+ord('@') ),'  ');

      write(ord(c),'  ');

      case c of
         #201..#210:  write('F',ord(c)-200);
         #213:        write('HOME');
         #224:        write('INSERT');
         #225:        write('DELETE');
         #221:        write('END');
         #215:        write('PGUP');
         #223:        write('PGDN');
         #214:        write('UP');
         #222:        write('DOWN');
         #217:        write('LEFT');
         #218:        write('RIGHT');

      end;

      writeln;
   until c = #13;

end.
