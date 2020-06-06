
var
   line:       string;
   oline:      string;
   finished:   boolean;
   src:        array[1..10] of text;
   srclev:     integer;
   incomment:  boolean;
   trace:      boolean;


procedure traces(why: string);
begin
   if trace then
      writeln('#trace: ',why,' cmt=',incomment,' line=',line);
end;

(* ----------------------------------------------------------- *)
procedure scan_comments;
var
   i: integer;
begin
   traces('comment(1) ');

   i := 1;
   while i <= length(line) do
   begin
      if (line[i] = '}') or
         ((line[i] = '*') and (line[i+1] = ')')) then
      begin
         incomment := false;
         if line[i] = '*' then inc(i);
         line := copy(line,i+1,255);
         exit;
      end;
      inc(i);
   end;
   line := '';
end;


(* ----------------------------------------------------------- *)
procedure scan_directives;
var
   fname:   string;
   i:       integer;
begin
   traces('directive(1) ');

   if copy(line,1,2) = '$I' then
   begin
      fname := '';
      i := 3;
      while line[i] = ' ' do
         inc(i);
      repeat
         fname := fname + line[i];
         inc(i);
      until (i > length(line)) or (line[i] = '}') or (line[i] = ' ') or (line[i] = '*');

      inc(srclev);
      assign(src[srclev],fname);
      {$i-} reset(src[srclev]); {$i+}
      if ioresult <> 0 then
         dec(srclev);
   end;
end;


(* ----------------------------------------------------------- *)
procedure check_statement(line: string);
var
   p:    integer;
   par:  string;
begin
   par := line;
   while (length(par) > 1) and (par[1] = ' ') do
      delete(par,1,1);
   p := pos(' ',par);
   if p > 1 then
      par[0] := chr(p-1);

   if (par = 'IMPLEMENTATION') or (par = 'BEGIN') then
   begin
      finished := true;
      traces('finished(1) ');
   end;

end;


(* ----------------------------------------------------------- *)
procedure process_line;
var
   i: integer;
begin
   if incomment then
      scan_comments;

   while (line <> '') and (line[1] = ' ') do
      delete(line,1,1);
   i := 1;
   while i <= length(line) do
   begin
      if (line[i] = '{') or
         ((line[i] = '(') and (line[i+1] = '*')) then
      begin
         check_statement(copy(line,1,i));

         if line[i] = '(' then inc(i);
         line := copy(line,i+1,255);
         incomment := true;

         if line[1] = '$' then
            scan_directives;
         exit;
      end;
      inc(i);
   end;

   check_statement(line);
   line := '';
end;


(* ----------------------------------------------------------- *)
procedure usage;
begin
   writeln('Program Interface Scanner v1.0  (C) 1991 Samuel H. Smith');
   writeln;
   writeln('Usage: interface SOURCE [>outfile]');
   writeln;
   writeln('SOURCE specifies a pascal source file');
   writeln;
   halt(1);
end;


(* ----------------------------------------------------------- *)
var
   i:       integer;
   buff:    array[1..maxint] of char;
   par:     string;

begin
   trace := false;
   if paramcount < 1 then
      usage;

   for i := 2 to paramcount do
   begin
      par := paramstr(i);
      par[2] := upcase(par[2]);
      if par = '-T' then
         trace := true
      else
         usage;
   end;

   settextbuf(output,buff);

   srclev := 1;
   assign(src[srclev],paramstr(1));
   {$i-} reset(src[srclev]); {$i+}
   finished := ioresult <> 0;
   incomment := false;

   while not finished do
   begin
      readln(src[srclev],line);
      oline := line;

      for i := 1 to length(line) do
         line[i] := upcase(line[i]);

      while line <> '' do
         process_line;

      writeln(oline);

      if eof(src[srclev]) then
      begin
         close(src[srclev]);
         dec(srclev);
         if srclev = 0 then
         begin
            finished := true;
            traces('finished(2)');
         end;
      end;
   end;
end.

