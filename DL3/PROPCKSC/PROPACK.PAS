
(*
 * ProPack - Quickly Pack a PCBoard message base file
 *
 * Samuel H. Smith, 21-May-88 (rev. 01-05-89)
 *
 * Copyright 1988 Samuel H. Smith; All rights reserved.
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Phoenix, Az
 *         (602) 279-2673
 *
 *)

{$I PRODEF.INC}
{$M 10000,0,0}  {stack, minheap, maxheap}


uses ErrTrap,Dos,MdosIO,BufIO,DosMem,CRC32;

const
   bug = false;
   crcfilever = -2;        {.crc file format version number}

   version:    string[20] = '3.0 of 03-15-91';
   pcbver:     string[5] = '14.x';

   maxinbuf    = 160;      {input buffer records}
   maxoutbuf   = 320;      {output buffer records}

   maxtxtblock = 160;      {message text buffer records}
   blksiz      = 128;
   maxlines    = 255;      {maximum number of text lines}
   maxmsgs     = 15000;    {maximum number of active messages}


{$i \tinc\anystring.inc}
{$i \tinc\atoi.inc}        {ascii to integer conversion}
{$i \tinc\stof.dcl}
{$i \tinc\stof.inc}        {basic single to pascal float conversions}
{$i \tinc\keypress.inc}    {keypressed and readkey}
{$i \tinc\gettime.inc}     {lget_ms and others}


(* layout of the message control file records for PCBoard *)

type

   message_rec = record
      case integer of

      {file header record}
         0: (himsg:    single;      {highest message on file}
             lowmsg:   single;      {low msg number in message base}
             msgcnt:   single;      {number of active messages}
             callers:  single;      {number of callers on system}
             lockflag: char6;       {LOCKED if file being updated}
             fill1:    array[1..105] of char);
                                    {reserved for future use}
      {message header record}
         1: (StatusCode:  char;     {protect, unprotect flag '*' or blank}
             Number:      single;   {message number}
             ReferTo:     single;   {reference message number}
             blocks:      byte;     {number of blksiz byte text blocks}
             Date:        char8;    {mm-dd-yy}
             Time:        char5;    {hh:mm}
             WhoTo:       char25;
             ReadDate:    single;   {yymmdd numeric date of reply message}
             ReadTime:    char5;    {hh:mm of reply}
             HasReplys:   char;     {'R' is ALL message has replys}
             WhoFrom:     char25;
             Subject:     char25;
             Password:    char12;   {blank=none}
             status:      char;     {dead_msg(226) or live_msg(225)}
             echoflag:    char;     {'E' if msg to be echoed}
             filler:      char6);   {reserved}

      {message text record}
         2: (body:      array[1..blksiz] of char);
                                    {body of the message, space fill}
   end;


const
   dead_msg    = #226;           {message status codes}
   live_msg    = #225;
   endline     = #227;           {end of line character in message files}
   

type
   ixarray  = array[1..maxmsgs+10] of single;   {index for each message}
   crcarray = array[1..maxmsgs+10] of longint;  {crc of each message}
   
