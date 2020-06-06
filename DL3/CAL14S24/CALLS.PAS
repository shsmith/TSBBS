
{$M 50000,30000,500000}  {Stack, minheap, maxheap}

{$V-}    {Relax string rules}
{$S-}    {Stack testing}
{$R-}    {Range checks}
{$L+}    {Local debug info}
{$D+}    {Global debug info}

program caller_log_report;

uses Dos, Qread, ansiCrt, MdosIO, openShare;


{                 PCBoard Call Analyzer Ver. 11.7  02/19/87                }
{                                                                          }
{       PCBoard Call Analyzer written by Warren Lauzon of Phoenix AZ       }
{                 Phoenix Techline PCBoard   602-936-3058                  }
{                                                                          }
{      (updated for PCBoard 11.8 and PCB ProDOOR, S.H.Smith, 09/02/87)     }
{              (updated for PCBoard 14.1 S.H.Smith, 08/02/89)              }


const
   version     = '14s24';
   reldate     = '10-29-92';
   pcbversion  = 'For PCBoard v14.x';

type
   anystring   = string[80];
   FileStr     = string[64]; {array[1..64] of char;}
   char64      = array[1..64] of char;
   ItemNameStr = string[20];

   ItemPointer = ^ItemList;
   ItemList    = record
                     name:    ItemNameStr;
                     count:   real;
                     next:    ItemPointer;
               end;

   FilePointer = ^FileRec;
   FileRec     = record
                     name:    string[16];
                     count:   longint;
                     size:    longint;
                     higher:  FilePointer;
                     lower:   FilePointer;
               end;

   ProtocolRecord = record
                     Code:       char;
                     Name:       string[20];
                     Uploads:    longint; {count of uploads}
                     UpTime:     real; {time spent uploading}
                     UpIdeal:    real; {ideal time if 100% efficient}
                     Downloads:  longint;
                     DownTime:   real;
                     DownIdeal:  real;
               end;

const
   OldProtocolCount = 27;
   ProtocolCount = 56;
   Protocol:  array[1..ProtocolCount] of ProtocolRecord = (
      (Code:  'A'; Name:  'ASCII'),
      (Code:  'B'; Name:  'B'),
      (Code:  'C'; Name:  'CRC Xmodem'),
      (Code:  'D'; Name:  'D'),
      (Code:  'E'; Name:  'E'),
      (Code:  'F'; Name:  'Full Flow'),
      (Code:  'G'; Name:  'Ymodem-G (dsz)'),
      (Code:  'H'; Name:  'HS/Link'),
      (Code:  'I'; Name:  'I'),
      (Code:  'J'; Name:  'Jmodem'),
      (Code:  'K'; Name:  'Kermit'),
      (Code:  'L'; Name:  'Sysop (Local)'),
      (Code:  'M'; Name:  'MobyTurbo Zmodem'),
      (Code:  'N'; Name:  'N'),
      (Code:  'O'; Name:  '1K-Xmodem'),
      (Code:  'P'; Name:  'P'),
      (Code:  'Q'; Name:  'Q'),
      (Code:  'R'; Name:  'R'),
      (Code:  'S'; Name:  'S'),
      (Code:  'T'; Name:  'T'),
      (Code:  'U'; Name:  'U'),
      (Code:  'V'; Name:  'V'),
      (Code:  'W'; Name:  'WXmodem'),
      (Code:  'X'; Name:  'Xmodem'),
      (Code:  'Y'; Name:  'Ymodem'),
      (Code:  'Z'; Name:  'Zmodem'),

      (Code:  '0'; Name:  '0'),
      (Code:  '1'; Name:  '1'),
      (Code:  '2'; Name:  '2'),
      (Code:  '3'; Name:  '3'),
      (Code:  '4'; Name:  '4'),
      (Code:  '5'; Name:  '5'),
      (Code:  '6'; Name:  '6'),
      (Code:  '7'; Name:  '7'),
      (Code:  '8'; Name:  '8'),
      (Code:  '9'; Name:  '9'),
      (Code:  '!'; Name:  '!'),
      (Code:  '@'; Name:  '@'),
      (Code:  '#'; Name:  '#'),
      (Code:  '$'; Name:  '$'),
      (Code:  '%'; Name:  '%'),
      (Code:  '^'; Name:  '^'),
      (Code:  '&'; Name:  '&'),
      (Code:  '*'; Name:  '*'),
      (Code:  '+'; Name:  '+'),
      (Code:  '-'; Name:  '-'),
      (Code:  '<'; Name:  '<'),
      (Code:  '>'; Name:  '>'),
      (Code:  '/'; Name:  '/'),
      (Code:  '['; Name:  '['),
      (Code:  ']'; Name:  ']'),
      (Code:  '{'; Name:  '{'),
      (Code:  '}'; Name:  '}'),
      (Code:  '`'; Name:  '`'),
      (Code:  '~'; Name:  '~'),

      (Code:  '?'; Name:  'Others')  {must be last}
   );


{$i stoupper.inc}

(* -------------------------------------------------------- *)
const
   red:        string[7] = #27'[1;31m';
   green:      string[7] = #27'[1;32m';
   yellow:     string[7] = #27'[1;33m';
   blue:       string[7] = #27'[1;34m';
   magenta:    string[7] = #27'[1;35m';
   cyan:       string[7] = #27'[0;36m';
   white:      string[7] = #27'[1;37m';
   gray:       string[7] = #27'[0m';



