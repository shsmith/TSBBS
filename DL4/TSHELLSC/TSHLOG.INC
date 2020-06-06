
const tshlog_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Sourcefile logging 1.0'#0;
#log Sourcefile logging 1.0

(*
 * tshlog - log sourcefiles during compilation
 *)

#include "\shs\tools\gettime.inc"   {get time as a real}

var
   started:        real;
   logfd:          text;
   logging:        boolean;


procedure log_sourcefile(name: anystring);
begin
   if logging then
      writeln(logfd,get_file_date(name),' ',name);

#ifdef STAND_ALONE
   flush(logfd);
#endif
end;


procedure log_message(msg: anystring);
begin
   if logging then
      writeln(logfd,'; ',msg);

#ifdef STAND_ALONE
   flush(logfd);
#endif
end;


procedure open_logfile(name: anystring);
var
   fname: anystring;
   p:     integer;

begin
   p := pos('.',name);
   if p = 0 then
      COPY_STR(fname, name)
   else
      fname := copy(name,1,p-1) + '.log';

   assign(logfd,fname);
   rewrite(logfd);

   started := get_time;
   logging := true;

#ifdef STAND_ALONE
   writeln(logfd);
   writeln(logfd,'Preprocessing started: ',system_date,' ',system_time);
   writeln(logfd,'Processor: ',whoami, ' ',
                 program_version, ',  ',last_update);
   writeln(logfd);
#else
   writeln(logfd);
   writeln(logfd,'Compilation started: ',system_date,' ',system_time);
   writeln(logfd,'Compiler: TURBO PASCAL Version ',
                 version_name[version], ',  Path: ',progname);
   writeln(logfd,'Running under ',whoami, ' ',
                 program_version, ',  ',last_update);
   writeln(logfd);
#endif

end;


procedure close_logfile(code:  byte;
                        lines: integer);
var
   elapsed: real;
   stop:    real;
   rate:    real;
   x:       integer;

begin
   if logging then
   begin
      stop := get_time;
      elapsed := stop - started;
      rate := int(lines) / elapsed * 60.0;

#ifndef STAND_ALONE
      x := wherex;
      writeln; writeln; writeln;
      writeln; writeln; writeln;
      clreol;
      normvideo;
      writeln('Speed:    ',rate:6:0,' lines/min  (',elapsed:6:1,' seconds)');
      lowvideo;
      writeln;
      gotoxy(x,wherey-8);
#endif

      writeln(logfd);

      if code <> 0 then
      begin
         writeln(logfd,'*** ERROR ',code,' ***,  Source:');
         writeln(logfd,line_txt);
         writeln(logfd);
         INCR(error_count);
      end;

      if error_count = 0 then
         writeln(logfd,'No errors detected')
      else
         writeln(logfd,error_count,' errors detected');
      writeln(logfd);

#ifdef STAND_ALONE
      writeln(logfd,'Processing rate:  ',
#else
      writeln(logfd,'Compile rate:  ',
#endif
                    lines,' lines in ',elapsed:0:1,' seconds,  ',
                    rate:0:0,' lines/min');

      close(logfd);
   end;

   logging := false;
end;

