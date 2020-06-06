

(*
 * pickcmd - pick from a list and form a command from it
 *
 * shs 29-may-86
 *
 *)

program pick_command;


{$g512,p512,d-}

const
   version = 'PICKCMD, Pick command from list of options   v3.0 (29-May-86, S.H.Smith)';
   maxoptions = 200;

type
   anystring = string[128];

var
   commandprefix:  anystring;
   optioncount:    integer;
   optionlist:     array[1..maxoptions] of anystring;
   selected:       integer;


procedure usage;
begin
   writeln(version);
   writeln;
   writeln('Usage:  pickcmd <OPTIONFILE COMMANDPREFIX >OUTFILE');
   writeln;
   writeln('Where OPTIONFILE    is the file containing the option list');
   writeln('      COMMANDPREFIX is the prefix before the option in the output');
   writeln('      OUTFILE       is the generated (batch) command output');
   writeln;
   writeln('Example:');
   writeln('   pickcmd <\alldirs.dat chdir >\tmp\newdir.bat');
   writeln('   \tmp\newdir');
   writeln;
   halt;
end;


procedure display_option_list;
var
   y:       integer;
   x:       integer;
   len:     integer;
   i:       integer;
   line:    anystring;
   pline:   anystring;
   dline:   anystring;
   p:       integer;

begin
   clrscr;

   for i := 1 to 99 do
   optionlist[i] := '';

   optioncount := 0;
   len := 0;
   y := 0;
   x := 1;
   pline := '';

   while not eof(input) do
   begin
      readln(line);
      optioncount := optioncount + 1;
      optionlist[optioncount] := line;

      dline := '';
      p := 0;
      for i := 1 to length(line) do
         if line[i] = '\' then
         begin
            dline := dline + '.';
            p := i;
         end;

      dline := dline + copy(line,p+1,99);


      if length(dline) > len then
         len := length(dline);

      y := y + 1;
      if y > 23 then
      begin
         y := 1;
         x := x + len + 5;
      end;

      gotoxy(x,y);

      normvideo;
      if optioncount < 10 then
         write(con,'0');
      if optioncount < 100 then
         write(con,'0');
      write(con,optioncount,'=');

      lowvideo;
      write(con,dline);

      pline := line;
   end;

end;


procedure select_option;
var
  k1,k2,k3: char;

  function digit: char;
  var
    d: char;
  begin
     repeat
       read(kbd,d);
       if d = #27 then halt;
     until d in ['0'..'9',^h];
     write(con,d);
     if d = ^h then write(con,' '^h);
     digit := d;
  end;

begin
   gotoxy(1,25);
   normvideo;
   write(con,'Select option number: ');
   k2 := ^H;
   k3 := ^H;
   repeat
      k1 := digit;
      if k1 <> ^H then
      begin
         k2 := digit;
         if k2 <> ^H then
            k3 := digit;
      end;
   until (k1 <> ^H) and (k2 <> ^H) and (k3 <> ^H);

   selected := (ord(k1) - ord('0')) * 100 +
               (ord(k2) - ord('0')) * 10  +
               (ord(k3) - ord('0'));
end;


procedure produce_output;
var
   i:  integer;

begin
   if (selected < 1) or (selected > optioncount) then
      halt;

   for i := 1 to paramcount do
      write(paramstr(i),' ');
   writeln(optionlist[selected]);
end;



begin {main}

   if paramcount < 1 then
      usage;

   display_option_list;
   select_option;
   produce_output;

end.
