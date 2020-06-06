
{$m 10000,10000,10000}

{$i api1123.inc}

const
   group_size = 10;

   snA = 'DT900402';
   k0A = -1.36278E+3;
   k1A = -3.07886E-2;
   k2A =  2.154670E-3;

   snB = 'DT900402';
   k0B = -1.36278E+3;
   k1B = -3.07886E-2;
   k2B =  2.154670E-3;

var
   Otime:   longint;
   ptime:   longint;

(* ------------------------------------------------------------ *)
function period(f: real): real; {period in uS from frequency}
begin
   if f = 0 then
      period := 1e30
   else
      period := 1e6/f;
end;

(* ------------------------------------------------------------ *)
function crhoA(f: real): real;
var
   t: real;
begin
   if f = 0 then
      crhoA := 999
   else
      crhoA := k0A + k1A*period(f) + k2A*sqr(period(f));
end;

(* ------------------------------------------------------------ *)
function crhoB(f: real): real;
begin
   if f = 0 then
      crhoB := 999
   else
      crhoB := k0B + k1B*period(f) + k2B*sqr(period(f));
end;

(* ------------------------------------------------------------ *)
function frho(t: real): real; {fluid density}
begin
   frho := 1000*api1123(t);  {water}
(**
   frho := 1.141654*(560+68.4)/(560+t);  {air, kg/m3}
**)
end;

(* ------------------------------------------------------------ *)
function ftoc(f: real): real; {degrees F to C conversion}
begin
   ftoc := (f-32.0) / 1.8;  {F to C}
end;

(* ------------------------------------------------------------ *)
function hhmmss_to_sec(hhmmss: string): longint;
var
   hh,mm,ss: longint;
   e:        integer;
   tm:       longint;
begin
   val(copy(hhmmss,1,2),hh,e);
   val(copy(hhmmss,4,2),mm,e);
   val(copy(hhmmss,7,2),ss,e);

   tm := otime+ss+60*(mm+60*(hh));
   if tm < ptime then
   begin
      otime := otime+86400;
      tm := tm+86400;
   end;
   ptime := tm;

   hhmmss_to_sec := tm;
end;

(* ------------------------------------------------------------ *)
function atof(a: string): real;
var
   i: integer;
   e: integer;
   f: real;
begin
   while (a <> '') and (a[1] = ' ') do
      delete(a,1,1);
   while a[length(a)] = ' ' do
      dec(a[0]);
   val(a,f,e);
   atof := f;
end;

(* ------------------------------------------------------------ *)
var
   fd,ofd:  text;
   time:    longint;
   f1:      real;
   f2:      real;
   t:       real;
   d:       real;
   ok:      boolean;
   time0:   longint;
   f10:     real;
   f20:     real;
   rhoA0:   real;
   rhoB0:   real;
   rhoA:    real;
   rhoB:    real;
   t0:      real;
   d0:      real;
   f12:     real;
   f22:     real;
   t2:      real;
   f1sd:    real;
   f2sd:    real;
   tsd:     real;
   n:       longint;
   r:       real;

const
   CL = 2.0;

(* ------------------------------------------------------------ *)
procedure get_line;
var
   s: string;
begin
   ok := false;

   readln(fd,s);
   if length(s) < 49 then
      exit;
   if s[7] <> ':' then
      exit;

   ok := true;
   time := hhmmss_to_sec( copy(s,5,8) );
   f1 := atof( copy(s,17,10) );
   f2 := atof( copy(s,30,10) );
   t := atof( copy(s,44,10) );
end;

(* ------------------------------------------------------------ *)
procedure convert_line;
var
   i:       integer;
   n:       real;
   ttime:   real;
   tf1:     real;
   tf2:     real;
   tt:      real;

