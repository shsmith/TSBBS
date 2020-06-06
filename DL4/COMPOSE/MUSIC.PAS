(*
 * Random Music Generator
 * (see Scientific American, April 1978)
 *
 * S.H.Smith, 21-Nov-86
 *)

{$c-,r+}
{$i play.inc}

procedure white;
var
   pitch:     integer;
   duration:  integer;
   level:     integer;
   dice:      1..18;
   i:         integer;
   sides:     integer;

begin
   writeln;
   write('dice (1-18): ');
   readln(dice);
   sides := 36 div dice;

   init;
   writeln('White music, ',dice,' dice, ',sides,' sides');

   repeat
      pitch := 0;
      duration := 0;
      level := 0;

      for i := 1 to dice do
      begin
         pitch := pitch + random(sides) + 1;
         duration := duration + random(sides) + 1;
         level := level + random(sides) + 1;
      end;

      play(pitch,duration,level);
   until keypressed;

end;

procedure brown;
var
   pitch:     integer;
   duration:  integer;
   level:     integer;
   order:     integer;
   i:         integer;

begin
   writeln;
   write('variations (1-100): ');
   readln(order);

   init;
   writeln('Brown music, ',order,' variations');

   pitch := 21;
   duration := 21;
   level := 21;

   repeat
      for i := 1 to order do
      begin
         pitch := pitch + random(3);
         duration := duration + random(3);
         level := level + random(3);
      end;

      pitch := pitch - order;
      if pitch < 0 then pitch := 0;

      duration := duration - order;
      if duration < 0 then duration := 0;

      level := level - order;
      if level < 0 then level := 0;

      play(pitch,duration,level);
   until keypressed;

end;


procedure norm;
type
   state = record
      rolls:    array[1..16] of integer;
      before:   integer;
      now:      integer;
   end;

var
   pitch:    state;
   duration: state;
   level:    state;
   dice:     1..16;
   sides:    integer;


procedure generate(var st: state);     {generate normal 1/f noise with 6 dice}
var
   next: integer;
   i:    integer;
   m:    integer;

begin
   with st do
   begin
      m := 1;
      next := random(sides) + 1;

      for i := 1 to dice-1 do
      begin
         if ((before and m) <> (now and m)) then
            rolls[i] := random(sides) + 1;
         next := next + rolls[i];
         m := m shl 1;
      end;

      before := now;
      now := next;
   end;
end;


begin
   writeln;
   write('dice (1-16): ');
   readln(dice);
   sides := 36 div dice;

   init;
   writeln('Normal 1/f music, ',dice,' dice, ',sides,' sides');

   with pitch    do begin now:=0; before:=-1; end;
   with duration do begin now:=0; before:=-1; end;
   with level    do begin now:=0; before:=-1; end;

   repeat
      generate(pitch);
      generate(duration);
      generate(level);
      play(pitch.now,duration.now,level.now);
   until keypressed;

end;



var
   c: char;

begin
   repeat
      clrscr;
      textmode(bw40);
      writeln;
      writeln('Random Music Generator');
      writeln;
      writeln('(See Scientific American, April 1978.  ');
      writeln(' Coded: S.H.Smith, 21-Nov-86)');
      writeln;
      writeln;
      writeln('   0 - Exit');
      writeln;
      writeln('   1 - White  1/1   noise');
      writeln;
      writeln('   2 - Normal 1/f^1 noise');
      writeln;
      writeln('   3 - Brown  1/f^2 noise');
      writeln;
      writeln;
      write('What kind do you want? ');
      read(kbd,c);

      case c of
         '1':  white;
         '2':  norm;
         '3':  brown;
      end;

      sound_off;
      if keypressed then read(kbd,c);

   until c = '0';

   textmode(bw80);
end.


