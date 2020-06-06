
(*
 * mapsize - filter to append sizes to lines of LINK .MAP files
 *
 * shs 19-mar-86 (rev. 15-may-87)
 *
 *)

{$g10240,p1024,d-}

type
   anystring = string[128];

var
   cline:   anystring;
   nline:   anystring;


function hex_to_real(hex: anystring): real;
var
   i:   integer;
   c:   char;
   r:   real;

begin
   r := 0;
   for i := 1 to length(hex) do
   begin
      r := r * 16.0 + ord(hex[i]) - ord('0');
      if hex[i] > '9' then
         r := r - 7;
   end;

   hex_to_real := r;
end;



procedure process_line;
var
   first:  real;
   last:   real;
   newseg: boolean;

begin
   first := hex_to_real(copy(cline,7,4));
   last  := hex_to_real(copy(nline,7,4));
   newseg := copy(cline,2,4) <> copy(nline,2,4);

   write(copy(cline,1,13));

   if (first <> last) and (not newseg) then
      write(last-first:7:0,' ')
   else
      write('        ');

   writeln(copy(cline,15,99));

   if newseg then
   begin
      writeln;
      writeln;
      writeln(' Location       Size    Symbol');
      writeln;
   end;
end;


begin
   writeln;
   writeln(' Location       Size    Symbol');
   writeln;
   flush(output);

   repeat
      readln(nline);
   until nline = '  Address         Publics by Value';
   readln;

   readln(cline);
   readln(nline);

   repeat
      process_line;
      cline := nline;
      readln(nline);
   until nline = '';

end.


