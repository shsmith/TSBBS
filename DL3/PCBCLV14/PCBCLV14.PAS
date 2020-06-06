
(*
 * CLView - Caller Log Viewer for PCBoard 11.x and 12.0
 *
 * Samuel H. Smith, 17-may-87 (rev. 03-Oct-87)
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Phoenix, Az
 *         (602) 279-2673
 *
 * This program uses many of the building-blocks in the Tool Shop Library,
 * which is available for download from the Tool Shop.   Compile using
 * TSHELL 1.2, also avaliable from the Tool Shop.
 *
 *
 * Revision history
 * ----------------
 *
 *    17-May-87 1.00 Initial coding, S.H.Smith.
 *
 *    17-May-87 1.01 Changed screen alignment when 'N' command crosses EOF.
 *                   Released as PCBCLV10.ARC.
 *
 *    20-May-87 1.10 Added file-sharing support for multi process/node
 *                   operation.
 *
 *    21-May-87 1.11 Changed file sharing modes to deny nothing.
 *                   Released as PCBCLV11.ARC.
 *
 *    25-May-87 1.20 Added Search and ReverseSearch functions.
 *
 *    25-May-87 1.30 Updated filter for PCB 12.0.
 *                   Released as PCBCLV13.ARC.
 *
 *    17-Jul-88 1.4  Updated for Turbo Pascal 4.0.
 *                   Released as PCBCLV14.ARC.
 *
 *
 * Disclaimer
 * ----------
 *
 * This software is completely FREE.   I ask only for your comments,
 * suggestions and bug reports.   If you modify this program, I would
 * appreciate a copy of the new source code.   Please don't delete my
 * name from the program.
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (602) 279-2673.
 *
 * Enjoy!     Samuel H. Smith
 *
 *)


uses DOS, CRT;

{$i \tinc\anystring.inc}
{$i \tinc\border.inc}

const
   whoami = 'PCBCLV14';
   version = 'v1.4 (7/17/88)';

type
   callrec = record
      data:  array[1..62] of char;
      crlf:  array[1..2] of char;
   end;


var
   line:    callrec;
   calfile: anystring;
   fd:      file of callrec;
   hi_rec:  longint;
   lo_rec:  longint;
   rec:     longint;
   last:    longint;
   cmd:     char;
   filter:  boolean;
   ok:      boolean;
   skey:    string[62];

procedure lowview;
begin
   textcolor(lightgray);
end;

procedure highvideo;
begin
   textcolor(white);
end;


function line_matches: boolean;
   {see if a line matches the filter criteria}
var
   match: boolean;

begin
   match := not filter;
   if not match then match := line.data[1] <> ' ';
   if not match then match := pos('using',line.data) <> 0;
   if not match then match := pos('left.',line.data) <> 0;
   if not match then match := pos('Left:',line.data) <> 0;
   line_matches := match;
end;


procedure display_line(n: longint);
   {display the current log line}
begin
   lowvideo;
   write(n:6,': ');

   if line.data[1] = '*' then
      lowvideo
   else
      highvideo;
   write(line.data);
end;


procedure prior_block;
   {display prior block of log entries}
begin
   gotoxy(1,23);
   if lo_rec <= 0 then
      lo_rec := last-1;
   hi_rec := lo_rec;

   while wherey > 3 do
   begin
      clreol;

      if (lo_rec < 0) or (lo_rec >= last) then
         gotoxy(1,wherey-1)
      else

      begin
         seek(fd,lo_rec);
         read(fd,line);
         if line_matches then
         begin
            display_line(lo_rec);
            gotoxy(1,wherey-1);
         end;
      end;

      lo_rec := lo_rec - 1;
   end;

   lo_rec := lo_rec + 1;
   if lo_rec < 0 then
      lo_rec := 0;
end;


procedure next_block;
   {display the next block of log entries}
begin
   gotoxy(1,4);
   if hi_rec >= last-1 then
      hi_rec := 0;
   lo_rec := hi_rec;

   repeat
      clreol;

      if (hi_rec < 0) or (hi_rec >= last) then
      begin
         if wherey > 22 then
            gotoxy(1,wherey+1)
         else
         begin
            lo_rec := last-1;
            prior_block;
            exit;
         end;
      end
      else

      begin
         seek(fd,hi_rec);
         read(fd,line);
         if line_matches then
         begin
            display_line(hi_rec);
            if wherey < 23 then
               gotoxy(1,wherey+1);
         end;
      end;

      hi_rec := hi_rec + 1;
   until (wherey = 23) and (wherex > 1);

   hi_rec := hi_rec - 1;
   if hi_rec >= last then
      hi_rec := last-1;
