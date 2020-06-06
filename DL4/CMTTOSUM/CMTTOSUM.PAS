
(*
 * cmttosum - convert standard block procedure comments into
 *            a standard procedure summary header
 *
 * usage:  cmttosum <infile >outfile
 *
 * shs 23-aug-85
 *
 *)

{$g10240,p128,d-}

const
   seperator = #255;
   newline = #10;
   return = #13;


type
   anystring = string[132];

var
   buf:        anystring;
   tail:       anystring;
   leading:    integer;
   combine:    boolean;
   split:      boolean;
   c:          char;


function skipspace(s: anystring): anystring;
begin

   while (length(s) > 0) and (s[1] = ' ') do
      s := copy(s,2,132);

   skipspace := s;
end;

begin

   (* default options *)
   combine := false;
   split   := false;

   (* get option string *)
   if paramcount = 1 then
      buf := paramstr(1)
   else
      buf := '';

   (* select options *)
   if buf = '-combine' then
      combine := true
   else if buf = '-split' then
      split := true
   else if buf <> '' then
   begin
      writeln(con,'Invalid argument');
      writeln(con);
      writeln(con,'usage: cmttosum <infile >outfile [option]');
      writeln(con,'options:  -combine   [combine output into a single line per procedure]');
      writeln(con,'          -split     [split up combined output into normal text]');
      writeln(con);
      writeln(con,'The default is to produce notmal text from pascal source');
      writeln(con);
      writeln(con,'example: cmttosum <file.pas -combine|sort|cmttosum -split >outfile');
      halt;
   end;


(* process split mode *)

   if split then
   begin
      while not eof do
      begin
         write(' * ');
         read(c);
         while c <> newline do
         begin

            if c = seperator then
            begin
               writeln;
               write(' * ');
            end
            else if c <> return then
               write(c);

            read(c);
         end;
         writeln;
      end;
      writeln;
      halt;
   end;


(* process normal and combine modes *)

   while not eof do
   begin

      readln(buf);
      if (copy(buf,1,13) = ' * Procedure:') or
         (copy(buf,1,12) = ' * Function:') then
      begin

         leading := 14;
         while (leading < length(buf)) and
               (buf[leading] = ' ') do
               leading := leading + 1;

         if leading >= length(buf) then
            tail := '(UNKNOWN PROCEDURE)'
         else
            tail := copy(buf,leading,132);

         if combine then
            write(tail, seperator)
         else
            writeln(' * ',tail);

         readln(buf);
         while copy(buf,1,11) <> ' * Example:' do
         begin
            tail := copy(buf,leading,132);
            if tail <> '' then
            begin
               if combine then
                  write('   ', tail, seperator)
               else
                  writeln(' *    ',tail);
            end;
            readln(buf);
         end;

         if combine then
            writeln
         else
            writeln(' *');

         flush(output);
      end;

   end;

end.