const
   maxactive:  word     = 0;     {maximum number of messages to keep}
   active:     word     = 0;     {active messages}
   killed:     word     = 0;     {messages killed}
   skipped:    word     = 0;     {messages skipped}
   dups:       word     = 0;     {duplicate messages}
   oldref:     word     = 0;     {obsolete refer#'s cleared}
   received:   word     = 0;     {received+private messages skipped}
   unrecvd:    word     = 0;     {unreceived+private messages kept}
   saved:      word     = 0;     {messages saved}

   firstmsg:   longint  = 0;     {first message number to keep}
   basemsg:    longint  = 0;     {base message number}
   lastmsg:    longint  = 0;     {highest message number}
   curnum:     longint  = 0;     {current message number}

   ixfd:       dos_handle = 0;   {index file handle}
   ixsize:     longint  = 0;     {index file size in bytes}
   ixcnt:      word     = 0;     {index entries allocated}
   ixbuf:      ^ixarray = nil;   {pointer to index file buffer}
   lastix:     word     = 0;     {highest index entry used}
   
   basecrc:    longint  = 0;     {base message number in crc table}
   lastcrc:    word     = 0;     {highest crc table entry}
   msgcrc:     ^crcarray = nil;  {pointer to message crc buffer}
   
   killdups:   boolean  = false; {kill duplicate messages?}
   killrecvd:  boolean  = false; {kill RECEIVED+PRIVATE messages?}
   keepunrecvd:boolean  = false; {keep UnRECEIVED+PRIVATE messages?}
   listdups:   boolean  = false; {list duplicates as they are deleted}
   sethimsg:   boolean  = false; {reset 'high message number'}
   cleantags:  boolean  = false; {cleanup message taglines?}
   novia:      boolean  = false; {remove Via and tearlines}
   maxtags:    integer  = 9;     {maximum number of taglines}
   nocrctags:  boolean  = false; {exclude taglines in crc calculation}
   relay2:     boolean  = false; {keep 2 line Relay: taglines}
   noibm:      boolean  = false; {remove IBM and high ascii codes}
   listmsgs:   boolean  = false; {list full message texts}
   killbak:    boolean  = false; {kill .bak file}
   saveold:    boolean  = false; {save old messages}

   firstdate:  char6    = '000000';  {yymmdd oldest message date to keep}

var
   infd:       buffered_file;    {input file handle}
   outfd:      buffered_file;    {output file handle}
   msgfile:    dos_filename;     {original message base filename}
   newfile:    dos_filename;     {new message base filename}
   bakfile:    dos_filename;     {backup filename}
   ndxfile:    dos_filename;     {index filename}
   crcfile:    dos_filename;     {crc filename}

   mheader:    message_rec;      {message base header record}

   header:     message_rec;      {current message header}
   txtblocks:  integer;          {text blocks in current message}

   block:      array[1..maxtxtblock]
               of message_rec;   {current text blocks}

   raw:        array[1..maxtxtblock*blksiz]
               of char           {raw form of text blocks}
               absolute block;

   maxpos:     integer;          {end of data in raw/block}

   lines:      array[1..maxlines+10]
               of string80;      {line form of text blocks}

   linecnt:    integer;
   vialine:    integer;
   tearline:   integer;
   tagline:    integer;

   con:        text;

   savefd:     text;

   cmdline:    string[128];      {command line options used}

   t_start:    longint;


procedure pause;
var
   stop:    integer;
   togo:    integer;
   ptogo:   integer;

begin
   write(con,^M^J'Press ENTER (3 minute delay): ');
   stop := get_mins+3;
   togo := 0;
   repeat
      ptogo := togo;
      togo := (stop-get_mins);
      if ptogo <> togo then
         write(^G^G^G);
   until (keypressed) or (togo <= 0);

   if keypressed then
      readln;
end;

procedure echo_message(what: string);
begin
   writeln;
   write(what);   write(con,^M,what);
   writeln;
end;

procedure stop_run(why: string);
begin
   echo_message('** ProPack Aborted.  Reason: '+why);
   pause;
   halt(1);
end;


(* --------------------------------------------------------- *)
(*                 command line handlers                     *)
(* --------------------------------------------------------- *)


procedure usage(why: string80);
   {display program usage instructions}
var
   i: integer;

begin
{$i-}
   writeln(con,^M^J'ProPack:  High Performance Conference Maintenance Utility.');
   writeln(con,'Copyright 1988-1991 Samuel H. Smith; All rights reserved.'^M^J);

   writeln(con,'Version ',version,' for PCBoard ',pcbver,' file formats.');
   writeln(con,'Supported by The Tool Shop BBS (818) 891-6780.'^M^J);

   writeln(con,'This is NOT public domain software.  If you like and use ProPack, I request');
   writeln(con,'you register the program after a reasonable trial period (about 30-45 days).'^G^M^J);

   echo_message('Error: '+why+'!');

   writeln(con,^M^J'Command line used: '^G^G);
   write(con,'   PROPACK ');
   for i := 1 to paramcount do
      write(con,paramstr(i),' ');

   writeln(con);
   pause;

   writeln(con,^M^J'Usage:  ProPack MAILFILE MAXMSGS [options]'^M^J);
   writeln(con,'   MAILFILE  Mail file d:\path\name to be packed');
   writeln(con,'   MAXMSGS   Maximum number of messages to keep, 0=no limit');
   writeln(con,'   /D        Kill identical duplicate messages');
   writeln(con,'   /E        Exclude taglines when checking for duplicates');
   writeln(con,'   /H        Reset "high message number" to last message number');
   writeln(con,'   /I        Remove IBM and "high ascii" codes');
   writeln(con,'   /K        Delete .BAK file after successful pack');
   writeln(con,'   /L        List duplicate message numbers as they are killed');
   writeln(con,'   /Nxxx     Kill messages over xxx days old');
   writeln(con,'   /R        Purge RECEIVED+PRIVATE messages');
   writeln(con,'   /Sfile    Save purged messages in text file');
   writeln(con,'   /T        Remove extra network tag-lines');
   writeln(con,'   /U        Always keep UN-RECEIVED+PRIVATE messages');
   writeln(con,'   /V        Remove reader via-lines');
   writeln(con,'   /W        Keep second line PCRelay: tagline');
   writeln(con,'   /X        List text of new messages with TEAR/VIA/TAG markers');

   pause;

   writeln(con,^M^J'Examples: ProPack d:\pcb\main\msgs 1000');
   writeln(con,^M^J'          ProPack c:\pcb\tools\tools 500 /d /l');
   writeln(con,^M^J'          ProPack c:\pcb\sysops\sysops 13000 /RDLT /N90');
   writeln(con,^M^J'          ProPack c:\pcb\music\music 100 eltkn90');
   writeln(con,^M^J'          ProPack c:\pcb\tools\tools 100 eltkn90 /sOLDTOOLS.TXT'^M^J);
{$i+}
   stop_run(why);
end;


(* --------------------------------------------------------- *)
procedure itoa2(i: integer; var sp);
var
   s: array[1..2] of char absolute sp;
begin
   s[1] := chr( (i div 10) + ord('0'));
   s[2] := chr( (i mod 10) + ord('0'));
end;


(* --------------------------------------------------------- *)
procedure determine_first_date(days: integer);
   (* determine first_date as n days before today *)
var
   year:    word;
   month:   word;
   day:     word;
   dow:     word;

const
   monthdays:  array[1..12] of integer =
      (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

begin
   { get today's date from DOS }
   GetDate(year,month,day,dow);
   year := year - 1900;

   { backup N days }
   while (days > 0) do
   begin
      dec(days);

      if (day > 1) then
         dec(day)
      else

      if (month > 1) then
      begin
         dec(month);
         day := monthdays[month];
      end
      else

      begin
         dec(year);
         month := 12;
         day := monthdays[month];
      end;
   end;

   { format the date for comparison }
   itoa2(year,firstdate[1]);
   itoa2(month,firstdate[3]);
   itoa2(day,firstdate[5]);

   writeln('Skipping all messages before ',month,'-',day,'-',year);
end;


(* --------------------------------------------------------- *)
procedure decode_params;
var
   i:    integer;
   par:  string[128];

begin
   writeln;

   t_start := lget_ms;
   assign(con,'con');
   rewrite(con);

   if paramcount < 2 then
      usage('Missing command line parameters');

   msgfile := paramstr(1);
   newfile := msgfile + '.NEW';
   bakfile := msgfile + '.BAK';
   ndxfile := msgfile + '.NDX';
   crcfile := msgfile + '.CRC';

   par := paramstr(2);
   for i := 1 to length(par) do
      if (par[i] < '0') or (par[i] > '9') then
         usage('Invalid digit in "MAXMSGS" parameter ('+par+')');

   maxactive := atow(paramstr(2));

   par := '';
   for i := 3 to paramcount do
      par := par + paramstr(i);

   fillchar(cmdline,sizeof(cmdline),0);
   cmdline := par;

   i := 1;
   while i <= length(par) do
   begin

      case upcase(par[i]) of
         '/':  ;

         'D':  killdups := true;

         'E':  begin
                  killdups := true;
                  nocrctags := true;
               end;

         'H':  sethimsg := true;

         'I':  noibm := true;

         'K':  killbak := true;

         'L':  listdups := true;

         'N':  determine_first_date(atoi(copy(par,i+1,5)));

         'R':  killrecvd := true;

         'S':  begin
                  saveold := true;
                  par := copy(par,i+1,255);
                  if par = '' then
                     par := 'SAVE.OUT';
                  i := length(par);

                  assign(savefd,par);
                  {$i-} append(savefd); {$i+}
                  if ioresult <> 0 then
                  begin
                     {$i-} rewrite(savefd); {$i+}
                     if ioresult <> 0 then
                        usage('Cannot open save file: '+par);
                  end;
               end;

         'T':  begin
                  cleantags := true;
                  maxtags := 1;
               end;

         'U':  keepunrecvd := true;

         'V':  begin
                  cleantags := true;
                  novia := true;
               end;

         'W':  relay2 := true;

         'X':  listmsgs := true;

         '0'..'9':
               ;
      else
         usage('Unknown option: '+par);

      end;

      inc(i);
   end;

(******
if bug then
writeln('killdups=',killdups,
        ' nocrctags=',nocrctags,
        ' sethimsg=',sethimsg,
        ' listdups=',listdups,
        ' killrecvd=',killrecvd,
        ' cleantags=',cleantags,
        ' maxtags=',maxtags,
        ' novia=',novia,
        ' relay2=',relay2,
        ' firstdate=',firstdate);
******)

end;


(* --------------------------------------------------------- *)
procedure rename_files;
var
   fd: file;
begin
   assign(fd,msgfile);
   {$i-} rename(fd,bakfile); {$i+}
   if ioresult <> 0 then
   begin
{$i-}
      writeln(con,'Error: Could not rename old msgbase to .BAK!');
      writeln(con,'Make sure that no other programs are accessing ',msgfile);
      writeln(con,'Your message file is unchanged.');
{$i+}
      dos_unlink(newfile);    {release aborted scratch file}
      stop_run('Could not rename '+msgfile+' to '+bakfile);
   end;
      
   assign(fd,newfile);
   {$i-} rename(fd,msgfile); {$i+}
   if ioresult <> 0 then
   begin
{$i-}
      writeln(con,'Error: Could not rename new msgbase!');
      writeln(con,'Your message has been renamed to ',bakfile);
{$i+}
      dos_unlink(newfile);    {release aborted scratch file}
      stop_run('Could not rename '+newfile+' to '+msgfile);
   end;

   if killbak then
      dos_unlink(bakfile);
end;


procedure iocheck;
   {check for write failure}
begin
   if berr then
   begin
{$i-}
      writeln(con,'Write failure!  You are probably out of disk space.');
      writeln(con,'Your message file is unchanged.');
{$i+}
      bclose(outfd);
      dos_unlink(newfile);    {release aborted scratch file}
      stop_run('Write failure - disk full or bad sector');
   end;
end;


(* --------------------------------------------------------- *)
(*             message tagline processing                    *)
(* --------------------------------------------------------- *)

procedure delete_trailing_spaces(var line: string);
begin
   while (length(line) > 0) and (line[length(line)] = ' ') do
      dec(line[0]);
end;

procedure delete_line(n: integer);
var
   i: integer;
begin
   if n > linecnt then
      exit;
   for i := n to linecnt-1 do
      lines[i] := lines[i+1];
   dec(linecnt);
end;

procedure insert_line(n: integer);
var
   i: integer;
begin
   if linecnt >= maxlines then
      exit;
   for i := linecnt downto n do
      lines[i+1] := lines[i];
   lines[n] := '';
   inc(linecnt);
end;


const
   c:       char = '?';
   tline:   string80 = '';
   rawp:    integer = 0;
procedure get_text;
   {convert PCBoard's block format text into normal text lines}
var
   n:       integer;

begin
   {convert them into lines of text}
   fillchar(lines,sizeof(lines),0);
   linecnt := 0;
   tline := '';
   maxpos := txtblocks*blksiz;

   rawp := 1;
   while rawp <= maxpos do
   begin

      {grab next char from buffer}
      c := raw[rawp];
      inc(rawp);

(*************
      while (rawp < maxpos) and (c <> ^J) and (c <> endline) do
      begin
         if length(tline) < 80 then
            inc(tline[0]);
         tline[length(tline)] := c;

         {grab next char from buffer}
         c := raw[rawp];
         inc(rawp);
      end;
***********)

Inline(
  $8B/$0E/>maxpos/       {        mov cx,[>maxpos]        ;cx=maxpos}
  $8B/$36/>rawp/         {        mov si,[>rawp]          ;si=rawp}
  $29/$F1/               {        sub cx,si               ;special case- last byte of buffer}
  $7E/$2F/               {        jle exit}
  $30/$E4/               {        xor ah,ah}
  $A0/>tline/            {        mov al,[>tline]         ;di=length(tline)}
  $89/$C7/               {        mov di,ax}
  $A0/>c/                {        mov al,[>c]             ;al=c}
                         {top:}
  $3C/<$0a/              {        cmp al,<$0a             ;end on ^M}
  $74/$15/               {        jz break}
  $3C/<$e3/              {        cmp al,<$e3             ;end on endline}
  $74/$11/               {        jz break}
  $83/$FF/$50/           {        cmp di,80               ;line full?}
  $7D/$01/               {        jge linefull}
  $47/                   {        inc di                  }
                         {linefull:}
  $88/$85/>tline/        {        mov [di+>tline],al      ;line := line + c}
  $8A/$84/>raw-1/        {        mov al,[si+>raw-1]      ;c := raw[rawp++]}
  $46/                   {        inc si}
  $E2/$E7/               {        loop top                ;continue until end of buffer}
                         {                                ;or ^M/endline is seen}
                         {break:}
  $A2/>c/                {        mov [>c],al}
  $89/$F8/               {        mov ax,di}
  $A2/>tline/            {        mov [>tline],al}
  $89/$36/>rawp);        {        mov [>rawp],si}
                         {exit:}


      {end of line seen - store the line}
      case c of
         endline, ^J:
            begin
               if linecnt >= maxlines then
               begin
                  write('      '^M^J'    Message # ',curnum,' has more than ',maxlines,' lines!  Truncated. ');
                  lines[maxlines] := '<<MESSAGE TOO LONG -- SOME LINES WERE DELETED>>';
                  exit;
               end;

               delete_trailing_spaces(tline);
               inc(linecnt);
               lines[linecnt] := tline;
               tline := '';
            end;

         ^M:   ;

         else
            begin
               {append the byte to the buffer (this hack goes faster than +c) }
               if length(tline) < 80 then
                  inc(tline[0]);
               tline[length(tline)] := c;
            end;
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure put_msgtext(s: string80);
begin
   if maxpos+length(s) > sizeof(raw) then
      exit;
   move(s[1], raw[maxpos+1], length(s));
   inc(maxpos,length(s));
end;

procedure put_text;
   {convert the text into PCBoard's block format and write it to the file}
var
   i:         integer;
begin
   {convert the lines into a block of bytes}
   maxpos := 0;
   for i := 1 to linecnt do
   begin
      put_msgtext(lines[i]);
      put_msgtext(endline);
   end;

   while (maxpos and 127) <> 0 do
      put_msgtext(' ');

   txtblocks := maxpos div blksiz;
   header.blocks := txtblocks+1;
end;


(* ---------------------------------------------------------- *)
procedure check_tagline(i: integer;
                        var is_tearline: boolean;
                        var is_vialine:  boolean;
                        var is_tagline:  boolean);
begin
   is_tagline := false;
   is_tearline := false;
   is_vialine := false;

(****
   if lines[i] = '' then
      is_tearline := true
   else
****)

   {most all readers}
   if (lines[i][1] = '-') and (copy(lines[i],1,3) = '---') then
      is_tearline := true
   else

   {pc relay}
   if (lines[i][8] = ':') and (copy(lines[i],1,8) = 'PCRelay:') then
      is_tagline := true
   else

   {new netmail}
   if (lines[i][4] = '/') and (copy(lines[i],1,8) = 'NET/Mail') then
      is_tagline := true
   else

   {old netmail}
   if (lines[i][4] = '') and (copy(lines[i],1,8) = 'NETMail') then
      is_tagline := true
   else

   {hypermail}
   if (lines[i][1] = '*') and (copy(lines[i],1,4) = '*** ') then
      is_tagline := true
   else

   {qnet 1.1?}
   if (lines[i][1] = '*') and (lines[i][2] = ' ') then
      is_tagline := true
   else

   {new qnet}
   if (lines[i][1] = 'þ') and (lines[i][2] = ' ') then
      is_tagline := true
   else

   if lines[i][1] = ' ' then
   begin
      case lines[i][2] of
      '*':
         begin                      {qnet/qmail/prodoor}
            if lines[i-1] = '---' then
               is_vialine := true
            else
               is_tagline := true;
            {tagline := i;}
         end;

      '-':                          {relaymail/pcbrelay}
         if lines[i][3] = '>' then
         begin
            if copy(lines[i],1,9) = ' -> Relay' then
               is_vialine := true
            else
               is_tagline := true;
         end;

      '.','þ':                      {ez-reader}
         if lines[i][5] = 'Z' then
           is_vialine := true;
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure analyze_taglines;
var
   i:             integer;
   tear,via,tag:  boolean;

begin

(***
   if lines[1] = 'CMI HyperMail -->' then
      delete_line(1);
***)

   {locate all taglines and vialines}
   vialine := 0;
   tagline := 0;
   tearline := 0;

   for i := 1 to linecnt do
   begin
      check_tagline(i,tear,via,tag);
      if tear and (tearline = 0) then tearline := i;
      if via  and (vialine = 0)  then vialine := i;
      if tag  and (tagline = 0)  then tagline := i;
   end;

   {tearline is always line before vialine}
   if (vialine > 0) and (tearline > 0) then
      tearline := vialine-1;

   {locate the tearline, if present}
   if tearline = 0 then
   begin
      i := linecnt;

      while (i > 0) and (tearline = 0) do
      begin
         check_tagline(i,tear,via,tag);
         if tear then
            tearline := i
         else
         if not (via or tag) then
            tearline := i+1
         else
            dec(i);
      end;
   end;

   {ignore taglines that come before the tearline}
   if tagline < tearline then
      tagline := 0;
end;


(* ---------------------------------------------------------- *)
procedure clean_taglines;
var
   i:          integer;

begin

   {remove vialines if needed}
   if vialine > 0 then
   begin
      if novia then
      begin
         delete_line(vialine);
         dec(tagline);

         if (lines[vialine-1] = '---') or (lines[vialine-1] = '') then
         begin
            delete_line(vialine-1);
            dec(tagline);
         end;

         vialine := 0;
      end
      else

      {remove blank line between vialine and first tagline}
      if tagline > vialine then
         tagline := vialine+1;

     {ignore taglines that come before the tearline}
     if tagline < tearline then
        tagline := 0;
   end;


   if tagline > 0 then
   begin

(*******
if bug then begin
writeln;
write('final tagline=',tagline);
end;
*********)

      {remove blank lines between taglines}
      i := tagline;
      while i <= linecnt do
      begin
         if lines[i] = '' then
            delete_line(i)
         else
            inc(i);
      end;

      {remove all but N taglines if needed}
      i := tagline+maxtags;

(******
if i > 100 then
begin
   writeln('curnum=',curnum,' i=',i,' linecnt=',linecnt,' tagline=',tagline,' maxtags=',maxtags);
end;
writeln('i=',i,' tag=',tagline,' lines[i-1]=',lines[i-1]);
*****)

      if relay2 and (copy(lines[i-1],1,8) = 'PCRelay:') then
         inc(i);

      while i <= linecnt do
         delete_line(i);

      {make sure there is 1 blank line before the tagline}
      if (vialine = 0) and (maxtags > 0) and (lines[tagline-1] <> '') then
         insert_line(tagline);
   end;

(***
   if lines[1] = 'CMI HyperMail -->' then
      delete_line(1);
***)

(*********)
if bug then begin
writeln;
write('==================================');
end;
(**********)

end;


(* --------------------------------------------------------- *)
(*             message content listing                       *)
(* --------------------------------------------------------- *)

procedure format_listing;
var
   i: integer;
begin
   if linecnt = 0 then exit;

   writeln('_________________________________________________________');
   writeln;
   writeln('Date: ',header.date,' (',header.time,')     Number: ',curnum,
           '   CRC: ',itoh(crc_out shr 16),itoh(crc_out and $FFFF));
   writeln('To:   ',header.whoto);
   writeln('From: ',header.whofrom);
   writeln('Subj: ',header.subject);
   writeln;

   for i := 1 to linecnt do
   begin
      if i = tearline then write('>Tear| ');
      if i = vialine  then write('>Via | ');
      if i = tagline  then write('>Tag | ');
      if (i <> tearline) and (i <> vialine) and (i <> tagline) then
         write('     | ');
      writeln(lines[i]);
   end;

   if (tearline = linecnt+1) then
      writeln('>Tear');
end;


procedure capture_message;
var
   i:    integer;
   par:  string;
begin
   inc(saved);
   get_text;

   writeln(savefd);

   write(savefd,'Date: ',header.date,' (',header.time,')');
   write(savefd,'    Number: ',curnum);
   writeln(savefd);

   write(savefd,'To:   ',header.whoto);
   writeln(savefd);

   write(savefd,'From: ',header.whofrom);
   writeln(savefd);

   writeln(savefd,'Subj: ',header.subject);
   writeln(savefd);

   for i := 1 to linecnt do
      writeln(savefd,lines[i]);
end;


(* --------------------------------------------------------- *)
(*             header record handlers                        *)
(* --------------------------------------------------------- *)

procedure load_header;
begin
   bread(infd,mheader);

   mheader.lockflag := '      ';
   bwrite(outfd,mheader);

   basemsg := stol(mheader.lowmsg);
   lastmsg := stol(mheader.himsg);
end;


(* --------------------------------------------------------- *)
procedure update_header;
   {update the message-base header record to reflect the correct number
    of active messages on file}
begin
   ltos(active,mheader.msgcnt);
   ltos(basemsg,mheader.lowmsg);

   if sethimsg then
      ltos(lastmsg,mheader.himsg);

   bseek(outfd,0);
   bwrite(outfd,mheader);
   bclose(outfd);
end;


(* --------------------------------------------------------- *)
(*             index file handlers                           *)
(* --------------------------------------------------------- *)

procedure load_index;
var
   n:       word;
   zero:    single;
   msgs:    word;
      
begin
   ixfd := dos_open(ndxfile,open_update);
   if ixfd = dos_error then
      usage('Can''t open index file: '+ndxfile);

   dos_lseek(ixfd,0,seek_end);
   ixsize := dos_tell;
   if ixsize = 0 then
      stop_run('Invalid index file '+ndxfile+' - use PCBPACK to rebuild');

   if ixsize > (word(maxmsgs) * word(sizeof(single))) then
   begin
{$i-}
      writeln(con,'Your index is too large for ProPack to handle!');
      writeln(con,'Use PCBSETUP to reduce the number of index blocks to 14 or less.');
      writeln(con,'Then run PCBPACK to build the new, smaller index.');
{$i+}
      stop_run('Index too large - decrease index blocks');
   end;

   dos_getmem(ixbuf,ixsize);
   ixcnt := ixsize div sizeof(single);


   {scan original index to fine starting message number to keep}
   dos_lseek(ixfd,0,seek_start);
   n := dos_read(ixfd,ixbuf^,ixsize);

   msgs := 0;
   n := ixcnt;
   while (n > 0) and (firstmsg = 0) do
   begin
      if stol(ixbuf^[n]) >= 1 then
      begin
         inc(msgs);
         if msgs = maxactive then          {calculate first msg num to keep}
            firstmsg := n + basemsg - 1;
      end;
      dec(n);
   end;
   {writeln('msgs=',msgs,' basemsg=',basemsg,' firstmsg=',firstmsg);}


   {clear all index entries}
   zeros(zero);
   for n := 1 to ixcnt do
      ixbuf^[n] := zero;
end;


(* --------------------------------------------------------- *)
procedure update_index;
begin
   dos_lseek(ixfd,0,seek_start);
   dos_write(ixfd,ixbuf^,ixsize);
   dos_close(ixfd);
end;


(* --------------------------------------------------------- *)
procedure store_index;
var
   ix:   integer;
begin
   if active = 1 then
   begin
      basemsg := curnum;
      lastix := 1;
   end;

   ix := curnum - basemsg + 1;
   if ix > lastix then
      lastix := ix;

   if lastix >= ixcnt then
   begin
      writeln('curnum=',curnum,' lastix=',lastix,' ixcnt=',ixcnt);
      stop_run('Index file overflow - increase index blocks');
   end;

   ltos(btell(outfd)+1,ixbuf^[ix]);
end;



(* --------------------------------------------------------- *)
(*                 CRC file handlers                         *)
(* --------------------------------------------------------- *)

procedure load_crc;
var
   crcfd:   dos_handle;
   n:       word;
   ver:     integer;
   cmd:     string[128];
   junk4:   longint;

begin
   dos_getmem(msgcrc,sizeof(crcarray));
   fillchar(msgcrc^,sizeof(crcarray),0);

   if not dos_exists(crcfile) then
      exit;

   crcfd := dos_open(crcfile,open_read);
   n := dos_read(crcfd,ver,sizeof(ver));
   if ver = crcfilever then
   begin
      n := dos_read(crcfd,cmd,sizeof(cmd));
      if cmd = cmdline then
      begin
         n := dos_read(crcfd,junk4,sizeof(junk4));
         n := dos_read(crcfd,junk4,sizeof(junk4));
         n := dos_read(crcfd,basecrc,sizeof(basecrc));
         n := dos_read(crcfd,lastcrc,sizeof(lastcrc));
         n := dos_read(crcfd,msgcrc^,lastcrc*sizeof(msgcrc^[1]));
      end;
   end;

   dos_close(crcfd);
end;


(* --------------------------------------------------------- *)
procedure save_crc;
var
   crcfd:   dos_handle;
   ver:     integer;
   junk4:   longint;

begin
   crcfd := dos_create(crcfile);
   if crcfd = dos_error then
      usage('Can''t create CRC file: '+crcfile);

   ver := crcfilever;
   dos_write(crcfd,ver,sizeof(ver));
   dos_write(crcfd,cmdline,sizeof(cmdline));

   junk4 := 0;
   dos_write(crcfd,junk4,sizeof(junk4));
   dos_write(crcfd,junk4,sizeof(junk4));

   dos_write(crcfd,basecrc,sizeof(basecrc));
   dos_write(crcfd,lastcrc,sizeof(lastcrc));
   dos_write(crcfd,msgcrc^,lastcrc*sizeof(msgcrc^[1]));

   dos_close(crcfd);
end;


(* --------------------------------------------------------- *)
procedure lookup_crc;
var
   ix:   integer;
begin
   if basecrc = 0 then
   begin
      basecrc := curnum;
      lastcrc := 1;
   end;

   ix := curnum - basecrc + 1;

(***
   writeln('lookup ',curnum,' ix=',ix,' crc=',msgcrc^[ix],' lastcrc=',lastcrc,' basecrc=',basecrc);
***)

   if (ix > lastcrc) or (ix < 1) then
      crc_out := 0
   else
      crc_out := msgcrc^[ix];
end;


(* --------------------------------------------------------- *)
function unique_crc: boolean;
var
   i:    integer;
   ix:   integer;

begin
   if basecrc = 0 then
   begin
      basecrc := curnum;
      lastcrc := 1;
   end;

   ix := curnum - basecrc + 1;

(***
writeln;
write('num: ',curnum:5,' crc=',crc_out:11,' ix=',ix:3);
***)

   for i := 1 to ix-1 do
      if (msgcrc^[i] = crc_out) then
      begin
         unique_crc := false;

         if listdups then
         begin
            writeln('      ');
            write('    Message # ',curnum,' deleted because it is the same as # ',i+basecrc-1,'  ');
(***
writeln;
writeln('**   crc=',crc_out,' ix=',ix);
***)
         end;
         exit;
      end;

   unique_crc := true;
end;


(* --------------------------------------------------------- *)
procedure store_crc;
   {enter into crc table}
var
   ix:   integer;
begin
   ix := curnum - basecrc + 1;
   if ix > lastcrc then
      lastcrc := ix;

   if (ix >= maxmsgs) or (ix < 1) then
   begin
      writeln('curnum=',curnum,' basecrc=',basecrc,' ix=',ix,' maxmsgs=',maxmsgs);
      stop_run('CRC table overflow - delete '+crcfile+' and rerun');
   end;

   msgcrc^[ix] := crc_out;
end;


(* --------------------------------------------------------- *)
(*             message date comparison                       *)
(* --------------------------------------------------------- *)


function message_outdated: boolean;
var
   match:   char6;
begin
   match[1] := header.date[7];  {yy}
   match[2] := header.date[8];
   match[3] := header.date[1];  {mm}
   match[4] := header.date[2];
   match[5] := header.date[4];  {dd}
   match[6] := header.date[5];

   message_outdated := match < firstdate;
end;


(* --------------------------------------------------------- *)
(*             the mainline code...pack messages             *)
(* --------------------------------------------------------- *)

procedure process_message;
var
   n:          integer;
   i:          integer;
   refnum:     longint;

begin
   {load the message}
   bread(infd,header);

   txtblocks := header.blocks-1;
   curnum := stol(header.number);

   if (curnum mod 10) = 0 then
      write(con,curnum:5,^H^H^H^H^H);


   {reject invalid looking messages}
   if (txtblocks < 1) or (txtblocks > maxtxtblock) or
      ((active > 0) and (curnum < basemsg)) or (curnum > 999999999) then
      exit;


   {load text blocks of message}
   for i := 1 to txtblocks do
      bread(infd,block[i]);


   {check for dead messages}
   if header.status = dead_msg then
   begin
      inc(killed);
      exit;
   end;


   {determine if message is to be kept}
   {check for outdated messages to be purged}
   if curnum < firstmsg then
   begin
      {keep unReceived+private if needed}
      if keepunrecvd and ((header.StatusCode = '*') or
                          (header.StatusCode = '~') or
                          (header.StatusCode = '#')) then
      begin
         inc(unrecvd);     {count the kept message}
         inc(firstmsg);    {and skip another to make up for it}
      end
      else

      {skip all other old messages}
      begin
         inc(skipped);
         if saveold then
            capture_message;
         exit;
      end;
   end;


   {check for received+private messages if needed}
   if killrecvd then
      if (header.StatusCode = '+') or
         (header.StatusCode = '`') or
         (header.StatusCode = '$') then
      begin
         inc(received);
         exit;
      end;


   {remove messages that are too old}
   if message_outdated then
   begin
      inc(skipped);
      if saveold then
         capture_message;
      exit;
   end;


   {remove ibm and high-ascii codes if needed}
   maxpos := txtblocks*blksiz;
   if noibm then
      for i := 1 to maxpos do
         case raw[i] of
            endline:
               ;

            #0..#6,
            #8,#11,#12,
            #14..#31,
            #127..#255:
               raw[i] := '.';
         end;


   {lookup prior crc value for this message, 0 if none}
   lookup_crc;


   {clean up taglines if needed}
   if (cleantags or nocrctags) and (crc_out = 0) then
   begin
      get_text;
      analyze_taglines;

      if cleantags then
      begin
         clean_taglines;
         put_text;
      end;
   end;


   {compute message CRC only if no crc is available for it}
   if crc_out = 0 then
   begin
      crc_out := crc_seed;
      crcstr(header.whofrom,crc_out,sizeof(header.whofrom));
      crcstr(header.subject,crc_out,sizeof(header.subject));

      {compute crc of text blocks}
      if not nocrctags then
         crcstr(block,crc_out,txtblocks*sizeof(block[1]))
      else

      {exclude taglines from crc calculation if needed}
      begin
         if (tearline > 1) and (tearline < linecnt) then
            n := tearline-1
         else
            n := linecnt;

         for i := 1 to n do
         begin
            {if listmsgs then
               writeln('(CRC)! ',lines[i]);}
            crcstr(lines[i],crc_out,length(lines[i])+1);
         end;
      end;
   end;


   {produce listing if needed}
   if listmsgs then
      format_listing;


   {check for duplicates if needed}
   if killdups then
   begin
      case header.StatusCode of
         '*','+','~','`','#','$':
            ;                 {exclude private codes}

      else                    {check this message for duplication}
         if not unique_crc then
         begin
            inc(dups);
            exit;
         end;
      end;
   end;


   {message is to be kept - enter it into the index and crc files}
   inc(active);
   store_index;
   store_crc;
   lastmsg := curnum;


   {remove obsolete refer numbers}
   refnum := stol(header.referto);
   if (refnum > 0) then
      if (refnum < basemsg) or (refnum > lastmsg) or
         (stol(ixbuf^[refnum-basemsg+1]) < 1) then
   begin
      inc(oldref);
      zeros(header.referto);
   end;


   {copy message to new message file}
   bwrite(outfd,header);
   iocheck;
   for i := 1 to txtblocks do
   begin
      bwrite(outfd,block[i]);
      iocheck;
   end;
end;


(* --------------------------------------------------------- *)
procedure scan_messages;
   {scan the message file and output header summaries}
begin
   dos_unlink(bakfile);    {make room}

   while not beof(infd) do
      process_message;

   bclose(infd);
   bflush(outfd);
   iocheck;
end;



(* --------------------------------------------------------- *)
procedure display_summary(var fd: text);
var
   elapsed: real;

begin
   if saveold then
      write(fd,saved:3,' saved, ');

   if killdups then
      write(fd,dups:3,' dups, ');

   if killrecvd then
      write(fd,received:3,' received, ');

   elapsed := int(lget_ms - t_start) / 1000.0;
   write(fd,skipped:3,' skipped, ',
            killed:3,' dead, ',
            active:4,' active msgs, ',
            elapsed:5:1,' sec.');
end;


(* --------------------------------------------------------- *)
(*             the main program                              *)
(* --------------------------------------------------------- *)

var
   i: integer;
begin
   decode_params;

   bopen(infd,msgfile,maxinbuf,sizeof(message_rec));
   if berr then
      usage('Can''t open message file: '+msgfile);

   bcreate(newfile);
   bopen(outfd,newfile,maxoutbuf,sizeof(message_rec));
   
   write('Packing ',msgfile,' ...  Options: ',cmdline);
   write(con,^M,'':78,^M'Packing ',msgfile,' ...');

   load_header;
   load_index;
   load_crc;

   scan_messages;

   writeln(con,' Done!');
   writeln;

   if saveold then
      close(savefd);

   update_header;
   rename_files;       
   update_index;
   save_crc;

   display_summary(output);
   write(con,^M);
   display_summary(con);
   writeln(con);

   dos_freemem(ixbuf);
   dos_freemem(msgcrc);
   halt(0);
end.


