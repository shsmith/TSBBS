
const
   sound_port = $c0;           {I/O address of SN76496 sound generator}

type
   voices = 0..3;              {voice numbers for the 4 voices}
   attenuations = 0..15;       {legal attenuator values; 15=off}


procedure sound_period (voice:      voices;
                        period:     integer);
   {change the sound divider (period) of a voice}
begin
   port[sound_port] := ($80 + (voice shl 5) + (period and $0F)); {lo 4 bits}
   port[sound_port] := ((period shr 4) and $3F);                 {hi 6 bits}
end;


procedure sound_pitch (voice:      voices;
                       frequency:  real);
   {change the pitch (frequency) of a voice}
var
   period:  real;

begin
   if frequency = 0.0 then
      period := 0
   else
      period := 70000.0 / frequency;

   if (period <= 1) or (period > $3FF) then
      period := 1;

   sound_period(voice, trunc(period));
end;


procedure sound_level (voice:       voices;
                       attenuation: attenuations);
   {change the level (attenuation) of a voice}
begin
   if attenuation < 0 then
      attenuation := 0
   else
   if attenuation > 15 then
      attenuation := 15;

   port[sound_port] := ($90 + (voice shl 5) + (attenuation and $0F));
end;


procedure sound_off;
var
   v: voices;

begin
   for v := 0 to 3 do
   begin
      sound_level(v,15);
      sound_pitch(v,0);
   end;
end;


var
   x: integer;
   y: integer;
   tempo: integer;

procedure play(pitch,duration,level: integer);
var
   px: integer;
   py: integer;

begin
   px := x; py := y;
   x := x + duration;
   y := pitch *5;

   draw(px shr 3,200-py,px shr 3,200-y,1);
   draw(x shr 3,200-y,px shr 3,200-y,1);

   if (x shr 3) > 320 then
      x := 0;

   sound_level (1,level div 4);
   sound_pitch (1,pitch*10+10*18);
   delay(duration*tempo);
end;


procedure init;
begin
   writeln;
   write('tempo (1-100): ');
   readln(tempo);

   graphmode;
   x := 0; y := 100;
   gotoxy(1,5);
   writeln('p'); writeln('i'); writeln('t'); writeln('c'); writeln('h');
   gotoxy(35,25); write('time');
   gotoxy(1,25);  write('0');
   draw(0,199,320,199,1);
   draw(0,0,0,199,1);
   gotoxy(1,1);
end;

