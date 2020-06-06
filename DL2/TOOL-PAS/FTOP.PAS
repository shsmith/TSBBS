
procedure translate(var line: string);
var
   p:    integer;
   num:  string;
   key:  string;

begin
   {blank lines}
   if line = '' then exit;

   {comments}
   if line[1] = 'C' then
   begin
      repeat
         delete(line,1,1);
      until (line = '') or (line[1] <> ' ');
      while line[length(line)] = ' ' do
         dec(line[0]);
      if length(line) > 2 then
         line := '{ '+line+' }'
      else
         line := '';
   end
   else

   begin
      while (line <> '') and (line[1] = ' ') do
         delete(line,1,1);
      if line = '' then exit;

      {simple statements}
      if (line[1] < '0') or (line[1] > '9') then
         num := '     '
      else

      {line number statements}
      begin
         p := pos(' ',line);
         if p > 0 then
         begin
            num := copy(line,1,p-1);
            while length(num) < 5 do
               num := ' ' + num;
            delete(line,1,p);
            while (line <> '') and (line[1] = ' ') do
               delete(line,1,1);
         end;
      end;

      p := pos(' ',line);
      if p > 0 then
      begin
         key := copy(line,1,p-1);
         if key = 'CALL' then
         begin
            delete(line,1,5);
            line := line + ';'
         end;
      end;

      p := pos('=',line);
      if p > 0 then
      begin
         line := copy(line,1,p-1) + ':' + copy(line,p,255) + ';'
      end;

      line := num + ' ' + line;
   end;
end;


var
   line: string;
begin
   while not eof do
   begin
      readln(line);
      translate(line);
      writeln(line);
   end;
end.

