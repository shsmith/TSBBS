
(*
 * timepaus - timed pause,
 *
 * use in batch files to allow an automatic boot-up sequence, but
 * allow the operator to stop part of it if he is there when it happens.
 *
 * s.h.smith, 9-aug-87 (rev. 27-jun-94)
 *
 *)

uses crt,tools;

var
   i:     integer;
   start: real;
   stop:  real;
   c:     char;
   pnow:  real;
   now:   real;
   count: real;

begin
   if paramcount = 0 then
   begin
      writeln('Usage:  TIMEPAUS seconds <prompt>');
      writeln('        if errorlevel 1 goto escape_pressed');
      writeln('        rem timed out... continue normally');
      halt;
   end;

   writeln;
   for i := 2 to paramcount do
      write(paramstr(i),' ');
   writeln;

   count := atoi(paramstr(1));
   start := int(get_time);
   stop := start + count;
   pnow := 0;

   repeat
      pnow := now;
      now := int(get_time);
      if pnow <> now then
      begin
         if now < start then  {midnight rolover}
         begin
            start := now;
            stop := start + count;
         end;

         count := int(stop-now);
         write(^M'You have ',count:0:0,' seconds.   ');
      end;
   until keypressed or (now >= stop);

   if keypressed then
   begin
      c := readkey;
      if c = #27 then
      begin
         writeln('Sequence aborted.');
         halt(1);
      end
      else
      begin
         writeln('Normal exit.');
         halt(0);
      end;
   end
   else

   begin
      writeln('Timeout; normal exit.');
      halt(0);
   end;

end.


