
(*
 * playnote.inc - library to play notes based lettered scales
 *
 * This version uses a different voice for each note played
 * s.h.smith, 5-jul-86
 *)

const
   max_voice           = 3;

   level:      integer = 2;
   sustain:    integer = 5;
   base_pitch: real    = 150.0;
   natural:    boolean = true;
   translate:  boolean = false;

   F1 = ';';   F2 = '<';
   F3 = '=';   F4 = '>';
   F5 = '?';   F6 = '@';
   F7 = 'A';   F8 = 'B';
   F9 = 'C';   F10 = 'D';
   UP = 'H';   DOWN = 'P';
   LEFT = 'K'; RIGHT = 'M';
   HOME = 'G';

type
   anystring           = string[255];

var
   time:       real;
   note_time:  array[0..max_voice] of integer;
   note_level: array[0..max_voice] of integer;
   nextv:      voices;


procedure tick;      {process 1 tick of the clock; sets the new loudness
                      for each active voice}
var
   voice:  integer;
   atten:  integer;

begin
   time := time + 1;

   for voice := 0 to max_voice do

      if note_time[voice] > 0 then
      begin
         note_time[voice] := note_time[voice]-1;
         atten := 15-(note_time[voice] div sustain) + note_level[voice];

         if atten < level then
            atten := level;

         if atten >= 15 then
         begin
            write(' ');
            note_time[voice] := 0;
         end;

         sound_level(voice,atten);
      end;
end;


procedure notecheck (key:     char;
                     scale:   anystring;
                     voice:   integer;
                     octave:  real;
                     trans:   anystring);
var
   freq: real;
   n:    integer;

begin
   n := pos(key,scale);

   if n > 0 then
   begin
      if translate then
         write(copy(trans,n,1));

      if voice <> 3 then      {assign new vioces for each key, except noises}
      begin
         voice := nextv;
         nextv := (nextv + 1) mod 3;
      end;

      note_time[voice] := sustain*20;
      note_level[voice] := level;

      freq := (int(n-1) / int(length(scale)) + 1.0) * octave * base_pitch;
      sound_pitch(voice,freq);    {assign new pitch; tick will set levels}
   end;
end;


procedure play(c: char);
begin
   if natural then
   begin
      notecheck(c,'qQwWeErRtTyYuU',0,4,'');
      notecheck(c,'aAsSdDfFgGhHjJ',0,2,'');
      notecheck(c,'zZxXcCvVbBnNmM',0,1,'');
      notecheck(c,'1!2@3#4$5%6^7&',3,1,'');
   end
   else

   begin
      notecheck(c,'cCdDeEfFgGaAbB',0,2,'');

      notecheck(#0,'cCdDeEfFgGaAbB',0,2,'');
      notecheck(#0,'cCdDeEfFgGaAbB',0,2,'');
      notecheck(#0,'cCdDeEfFgGaAbB',0,2,'');
   end;

   if c = ' ' then
      sound_off;
end;


procedure play_init;
var
   v: voices;

begin
   time := 0;
   for v := 0 to max_voice do
   begin
      note_time[v] := 0;
      note_level[v] := 0;
   end;

   sound_off;
   nextv := 0;

   window (1,wherey,80,25);
end;


procedure display_function_key(c: char);
begin
   case c of
      F1:     write(' F1 ');
      F2:     write(' F2 ');
      F3:     write(' F3 ');
      F4:     write(' F4 ');
      F5:     write(' F5 ');
      F6:     write(' F6 ');
      F7:     write(' F7 ');
      F8:     write(' F8 ');
      F9:     write(' F9 ');
      F10:    write(' F10 ');
      UP:     write(' UP ');
      DOWN:   write(' DOWN ');
      LEFT:   write(' LEFT ');
      RIGHT:  write(' RIGHT ');
      HOME:   write(' HOME ');
      else    write(' ESC-',c,' ');
   end;
end;


procedure function_key(c: char);
begin
   case c of
      F1:    sustain := sustain + 1;
      F2:    if sustain > 1 then sustain := sustain - 1;

      F3:    if level > 0 then level := level - 1;
      F4:    if level < 14 then level := level + 1;

      F5:    natural := true;
      F6:    natural := false;

      F8:    translate := not translate;

      RIGHT: base_pitch := base_pitch * 1.02;
      LEFT:  if base_pitch > 70.0 then base_pitch := base_pitch / 1.02;

      UP:    base_pitch := base_pitch * 2;
      DOWN:  if base_pitch > 70.0 then base_pitch := base_pitch / 2;
   end;
end;