(* -------------------------------------------------------- *)
const
   nodes:         longint = 1;   {number of nodes}
   logsize:       word = 0;
   UsedMinutes:   longint = 0;   {time used, minutes}
   Hours:         longint = 0;   {time used, hours}
   stuff:         longint = 0;
   runtime:       real = 0;      {how long it takes the program to run}
   Endtime:       real = 0;      {End time for program start}

   viewmember:    longint = 0;   {number of zip member textviews}
   extmember:     longint = 0;   {number of zip member extracts}
   repacks:       longint = 0;   {number of re-ziphive runs}
   testexec:      longint = 0;   {number of ziphives tested}
   viewexec:      longint = 0;   {number of 'view executed'}
   backdos:       longint = 0;   {number of times back from dos}
   batchs:        longint = 0;   {number of batch transfers}
   baud:          word = 0;      {current caller's baud rate}
   clevel:        anystring = '';{current caller's security leve]}
   blts:          longint = 0;   {bulletins read}
   caller:        longint = 0;   {number of callers}
   comments:      longint = 0;   {number of comments}
   dirscan:       longint = 0;   {number of DIR scans}
   DOORs:         longint = 0;   {number of DOORs opened}
   DosTimes:      longint = 0;   {how many times dropped to DOS}
   down:          longint = 0;   {number of downloads}
   d_abort:       longint = 0;   {number of download aborts}
   events:        longint = 0;   {event timer activated}
   even_parity:   longint = 0;   {7E callers}
   free_down:     longint = 0;   {free downloads}
   graphics:      longint = 0;   {graphics callers}
   joins:         longint = 0;   {number of conference joins}
   kills:         longint = 0;   {messages killed}
   lockouts:      longint = 0;   {Automatic lockouts done}
   mssgs:         longint = 0;   {messages left}
   Qmssgs:        longint = 0;   {Qmail messages left}
   Mmssgs:        longint = 0;   {Markmail messages left}
   new_guys:      longint = 0;   {new users registered}
   non_graphics:  longint = 0;   {non-graphics callers}
   sysop_paged:   longint = 0;   {sysop pages}
   pwfail:        longint = 0;   {password fails}
   question:      longint = 0;   {main questionnaire answered}
   refused:       longint = 0;   {refused to register}
   secviol:       longint = 0;   {security violations}
   start_time:    real = 0;      {0 time for program start}
   sysop_local:   longint = 0;   {local sysop sessions}
   sysop_remote:  longint = 0;   {remote sysop sessions}
   tcan:          longint = 0;   {number of trashcan name attempts}
   time_limit:    longint = 0;   {daily time limit exceeded}
   UniqFiles:     longint = 0;   {number of dIfferent files}
   up:            longint = 0;   {number of uploads}
   u_abort:       longint = 0;   {number of upload aborts}
   zipmail:       longint = 0;   {number of ARCM runs}
   msgcount:      longint = 0;   {number of ARCM messges}
   invalids:      longint = 0;   {number of invalid uploads}
   schat:         longint = 0;   {sysop chat initiated}
   nchat:         longint = 0;   {node chat initiated}
   DosTime:       longint = 0;   {time spent in remote DOS}
   libdisk:       longint = 0;

   event_time:    anystring = '';{time last event started or '' if none}
   event_mins:    longint = 0;   {minutes spent processing events}

   spare1:        longint = 0;
   spare2:        longint = 0;
   spare3:        longint = 0;
   spare4:        longint = 0;
   spare6:        longint = 0;
   spare7:        longint = 0;
   spare8:        longint = 0;
   spare9:        longint = 0;
   spare10:       longint = 0;
   spare11:       longint = 0;
   spare12:       longint = 0;
   spare13:       longint = 0;
   spare14:       longint = 0;
   spare15:       longint = 0;
   spare16:       longint = 0;


   Inrec:         FileStr = '';  {64 char line}
   Urec:          anystring = '';{upper case version of inrec}

   PeriodCovered: anystring = '';{concats to send to ofd}

   min_download:  longint = 2;   {min downloads to include in report}

   saveFile:      anystring = 'CALLS.SAV';    {saved history filename}

   inName:        anystring = 'CALLER';   {input filename}

   outfile:       anystring = 'BLT99';    {output filename}

   subtitle:      anystring = '';

   reports:       anystring = 'ANBCORPDEFGHIJKLQM';
                                          {list of reports to produce}

   {table of peak hours, 'Y'=peak, anything else=not}
                               {          1         2   }
                               {012345678901234567890123}
   PeakTable:     string[24] = 'YNNNNNNNNNNNNNNNNYYYYYYY';

   maxConf:       word = maxint;
   maxBlt:        word = maxint;
   maxDoor:       word = maxint;
   maxBatch:      word = maxint;
   maxFree:       word = maxint;

   event_mode:    string[20] = 'BUSY';


const
   FileTree:      FilePointer = nil;
   FirstBatch:    ItemPointer = nil;
   FirstBullet:   ItemPointer = nil;
   FirstConf:     ItemPointer = nil;
   FirstDoor:     ItemPointer = nil;
   FirstBaud:     ItemPointer = nil;
   FirstConType:  ItemPointer = nil;
   FirstSecLevel: ItemPointer = nil;
   FirstFreeDL:   ItemPointer = nil;

   FirstAvemins:  ItemPointer = nil;
   FirstSpare3:   ItemPointer = nil;
   FirstSpare4:   ItemPointer = nil;
   FirstSpare5:   ItemPointer = nil;
   FirstSpare6:   ItemPointer = nil;
   FirstSpare7:   ItemPointer = nil;
   FirstSpare8:   ItemPointer = nil;

   filever:       integer = 0;

   last_rec:      anystring = '';   {last entry in log}
   last_entry:    anystring = '';   {last entry in log}
   last_rec_seen: anystring = '';   {last entry in current log}

   first_rec:     anystring = '';   {first entry in log}
   first_entry:   anystring = '';   {first entry in log}

   TotHours:      real = 0;         {Total hours from first to last log entry}
   end_hours:     real = 0;
   beg_hours:     real = 0;

   Hrs:           array[0..23] of longint = {minutes used by hours}
         (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

var
   ifd:  text;   {caller log}

   ofd:  text;   {file that goes to the bulletin}

   iobuf: array[1..10240] of char;


const
   graph_num = 100;
   graph_set:  string[3] = 'ฐฒฑ';

type
   sort_keys = (percent_sort, name_sort, no_sort);

const
   graph_min:    longint = 0;
   graph_max:    longint = 0;
   graph_lim:    real = 0;
   graph_line:   longint = 0;
   graph_count:  integer = 0;
var
   graph_val:    array[1..graph_num] of real;
   graph_title:  array[1..graph_num] of string[20];

const
   pcol: string = '';



(* -------------------------------------------------------- *)
procedure setcolor(col: string);
begin
   if pcol <> col then
   begin
      write(ofd,col);
      pcol := col;
   end;
end;


(* -------------------------------------------------------- *)
function itoa(l: longint): anystring;
var
   s: anystring;
begin
   str(l,s);
   itoa := s;
end;

function wtoa(w: word): anystring;
var
   s: anystring;
begin
   str(w,s);
   wtoa := s;
end;


(* -------------------------------------------------------- *)
procedure section_title(title:  anystring);
   begin
      writeln(ofd);
      writeln(ofd, '':  35-(length(title) div 2),
            red, '-= ', yellow, title, red, ' =-');
      writeln(ofd);
   end;


(* -------------------------------------------------------- *)
procedure empty_section;
   begin
      writeln(ofd, gray, '':34,'**NONE**');
   end;


(* -------------------------------------------------------- *)
procedure start_graph(title:  anystring; limit:  real);
   begin
      graph_lim := limit;
      graph_max := 0;
      graph_min := 100;
      graph_line := 0;
      graph_count := 0;
      section_title(title);
   end;

(* -------------------------------------------------------- *)
procedure graph(item:  anystring; n:  real);
   var
      pct:  real;
   begin
      if graph_lim = 0 then
         pct := 0
      else
         pct := abs(n/graph_lim)*100.0;
      if (pct <= 0) or (pct > maxint) then
         exit;

      if pct > graph_max then
         graph_max := trunc(pct);
      if pct < graph_min then
         graph_min := trunc(pct*0.7);

      if graph_count < graph_num then
         inc(graph_count);

      graph_val[graph_count] := n;
      graph_title[graph_count] := item;
   end;


(* -------------------------------------------------------- *)
procedure graph_output(item:  anystring; n:  real);
   var
      pct:  real;
      i:    integer;
      w:    integer;
      lim:  longint;
   begin
      if graph_line < length(graph_set) then
         inc(graph_line)
      else
         graph_line := 1;

      if graph_lim = 0 then
         pct := 0
      else
         pct := abs(n/graph_lim*100.0);

      if pct > 150 then
         pct := 150;

      write(ofd, green, item:20, ': ', white);

      if graph_lim < 0 then
         if pct > 99.9 then
            write(ofd, pct:3:0,' % ')
         else
            write(ofd, pct:4:1, '% ')
      else

      begin
         if (int(graph_lim) <> graph_lim) and (graph_lim < 9999.0) then
            write(ofd, n:6:1)
         else
            write(ofd, n:5:0);

         if pct > 99.9 then
            write(ofd,gray, ' (',pct:3:0,' %) ')
         else
            write(ofd,gray,' (', pct:4:1, '%) ');
      end;

      if graph_lim < 0 then lim := 50 else lim := 42;

      if (pct < graph_min) then
         w := 0
      else
      if (graph_min = graph_max) then
         w := lim
      else
         w := round((pct-graph_min)/(graph_max-graph_min)*lim);

      if w > lim then
         w := lim;

      write(ofd, white, 'ณ', cyan);

      for i := 1 to w-1 do
         write(ofd, graph_set[graph_line]);
      if w > 0 then
         write(ofd, white, 'Û');

      writeln(ofd);
   end;


   (* -------------------------------------------------------- *)
   procedure sort_graph(onkey: sort_keys);
   var
      ts:   string[20];
      tv:   real;
      swap: boolean;
      i,j:  integer;

      function swap_needed: boolean;
      begin
         if onkey = percent_sort then
            tv := graph_val[i]-graph_val[i+1]
         else
            tv := 0;
         if tv = 0 then
            if graph_title[i] > graph_title[i+1] then
               tv := -1;
         swap_needed := (tv < 0);
      end;
      
      (* -------------------------------------------------------- *)
      procedure swap_entries;
      begin
         swap := true;
         tv := graph_val[i+1];
         graph_val[i+1] := graph_val[i];
         graph_val[i] := tv;
         ts := graph_title[i+1];
         graph_title[i+1] := graph_title[i];
         graph_title[i] := ts;
      end;

   begin

     j := graph_count;
     repeat
         swap := false;
         dec(j);
         for i := 1 to j do
            if swap_needed then
               swap_entries;
      until swap = false;
   end;


(* -------------------------------------------------------- *)
procedure end_graph(onkey: sort_keys; maxcnt: word);
   var
      i:  integer;

   begin
      if onkey <> no_sort then
         sort_graph(onkey);

      if graph_count > maxcnt then
         graph_count := maxcnt;

      for i := 1 to graph_count do
         graph_output(graph_title[i], graph_val[i]);

      if graph_count = 0 then
         empty_section;

      writeln(ofd);
   end;


(* -------------------------------------------------------- *)
   procedure graph_list(node:    ItemPointer;
                        title:   string;
                        n:       real;
                        key:     sort_keys;
                        maxcnt:  word);
   begin
      if maxcnt = maxint then
         start_graph(title,n)
      else
         start_graph('Top '+itoa(maxcnt)+' '+title,n);

      while (node <> nil) do
      begin
         graph(node^.name, node^.count);
         node := node^.next;
      end;

      end_graph(key,maxcnt);
   end;


(* -------------------------------------------------------- *)
procedure walk_tree( var Node:  FilePointer;
                     var a:  integer);
   {traverse the binary filename tree and output in sorted order}
begin
   if Node = nil then exit;

   walk_tree(Node^.lower, a);

   if Node^.count >= min_download then
   begin
      case Node^.count-min_download of
         0.. 2: write(ofd, cyan,   '     ');
         3.. 6: write(ofd, green,  '   * ');
         7..12: write(ofd, red,    '  ** ');
        13..24: write(ofd, yellow, ' *** ');
         else   write(ofd, white,  '**** ');
      end;

      write(ofd, Node^.name:  12, Node^.count:  5);

      if a mod 3 = 0 then
         writeln(ofd)
      else
         write(ofd,'   ');

      inc(a);
   end;

   walk_tree(Node^.higher, a);
end;


(* -------------------------------------------------------- *)
procedure output_results(outfile: anystring);
   var
      UsedHours:  real;
      DownEffic:  real;
      UpEffic:    real;
      daymsg:     anystring;
      Days:       longint;
      report:     integer;
      c:          char;
      PeakUsed:   real;
      PeakHours:  real;

      procedure init_report;
      var
         i,j,k: integer;
         pr:    array[0..23] of real;
         ph:    array[0..23] of integer;
         th:    integer;
         tr:    real;
      begin
         gotoxy(15, 15);
         highvideo;
         textcolor(ansicrt.yellow);

         gotoxy(1, 2);
         write('Sending output to ', outfile,' ');

         assign(ofd, outfile);
         rewrite(ofd);
         setTextbuf(ofd,iobuf);

         UsedHours := int(UsedMinutes)/60.0+int(Hours);

         if TotHours < 1 then
            TotHours := 1;
         Days := trunc( (TotHours+23.9) /24.0 );
         daymsg := itoa((days{+nodes-1}) div nodes);

         {automatically choose peak hours if needed}
         if PeakTable = 'AUTO' then
         begin
            for i := 0 to 23 do
            begin
               ph[i] := i+1;
               pr[i] := hrs[i];
            end;
            for i := 22 downto 1 do
               for j := 0 to i do
                  if pr[j] < pr[j+1] then
                  begin
                     tr := pr[j];
                     th := ph[j];
                     pr[j] := pr[j+1];
                     ph[j] := ph[j+1];
                     pr[j+1] := tr;
                     ph[j+1] := th;
                  end;
            PeakTable := 'NNNNNNNNNNNNNNNNNNNNNNNN';
            for i := 0 to 5 do
               PeakTable[ph[i]] := 'Y';
         end;

         {calculate number of hours in peak times}
         i := 0;
         for j := 0 to 23 do
            if PeakTable[j+1] = 'Y' then
               inc(i);
         if i = 0 then
            i := 24;
         PeakHours := TotHours / 24.0 * int(i);

         {calculate time used in peak times}
         if i = 24 then
            PeakUsed := UsedHours
         else
         begin
            PeakUsed := 0;
            for j := 0 to 23 do
               if PeakTable[j+1] = 'Y' then
                  PeakUsed := PeakUsed + int(hrs[j])/60.0;
         end;

         writeln(ofd,white);
         writeln(ofd, '               Calls ', version, ' - Call Analyzer ',pcbversion);
         writeln(ofd, blue, '            ', PeriodCovered);
      end;

      procedure system_statistics;
      begin
         if nodes > 1 then
            section_title('Combined Statistics for '+itoa(nodes)+' nodes over '+daymsg+' days')
         else
            section_title('System Statistics for '+daymsg+' days');

         if SubTitle <> '' then
            section_title(subTitle);

         if (caller = 0) or (days = 0) or
            (totHours = 0) or (peakHours = 0) then exit;

         write  (ofd, green, '  Directory Scans........ ', white, dirscan:6);
         writeln(ofd, green, '  Messages Left.......... ':33, white, mssgs:6);

         write  (ofd, green, '  Doors Opened........... ', white, DOORs:6);
         writeln(ofd, green, '    Comments Left........ ':33, white, comments:6);

         write  (ofd, green, '  Downloads Completed.... ', white, down:6);
         writeln(ofd, green, '    Qmail Messages Left.. ':33, white, Qmssgs:6);

         write  (ofd, green, '    Different Files...... ', white, UniqFiles:6);
         writeln(ofd, green, '    MarkMail Messages.... ':33, white, Mmssgs:6);

         write  (ofd, green, '    Downloads Aborted.... ', white, d_abort:6);
         writeln(ofd, green, '    ZIPM Executed........ ':33, white, zipmail:6);

         write  (ofd, green, '    Free Downloads....... ', white, free_down:6);
         writeln(ofd, green, '    ZIPM Messages........ ':33, white, msgcount:6);

         write  (ofd, green, '  LIB Executed........... ', white, libdisk:6);
         writeln(ofd, green, '  Number of Callers...... ':33, white, caller:6);

         write  (ofd, green, '  REPACK Executed........ ', white, repacks:6);
         writeln(ofd, green, '    New Users Registered. ':33, white, new_guys:6);

         write  (ofd, green, '  TEST Executed.......... ', white, testexec:6);
         writeln(ofd, green, '    Ave. Calls Per Day... ':33, white, nodes*caller/Days:6:1);

         write  (ofd, green, '  Uploads Completed...... ', white, up:6);
         writeln(ofd, green, '    Ave. Call Duration... ':33, white, (UsedHours*60)/caller:6:1);

         write  (ofd, green, '    Bad Uploads Deleted.. ', white, invalids:6);
         writeln(ofd, green, '    Ave. Idle Time....... ':33, white, (TotHours-UsedHours)*60/caller:6:1);

         write  (ofd, green, '    Uploads Aborted...... ', white, u_abort:6);
         writeln(ofd, green, '  Scripts Completed...... ':33, white, question:6);

         write  (ofd, green, '  VIEW Executed.......... ', white, viewexec:6);
         writeln(ofd, green, '  Total Operation Hours.. ':33, white, TotHours:6:1);

         write  (ofd, green, '    Members Extracted.... ', white, extmember:6);
         writeln(ofd, green, '    Utilization Hours.... ':33, white, UsedHours:6:1);

         write  (ofd, green, '    Members Viewed....... ', white, viewmember:6);
         writeln(ofd, green, '    Total Utilization %.. ':33, white, (UsedHours/TotHours)*100:6:1);

         write  (ofd, '':32);
         writeln(ofd, green, '    Peak Utilization %... ':33, white, (PeakUsed/PeakHours)*100:6:1);
         writeln(ofd);
      end;

      procedure security_statistics;
      var
         evmins:  real;
      begin
         section_title('Security Statistics');

         write  (ofd, green, '  Automatic Lockouts..... ', white, lockouts:6);
         writeln(ofd, green, '  Node Chats Initiated... ':33, white, nchat:6);

         write  (ofd, green, '  Password Failures...... ', white, pwfail:6);
         writeln(ofd, green, '  Sysop Chats Initiated.. ':33, white, schat:6);

         write  (ofd, green, '  Refused to Register.... ', white, refused:6);
         writeln(ofd, green, '  Sysop Paged............ ':33, white, sysop_paged:6);

         write  (ofd, green, '  Remote DOS Time (min).. ', white, DosTime:6);
         writeln(ofd, green, '  Sysop Sessions......... ':33, white, sysop_local+sysop_remote:6);

         write  (ofd, green, '  Remote Drops to DOS.... ', white, DosTimes:6);
         writeln(ofd, green, '  Time Limit Expired..... ':33, white, time_limit:6);

         write  (ofd, green, '  Scheduled Events....... ', white, events:6);
         writeln(ofd, green, '  Trashcan Names......... ':33, white, tcan:6);

         if event_mode = 'OFF' then
            write(ofd, '':32)
         else
         begin
            if events = 0 then
               evmins := 0
            else
               evmins := event_mins/(events*nodes);
            write  (ofd, green, '  Ave Event Length (min). ', white, evmins:6:1);
         end;

         writeln(ofd, green, '  Security Violations.... ':33, white, secviol:6);
         writeln(ofd);
      end;

      procedure graphic_modes;
      var
         k: longint;
      begin
         k := (graphics+non_graphics+even_parity);
         start_graph('Graphics Modes', k);
         graph('Color Graphics', graphics);
         graph('Non Graphics', non_graphics);
         graph('7 Bit Even-Parity', even_parity);
         end_graph(percent_sort,maxint);
      end;

      procedure baud_rates;
      begin
         graph_list(FirstBaud,'Baud Rates', caller, percent_sort, maxint);
      end;

      procedure connect_types;
      begin
         graph_list(FirstConType,'Connect Types', caller, percent_sort, maxint);
      end;

      procedure security_levels;
      begin
         graph_list(FirstSecLevel,'Number of Calls by Security Level', caller, percent_sort, maxint);
      end;

      procedure average_minutes;
      begin
         graph_list(FirstAveMins,'Hours Used by Security Level', UsedMinutes/60.0+UsedHours, percent_sort, maxint);
      end;

      procedure free_downloads;
      begin
         graph_list(FirstFreeDL,'Free Downloads', caller, percent_sort, maxFree);
      end;

      procedure hourly_usage;
      var
         hits: longint;
         slot: integer;
         a:    integer;
         k:    integer;
         whole_days:  real;

      begin
         section_title('Average Percent of Hourly Usage');

         write(ofd, green, '       00');
         for a := 1 to 23 do
         begin
            if a < 10 then write(ofd,'  ') else write(ofd,' ');
            write(ofd,a);
         end;
         writeln(ofd);

         whole_days := int((TotHours+23)/24) * 0.60;

         hits := 0;
         for k := 20 downto 1 do 
         begin
            write(ofd, green, k*5:  3, '%');
            pcol := '';
            setcolor(white);
            write(ofd, ' ณ ');
            hits := 0;

            for a := 0 to 23 do 
            begin
               c := graph_set[(a mod 3)+1];
               slot := round( (hrs[a] / whole_days) / 5);
               if slot > 20 then
                  slot := 20;

               if slot = k then
               begin
                  setcolor(white);
                  write(ofd, 'ÛÛ ');
               end
               else

               if slot > k then
               begin
                  setcolor(cyan);
                  write(ofd, c,c,' ');
                  inc(hits);
               end
               else 

               begin
                  setcolor(blue);
                  write(ofd, ' ๚ ');
               end;
            end;

            writeln(ofd);
         end;

         write(ofd, green, '       00');
         for a := 1 to 23 do
         begin
            if a < 10 then write(ofd,'  ') else write(ofd,' ');
            write(ofd,a);
         end;
         writeln(ofd);

         write(ofd, yellow, 'Peak: ', red);
         for a := 0 to 23 do
            if PeakTable[a+1] = 'Y' then
               write(ofd,' **')
            else
               write(ofd,'   ');
         writeln(ofd);
         writeln(ofd);
      end;

      procedure conferences_joined;
      begin
         graph_list(FirstConf,'Conferences Joined', joins, percent_sort, maxConf);
      end;

      procedure bulletins_read;
      begin
         graph_list(FirstBullet,'Bulletins Read', blts, percent_sort, maxBlt);
      end;

      procedure doors_opened;
      begin
         graph_list(FirstDoor,'Doors Opened', DOORs, percent_sort, maxDoor);
      end;

      procedure download_protocols;
      var
         k: integer;
      begin
         start_graph('Protocol Usage (Downloading)', down);
         for k := 1 to ProtocolCount do
            with Protocol[k] do
               if (Downloads <> 0) then
                  graph(Name, Downloads);
         end_graph(percent_sort,maxint);
      end;

      procedure download_efficiency;
      var
         k: integer;
      begin
         start_graph('Average Protocol Efficiency (Downloading)', -100);
         for k := 1 to ProtocolCount do
            with Protocol[k] do
               if (Downloads <> 0) and (DownTime <> 0) then
                  begin
                     DownEffic := 100.0*DownIdeal/DownTime;
                     graph(Name, DownEffic);
                  end;
         end_graph(percent_sort,maxint);
      end;

      procedure upload_protocols;
      var
         k: integer;
      begin
         start_graph('Protocol Usage (Uploading)', up);
         for k := 1 to ProtocolCount do
            with Protocol[k] do
               if (Uploads <> 0) then
                  graph(Name, Uploads);
         end_graph(percent_sort,maxint);
      end;

      procedure upload_efficiency;
      var
         k: integer;
      begin
         start_graph('Average Protocol Efficiency (Uploading)', -100);
         for k := 1 to ProtocolCount do
            with Protocol[k] do
               if (Uploads <> 0) and (UpTime <> 0) then
                  begin
                     UpEffic := 100.0*UpIdeal/UpTime;
                     graph(Name, UpEffic);
                  end;
         end_graph(percent_sort,maxint);
      end;

      procedure batch_sizes;
      begin                                                    {name_sort}
         graph_list(FirstBatch,'Batch Transfer Sizes', batchs, percent_sort, maxBatch);
      end;

      procedure files_downloaded;
      var
         a: integer;
         s: anystring;
      begin
         if min_download = 1 then
            s := ''
         else
            s := ' '+ itoa(min_download) + ' or More Times';

         section_title('Files Downloaded'+s);
         if down < 1 then
            empty_section
         else
            begin
               a := 1;
               walk_tree(FileTree, a);
            end;
         writeln(ofd);
      end;

(* -------------------------------------------------------- *)
   begin
      init_report;

      for report := 1 to length(reports) do
         case upcase(reports[report]) of
           'A': system_statistics;
           'B': graphic_modes;
           'C': baud_rates;
           'D': hourly_usage;
           'E': conferences_joined;
           'F': bulletins_read;
           'G': doors_opened;
           'H': download_protocols;
           'I': download_efficiency;
           'J': upload_protocols;
           'K': upload_efficiency;
           'L': batch_sizes;
           'M': files_downloaded;
           'N': security_statistics;
           'O': security_levels;
           'P': connect_types;
           'Q': free_downloads;
           'R': average_minutes;
           'Z': writeln(ofd);
         end;

      write(ofd,gray);
      close(ofd);
   end;



(* -------------------------------------------------------- *)
procedure getrec;
   var
      c:    char;
   begin
      Qreadln(ifd, Inrec, sizeof(Inrec));
      Urec := Inrec;
      stoupper(Urec);

      if Urec[3] = '-' then
         last_rec_seen := Urec;

      if keypressed then
      begin
         c := readkey;
         if c = #27 then
         begin
            gotoxy(1, 24);
            writeln('** ESC pressed - Aborted **');
            delay(2000);
            halt;
         end;
      end;
   end;



(* -------------------------------------------------------- *)
procedure add_item(var FirstItem:  ItemPointer;
                   ItemName:       ItemNameStr;
                   Number:         real);
var
   NewItem:  ItemPointer;

begin
   NewItem := FirstItem;
   while NewItem <> nil do
      if NewItem^.name = ItemName then
         begin
            NewItem^.count := NewItem^.count + Number;
            exit;
         end
      else
         NewItem := NewItem^.next;

   new(NewItem);          { get a new record}
   NewItem^.next := FirstItem;
   FirstItem := NewItem;
   NewItem^.name := ItemName;
   NewItem^.count := Number;
end;


(* -------------------------------------------------------- *)
procedure store_name(var Node:  FilePointer;
                     var Name:  anystring;
                     var Size:  longint);
      {stores the name in the sorted name tree; recursive}

   begin

      if Urec[8] = 'U' then
      begin
         size := 100000;
         exit;
      end;


      (* insert new nodes *)
      if Node = nil then
      begin
         new(Node);
         Node^.count := 1;
         Node^.name := Name;
         Node^.size := 100000;
         Size := Node^.size;
         Node^.higher := nil;
         Node^.lower := nil;
         inc(UniqFiles);
      end
      else

      (* count existting nodes *)
      if Node^.name = Name then
      begin
         inc(Node^.count);
         Size := Node^.size;
      end
      else

      (* else traverse the tree looking for the right node *)
      if Name > Node^.name then
         store_name(Node^.higher,Name,Size)
      else
         store_name(Node^.lower,Name,Size);
   end;


(* -------------------------------------------------------- *)
function pos(pattern: string; value: string): integer;
var
   i: integer;
begin
   if length(pattern) = 1 then
   begin
      for i := 1 to length(value) do
         if value[i] = pattern[1] then
         begin
            pos := i;
            exit;
         end;
      pos := 0;
   end
   else
      pos := system.pos(pattern,value);
end;


(* -------------------------------------------------------- *)
type
   str12 = string[12];
   str80 = string[80];

{  This Function returns a name expanded to line up both the name and ext    }
{  for example:  abc.com      =  abc      com                                }
{                datafile.1   =  datafile   1                                }

function ExpandName(name:  str12):  str12;

   var
      Counter, DotPos:  integer;

   begin
      DotPos := pos('.', name); {where's the dot at?}
      if DotPos = 0 then
      begin
         repeat
            name := name+' '; {If no ext, pad with spaces}
         until length(name) = 12;
      end else
      begin
         delete(name, DotPos, 1);
         repeat
            insert(' ', name, DotPos);
         until length(name) = 12;
      end;
      ExpandName := name;
   end;


(* -------------------------------------------------------- *)
procedure print(col, row:  integer;
                str:       str80;
                Attrib:    integer);
   begin
      gotoxy(col, row);
      textcolor(Attrib);
      write(str);
   end;


(* -------------------------------------------------------- *)
function Time:  real;
   var
      Reg:  Registers;

   begin Reg.AX := $2C00;
      intr($21, Reg);
      Time := (Reg.CX shr 8)*3600 {Hours}
             +(Reg.CX and $00FF)*60 {Minutes}
             +(Reg.DX shr 8)      { * 1 }
                                  {Seconds    }
             +(Reg.DX and $00FF)/100; {Hundredths }
   end;



(* -------------------------------------------------------- *)
procedure calculate_event_time;
   var
      minbeg,hourbeg:   integer;
      minend,hourend:   integer;
      a:                integer;
      timebeg:          integer;
      timeend:          integer;
      mins:             integer;

   begin
      val(copy(event_time,1,2),hourbeg,a);
      if hourbeg > 23 then
         hourbeg := hourbeg - 24;
      val(copy(event_time,4,2),minbeg,a);
      event_time := '';

      val(copy(Urec,11,2),hourend,a);
      if hourend > 23 then
         hourend := hourend - 24;
      val(copy(Urec,14,2),minend,a);

      timebeg := hourbeg*60 + minbeg;
      timeend := hourend*60 + minend;
      if timeend < timebeg then
         timeend := timeend + 1440;

      mins := timeend-timebeg;
      event_mins := event_mins + mins;

      if event_mode = 'BUSY' then
      begin
         while mins > 0 do
         begin
            if mins > minend then
               a := minend
            else
               a := mins;

            UsedMinutes := UsedMinutes + a;
            while UsedMinutes > 60 do
            begin
               inc(Hours);
               UsedMinutes := UsedMinutes - 60;
            end;

            Hrs[hourend] := Hrs[hourend]+a;
            mins := mins-a;

            if hourend > 0 then
               dec(hourend)
            else
               hourend := 23;
            minend := 60;
         end;
      end;
   end;



(* -------------------------------------------------------- *)
procedure incaller;
   var
      posit:   integer;
      num:     integer;
      j:       integer;
      temp:    anystring;
      BaudName:anystring;

   begin
      temp := copy(Urec,23,99);
      posit := pos(') (',temp);
      if posit = 0 then
         exit;

      inc(caller);

      if pos(' (LOCAL) (', Urec) <> 0 then
      begin
         inc(sysop_local);
         BaudName := 'Local ';
         add_item(FirstBaud, BaudName, 1);
         baud := 0;
      end
      else

      begin
         if pos(' SYSOP (', Urec) > 0 then
            inc(sysop_remote);

         j := posit-1;
         while (j > 0) and (temp[j] <> '(') do
            dec(j);
         inc(j);
         BaudName := copy(temp,j,posit-j);

         j := length(BaudName);
         if BaudName[j] <> 'E' then
            BaudName := BaudName + ' ';

         add_item(FirstBaud, BaudName, 1);

         dec(BaudName[0]);
         {writeln('baud=[',baudName,']');}
         baud := 0;
         val(BaudName,baud,posit);
      end;

      if pos('(G', Urec) > 0 then inc(graphics)
      else if pos('(N', Urec) > 0 then inc(non_graphics)
      else if pos('(7', Urec) > 0 then inc(even_parity);

      if pos(' TRASHCAN ', Urec) > 0 then inc(tcan);

      if event_time <> '' then
         calculate_event_time;

      clevel := '';
   end;


(* -------------------------------------------------------- *)
procedure indownload;      {upload/downloaded file stuff}
   var
      prot:    char;
      posit:   integer;
      k:       integer;
      CPS:     real;
      FileName:  string[12];
      tmp:     string;
      size:    longint;
      ideal:   real;
      Time:    real;

   begin
      if Urec[9] <> ')' then exit;

      if pos(' ABORTED ', Urec) > 0 then
      begin
         if Urec[8] = 'D' then
            inc(d_abort) {Aborted dl's}
         else
            inc(u_abort);
         exit;
      end;

      posit := pos(' COMPLETED ', Urec); {find End of name}
      if posit=0 then exit;

      {determine file name}
      FileName := ExpandName(copy(Urec, 11, (posit-11)));
      if FileName[1] = ' ' then exit;

      {store name, return file size}
      store_name(FileTree,FileName,size);

      {determine transfer time}
      if baud <> 0 then
         ideal := size/baud*10.0
      else
         ideal := 111;

      {determine actual transfer time}
      posit := pos('CPS=', Urec);
      if posit = 0 then
         CPS := baud/11.0
      else
      begin
         tmp := copy(Urec,posit+4,6);
         posit := pos(' ',tmp);
         tmp := copy(tmp,1,posit-1);
         CPS := 0;
         val(tmp,cps,posit);
      end;

      if (CPS < 20) or (CPS > (baud/5.0)) then
      begin
         Time := 0;     {don't consider aborted or invalid transfers}
         ideal := 0;
(***
         gotoxy(1,3);
         writeln('Download time out of range: CPS=',CPS:4:0,' Min=20 Max=',baud/5:0:0);
         writeln(urec);
***)
      end
      else
         Time := size/CPS;

      {determine protocol and find table entry}
      posit := pos(' USING ', Urec);
      prot := Urec[posit+7];

      for k := 1 to ProtocolCount do
      with Protocol[k] do

         if (Code = prot) or (Code = '?') then
         begin
            if Code = '?' then
            begin
               gotoxy(1,3);
               writeln('Unknown protocol: ',Urec);
            end;

            if Urec[8] = 'D' then
            begin
               inc(Downloads);
               DownTime := DownTime+Time;
               DownIdeal := DownIdeal+ideal;
               inc(down);
            end
            else
            begin
               inc(Uploads);
               UpTime := UpTime+Time;
               UpIdeal := UpIdeal+ideal;
               inc(up);
            end;

            exit;
         end;
   end;


(* -------------------------------------------------------- *)
procedure confjoin;        {conferences joined}
   var
      posit:   integer;
      ConfName:  anystring;

   begin
      posit := pos(' CONFERENCE', Urec);
      if posit < 8 then
         exit;

      ConfName := copy(Inrec, 7, 10);
      posit := pos(' ',ConfName);
      if posit > 0 then
         ConfName[0] := chr(posit-1);

      case ConfName[1] of
         '0'..'9', 'a'..'z', 'A'..'Z':
         begin
            inc(joins);
            add_item(FirstConf, ConfName, 1);
         end;
      end;
   end;


(* -------------------------------------------------------- *)
procedure batch;        {batch transfer}
   var
      posit:   integer;
      num:     integer;
      BatchName:  anystring;
      temp:    anystring;

   begin
      posit := pos(' FILES', Urec);
      temp := copy(Urec,7,posit-7);
      num := 0;
      val(temp,num,posit);
      if num < 1 then
         exit;
      if Urec[posit+7] = '0' then
         exit;

      if num = 1 then
         BatchName := '  Single Files'
      else
         BatchName := itoa(num) + ' Files';

      batchs := batchs + num;
      add_item(FirstBatch, BatchName, num);
   end;


(* -------------------------------------------------------- *)
procedure zipmsgs;        {ziphived message count}
   var
      posit:   integer;
      num:     integer;
   
   begin
      posit := pos(' MESSA', Urec);
      num := 0;
      val(copy(Urec,7,posit-7),num,posit);
      if num < 1 then
         exit;
      msgcount := msgcount + num;
   end;


(* -------------------------------------------------------- *)
var
   numdays:  integer;

function finday(Days:  integer):  integer;
   begin
      case Days of
        12:  numdays := 334;
        11:  numdays := 304;
        10:  numdays := 273;
         9:  numdays := 243;
         8:  numdays := 212;
         7:  numdays := 181;
         6:  numdays := 151;
         5:  numdays := 120;
         4:  numdays := 90;
         3:  numdays := 59;
         2:  numdays := 31;
         1:  numdays := 0;
      end;                 {case}
      finday := numdays;
   end;


(* -------------------------------------------------------- *)
procedure bulletins;
   var
      posit:      integer;
      BltNumber:  anystring;
      BltName:    anystring;

   begin
      BltName := copy(Inrec, 22, 10);
      posit := pos(' ', BltName);
      if posit > 0 then
         BltName[0] := chr(posit-1);
      if length(BltName) = 0 then
         exit;

      posit := pos('#', Inrec);
      if posit = 0 then
         exit;
      BltNumber := copy(Inrec,posit+2,4);
      posit := pos(' ', BltNumber);
      if posit > 0 then
         BltNumber[0] := chr(posit-1);
      while length(BltNumber) < 3 do
         BltNumber := ' ' + BltNumber;

      BltName := BltName + ' #' + BltNumber;
      inc(blts);
      add_item(FirstBullet, BltName, 1);
   end;                    {bulletins}


(* -------------------------------------------------------- *)
procedure sec_level;
   var
      Name: anystring;
      p: integer;
   begin
      p := pos(':',Inrec);
      if p = 0 then exit;
      Name := copy(Inrec,p+1,19);
      while Name[length(Name)] = ' ' do
         dec(Name[0]);
      while copy(Name,1,1) = ' ' do
         delete(Name,1,1);
      if Name = '' then exit;

      while length(Name) < 3 do
         Name := ' ' + Name;
      Name := 'Level '+Name;
      add_item(FirstSecLevel, Name, 1);
      clevel := Name;
   end;


(* -------------------------------------------------------- *)
procedure con_type;
   var
      Name: anystring;

   begin          {......Connect Type: xxxx}
      Name := copy(Inrec,21,255);
      while Name[length(name)] = ' ' do
         dec(Name[0]);
      if (copy(Name,1,8) = 'CARRIER ') or (copy(Name,1,8) = 'CONNECT ') then
         Name := copy(Name,9,255);
      add_item(FirstConType, Name, 1);
   end;


(* -------------------------------------------------------- *)
procedure pfree_down;
   var
      Name: anystring;

   begin          {......Free Download: xxxx}
      Name := copy(Inrec,22,12);
      add_item(FirstFreeDL, Name, 1);
      inc(free_down)
   end;


(* -------------------------------------------------------- *)
procedure pdoors;
   var
      posit:      integer;
      DoorName:   string[40];

   begin
      if pos(' AT ', Urec) = 0 then exit;

      posit := pos('(', Inrec);
      if posit = 0 then exit;

      DoorName := copy(Inrec, posit+1, pos(')', Inrec)-posit-1);
      repeat
         posit := pos('\',DoorName);
         if posit > 0 then
            DoorName := copy(DoorName, posit+1, 99);
      until posit = 0;

      inc(DOORs);
      add_item(FirstDoor, DoorName, 1);

      if pos('CHAT', Urec) > 0 then
         inc(nchat);
   end;


(* -------------------------------------------------------- *)
procedure DOSdrop;
   var
      DT1, DT2:   integer;
      a:          integer;

   begin
      val(copy(Urec, 34, 2), DT1, a); {exit to DOS time}

      getrec;
      val(copy(Urec, 27, 2), DT2, a); {back from DOS time}
      if a = 0 then 
      begin
         DT1 := (DT2-DT1);
         if DT1 < 0 then DT1 := DT1+60; {adjust for hour rollover}
         DosTime := DosTime+DT1;
      end;
      inc(DosTimes);
   end;


(* -------------------------------------------------------- *)
procedure sysop_chat;
   var
      DT1, DT2:   integer;
      a:          integer;
      node:       boolean;

   begin
      node := (Urec[7] = 'N');
      val(copy(Urec, 34, 2), DT1, a); {chat started time time}

      getrec;
      val(copy(Urec, 27, 2), DT2, a); {chat ended time}
      if a = 0 then 
      begin
         DT1 := (DT2-DT1);
         if DT1 < 0 then DT1 := DT1+60; {adjust for hour rollover}
      end;

      if node then
         inc(nchat)
      else
         inc(schat);
   end;


(* -------------------------------------------------------- *)
procedure system_event;
   var
      p: integer;
   begin
      p := pos(':',urec);
      if p > 0 then
         event_time := copy(urec,p-2,5)
      else
         event_time := '';
      inc(events);
   end;


(* -------------------------------------------------------- *)
procedure mins_used;
   var
      a, y, p:  integer;
      minutoff,
      houroff,
      timeused:  integer;

   begin
      p := pos(':', Urec)+2;
      y := p;
      while (Urec[y] >= '0') and (Urec[y] <= '9') do
         inc(y);
      val(copy(Urec, p, y-p), timeused, a);

      if clevel <> '' then
      begin
         add_item(FirstAveMins, clevel, timeused/60.0);
         clevel := '';
      end;

      getrec;
      val(copy(Urec, 11, 2), houroff, a);
      if houroff > 23 then
         houroff := houroff - 24;
      val(copy(Urec, 14, 2), minutoff, a);

      while timeused > 0 do
      begin
         if timeused > minutoff then
            a := minutoff
         else
            a := timeused;

         UsedMinutes := UsedMinutes + a;
         while UsedMinutes > 60 do
         begin
            inc(Hours);
            UsedMinutes := UsedMinutes - 60;
         end;

         Hrs[houroff] := Hrs[houroff]+a;
         timeused := timeused-a;

         if houroff > 0 then
            dec(houroff)
         else
            houroff := 23;
         minutoff := 60;
      end;
   end;


(* -------------------------------------------------------- *)
procedure catchall;
   begin
      if pos(' CHAT ', Urec)              > 0 then sysop_chat
      else if pos('LIVECHAT', Urec)       > 0 then inc(nchat)
      else if pos('SCHEDULED', Urec)      > 0 then system_event
      else if pos('OPENED DOOR ', Urec)   > 0 then pdoors
      else if pos('OINED', Urec)          > 0 then confjoin
      else if pos('MINUTES USED', Urec)   > 0 then mins_used
      else if pos('ACCESS DENIED', Urec)  > 0 then inc(tcan)
      else if pos('COMMENT ', Urec)       > 0 then inc(comments)
      else if pos('NOT REGISTERED', Urec) > 0 then inc(secviol)
      else if pos('OCK-', Urec)           > 0 then inc(lockouts)
      else if pos('PAGED', Urec)          > 0 then inc(sysop_paged)
      else if pos('QUESTIONNAIRE ', Urec) > 0 then inc(question)
      else if pos('REFUSED', Urec)        > 0 then inc(refused)
      else if pos('TIME LIMIT', Urec)     > 0 then inc(time_limit)
      else if pos('VIOLATION', Urec)      > 0 then inc(secviol)
      else if pos('LEFT:', Urec)          > 0 then inc(mssgs)
   end;


(* -------------------------------------------------------- *)
procedure scanrec;
   begin

      if Urec[1] <> ' ' then
         incaller
      else

      case Urec[7] of
         '*' :;

         '(':  if Urec[9] <> ')' then inc(stuff)
               else if Urec[8] = 'D' then indownload
               else if Urec[8] = 'U' then indownload
               else catchall;

         'A':  if pos('ACCESS DENIED', Urec)       > 0 then inc(tcan)
               else catchall;

         'B':  if pos('BULLETIN READ:', Urec)      > 0 then bulletins
               else if pos('BACK FROM DOS', Urec)  > 0 then inc(backdos)
               else catchall;

         'C':  if pos('COMMENT ', Urec)            > 0 then inc(comments)
               else if pos('CALLER EXITED ', Urec) > 0 then DOSdrop
               else if pos('CONNECT TYPE:',Urec)   > 0 then con_type
               else if pos('CALLER SECURITY',Urec) > 0 then sec_level
               else catchall;

         'D':  if pos('DIRECTORY SCAN ', Urec)     > 0 then inc(dirscan)
               else catchall;

         'E':  if pos('EXTRACT M', Urec)           > 0 then inc(extmember)
               else catchall;

         'F':  if pos('FILE (', Urec)              > 0 then inc(stuff)
               else if pos('FREE DOWNLOAD', Urec)  > 0 then pfree_down
               else catchall;

         'K':  if pos('KEYBOARD TIME',Urec)        > 0 then inc(stuff)
               else catchall;

         'I':  if pos('INSUFFICIENT ',Urec)        > 0 then inc(secviol)
               else if pos('INVALID ARC',Urec)     > 0 then inc(invalids)
               else if pos('INVALID ZIP',Urec)     > 0 then inc(invalids)
               else if pos('INVALID FIL',Urec)     > 0 then inc(invalids)
               else catchall;

         'M':  if pos('LEFT:', Urec)               > 0 then
               begin
                  inc(mssgs);
                  if pos('VIA QMAIL', Urec) > 0 then
                     inc(Qmssgs);
                  if pos('THRU MARKM', Urec) > 0 then
                     inc(Mmssgs);
               end
               else if pos('KILLED:', Urec)        > 0 then inc(kills)
               else if pos('MINUTES USED', Urec)   > 0 then mins_used
               else catchall;

         'N':  if pos('NODE CHAT ENT', Urec)       > 0 then sysop_chat
               else if pos('NODE CHAT END', Urec)  > 0 then inc(stuff)
               else catchall;

         'O':  if pos('OPERATOR', Urec)            > 0 then inc(sysop_paged)
               else if pos('OPENED DOOR ', Urec)   > 0 then pdoors
               else catchall;

         'P':  if pos('PASSWORD FAILURE', Urec)    > 0 then inc(pwfail)
               else catchall;

         'R':  if pos('REFUSED', Urec)             > 0 then inc(refused)
               else if pos('REGISTRATION', Urec)   > 0 then inc(new_guys)
               else if pos('REPACK ', Urec)        > 0 then inc(repacks)
               else if pos('REQUEST LIBRARY',Urec) > 0 then inc(libdisk)
               else catchall;

         'S':  if pos('SCHEDULED', Urec)           > 0 then system_event
               else if pos('SORRY', Urec)          > 0 then inc(secviol)
               else if pos('SYSOP CHAT A', Urec)   > 0 then sysop_chat
               else if pos('SYSOP CHAT E', Urec)   > 0 then inc(stuff)
               else if pos('SECURITY LEVEL:',Urec) > 0 then sec_level
               else catchall;

         'T':  if pos('TIME LIMIT', Urec)          > 0 then inc(time_limit)
               else if pos('REGISTRATION', Urec)   > 0 then inc(new_guys)
               else if pos('TEST EXECUTED', Urec)  > 0 then inc(testexec)
               else if pos('THANKS, ', Urec)       > 0 then inc(secviol)
               else catchall;

         'V':  if pos('VIEW E', Urec)              = 7 then inc(viewexec)
               else if pos('VIEW M', Urec)         = 7 then inc(viewmember)
               else catchall;

         'Z':  if pos('ZIPM EXE', Urec)            > 0 then inc(zipmail)
               else catchall;

         '0'..'9':
               if pos(' FILES,',Urec)              > 0 then batch
               else if pos(' MESSAGES ',Urec)      > 0 then zipmsgs
               else catchall;
         else
               catchall;
      end;
   end;


(* -------------------------------------------------------- *)
function rec_time(rec: anystring): anystring;
var
   temp: anystring;

begin      {12345678901234}
           {yy-mm-dd hh:mm};
   temp := '00-00-00 00:00';

   if length(rec) > 15 then
   begin
      temp[1] := rec[7];
      temp[2] := rec[8];

      temp[4] := rec[1];
      temp[5] := rec[2];

      temp[7] := rec[4];
      temp[8] := rec[5];

      temp[10] := rec[11];
      temp[11] := rec[12];
      temp[13] := rec[14];
      temp[14] := rec[15];
   end;

   rec_time := temp;
end;


(* -------------------------------------------------------- *)
procedure jdate(rec: string; var dt: real);
var
   a,mostr,daystr,yrstr:   word;
   frac:                   real;
   days:                   real;
   hours:                  real;

begin
   {12345678901234}
   {yy-mm-dd hh:mm}

   val( copy(rec, 4, 2), mostr, a);   {get month}
   days := finday(mostr);

   val(copy(rec, 7, 2), daystr, a);   {get day}

   val(rec[2], YrStr, a);             {last digit of year}
   if YrStr < 8 then
      inc(YrStr,10);

   val(copy(rec, 10, 2), hours, a);   {hour digit of logon}
   if hours > 23 then
      hours := hours - 24;

   val(copy(rec, 13, 2), frac, a);
   frac := frac/60;

   dt := hours + (yrstr*365+days+daystr) * 24 + frac;
end;


(* -------------------------------------------------------- *)
procedure scanfile(node: integer);
   var
      tx1:     string[20];
      tx:      anystring;
      nrec:    word;

   begin
      nrec := 0;

      while not eof(ifd) do
      begin
         scanrec;

         inc(nrec);
         if (nrec mod 50) = 1 then
         begin
            str((int(nrec)/int(logsize)*100.0):  5:  1, tx1);
            tx1 := 'Working ... '+tx1+' %';
            print(2, 17, tx1, ansicrt.lightred);
         end;

         getrec;
      end;

      close(ifd);

      tx1 := 'Working ... 100.0 %';
      print(2, 17, tx1, ansicrt.cyan);

      if rec_time(last_rec_seen) > rec_time(last_rec) then
         last_rec := last_rec_seen;
      last_entry := rec_time(last_rec);
      print(2, 23, 'Last log entry:  '+last_rec, ansicrt.lightgreen);
      jdate(last_entry,end_hours);

      {determine the period involved}
      PeriodCovered := 'Period covered:  From '+first_entry+' to '+last_entry;
      print(2, 21, PeriodCovered, ansicrt.lightmagenta);

      if node = nodes then
      begin
         TotHours := (end_hours-beg_hours) * nodes;
         str(TotHours:  5:  1, TX);
         TX := concat('Total Hours of Operation: ', TX);
         print(2, 19, TX, ansicrt.white);
      end;
   end;


(* -------------------------------------------------------- *)
procedure openfiles(node: integer);
   var
      TX:   string[62];
      name: anystring;
      a:    integer;
      fd:   dos_handle;

   begin
      stoupper(inName);
      if (node > 0) and (inName <> 'NUL') then
         TX := itoa(node)
      else
         TX := '';
      name := InName + TX;

      if name <> 'NUL' then
         print(1,1,'Reading '+name+' ...',ansicrt.white);
      clreol;

      fd := dos_open(name,open_read);
      if ioresult = dos_error then
      begin
         writeln('Cant open caller file: ',name);
         halt(1);
      end;

      dos_lseek(fd,0,seek_end);
      logsize := dos_tell div 64;
      dos_close(fd);

      TX := 'Total Records in the Callers file: '+wtoa(logsize);
      print(2, 20, TX, ansicrt.yellow);

      assignText(ifd,name);
      {$i-} reset(ifd); {$i+}
      if ioresult <> 0 then
      begin
         writeln('Cant open caller file: ',name);
         halt(1);
      end;

      SetTextbuf(ifd,iobuf);

      {decode the beginning of the logfile}
      repeat
         getrec;
      until (Urec[3] = '-') or eof(ifd);

      if (not eof(ifd)) then
         if (first_rec = '') or (rec_time(first_rec) > rec_time(Urec)) then
            first_rec := Urec;

      first_entry := rec_time(first_rec);
      print(2, 22, 'First log entry: '+first_rec, ansicrt.lightgreen);

      jdate(first_entry,beg_hours);
   end;



(* -------------------------------------------------------- *)
var
   line: string;
   xfd: text;

procedure write_list(node: ItemPointer);
begin
   while node <> nil do
   begin
      writeln(xfd,node^.name);
      writeln(xfd,node^.count);
      node := node^.next;
   end;
   writeln(xfd);
end;


(* -------------------------------------------------------- *)
procedure write_tree(node: FilePointer);
begin
   if node = nil then
      writeln(xfd)
   else
   begin
      writeln(xfd,node^.name);
      writeln(xfd,node^.size,' ',node^.count);
      write_tree(node^.higher);
      write_tree(node^.lower);
   end;
end;


(* -------------------------------------------------------- *)
procedure read_list(var node: ItemPointer);
var
   add:  ItemPointer;

begin
   {special case - empty list}
   Qreadln(xfd,line,sizeof(line));
   repeat
      if length(line) = 0 then
      begin
         node := nil;
         exit;
      end;
      if line[1] = ' ' then
         delete(line,1,1);
   until line[1] <> ' ';

   {insert head of list}
   new(node);
   add := node;
   add^.name := line;
   readln(xfd,add^.count);

   {add rest of the list}
   Qreadln(xfd,line,sizeof(line));
   while length(line) <> 0 do
   begin
      new(add^.next);
      add := add^.next;
      add^.name := line;
      readln(xfd,add^.count);

      Qreadln(xfd,line,sizeof(line));
   end;

   add^.next := nil;
end;


(* -------------------------------------------------------- *)
procedure read_tree(var node: FilePointer);
begin
   Qreadln(xfd,line,sizeof(line));
   if length(line)=0 then
      node := nil
   else
   begin
      new(node);
      node^.name := line;
      read(xfd,node^.size);
      readln(xfd,node^.count);
      read_tree(node^.higher);
      read_tree(node^.lower);
   end;
end;


(* -------------------------------------------------------- *)
procedure save_state;
var
   i: integer;

begin
   stoupper(saveFile);
   if saveFile = 'NUL' then
      exit;

   print(1,1,'Writing '+saveFile+' ...',ansicrt.white);
   clreol;

   assign(xfd,saveFile);
   rewrite(xfd);
   SetTextbuf(xfd,iobuf);

   writeln(xfd,'-7');

   writeln(xfd,spare1);
   writeln(xfd,spare2);
   writeln(xfd,spare3);
   writeln(xfd,spare4);
   writeln(xfd,event_mins);
   writeln(xfd,event_time);

   writeln(xfd,copy(last_rec,1,62));

   writeln(xfd,
           Qmssgs,' ',
           libdisk,' ',
           spare13);

   writeln(xfd,
           zipmail,' ',
           msgcount,' ',
           invalids,' ',
           spare6,' ',
           spare7,' ',
           spare8,' ',
           nchat,' ',
           spare9,' ',
           testexec,' ',
           free_down);

   writeln(xfd,
           viewexec,' ',
           spare15,' ',
           spare11,' ',
           spare14,' ',
           spare16,' ',
           spare12,' ',
           backdos,' ',
           batchs);

   writeln(xfd,
           Mmssgs,' ',
           blts,' ',
           caller,' ',
           schat,' ',
           comments,' ',
           dirscan,' ',
           DOORs,' ',
           DosTime);

   writeln(xfd,
           DosTimes,' ',
           down,' ',
           d_abort,' ',
           events,' ',
           even_parity,' ',
           extmember,' ',
           graphics,' ',
           Hours);

   writeln(xfd,
           joins,' ',
           kills,' ',
           lockouts,' ',
           UsedMinutes,' ',
           mssgs,' ',
           new_guys,' ',
           non_graphics,' ',
           sysop_paged);

   writeln(xfd,
           pwfail,' ',
           question,' ',
           repacks,' ',
           refused,' ',
           secviol,' ',
           stuff,' ',
           sysop_local,' ',
           sysop_remote);

   writeln(xfd,
           tcan,' ',
           time_limit,' ',
           TotHours:0:2,' ',
           UniqFiles,' ',
           up,' ',
           u_abort,' ',
           viewmember);

   writeln(xfd,copy(first_rec,1,62));

   for i := 1 to ProtocolCount do
   with Protocol[i] do
      writeln(xfd,
                 code,' ',
                 Uploads,' ',
                 UpTime:0:2,' ',
                 UpIdeal:0:2,' ',
                 Downloads,' ',
                 DownTime:0:2,' ',
                 DownIdeal:0:2);

   for i := 0 to 23 do
      writeln(xfd,Hrs[i]);

   write_list(FirstAvemins);
   write_list(FirstSpare3);
   write_list(FirstSpare4);
   write_list(FirstSpare5);
   write_list(FirstSpare6);
   write_list(FirstSpare7);
   write_list(FirstSpare8);

   write_list(FirstFreeDL);
   write_list(FirstConType);
   write_list(FirstSecLevel);
   write_list(FirstBaud);
   write_list(FirstBatch);
   write_list(FirstBullet);
   write_list(FirstConf);
   write_list(FirstDoor);

   write_tree(FileTree);

   close(xfd);
end;


(* -------------------------------------------------------- *)
procedure load_state;
var
   i: integer;
   n: integer;
   c: char;

begin
   assign(xfd,saveFile);
   {$i-} reset(xfd); {$i+}
   if ioresult <> 0 then
      exit;

   SetTextbuf(xfd,iobuf);
   print(1,1,'Loading '+saveFile+' ...',ansicrt.white);
   clreol;

   read(xfd,filever);
   if (filever <> -6) and (filever <> -7) then
   begin
      writeln('Can''t use your old ',saveFile,' file!  Will create a new one.');
      close(xfd);
      exit;
   end;

   readln(xfd, spare1);
   readln(xfd, spare2);
   readln(xfd, spare3);
   readln(xfd, spare4);
   readln(xfd, event_mins);
   readln(xfd, event_time);

   Qreadln(xfd,last_rec,sizeof(last_rec));

   read(xfd, Qmssgs, libdisk, spare13, zipmail, msgcount, invalids,
           spare6, spare7, spare8, nchat, spare9, testexec, free_down,
           viewexec, spare15, spare11, spare14, spare16, spare12,
           backdos, batchs, Mmssgs, blts, caller, schat, comments,
           dirscan, DOORs, DosTime, DosTimes, down, d_abort, events,
           even_parity, extmember, graphics, Hours, joins, kills,
           lockouts, UsedMinutes, mssgs, new_guys, non_graphics,
           sysop_paged, pwfail, question, repacks, refused, secviol,
           stuff, sysop_local, sysop_remote, tcan, time_limit, TotHours,
           UniqFiles, up, u_abort);

   readln(xfd, viewmember);

   Qreadln(xfd,first_rec,sizeof(first_rec));

   if filever = -6 then
      n := OldProtocolCount
   else
      n := ProtocolCount;
   for i := 1 to n do
   with Protocol[i] do
      readln(xfd, code, Uploads, UpTime, UpIdeal,
                        Downloads, DownTime, DownIdeal);

   for i := 0 to 23 do
      readln(xfd,Hrs[i]);

   read_list(FirstAvemins);

   read_list(FirstSpare3);
   read_list(FirstSpare4);
   read_list(FirstSpare5);
   read_list(FirstSpare6);
   read_list(FirstSpare7);
   read_list(FirstSpare8);

   read_list(FirstFreeDL);
   read_list(FirstConType);
   read_list(FirstSecLevel);

   read_list(FirstBaud);
   read_list(FirstBatch);
   read_list(FirstBullet);
   read_list(FirstConf);
   read_list(FirstDoor);

   read_tree(FileTree);

   close(xfd);

   write(^M);
   clreol;
end;


(* -------------------------------------------------------- *)
procedure usage;
begin
   writeln('Usage:   calls CONFIG_FILE');
   writeln('Example: calls calls.cnf');
   halt;
end;


(* -------------------------------------------------------- *)
procedure clean(var s: anystring);
begin
   while s[length(s)] = ' ' do
      dec(s[0]);         {skip trailing blanks}
   while copy(s,1,1) = ' ' do
      delete(s,1,1);     {skip leading blanks}
end;


(* -------------------------------------------------------- *)
procedure define_protocol(par: anystring);
var
   k: integer;
begin
      for k := 1 to ProtocolCount do
      with Protocol[k] do
         if (Code = par[1]) then
            name := copy(par,3,255);
end;


(* -------------------------------------------------------- *)
procedure set_event_mode(par: anystring);
begin
   if (par = 'OFF') or (par = 'BUSY') or (par = 'IDLE') then
      event_mode := par
   else
   begin
      writeln('Invalid EVENTMODE parameter: ',par);
      writeln('Must be one of:  OFF BUSY IDLE');
      halt(1);
   end;
end;


(* -------------------------------------------------------- *)
procedure load_configuration;
var
   fd:   text;
   cmd:  anystring;
   par:  anystring;
   p:    integer;

begin
   if paramcount < 1 then
      usage;

   assignText(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open config file: ',paramstr(1));
      halt;
   end;

   while not eof(fd) do
   begin
      readln(fd,cmd);

      p := pos(';',cmd);      {skip       ;comments}
      if p > 0 then
         cmd[0] := chr(p-1);

      clean(cmd);

      p := pos(' ',cmd);
      if p = 0 then
         par := ''
      else
      begin
         par := copy(cmd,p+1,255);
         cmd[0] := chr(p-1);
         clean(cmd);
         clean(par);
      end;

      stoupper(cmd);

      if (cmd = 'INFILE')        then  inName := par

      else if (cmd = 'OUTFILE')  then  outFile := par

      else if (cmd = 'SAVEFILE') then  saveFile := par

      else if (cmd = 'SUBTITLE') then  subTitle := par

      else if (cmd = 'NODES')    then  val(par,nodes,p)

      else if (cmd = 'REPORTS')  then  reports := par

      else if (cmd = 'MINDL')    then  val(par,min_download,p)

      else if (cmd = 'PEAK')     then  PeakTable := par

      else if (cmd = 'MAXCONF')  then  val(par,maxConf,p)

      else if (cmd = 'MAXBLT')   then  val(par,maxBlt,p)

      else if (cmd = 'MAXDOOR')  then  val(par,maxDoor,p)

      else if (cmd = 'MAXBATCH') then  val(par,maxBatch,p)

      else if (cmd = 'MAXFREE')  then  val(par,maxFree,p)

      else if (cmd = 'PROTOCOL') then  define_protocol(par)

      else if (cmd = 'EVENTMODE') then set_event_mode(par)

      else if (cmd <> '') then
      begin
         writeln('Invalid config keyword: ',cmd,' ',par);
         writeln;
         writeln('Each config line must start with one of these words:');
         writeln('   INFILE OUTFILE SAVEFILE NODES REPORTS MINDL PEAK');
         writeln('   MAXCONF MAXBLT MAXDOOR MAXBATCH PROTOCOL EVENTMODE');
         halt(1);
      end;
   end;

   stoupper(inName);
   close(fd);
end;


(* -------------------------------------------------------- *)
procedure init;            {initialize}
   begin
      runtime := 0;
      start_time := Time;

      load_configuration;

      clrscr;
      print(13,  5, 'ษอออออออออออออออออออออออออออออออออออออออออออออออออออออป', lightred);
      print(13,  6, 'บ                                                     บ', lightred);
      print(13,  7, 'บ                                                     บ', lightred);
      print(13,  8, 'บ                                                     บ', lightred);
      print(13,  9, 'บ                                                     บ', lightred);
      print(13, 10, 'บ                                                     บ', lightred);
      print(13, 11, 'บ                                                     บ', lightred);
      print(13, 12, 'บ                                                     บ', lightred);
      print(13, 13, 'บ                                                     บ', lightred);
      print(13, 14, 'บ                                                     บ', lightred);
      print(13, 15, 'ศอออออออออออออออออออออออออออออออออออออออออออออออออออออผ', lightred);

      print(32, 7, pcbversion, lightgreen);
      print(25, 9,  '     Calls v'+version+', '+reldate, lightgreen);
      print(25, 10, '     (c) 1987  Warren Lauzon', lightcyan);
      print(25, 12, '   Modified by Samuel H. Smith',ansicrt.white );
      gotoxy(1,1);
   end;


(* -------------------------------------------------------- *)
var
   node: integer;

begin
   init;
   load_state;

   if nodes = 1 then
   begin
      openfiles(0);
      scanfile(1);
   end
   else

   for node := 1 to nodes do
   begin
      openfiles(node);
      scanfile(node);
   end;

   Endtime := Time;
   runtime := Endtime-start_time;

   gotoxy(30, 17);
   writeln('Elapsed Time:  ', runtime:  6:  1);

   output_results(outfile+'G');

   {disable colors and repeat for non-g file}
   red := '';
   green := '';
   yellow := '';
   blue := '';
   magenta := '';
   cyan := '';
   white := '';
   gray := '';
   output_results(outfile);

   save_state;
   gotoxy(1, 25);
   textcolor(LightGray);
end.

