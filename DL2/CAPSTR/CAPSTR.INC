
procedure capstr(var s: string);
var
   i:    integer;
   sp:   boolean;
begin
   sp := true;
   stolower(s);
   for i := 1 to length(s) do
   begin
      if sp then
         s[i] := upcase(s[i]);
      sp := s[i] = ' ';
   end;
end;

