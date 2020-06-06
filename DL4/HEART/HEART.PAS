
(*
 * heart - program to calculate and monitor heart rate
 *
 * author:  samuel hood smith,  8-dec-85 (23-jan-96)
 *
 *)

program heart_rate_monitor;

uses crt, osint;

const
   update_period = 10.0;   {figure heart rate every 6 seconds}
   minimum_count = 3;      {minimum heart beats for rate calculation}
   timeout_period = 2.0;   {seconds between heardbeats for rate timeout}

   default_age = 36;       {defaults for fitness calculation}
   default_resting = 60;

   reset_freq = 300;       {sound effects}
   beat_freq = 1400;
   rate_freq =  700;
   sound_duration = 8;

   escape = #27;           {escape key to terminate program}

   meter_init = 'ณ                                    บ              ณ';

var
   age:           real;        {age in years}
   resting_rate:  real;        {resting heart rate}
   max_rate:      real;        {maximum safe heart rate}
   target_rate:   real;        {workout target heart rate}


(*
 * chart_beat - mark individual heartbeat
 *
 *)

procedure chart_beat(elapsed: real);
var
   index:         real;
   meter_index:   integer;

begin
   index := elapsed / update_period * int(length(meter_init)-4) + 2;

   {clip if it is off the meter scale}
   if index < 2 then
      index := 2
   else
   if index >= length(meter_init) then
      index := length(meter_init)-1;

   meter_index := trunc(index);
   lowvideo;
   gotoxy(24+meter_index,wherey);
   case trunc( (index-trunc(index)) * 3.0) of
      0: write('Ý');
      1: write('บ');
     {1: write('ณ');}
      2: write('Þ');
   end;
   write(#13);
   normvideo;
end;


(*
 * chart_pulse - display the graphic of pulse rate
 *
 *)

procedure chart_pulse(rate: real);
var
   index:         real;
   meter_index:   integer;

begin
   {calculate the position on the analog meter display}
   index := (rate - resting_rate) /
            (max_rate - resting_rate) *
            int(length(meter_init)) + 1.0;

   {clip the indication if it is off the meter scale}
   if index < 2 then
      index := 2
   else
   if index >= length(meter_init) then
      index := length(meter_init)-1;

   meter_index := trunc(index);
   gotoxy(23+meter_index,wherey);

   if index-trunc(index) > 0.5 then
      write('ÞÛÝ')
   else
      write('ÛÛ ');

   writeln(#13);

   lowvideo;
   gotoxy(25,wherey);
   write(meter_init,#13);
   normvideo;
end;


(*
 * read_pulse - determine pulse rate
 *
 *)

procedure read_pulse;

var
   tFirst:  real;       {time of first beat}
   tLast:   real;       {time of final beat}
   beats:   integer;    {count of heart beats}
   rate:    real;
   wtime:   real;

begin
   beats := 0;
   delay(sound_duration);
   nosound;
   wtime := 0;

   while true do
   begin
      if (beats = 0) and (trunc(time-wtime) <> 0) then
      begin
         wtime := time;
         write('<waiting>    ', timeText,#13);
      end;

      {mark the time when each beat arrives}
      if keypressed then
      begin
         if readkey = escape then exit;   {end program}

         {if no beats seen, mark beginning time}
         if beats = 0 then tFirst := time;
         tLast := time;

         write(beats:4,'       '#13);
         inc(beats);

         chart_beat(time-tFirst);

         sound(beat_freq);
         delay(sound_duration);
         nosound;
      end;

      {when measurement period elapses, calculate and display the rate}
      if beats > 0 then
      begin

         if ((time-tLast) >= timeout_period) or
            ((time-tFirst) >= update_period) then
         begin
            {reset counter on timeout}
            if beats < minimum_count then
            begin
               beats := 0;
               wtime := 0;
               sound(reset_freq);
               delay(sound_duration*3);
               nosound;
            end
            else

            begin
               {measurement period is valid; calculate and display}
               rate := int(beats-1) / (tLast-tFirst) * 60.0;

               gotoxy(5,wherey);
               write(rate:7:0, '  ', timeText);
               chart_pulse(rate);

               {use final pulse as tFirst of next measurement}
               tFirst := tLast;
               beats := 1;
               write(0:4,#13);

               sound(rate_freq);
               delay(sound_duration*2);
               nosound;
            end;
         end;

      end;
   end;
end;


(*
 * display_headers - display display screen headers in preparation for
 *                   operation of main program
 *
 *)

procedure display_headers;
var
   topline: integer;
   i:       integer;

begin
   lowvideo;
   clrscr;

   normvideo;
   writeln('Beats  Rate    Time    ',
           resting_rate:3:0,'                                  ',
           target_rate:3:0, '            ',
           max_rate:3:0);

   lowvideo;  write('อออออ  ออออ  ออออออออ   ีอ');
   normvideo; write('Resting');
   lowvideo;  write('ออออออออออออออออออออออออออ');
   normvideo; write('Target');
   lowvideo;  write('อออ');
   normvideo; write('Maximum');
   lowvideo;  writeln('อธ');

   topline := wherey;
   for i := topline to screenlines-2 do
   begin
      gotoxy(25,i);
      write(meter_init);
   end;

   gotoxy(25,screenlines-1);
   writeln('ิออออออออออออออออออออออออออออออออออออสออออออออออออออพ');

   write  ('    Press <space> for each heartbeat,   press <esc> to stop program');

   normvideo;
   window(1,topline,80,screenlines-2);
   gotoxy(1,1);
end;


procedure getint(var result: real);
var
   s: string;
   i: integer;
begin
   s := '';
   readln(s);
   if s <> '' then
      val(s,result,i);
end;


(*
 * main program
 *
 *)

begin
   textbackground(blue);
   textcolor(white);
   clrscr;
   normvideo; write('Heart rate monitor                             ');
   lowvideo;  writeln('v1.2, 21-jan-96 S.H. Smith');
   writeln;

   age := default_age;
   lowvideo;  write('Enter your age (in years) <',default_age,'>: ');
   getint(age);

   resting_rate := default_resting;
   write('Enter your resting heart rate (in beats/min) <',default_resting,'>: ');
   getint(resting_rate);

   {calculations for males; from "the complete bicycle fitness book"}
   max_rate := 220.0 - age;
   target_rate := (max_rate - resting_rate) * 0.7 + resting_rate;

   {display the initial data screen and begin monitoring heart rate}
   display_headers;

   {continue to display the pulse rate and other information}
   read_pulse;

   {program stopped, prepare screen for exit}
   window(1,1,80,screenlines);
   gotoxy(1,screenlines);
   clreol;
   lowvideo;
   gotoxy(1,screenlines-1);   {dos prints a linefeed before the prompt}
end.

