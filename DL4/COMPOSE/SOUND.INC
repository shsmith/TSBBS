
(*
 * voice - multi-voice sound library for PCjr or Tandy 1000 sound chip
 *
 *)

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
   for v := 0 to 4 do
   begin
      sound_level(v,15);
      sound_pitch(v,0);
   end;
end;

