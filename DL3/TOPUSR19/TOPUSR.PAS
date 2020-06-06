
(*
 * TopUser     - Generate a report of the top uploaders and downloaders.
 *               for PCBoard 12.0
 *
 * (C) 1987 Samuel H. Smith, 04-oct-87 (rev. 24-Nov-87)
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Phoenix, Az
 *         (602) 279-2673
 *
 * This program uses many of the building-blocks in the Tool Shop Library,
 * which is available for download from the Tool Shop.   
 *
 *
 * Disclaimer
 * ----------
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

{$DEFINE PCB14}

{$r-,s-}             (* enable range checking *)
{$v-}                (* allow variable length string params *)
{$M 50000,0,0}  {Stack, minheap, maxheap}

uses DOS,DosMem,BufIO;

const
   top_max = 120;     {max number of top users to report}
   cty_max = 4000;    {max number of top cities to report}

   version = 'v1.9, 04-03-90';
   pcb_version = '14.x';

type bitmap = array[1..5] of byte;  {stub}
     varstring = byte;
     single = array[0..3] of byte;

{$i \tinc\anystring.inc}
{$i \pro\proint.dcl}
{$i \tinc\atoi.inc}
{$i \tinc\stof.inc}
{$i \tinc\sysdate2.inc}


type
   city_rec = record
      city:        string[25];
      calls:       longint;
      uploads:     longint;
      downloads:   longint;
      users:       longint;
   end;

   city_ptr = ^city_rec;
   city_array = array[1..cty_max] of city_ptr;


   {binary version of user record}
   user_rec = record
      usernum:     integer;
      name:        string[25];
      city:        string[25];
      level:       integer;
      calls:       longint;
      uploads:     longint;
      downloads:   longint;
      confs:       integer;
      key:         longint;
   end;

   counter_table = record
      entry:   array[1..top_max] of user_rec;
      count:   integer;
      minkey:  longint;
   end;

   level_rec = record
      calls:       longint;
      uploads:     longint;
      downloads:   longint;
      users:       longint;
   end;


var
   ufd:        buffered_file;
   ofd:        text;

   user:       user_rec;
   users:      integer;

   top_ul:     counter_table;
   top_dl:     counter_table;
   top_cal:    counter_table;
   nomail:     counter_table;

   top_cty:    city_array;
   num_cty:    integer;

   top_limit:  integer;
   min_calls:  integer;
   max_level:  integer;
   reports:    string;

   levels:     array[0..255] of level_rec;


(* ----------------------------------------------------------- *)
procedure usage;
begin
   writeln('Usage:  TOPUSR userfile reportfile [usercount mincalls [maxlevel]] [reportlist]');
   writeln;
   writeln('Example 1: TOPUSR \pcb\main\users \pcb\gen\blt5');
   writeln;
   writeln('Example 2: TOPUSR \pcb\main\users \pcb\gen\blt5 20 5 120 ABCEDF');
   writeln('   Reads userfile \pcb\main\users,');
   writeln('   Creates report in \pcb\gen\blt5,');
   writeln('   Reporting the top 20 users,');
   writeln('   and all cities with at least 5 calls,');
   writeln('   Excluding all users with levels >120.');
   writeln('   Generates reports A, B, C, E, D and then F.');
   writeln;
   writeln('Report codes:');
   writeln('   A - Top Uploaders and Downloaders');
   writeln('   B - Most active users');
   writeln('   C - Callers who don''t read mail');
   writeln('   D - Most active cities');
   writeln('   E - Security level analysis report');
   writeln('   F - Sorted listing of cities');
   halt;
end;


(* ----------------------------------------------------------- *)
procedure init;
begin
   fillchar(top_cty,sizeof(top_cty),0);
   top_limit := 20;
   min_calls := 5;
   max_level := 120;
   reports := 'ABCEDF';

   if paramcount = 2 then
   begin
      {use defaults}
   end
   else

   if (paramcount >= 4) then
   begin
      top_limit := atoi(paramstr(3));
      if top_limit > top_max then
      begin
         writeln('Usercount must be less than ',top_max);
         usage;
      end;

      min_calls := atoi(paramstr(4));

      if paramcount >= 5 then
         max_level := atoi(paramstr(5));

      if paramcount = 6 then
         reports := paramstr(6)
      else
      if paramcount > 6 then
         usage;
   end
   else
      usage;


   bopen(ufd,paramstr(1),50,sizeof(pcb_user_rec));
   if berr then
   begin
      writeln('Can''t open user file');
      usage;
   end;

   top_ul.count := 0;
   top_dl.count := 0;
   top_cal.count := 0;
   nomail.count := 0;
   num_cty := 0;
   users := 0;
   fillchar(levels,sizeof(levels),0);
end;


(* ----------------------------------------------------------- *)
procedure get_user;
var
   pcb:    pcb_user_rec;
   cty:    anystring;
   i:      integer;

begin
   inc(users);

   if (users mod 20) = 0 then
      write(^M,users:5,' users');

   bread(ufd,pcb);
   user.name      := pcb.name;
   user.city      := pcb.city;
   user.level     := pcb.level;
   user.calls     := pcb.total_calls;
   user.uploads   := pcb.uploads;
   user.downloads := pcb.downloads;

   {normalize the city format}
   cty := user.city;
   for i := 1 to length(cty) do
      if (cty[i] = '.') or (cty[i] = ',') then
         cty[i] := ' ';

   i := pos('  ',cty);
   while i > 0 do
   begin
      delete(cty,i,1);
      i := pos('  ',cty);
   end;

   while cty[length(cty)] = ' ' do
      dec(cty[0]);

   user.city := cty;

   {count number of conferences the user is active in}
   user.confs := 0;
   for i := 0 to 39{max_conf} do
      if stof(pcb.lastread[i]) <> 0.0 then
         inc(user.confs);

   {keep track of counts by level}
   with levels[user.level] do
   begin
      inc(users);
      inc(calls,user.calls);
      inc(uploads,user.uploads);
      inc(downloads,user.downloads);
   end;
end;


(* ----------------------------------------------------------- *)
procedure process_count(var table:     counter_table);
var
   rep:  integer;
   i:    integer;

begin
   if user.key = 0 then
     exit;

   if table.count = 0 then
   begin
      table.count := 1;
      table.entry[1] := user;
      table.minkey := 0;
      exit;
   end;

   if user.key <= table.minkey then
      exit;

   rep := 0;
   for i := 1 to table.count do
      if (rep = 0) and (user.key > table.entry[i].key) then
      begin
         if table.count < top_limit then
            inc(table.count);
         rep := i;
      end;

   if (rep = 0) and (table.count < top_limit) then
   begin
      inc(table.count);
      rep := table.count;
   end;

   if rep <> 0 then
   begin
      for i := table.count downto rep+1 do
         table.entry[i] := table.entry[i-1];
      table.entry[rep] := user;
   end;

   if table.count = top_limit then
      table.minkey := table.entry[table.count].key;
end;


procedure process_uploads;
begin
   user.key := user.uploads;
   process_count(top_ul);
end;

procedure process_downloads;
begin
   user.key := user.downloads;
   process_count(top_dl);
end;

procedure process_calls;
begin
   user.key := user.calls;
   process_count(top_cal);
end;

procedure process_mail;
begin
   user.key := (user.calls*1000) div (user.confs*20+1);
   process_count(nomail);
end;


(* ----------------------------------------------------------- *)
procedure process_cities;
var
   i:    integer;
begin
   for i := 1 to num_cty do
      if top_cty[i]^.city[1] = user.city[1] then
      if top_cty[i]^.city = user.city then
      begin
         inc(top_cty[i]^.calls,user.calls);
         inc(top_cty[i]^.uploads,user.uploads);
         inc(top_cty[i]^.downloads,user.downloads);
         inc(top_cty[i]^.users);
         exit;
      end;

   if num_cty < cty_max then
   begin
      inc(num_cty);
      dos_getmem(top_cty[num_cty],sizeof(city_rec));
   end
   else
      writeln(^M'No room for: ',user.city,'   ');

   top_cty[num_cty]^.city := user.city;
   top_cty[num_cty]^.calls := user.calls;
   top_cty[num_cty]^.uploads := user.uploads;
   top_cty[num_cty]^.downloads := user.downloads;
   top_cty[num_cty]^.users := 1;
end;


(* ----------------------------------------------------------- *)
procedure report_transfers;
var
   i: integer;
   n: integer;
begin
   writeln('Reporting Top Uploaders.');

   n := top_ul.count;
   if top_dl.count > n then
      n := top_dl.count;

   writeln(ofd);
   writeln(ofd,'        Top',top_ul.count:4,' uploaders                         Top',top_dl.count:4,' downloaders');
   writeln(ofd,'User Name                 U/L  D/L        User Name                 U/L  D/L');
   writeln(ofd,'------------------------  ---  ---        ------------------------  ---  ---');

   for i := 1 to n do
   begin
      if i > top_ul.count then
         write(ofd,'':42)
      else
         write(ofd,top_ul.entry[i].name,
                   top_ul.entry[i].uploads:4,
                   top_ul.entry[i].downloads:5,'':8);

      if i <= top_dl.count then
         write(ofd,top_dl.entry[i].name,
                   top_dl.entry[i].uploads:4,
                   top_dl.entry[i].downloads:5);

      writeln(ofd);
   end;
end;


(* ----------------------------------------------------------- *)
procedure report_table(title: string; var table: counter_table);
var
   i: integer;

begin
   writeln(ofd);
   writeln(ofd);
   writeln(ofd,'':(77-length(title)) div 2,table.count:2,' ',title);
   writeln(ofd,'User Name                City                       Calls   U/L    D/L   Confs');
   writeln(ofd,'-----------------------  -------------------------  -----  -----  -----  -----');

   for i := 1 to table.count do
   begin
      writeln(ofd,table.entry[i].name,
                  table.entry[i].city,'':24-length(table.entry[i].city),
                  table.entry[i].calls:7,
                  table.entry[i].uploads:7,
                  table.entry[i].downloads:7,
                  table.entry[i].confs:7);
   end;
end;


(* ----------------------------------------------------------- *)
procedure report_calls;
begin
   writeln('Reporting Most Active Callers.');
   report_table('most active callers',top_cal);
end;

procedure report_nomail;
begin
   writeln('Reporting Least Active Mail Readers.');
   report_table('callers who read the least mail',nomail);
end;


(* ----------------------------------------------------------- *)
procedure sort_cities_by_calls;
   {sort top cities with shell sort}
var
   x:       integer;
   gap:     integer;
   temp:    city_ptr;
   diff:    longint;
   noswaps: boolean;

begin
   gap := num_cty div 2;

   repeat

      repeat
         noswaps := true;

         for x := 1 to num_cty-gap do
         begin
            diff := top_cty[x+gap]^.calls - top_cty[x]^.calls;
            if diff = 0 then
               diff := ord(top_cty[x]^.city[1]) - ord(top_cty[x+gap]^.city[1]);
            if diff = 0 then
               if top_cty[x]^.city > top_cty[x+gap]^.city then
                  diff := 1
               else
               if top_cty[x]^.city < top_cty[x+gap]^.city then
                  diff := -1;

            if diff > 0 then
            begin
               temp := top_cty[x];
               top_cty[x] := top_cty[x+gap];
               top_cty[x+gap] := temp;
               noswaps := false;
            end;
         end;

      until noswaps;

      gap := gap div 2;

   until gap < 1;
end;


(* ----------------------------------------------------------- *)
procedure report_top_cities;
var
   i:          integer;
   lim:        integer;

begin
   writeln('Reporting Top Cities.');
   sort_cities_by_calls;

   lim := num_cty;
   if lim > top_limit then
      lim := top_limit;

   writeln(ofd);
   writeln(ofd);
   writeln(ofd,'':8,'             Top ',lim,' cities by number of calls');
   writeln(ofd,'':8,'City                       Users  Calls   U/L    D/L ');
   writeln(ofd,'':8,'-------------------------  -----  -----  -----  -----');

   for i := 1 to lim do
   begin
      writeln(ofd,'':8,top_cty[i]^.city,'':25-length(top_cty[i]^.city),
                       top_cty[i]^.users:7,
                       top_cty[i]^.calls:7,
                       top_cty[i]^.uploads:7,
                       top_cty[i]^.downloads:7);
   end;
end;


(* ----------------------------------------------------------- *)
procedure sort_cities_by_name;
   {sort cities with shell sort}
var
   x:       integer;
   gap:     integer;
   temp:    city_ptr;
   noswaps: boolean;

begin
   gap := num_cty div 2;

   repeat

      repeat
         noswaps := true;

         for x := 1 to num_cty-gap do
         begin

            if top_cty[x+gap]^.city < top_cty[x]^.city then
            begin
               temp := top_cty[x];
               top_cty[x] := top_cty[x+gap];
               top_cty[x+gap] := temp;
               noswaps := false;
            end;
         end;

      until noswaps;

      gap := gap div 2;

   until gap < 1;
end;


(* ----------------------------------------------------------- *)
procedure report_all_cities;
var
   i:        integer;

begin
   write('Sorting cities by Name of City.  ');
   sort_cities_by_name;

   writeln('Reporting Sorted List of Cities.');

   writeln(ofd);
   writeln(ofd);
   writeln(ofd,'':8,'             ',num_cty,' cities with at least ',min_calls,' calls');
   writeln(ofd,'':8,'City                       Users  Calls   U/L    D/L ');
   writeln(ofd,'':8,'-------------------------  -----  -----  -----  -----');

   for i := 1 to num_cty do
   begin
      writeln(ofd,'':8,top_cty[i]^.city,'':25-length(top_cty[i]^.city),
                       top_cty[i]^.users:7,
                       top_cty[i]^.calls:7,
                       top_cty[i]^.uploads:7,
                       top_cty[i]^.downloads:7);
   end;
end;


(* ----------------------------------------------------------- *)
procedure report_levels;
var
   i:       integer;

begin
   writeln('Reporting Security Level Analysis.');

   writeln(ofd);
   writeln(ofd);
   writeln(ofd,'':12,'            Security level analysis');
   writeln(ofd,'':12,'Security Level   Users   Calls    U/L     D/L ');
   writeln(ofd,'':12,'--------------   -----   -----   -----   -----');

   for i := 0 to max_level do
   if levels[i].users > 0 then
      writeln(ofd,'':12,i:8,'      ',
                       levels[i].users:8,
                       levels[i].calls:8,
                       levels[i].uploads:8,
                       levels[i].downloads:8);
end;


(* ----------------------------------------------------------- *)
(*
 * main program
 *
 *)

var
   i: integer;

begin
   writeln;
   writeln('Top Users ',version,' for PCB ',pcb_version);
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop, (602) 279-2673');
   writeln;

   init;

   get_user;

   while not beof(ufd) do
   begin
      get_user;

      if user.level <= max_level then
      begin
         process_uploads;
         process_downloads;
         process_calls;
         process_cities;
         process_mail;
      end;
   end;


   bclose(ufd);
   write(^M,'':60,^M);
   writeln('Processing completed on ',users,' user records');

   writeln('Sorting cities by Number of Calls.  ');
   sort_cities_by_calls;
   while (num_cty > 1) and (top_cty[num_cty]^.calls < min_calls) do
      dec(num_cty);

   assign(ofd,paramstr(2));
   {$i-} rewrite(ofd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open report output');
      usage;
   end;

   writeln(ofd);
   writeln(ofd,'                         Top Users and Cities Report' );
   writeln(ofd,'             Generated ',system_date,' ',system_time,' by Top Users ',version);

   for i := 1 to length(reports) do
      case upcase(reports[i]) of
         'A':  report_transfers;
         'B':  report_calls;
         'C':  report_nomail;
         'D':  report_top_cities;
         'E':  report_levels;
         'F':  report_all_cities;
      end;

   writeln(ofd);
   writeln(ofd,'Generated by Top Users ',version);
   writeln(ofd,'Courtesy of:  S.H.Smith  and  The Tool Shop, (602) 279-2673');
   writeln(ofd);
   close(ofd);
end.

