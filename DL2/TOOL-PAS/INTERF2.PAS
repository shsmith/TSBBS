
var
   line:       string;
   oline:      string;
   finished:   boolean;
   src:        array[1..10] of text;
   srclev:     integer;
   incomment:  boolean;
   inbody:     integer;
   allsource:  boolean;
   allbody:    boolean;
   inproc:     boolean;
   inlocal:    boolean;
   trace:      boolean;


procedure traces(why: string);
begin
   if trace then
      writeln('#trace: ',why,' cmt=',incomment,' body=',inbody,' proc=',inproc,' loc=',inlocal,' line=',line);
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

   if (par = 'IMPLEMENTATION') or
      ((allsource=false) and (par = 'BEGIN')) then
   begin
      finished := true;
      traces('finished(1) ');
   end;

   if par = 'BEGIN' then
   begin
      inlocal := false;
      inproc := false;
      inc(inbody);
      traces('inbody(1)');
   end;

   if par = 'END' then
   begin
      inlocal := false;
      dec(inbody);
      if inbody=0 then
         oline := '';
      traces('inbody(2)');
   end;

   if (par = 'PROCEDURE') or
      (par = 'FUNCTION') then
   begin
      inlocal := false;
      inproc := true;
      traces('inproc(1) ');
   end;

   if (par = 'VAR') or
      (par = 'CONST') or
      (par = 'TYPE') then
   begin
      if inproc then
         inlocal := true;
      traces('indcls');
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
   writeln('Usage: interface SOURCE [-a] [-b] [>outfile]');
   writeln;
   writeln('SOURCE specifies a pascal source file');
   writeln;
   writeln('-a causes all source lines to be output instead of stopping');
   writeln('   at the first procedure body');
   writeln;
   writeln('-b causes the body of each procedure to be output when -a is');
   writeln('   used, otherwise only the procedure headers are output');
   writeln;
   halt(1);
end;


(* ----------------------------------------------------------- *)
var
   i:       integer;
   buff:    array[1..maxint] of char;
   par:     string;

begin
   allsource := false;
   allbody := false;
   trace := false;
   inbody := 0;
   if paramcount < 1 then
      usage;

   for i := 2 to paramcount do
   begin
      par := paramstr(i);
      par[2] := upcase(par[2]);
      if par = '-A' then
         allsource := true
      else
      if par = '-B' then
         allbody := true
      else
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
   inproc := false;
   inlocal := false;

   while not finished do
   begin
      readln(src[srclev],line);
      oline := line;

      for i := 1 to length(line) do
         line[i] := upcase(line[i]);

      while line <> '' do
         process_line;

      if (allbody) or ((inbody=0) and (not inlocal)) then
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