begin
   n := 0;
   ttime := 0;
   tf1 := 0;
   tf2 := 0;
   tt := 0;

   for i := 1 to group_size do
   begin
      get_line;
      if ok then
      begin
         n := n + 1;
         ttime := ttime+time;
         tf1 := tf1 + f1;
         tf2 := tf2 + f2;
         tt := tt + t;
      end;
   end;

   if n = 0 then
      ok := false
   else
   begin
      ok := true;
      time := trunc(ttime/n);
      f1 := tf1/n;
      f2 := tf2/n;
      t := tt/n;
   end;
end;

(* ------------------------------------------------------------ *)
procedure determine_sd;
begin
   f10 := 0; f12 := 0;
   f20 := 0; f22 := 0;
   t0 := 0; t2 := 0;
   n := 0;

   while not eof(fd) do
   begin
      convert_line;

      if ok then
      begin
         if n = 0 then
            time0 := time;
         inc(n);
         f10 := f10 + f1; {f12 := f12 + sqr(f1); }
         f20 := f20 + f2; {f22 := f22 + sqr(f2); }
         t0 := t0 + t;    {t2 := t2 + sqr(t);    }
      end;
   end;
   close(fd);

   if n = 0 then
      exit;

   f10 := f10/n;
{  r := f12/n-sqr(f10);
   if (r <= 0) or (f10 = 0) then
      f1sd := 1e6
   else
      f1sd := CL*sqrt(r); }

   f20 := f20/n;
{  r := f22/n-sqr(f20);
   if (r <= 0) or (f20 = 0) then
      f2sd := 1e6
   else
      f2sd := CL*sqrt(r); }

   t0 := t0/n;
{  r := t2/n-sqr(t0);
   if (r <= 0) or (t0 = 0) then
      tsd := 1e6
   else
      tsd := CL*sqrt(r); }

   d0 := frho(t0);
   rhoA0 := crhoA(f10);
   rhoB0 := crhoB(f20);
end;

(* ------------------------------------------------------------ *)
begin
   assign(fd,paramstr(1));
   reset(fd);

   writeln('pass 1');
   otime := 0;
   ptime := 0;
   determine_sd;

   writeln('pass 2');
   otime := 0;
   ptime := 0;
   reset(fd);
   assign(ofd,paramstr(2));
   rewrite(ofd);

   writeln(ofd);
   writeln(ofd,'S/N A=',snA,' K0=',k0A,' K1=',k1A,' K2=',k2A);
   writeln(ofd,'S/N B=',snB,' K0=',k0B,' K1=',k1B,' K2=',k2B);
   writeln(ofd,'Group size: ',group_size);
   writeln(ofd);

   write(ofd,
      'time':10,
      'temp':10,
      'dens':10);

{f20 := 0;}
   if f10 <> 0 then
      write(ofd,
         'freqA':10,
         'rhoA':10);

   if f20 <> 0 then
      write(ofd,
         'freqB':10,
         'rhoB':10);

   writeln(ofd);

   while not eof(fd) do
   begin
      convert_line;

      if ok then
      begin
{        if abs(f10-f1) > f1sd then ok := false;
         if abs(f20-f2) > f2sd then ok := false;
         if abs(t0-t)   > tsd  then ok := false;  }

         time := time-time0;
         if time < 0 then
            time := time + 1440*60;

         d := frho(t) {/ d0};
         rhoA := crhoA(f1) {/crhoA(f10)};
         rhoB := crhoB(f2) {/crhoB(f20)};

{        if f10 = 0 then
            f1 := 0
         else
            f1 := f1/f10; }

{        if f20 = 0 then
            f2 := 0
         else
            f2 := f2/f20; }

{         t := (t+560)/(t0+560); }

         if ok then
         begin
            write(ofd,
               time/60:10:1,' ',
               ftoc(t):9:2,' ',
               d:9:6,' ');

            if f10 <> 0 then
               write(ofd,
                  f1:9:3,' ',
                  rhoA:9:6,' ');

            if f20 <> 0 then
               write(ofd,
                  f2:9:3,' ',
                  rhoB:9:6,' ');

            writeln(ofd);
         end;
      end;
   end;

   close(fd);
   close(ofd);
end.

