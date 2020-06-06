
(*
 * dfamon - monitor a DFA activity
 *
 * s.h.smith, 18-nov-86
 *
 *)

{$c-}

{$i \shs\tools\regpack.inc}
{$i \shs\tools\givetime.inc}
{$i \shs\tools\popup.inc}


type
   asciiz = array[1..63] of char;
   asciizp = ^asciiz;
   anystring = string[100];

   namerec = array [0..19] of record
      openmode:       char;
      name:           asciiz;
   end;

var
   segment:       integer;

   readhits:      ^integer;
   realreads:     ^integer;
   nametable:     ^namerec;
   bufn:          ^byte;
   changed:       ^byte;
   handle:        ^integer;

   bar:           string[80];
   prevhits:      integer;
   prevreal:      integer;
   prevlast:      integer;
   ch:            char;


procedure init;
var
   i:       integer;

begin
   segment := sseg + 1;
   while memw[segment:$60e] <> $DFAC do
   begin
      if segment = cseg then
      begin
         displn('Can''t find DFA13 in memory.');
         halt;
      end
      else
         segment := segment + 1;
   end;

   readhits  := ptr(segment,$107);
   realreads := ptr(segment,$109);
   bufn      := ptr(segment,$10c);
   changed   := ptr(segment,$10d);
   nametable := ptr(segment,$10e);
   handle    := ptr(segment,$611);

   changed^ := 1;
   prevreal := -1;
   prevhits := -1;
   prevlast := 0;

   bar := '';
   for i := 1 to 29 do
      bar := bar + #176;
   for i := 1 to 12 do
      bar := bar + #177;
   bar := bar + #178;
end;


procedure zero_totals;
begin
   readhits^ := 0;
   realreads^ := 0;
   changed^ := 1;
   prevreal := -1;
   prevhits := -1;
end;


procedure clear_files;
var
   i: integer;
begin
   for i := 0 to 19 do
      with nametable^[i] do
         if openmode = '.' then
         begin
            openmode := #0;
            name[1] := #0;
         end;

   changed^ := 1;
end;


procedure display_bar(y,n:       integer);
var
   s:       string[10];

begin
   if y=6 then
   begin
      if prevhits = n then exit;
      prevhits := n;
   end
   else begin
      if prevreal = n then exit;
      prevreal := n;
   end;

   if n > 999 then
      n := 999;
   if y=6 then
      str(n shr 1:3,s)
   else
      str(n:3,s);

   if n >= 30 then
      n := ((n-30) div 10) + 30;
   if n > length(bar) then
      n := length(bar);

   gotoxy(1,y);
   normvideo;
   disp(' '+s+' '+copy(bar,1,n));
   clreol;
end;


procedure display_name(n:       integer);
var
   i:       integer;
   s:       anystring;

begin

   with nametable^[n] do
   begin

      if (openmode <> #0) then
      begin
         if n = lo(handle^) then
            s := ' * '
         else
            s := '   ';

         s := s + openmode + ' ';
         i := 1;
         while name[i] <> #0 do
         begin
            s := s + name[i];
            i := i + 1;
         end;

         if i > 1 then
         begin
            if openmode = '.' then lowvideo else normvideo;
            disp(s);
            clreol;
            writeln;
         end;
      end;
   end;
end;


procedure display_status;
var
   va_ratio:       integer;
   i:              integer;
   j:              integer;

begin
   if changed^ <> 0 then
   begin
      changed^ := 0;

      gotoxy(1,9);
      for i := 0 to 19 do
         display_name(i);

      j := wherey;
      for i := j to prevlast-1 do
      begin
         clreol;
         writeln;
      end;

      prevlast := j;
   end;


   if (realreads^ < 0) or (readhits^ < 0) then
      zero_totals;

   if (realreads^ <> 0) then
      va_ratio := readhits^ div realreads^
   else
      va_ratio := 0;

   display_bar(3,va_ratio);
   display_bar(6,bufn^ shr 1);
   gotoxy(48,19);
end;


begin
   gotoxy(1,wherey-1);
   clreol;
   gotoxy(1,wherey-1);
   clreol;

   window(1,1,80,25);
   back_attr := 0;
   low_attr := lightgray;

   normvideo;
   open_pop_up(30,3,79,23,'File Accleration Monitor (v1.3 11/86 SHS)');

   clrscr;
   displn('Searching for DFA13 in memory...');
   init;

   clrscr; writeln;
   lowvideo;
   displn(' Logical/Physical Ratio:'); writeln; writeln;
   displn(' Buffer Contents:'); writeln; writeln;
   displn(' Files:');
   gotoxy(2,19);
   disp('Commands:  Q)uit,  Z)ero ratio,  C)lear files');

   ch := '?';
   repeat
      if not invisible then
         display_status;

      give_up_time;
      give_up_time;

      if keypressed then
      begin
         read(kbd,ch);
         ch := upcase(ch);
         case ch of
            'Q': ;
            'Z': zero_totals;
            'C': clear_files;
         end;
      end;
   until ch = 'Q';

   remove_pop_up;

end.

