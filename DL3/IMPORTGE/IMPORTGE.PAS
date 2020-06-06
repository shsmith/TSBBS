
(*
 * ImportGE - Decode GEnie capture files
 *          Post captured messages in PCBoard conferences.
 *
 * (C) 1988 Samuel H. Smith, 10-Sep-88 (rev. 16-Sep-88)
 *
 * Converted for  GEnie message base imports
 * by Jerry Shifrin, East Coast Forth Board, 703-442-8695
 * Version 1.1, 2/13/89 - 80x100 character messages
 * Version 2.0, 2/20/89 - Made GEnie only
 * All rights returned to Samuel H. Smith
 *)

{$i prodef.inc}
{ r+,s+}
{$d+}

{$M 18000,50000,50000}  {Stack(min=12), minheap(min=50), maxheap}
{$L+}                   {Link in ram}

uses mdosio, bufio, openshare, tools;

const
   version = 'v2.0á 02-13-89';
   max_conv = 100;
   max_excl = 50;
   max_ren = 50;
   tmonths: array[1..12] of string[3] = ('Jan', 'Feb', 'Mar', 'Apr', 'May',
                           'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
   nmonths: array[1..12] of string[2] = ('01', '02', '03', '04', '05', '06',
                                         '07', '08', '09', '10', '11', '12');

var
   packet_type:      (rsns_packet, arcm_packet);
   config_name:      string30;
   system_dir:       string30;
   packet_file:      string30;
   infd:             text;
   inbuffer:         array[1..20000] of byte;
   line:             string80;

   origin_system:    string72;
   cur_conf:         string12;
   posted:           integer;
   excluded:         integer;
   tposted:          integer;
   texcluded:        integer;
   reason:           string30;
   postall:          boolean;
   gotone:           boolean;
   debug:            boolean;

{current message information}
   echo:             boolean;
   odate:            string12;
   date:             string8;
   time:             string8;
   whoto:            string30;
   whofrom:          string30;
   subject:          string30;

{conference names and filenames from CNAMES}
   confname:         array[1..40] of string12;
   confpath:         array[1..40] of string30;
   confcount:        integer;

{conference name conversion table}
   convfrom:         array[1..max_conv] of string12;
   convto:           array[1..max_conv] of string12;
   convcount:        integer;

{excluded strings table}
   exclude:          array[1..max_excl] of string80;
   exclcount:        integer;

{user rename conversion table}
   renfrom:          array[1..max_conv] of string25;
   rento:            array[1..max_conv] of string25;
   rencount:         integer;



(* --------------------------------------------------------- *)
procedure usage;
begin
   writeln('Usage:    UnArcm CONFIGFILE SYSTEMDIR PACKETFILE DEBUG',
           ^M^J^M^J'Example:  unarcm unarcm.cnf c:\pcb2 tool2.txt debug'^M^J);
   writeln('SEE DOCUMENTATION BEFORE USING THIS PROGRAM!');
   halt(99);
end;


(* --------------------------------------------------------- *)
procedure deselect_conference; forward;

procedure error(message: string);
var
   fd:   text;
begin
   writeln(^M^J'Error: ',message,
           ^M^J'   At: "',line,'"');

   assign(fd,'UNARCM.ERR');
   {$i-} append(fd); {$i+}
   if ioresult <> 0 then
      {$i-} rewrite(fd); {$i+}

   if ioresult = 0 then
   begin
      writeln(fd,system_date,' ',system_time,' UnArcm ',version,
                 ^M^J'Error: ',message,
                 ^M^J'   At: "',line,'"'^M^J);
      close(fd);
   end;

   deselect_conference;
   halt(99);
end;


(* --------------------------------------------------------- *)
{$i msgio.inc}    {pcb 14 message i/o routines}


(* --------------------------------------------------------- *)
procedure getline;
   {read a line from the input file; special handling causes
    <return> to start a new line rather than the normal cr/lf}
var
   c: char;

begin
   line := '';
   while true do
   begin
      if eof(infd) then
      begin
         if length(line) = 0 then
            line := ^Z;
         exit;
      end;

      read(infd,c);
      case c of
         ^Z,^M:
               exit;

         ^J:
               ;

         ^H:   if length(line) > 0 then
                  dec(line[0]);

         else
         begin
            if length(line) < sizeof(line)-1 then
               inc(line[0]);
            line[length(line)] := c;
         end;
      end;
   end;
end;



(* --------------------------------------------------------- *)
procedure deselect_conference;
begin
   if length(cur_conf) > 0 then
   begin
      close_conference;
      writeln('   ',posted,' messages posted (',excluded,' excluded)',
              '  in Conference ', cur_conf);
      tposted := tposted + posted;
      texcluded := texcluded + excluded;
      cur_conf := '';
   end;
end;


(* --------------------------------------------------------- *)
procedure select_conference;
var
   i:          integer;

begin
   posted := 0;
   excluded := 0;

   stoupper(cur_conf);
   line := cur_conf;
   for i := 1 to convcount do
      if convfrom[i] = cur_conf then
         line := convto[i];

   mbfile := '';
   for i := 1 to confcount do
      if confname[i] = line then
         mbfile := confpath[i];

   if mbfile = '' then
   begin
      cur_conf := '';
      error('Conference not in CNAMES file');
   end;

   writeln(^M^J'Conference: ',ljust(cur_conf,12),
           '        Posting in: ',ljust(line,10) {,' (',mbfile,')'});

   open_conference;
end;


(* --------------------------------------------------------- *)
procedure load_config_file;
   (* load the configuration file *)
var
   fd:   text;
   i:    integer;
   key:  string12;

   (* --------------------------------------- *)
   procedure cexclude;
   begin
      inc(exclcount);
      if exclcount > max_excl then
         error('Too many EXCLUDE statements in config file');

      stoupper(line);
      exclude[exclcount] := line;
   end;

   (* --------------------------------------- *)
   procedure cconvert;
   begin
      stoupper(line);
      delete_spaces(line);

      i := pos(',',line);
      if i = 0 then
         error('Config entry syntax error:  convert Sourcename,Destname');

      inc(convcount);
      if convcount > max_conv then
         error('Too many CONVERT statements in config file');

      convfrom[convcount] := copy(line,1,i-1);
      convto[convcount]   := copy(line,i+1,99);
   end;

   (* --------------------------------------- *)
   procedure cpost;
   begin
      stoupper(line);
      if line = 'ALL' then
         postall := true
      else
      if line = 'ECHO' then
         postall := false
      else
         error('Format is POST ALL or POST ECHO');

   end;

   (* --------------------------------------- *)
   procedure crename;
   begin
      stoupper(line);

      i := pos(',',line);
      if i = 0 then
         error('Config entry syntax error:  rename ORIGINAL NAME, NEW NAME');

      inc(rencount);
      if rencount > max_ren then
         error('Too many RENAME statements in config file');

      renfrom[rencount] := copy(line,1,i-1);
      remove_comment(renfrom[rencount],';');

      rento[rencount]   := copy(line,i+1,99);
      remove_comment(rento[rencount],';');
   end;

   (* --------------------------------------- *)
   procedure corigin;
   begin
      origin_system := line;
   end;

   (* --------------------------------------- *)
   procedure cconference;
   begin
      deselect_conference;
      cur_conf := line;
      select_conference;
   end;


(* --------------------------------------- *)
begin
   assignText(fd,config_name);
   line := config_name;
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      error('Can''t open config file');

   exclcount := 0;
   convcount := 0;
   rencount := 0;

   while not eof(fd) do
   begin
      readln(fd,line);

      {remove comments and cosmetic spaces}
      remove_comment(line,';');

      if length(line) > 0 then
      begin
         i := pos(' ',line);
         if i = 0 then
            key := line
         else
         begin
            key := copy(line,1,i-1);
            line := copy(line,i+1,80);
         end;

         stoupper(key);
         if key = 'EXCLUDE' then
            cexclude
         else
         if key = 'CONVERT' then
            cconvert
         else
         if key = 'RENAME' then
            crename
         else
         if key = 'POST' then
            cpost
         else
         if key = 'ORIGIN' then
            corigin
         else
         if key = 'CONFERENCE' then
            cconference
         else
            error('Unrecognized config statement');
      end;
   end;

   close(fd);

   {check for missing information in config file}
   if exclcount = 0 then
      writeln('Warning: No EXCLUDE statements!  See documentation.');
   if rencount = 0 then
      writeln('Warning: No RENAME statements!  See documentation.');
end;


(* --------------------------------------------------------- *)
procedure load_setup_files;
   (* load the pcboard setup file and cnames file *)
var
   fd:   text;
   i:    integer;

begin
   line := system_dir + '\PCBOARD.DAT';
   assignText(fd,line);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      error('Can''t open pcboard setup file');

   readln(fd,line);
   if line <> '*** PCBoard Version 14.0 data file ***' then
      error('Only v14.0 PCBOARD.DAT format is supported');

   {get cnames filename from pcboard.dat}
   for i := 1 to 30 do
      readln(fd,line);

   close(fd);

   assignText(fd,line);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      error('Can''t open CNAMES file');

   confcount := 0;
   while not eof(fd) do
   begin
      readln(fd,line);
      stoupper(line);
      i := pos(' ',line);
      if i > 0 then
         line[0] := chr(i-1);

      inc(confcount);
      confname[confcount] := line;

      if confcount = 1 then
         if line <> 'MAIN' then
            error('Only v14.0 CNAMES format is supported');

      for i := 1 to 9 do
         readln(fd,confpath[confcount]);
      for i := 1 to 23 do
         readln(fd,line);
   end;

   close(fd);
end;


(* --------------------------------------------------------- *)
procedure initialize;
begin
   writeln(^M^J'ImportGE ',version,'  (C) 1988 S.H.Smith',
           ^M^J'Courtesy of:  The Tool Shop, (602) 279-2673.'^M^J,
           'and Jerry Shifrin, ECFB, 703-442-8695.'^M^J);
   if paramcount < 3 then
      usage;

   debug := false;
   if paramcount > 3 then begin
      if paramstr(4) <> 'debug' then
         usage
      else
         debug := true;
   end;

   cur_conf := '';
   line := '';
   origin_system := '';
   postall := false;
   packet_type := rsns_packet;

   system_dir := paramstr(2);
   load_setup_files;

   config_name := paramstr(1);
   load_config_file;

   packet_file := paramstr(3);
   line := packet_file;
   assignText(infd,packet_file);
   {$i-} reset(infd); {$i+}
   if ioresult <> 0 then
      error('Can''t open packet file');

   setTextBuf(infd,inbuffer);

   tposted := 0;
   texcluded := 0;

end;


(* ========================================================= *)

procedure exclude_check(what: string80);
   {turn off echo flag if message contains an exclude keystring}
var
   i: integer;
begin
   if not echo then
      exit;

   stoupper(what);
   for i := 1 to exclcount do
      if pos(exclude[i],what) > 0 then
      begin
         reason := 'Excluded';
         echo := false;
         if debug then
            writeln('*Exclude string found: ', exclude[i]);
      end;
end;


(* --------------------------------------------------------- *)
procedure rename_check(var who: string25);
   {perform rename function on a user name}
var
   i: integer;
begin
   if not echo then
      exit;

   for i := 1 to rencount do
      if renfrom[i] = who then
      begin
         who := rento[i];
         if debug then
            writeln(renfrom[i], ' renamed to ', rento[i]);
         exit;
      end;
end;


(* --------------------------------------------------------- *)
procedure format_header;
begin
   fillchar(header,sizeof(header),0);
   header.statusCode := ' ';
   header.readTime := '     ';
   header.hasReplys := ' ';
   header.status := live_msg;
   header.echoFlag := 'E';   {allow re-echo!}
   ftos(0,header.number);
   ftos(0,header.referTo);
   ftos(0,header.readDate);
   fill_chars(header.date,date,8);
   fill_chars(header.time,time,5);
   fill_chars(header.whoTo,whoTo,25);
   fill_chars(header.whoFrom,whoFrom,25);
   fill_chars(header.subject,subject,25);
end;


(* --------------------------------------------------------- *)
procedure save_message;
begin
   if not echo then
   begin
      inc(excluded);
      writeln(reason,':','':11-length(reason),
              ljust(whoto,  19),' ',
              ljust(whofrom,19),' ',
              subject);
      exit;
   end;
   inc(linecnt);
   repeat
      dec(linecnt);
      remove_trailing(lines[linecnt]);
   until (length(lines[linecnt]) > 0) or (linecnt <= 1);

   inc(posted);
   writeln('Post: ',lastmsg:5,' ',
           ljust(whoto,  19),' ',
           ljust(whofrom,19),' ',
           date,' ',
           subject);

   write_message;
end;


(* --------------------------------------------------------- *)
procedure decode_header_pcb;
   {parse PCBoard 12.1 and 14.0 headers}
begin

   (***
Date: 06-30-88 (17:37)       Invest Number: 332 (Echo)
  To: KEN PFEIFFER
From: JIM LEE                         Read: YES
City: AUSTIN,TX                    Last On: 09-12-87
Subj: MARKET PREDICTIONS
   ****)

   exclude_check(line);
   date := copy(line,7,8);
   time := copy(line,17,5);
   echo := (pos('(Echo)',line) > 0) or postall;
   if not echo then
      reason := 'Not Echo';
   getline;

   exclude_check(line);
   whoto := copy(line,7,25);
   remove_trailing(whoto);
   rename_check(whoto);
   getline;

   exclude_check(line);
   whofrom := copy(line,7,25);
   remove_trailing(whofrom);
   rename_check(whofrom);
   getline;

   if copy(line,1,5) = 'City:' then
      getline;

   exclude_check(line);
   subject := copy(line,7,25);
   remove_trailing(subject);
   getline;
end;


(* --------------------------------------------------------- *)
procedure convert_date;
   {convert from "Jan 27, 1989" to "01-27-89"}
var
   i: integer;

begin
   for i:= 1 to 12 do
      if copy(odate,1,3) = tmonths[i] then
         begin
            date := nmonths[i] + '-' + copy(odate,5,2) + '-' +
                      copy(odate,11,2);
            exit;
         end;
   end;

(* --------------------------------------------------------- *)
procedure decode_header_genie;
   {parse GEnie headers}
begin

   writeln(line);
   (***
Sub: Welcome to the Forth Interest Group
2 new messages.
 ************
 ------------
Category 1,  Topic 1
Message 43        Fri Jan 27, 1989
D.HARRIS4                    at 21:49 CST
   ***)

   gotone := TRUE;
   whoto := 'ALL';
   echo := true;
   odate := copy(line,23,12);
   convert_date;
   getline;

   exclude_check(line);
   whofrom := copy(line,1,25);
   remove_trailing(whofrom);
   stoupper(whofrom);
   rename_check(whofrom);
   time := copy(line,33,5);
   getline;


end;

(* --------------------------------------------------------- *)
procedure process_body;
begin
   linecnt := 0;
   getline;

   while (line[1] <> #255) and (line[1] <> ^Z) and (linecnt < maxlines) do
   begin

      if packet_type = rsns_packet then
      begin

         {check for more type prompts}
         if (copy(line,1,9) = '(H)elp, M') or      {more prompt, pcb14}
            (copy(line,1,8) = 'More (Y)') or       {more prompt, pcb12}
            (copy(line,6,9) = '[Y],N,NS?') then    {more prompt, rbbs16}
         begin
            repeat
               getline;
               remove_trailing(line);
            until length(line) > 0;
         end;

         {check for end-of-message - quite a bit of guesswork is going on here}
         if (copy(line,1,6) = 'Date: ') or         {start next message, pcb}
            (copy(line,1,5) = 'Msg #') or          {start next message, rbbs}
            (copy(line,6,11)= '[Y],N,NS,RE') or    {end message, rbbs}
            (copy(line,1,8) = '(H)elp, ') or       {no more messages, pcb14}
            (copy(line,1,7) = 'Read: (') then      {no more messages, pcb12}
         begin
            exit;
         end;
      end;


      {add a line of text to the message}
      inc(linecnt);
      lines[linecnt] := line;
      exclude_check(line);
      getline;
   end;
end;


(* --------------------------------------------------------- *)
procedure process_body_genie;
var
   p: integer;
   split: boolean;

begin
   linecnt := 0;
   split := false;
   getline;

   while (line[1] <> ^Z) and (linecnt < maxlines) do
   begin

      {check for end-of-message - quite a bit of guesswork is going on here}
      if (copy(line,1,14)= ' ------------') or   {end message text}
         (copy(line,1,12)= '-----------') or   {end message text}
         (copy(line,1,9)= 'Category ') or   {end message text}
         (copy(line,1,14)= ' ************') then {end message text}
      begin
         exit;
      end;


      exclude_check(line);

      {add a line of text to the message}
      {split line in the middle if it is too long - this might become
       a full word-wrap in a later version}

      if length(line) > 80 then
         split := true;

      if split and (length(line) > 40) then
      begin
         p := 41;
         while (p > 1) and (line[p] <> ' ') do
            dec(p);

         {chop the line if there are no spaces}
         if p < 71-length(line) then
            p := length(line) div 2;

         inc(linecnt);
         lines[linecnt] := copy(line,1,p);
         delete(line,1,p);
      end;

      inc(linecnt);
      lines[linecnt] := line;

      getline;
   end;
   if linecnt > maxlines then
      begin
         writeln('maxlines exceeded: ',linecnt);
      end;
end;



(* ========================================================= *
 *
 *    Top level parser - process each type of ARCM header
 *
 * ========================================================= *)

(* --------------------------------------------------------- *)
procedure porigin;
begin
   origin_system := copy(line,12,60);
   writeln('; ',line);
   getline;
end;


(* --------------------------------------------------------- *)
procedure pjoin_pcb;
begin
   deselect_conference;

   remove_leading(line);
   line := line + ' ';
   cur_conf := copy(line,1,pos(' ',line)-1);

   select_conference;
   getline;
end;

procedure parea;
begin
   line := copy(line,15,8);
   pjoin_pcb;
end;

procedure pabandon;
begin
   deselect_conference;
   cur_conf := 'Main';
   select_conference;
   getline;
end;


(* --------------------------------------------------------- *)
procedure pmessage_pcb;
begin
   if length(cur_conf) = 0 then
      error('PCB No conference selected');

   decode_header_pcb;
   format_header;
   process_body;
   save_message;
end;


(* --------------------------------------------------------- *)
procedure pjoin_genie;
begin
   line := copy(line,11,3);   {Category nnn}
   pjoin_pcb;
end;

procedure psubject_genie;
begin
   writeln(line);
   exclude_check(line);
   subject := copy(line,6,25);   {Sub: xxx}
   stoupper(subject);
   remove_trailing(subject);
   getline;
end;

procedure pmessage_genie;
begin
   if length(cur_conf) = 0 then
      error('GEnie No conference selected');

   decode_header_genie;
   format_header;
   process_body_genie;
   save_message;
end;


(* --------------------------------------------------------- *)
procedure peof;
begin
   deselect_conference;
   close(infd);
   writeln(^M^J'End of packet.');
   writeln('Total: ',tposted,' messages posted (',texcluded,' excluded)');
   halt(0);
end;


(* --------------------------------------------------------- *)
begin
   initialize;
   getline;

   while true do
   begin
      while copy(line,1,1) = #255 do
      begin
         delete(line,1,1);
         if line[1] = '*' then
            packet_type := arcm_packet;
      end;

      remove_trailing(line);

{writeln('[',line,']');}

{parse ARCM packets}
      if copy(line,1,10) = '** System:' then
         porigin
      else

      if copy(line,1,13) = '** Mail Area:' then
         parea
      else

{parse pcb 12 and pcb 14 messages}
      if pos('Conference Joined',line) > 0 then
         pjoin_pcb
      else

      if pos('Conference Abandon',line) > 0 then
         pabandon
      else

      if copy(line,1,5) = 'Date:' then
         pmessage_pcb
      else

{parse GEnie messages}
      if copy(line,1,10) = 'Category  ' then
         pjoin_genie
      else

      if (copy(line,1,5) = 'Sub: ') then
         psubject_genie
      else

      if (copy(line,1,8) = 'Message ') then
         pmessage_genie
      else

(*      if (copy(line,1,18) = 'Enter #, <Command>') and
           (gotone = true)  then
         peof
      else
*)
      if copy(line,1,21) = '** Messages Captured:' then
         peof
      else

      if line[1] = ^Z then
         if packet_type = arcm_packet then
            error('Unexpected EOF reading packet file')
         else
            peof
      else

      if length(line) = 0 then
         getline
      else

      begin
         writeln('; ',copy(line,1,75));
         getline;
      end;
   end;


end.

