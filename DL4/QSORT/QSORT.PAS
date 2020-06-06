
(*
 * qsort - quicksort filter for large files
 *
 * shs 9/9/85
 *
 *)


{$G5120,P5120,c-,d-}

program quicksort(input,output);

const
   linelength = 255;

type
   anystring = string[linelength];

var
  line:      anystring;
  linecnt:  integer;


{$I c:\turbo\SORT.BOX}

procedure abortpoll;
var
   c: char;
begin
   if keypressed then
   begin
      read(kbd,c);
      if c = ^C then
      begin
         writeln(con,'**^C');
         halt(1);
      end;
   end;
end;



procedure Inp; {this procedure is forward declared in SORT.BOX}
var
   buf:  anystring;
   line: integer;
begin
   line := 0;
   while not eof(input) do
   begin
      abortpoll;
      readln(input,buf);
      if length(buf) >= linelength then
         writeln(con,' truncated');

      sortrelease(buf);
      line := line + 1;
      if (line mod 16) = 1 then
         write(con,#13,line:5);
   end;
   writeln(con,' sort input lines');
end;


function Less; {this boolean function has two parameters, X and Y}
               {and is forward declared in SORT.BOX}
var
  a:  anystring absolute X;
  b:  anystring absolute Y;
begin
  Less := a < b;
end;


procedure OutP;
var
  buf:   anystring;
  line:  integer;

begin
  line := 0;
  repeat
    abortpoll;
    SortReturn(buf);
    writeln(output,buf);
    line := line + 1;
    if (line mod 16) = 1 then
       write(con,#13,line:5);

  until SortEOS;
  writeln(con,' output lines');

end;

var
  x: integer;

begin
  x:=TurboSort(linelength);
  if x <> 0 then
     WriteLn(con,'turbosort status=',x);
end.
