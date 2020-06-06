
(* lj - left justify; remove non-initial repeating spaces from text stream *)

var
   s: string;
   i: integer;

begin
   while not eof do
   begin
      readln(s);
      while copy(s,1,1) = ' ' do
      begin
         write(' ');
         delete(s,1,1);
      end;
      i := pos('  ',s);
      while i > 0 do
      begin
         delete(s,i,1);
         i := pos('  ',s);
      end;
      writeln(s);
   end;

end.

