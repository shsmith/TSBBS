
(*
 * dateact - report system activity by dates
 * for pcboard 14.5
 *
 * s.h.smith, 4-16-91
 *
 *)

uses openshare,dos,tools,qread;

const
   version = 'DATEACT 2.1 (2-7-94) Copyright 1994 Samuel H. Smith';

type
   weekdays = 0..6;

const
   dayname: array [weekdays] of string[3] =
       ('Sun',
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat');

type
   julian_date = longint;

   dateinfo_ptr = ^dateinfo_rec;
   dateinfo_rec = record
      date:    julian_date;
      dow:     weekdays;
      mins:    longint;
      next:    dateinfo_ptr;
   end;

var
   dates:   dateinfo_ptr;
   date:    julian_date;
   time:    integer;
   buf:     array[1..maxint] of char;
   nodes:   integer;
   minutes: array[0..23] of integer;
   days:    integer;
   lasthr:  integer;

function caljul (m,d,y:   integer): julian_date;
var
   x:   julian_date;
begin
   x := trunc(int(30.57 * m) + int(365.25 * y - 395.25) + d);
   if m > 2 then
      if trunc(y / 4) = y / 4 then
         x := x - 1
      else
         x := x - 2;
   caljul := x;
end;


procedure julcal (x:          julian_date;
                  var month, day, year:  integer);
var
   m, d, y: julian_date;
   d1:      integer;
   
begin
   y := trunc(x / 365.26)+ 1;
   d := x + trunc(395.25 - 365.25 * y);

   if trunc(y / 4)* 4 = y then
      d1 := 1
   else
      d1 := 2;
   
   if d > (91 - d1) then
      d := d + d1;

   m := trunc(d / 30.57);
   d := d - trunc(30.57 * m);

   if m > 12 then
   begin
      m := 1;
      y := y + 1;
   end;

   month := trunc(m);
   day := trunc(d);
   year := trunc(y);
end;


function dayofweek (jdate: julian_date): weekdays;
var
   month,day,year:   integer;
   century:          integer;
   dow:              integer;

begin
   julcal(jdate,month,day,year);

   if year < 1900 then
      year := year+1900;

   if month > 2 then
      month := month - 2
   else
   begin
      month := month + 10;
      year := pred (year);
   end;

   century := year div 100;
   year := year mod 100;
   dow := (day - 1 +((13 * month - 1) div 5) +
                    (5 * year div 4) +
                    (century div 4) -
                    (2 * century) + 1) mod 7;

   dayofweek := dow;
end;


procedure add_time(date: julian_date; time: integer; mins: integer);
var
   node: dateinfo_ptr;
   min:  integer;
   temp: integer;

begin
   if time+mins > 1440 then
   begin
      add_time(date,time,1440-time);
      mins := mins-(1440-time);
      add_time(date+1,0,mins);
      exit;
   end;

   temp := time;
   for min := 1 to mins do
   begin
      lasthr := temp div 60;
      inc(minutes[lasthr]);
      inc(temp);
   end;

   if dates = nil then
   begin
      new(dates);
      dates^.next := nil;
      dates^.date := date;
      dates^.dow := dayofweek(date);
      dates^.mins := mins;
      inc(days);
      exit;
   end;

   node := dates;
   while node <> nil do
   begin
      if node^.date = date then
      begin
         node^.mins := node^.mins + mins;
         exit;
      end;

      node := node^.next;
   end;

   node := dates;
   new(dates);
   dates^.next := node;
   dates^.date := date;
   dates^.dow := dayofweek(date);
   dates^.mins := mins;
   inc(days);
end;


procedure process_line(line: string);
var
   minutes:  string;

begin
   {'04-16-91 (07:34) (3) RUSS COOPER (2400) (N) GLENDALE, AZ'}
   {'      Minutes Used: 53                                  '}
   {'1234567890123456789012'}

   if length(line) < 21 then
      exit;

   {minutes used: }
   if (line[7] = 'M') and (line[15] = 'U') and (line[19] = ':') then
   begin
      minutes := copy(line,21,4);
      while minutes[length(minutes)] = ' ' do
         dec(minutes[0]);
      add_time(date,time,atoi(minutes));
   end;

   {mm-dd-yy (hh:mm)}
   {123456789012345}
   if (line[3] = '-') and (line[6] = '-') then
   begin
      date := caljul( atoi(copy(line,1,2)),
                      atoi(copy(line,4,2)),
                      atoi(copy(line,7,2)) );

      time := atoi(copy(line,11,2))*60+
              atoi(copy(line,14,2));
   end;

end;


procedure read_logfile(fname: string);
var
   line:    string;
   infd:    text;
begin
   inc(nodes);
   writeln('Reading ',fname,' ...');
   line := '   ';
   assignText(infd,fname);
   reset(infd);
   settextbuf(infd,buf);

   while line[1] <> ^Z do
   begin
      qReadLn(infd,line,sizeof(line)-1);
      process_line(line);
   end;
   close(infd);
end;


procedure output_reports(fname: string);
var
   node:    dateinfo_ptr;
   outfd:   text;
   percent: integer;
   year:    integer;
   month:   integer;
   day:     integer;
   dow:     string;
   tmins:   longint;
   tdays:   longint;
   hour:    integer;
   fnode:   dateinfo_ptr;

   procedure bargraph;
   var
      p: integer;
   begin
      write(outfd,'Ã');
      p := 0;
      while percent > 0 do
      begin
         if percent = 1 then
            write(outfd,'¯')
         else
            write(outfd,'þ');
         percent := percent-2;
         p := p + 2;
      end;

      while p <= 100 do
      begin
         case p of
            10,20,30,40,60,70,80,90:
               write(outfd,'ù');
            50:
               write(outfd,'+');
            100:
               write(outfd,'´');
            else
               write(outfd,' ');
         end;
         p := p + 2;
      end;

      writeln(outfd);
   end;

begin
   writeln('Writing ',fname,' ...');
   assign(outfd,fname);
   rewrite(outfd);

   write(outfd,days,' Day Hourly System Activity Summary');
   if nodes > 1 then
      write(outfd,' for ',nodes,' Nodes');
   writeln(outfd);
   writeln(outfd);
   writeln(outfd,'   Hour    %                  Relative Utilization');
   writeln(outfd,'   ----  -----   --------------------------------------------------');

   for hour := 0 to 23 do
   begin
      percent := trunc(minutes[hour] / nodes / days / 60.0 * 100.0);
      write(outfd,hour:6,percent:7,'   ');
      bargraph;
   end;

   writeln(outfd);

   write(outfd,'Weekly System Activity Summary');
   if nodes > 1 then
      write(outfd,' for ',nodes,' Nodes');
   writeln(outfd);
   writeln(outfd);
   writeln(outfd,'    Date Range          %               Relative Utilization');
   writeln(outfd,'--------------------  ----  --------------------------------------------------');

   node := dates;
   tmins := 0;
   tdays := 0;
   fnode := nil;

   while node <> nil do
   begin
      dow := dayname[node^.dow];

      if (fnode = nil) then
      begin
         fnode := node;
         tdays := 1;
         tmins := node^.mins;
      end
      else
      begin
         inc(tdays);
         tmins := tmins + node^.mins;
      end;

      if ((dow = 'Sun') or (node^.next = nil)) then
      begin
         percent := trunc(tmins / nodes / tdays / 1440.0 * 100.0);

         julcal(node^.date,month,day,year);
         write(outfd,month:2,'/',day:2,'/',year:2,' to ');

         julcal(fnode^.date,month,day,year);
         write(outfd,
            month:2,'/',day:2,'/',year:2,'  ',
            percent:3,'  ');

         bargraph;
         fnode := nil;
      end;

      node := node^.next;
   end;

   writeln(outfd);

   write(outfd,'Daily System Activity Summary');
   if nodes > 1 then
      write(outfd,' for ',nodes,' Nodes');
   writeln(outfd);
   writeln(outfd);
   writeln(outfd,'   Day   Date      %                 Relative Utilization');
   writeln(outfd,'   --- --------  -----  --------------------------------------------------');

   node := dates;
   tmins := 0;
   tdays := 0;
   fnode := nil;

   while node <> nil do
   begin
      dow := dayname[node^.dow];

      if (fnode = nil) then
      begin
         fnode := node;
         tdays := 1;
         tmins := node^.mins;
      end
      else
      begin
         inc(tdays);
         tmins := tmins + node^.mins;
      end;

      if dow = 'Sun' then
         writeln(outfd);

      percent := trunc(node^.mins / nodes / 1440.0 * 100.0);
      julcal(node^.date,month,day,year);

      write(outfd,'   ',
         dow, ' ',
         month:2,'/',day:2,'/',year:2,'  ',
         percent:4,'  ');

      bargraph;

      node := node^.next;
   end;

   writeln(outfd);
   writeln(outfd,'Report made by ',version);
   close(outfd);
end;

var
   i: integer;
   par: string;
begin
   if paramcount < 2 then
   begin
      writeln(version);
      writeln('Courtesy of:  The Tool Shop (818) 891-1344.');
      writeln;
      writeln('Usage: dateact OUTFILE INFILE {INFILE...}');
      halt;
   end;

   dates := nil;
   date := 0;
   nodes := 0;
   days := 0;
   for i := 0 to 23 do
      minutes[i] := 0;

   for i := 2 to paramcount do
      read_logfile(paramstr(i));

   output_reports(paramstr(1));

end.