end;


procedure search(reverse: boolean);
   {search for a keyword}
var
   newkey:  anystring;

   procedure advance;
   begin
      if not reverse then
      begin
         hi_rec := hi_rec + 1;
         if hi_rec >= last then
            hi_rec := 0;
      end
      else
      begin
         hi_rec := hi_rec - 1;
         if hi_rec < 0 then
            hi_rec := last-1;
      end;
   end;

begin
   write(' [Enter]='+skey+'? ');
   newkey := '';
   readln(newkey);
   if newkey <> '' then
      skey := newkey;
   write(' ');

   repeat
      lo_rec := hi_rec;
      if (lo_rec mod 32) = 0 then
         write(lo_rec:5,^H^H^H^H^H);

      seek(fd,hi_rec);
      read(fd,line);
      advance;
   until (pos(skey,line.data) > 0) or (hi_rec = lo_rec) or keypressed;

   hi_rec := hi_rec - 10;
   if hi_rec < 0 then
      hi_rec := 0;
   next_block;
end;

procedure advert;
   {display the advertisement}
begin
   writeln;
   writeln('Thank you for using ',whoami,' ',version,'!');
   writeln;
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop PCBoard, (602) 279-2673');
   writeln;
end;

procedure usage;
begin
   writeln;
   writeln('Usage:    '+whoami+' callerfile');
   writeln;
   writeln('Example:  '+whoami+' MAIN\CALLER');
end;


(*
 * main program
 *
 *)

begin
   clrscr;
   gotoxy(1,25);
   writeln;

   if (paramcount <> 1) then
   begin
      usage;
      advert;
      halt;
   end;

   calfile := paramstr(1);
   assign(fd,calfile);
   filemode := $42;  {deny none share mode}
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      gotoxy(1,4);
      writeln('Can''t open caller log file: '+paramstr(1));
      usage;
      advert;
      halt;
   end;

   highvideo;
   display_border(1,1,79,25,mixed_border);
   gotoxy(3,1);
   write('Caller Log Viewer '+version);

   window(2,2,77,24);
   gotoxy(1,1);
   lowvideo;
   writeln('  Command:  [N]ext, [P]rior, [F]ilter, [J]ump, [Q]uit, [L]ast, ');
   writeln('  [S]earch, [R]evSearch? ');
   writeln(' 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
   highvideo;

   skey := '*';
   last := filesize(fd);
   lo_rec := last-1;
   filter := true;
   prior_block;
   close(fd);

   repeat
      gotoxy(26,2);
      highvideo;
      clreol;
      cmd := upcase(readkey);

      assign(fd,calfile);
      filemode := $42;  {deny none share mode}
      {$i-} reset(fd); {$i+}
      if ioresult <> 0 then
      begin
         gotoxy(1,4);
         writeln('Can''t reopen caller log file: '+paramstr(1));
         writeln;
         halt;
      end;

      last := filesize(fd);

      case cmd of
         'N':   begin
                   write('Next page');
                   next_block;
                end;

         'P':   begin
                   write('Prior page');
                   prior_block;
                end;

         'F':   begin
                   filter := not filter;
                   hi_rec := lo_rec;
                   if filter then
                      write('Filter On')
                   else
                      write('Filter Off');
                   next_block;
                end;

         'J':   begin
                   write('Jump to: ');
                   readln(hi_rec);

                   if hi_rec >= last then
                   begin
                      lo_rec := last-1;
                      prior_block;
                   end
                   else

                   if hi_rec < 1 then
                   begin
                      hi_rec := 0;
                      next_block;
                   end
                   else
                      next_block;
                end;

         'L':   begin
                   write('Last block');
                   lo_rec := last-1;
                   prior_block;
                end;

         'S':   begin
                   write('+Search: ');
                   search(false);
                end;

         'R':   begin
                   write('-Search: ');
                   search(true);
                end;

         'Q':   writeln('Quit');

      end;

      close(fd);

   until cmd = 'Q';

   window(1,1,80,25);
   clrscr;
   advert;

end.

