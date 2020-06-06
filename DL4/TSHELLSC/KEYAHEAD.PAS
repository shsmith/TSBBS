
(*
 * keyahead - put keys into the double-dos type ahead buffer for
 *            the current side of the system
 *
 * author:  s.h. smith, 9-dec-85
 *
 *)

type
   regpack =      record
                     ax,bx,cx,dx,
                     bp,si,di,ds,
                     es,flags:         Integer;
                  end;

var
   reg:    regpack;
   i,j:    integer;
   params: string[128];
   c:      char;


   procedure keychar(c: char);
   begin
      reg.ax := $e300 + ord(c);   {send char c to key buffer}
      msdos(reg);
   end;

   procedure funkey(c: char);
   begin
      keychar(#27);
      keychar(c);
   end;

begin
   if paramcount = 0 then
   begin
      writeln(^G);
      writeln('usage:  keyahead STRING');
      writeln;
      writeln('action:  places STRING into dosble-dos type-ahead buffer');
      writeln;
      writeln('STRING may contain:');
      writeln('  ^X              produces control character CTRL-X');
      writeln('  ^N              produces function key Fn');
      writeln('  ^0              produces function key F10');
      writeln('  ^!              produces ";"');
      writeln('  ^#              produces "="');
      writeln('  ^[              produces "["');
      writeln('  [filename.ext]  produces "filename"');
      halt;
   end;

   params := '';
   for i := 1 to paramcount do
   begin
      if params = '' then
         params := paramstr(i)
      else
         params := params + ' ' + paramstr(i);
   end;

   i := 1;

   while i <= length(params) do
   begin
      c := params[i];
      i := i + 1;


      if c = '[' then           {[filename.ext] causes extention stripping}
      begin
         repeat
            c := params[i];     {output the filename}
            i := i + 1;
            keychar(c);
         until (params[i] in ['.',']']) or (i > length(params));

         if params[i] <> ']' then
         repeat
            c := params[i];     {skip the .ext, if any}
            i := i + 1;
         until (params[i] = ']') or (i > length(params));

         if i > length(params) then
            writeln(^G'error:  missing "]" in filename stripping request');

         i := i + 1;   {skip over the ']'}
      end
      else


      if c = '^' then
      begin
         c := upcase(params[i]);
         i := i + 1;

         case c of
            '!':  keychar(';');

            '#':  keychar('=');

            '[':  keychar('[');

            '0':  funkey('D');           {F10 key}

            '1'..'9':
                  funkey( chr( ord(c)-ord('1')+ord(';') ));

            else                      {process all other control chars}
               keychar( chr( ord(c) - ord('@') ));
         end;
      end

      else
         keychar(c);
   end;

end.


