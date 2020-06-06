
(*
 * Reward      - Generate a report of the top uploaders
 *               and Reward them with a special security level
 *               for PCBoard 14.x
 *
 * (C) 1989-1992 Samuel H. Smith, 17-sep-89 (rev. 29-Feb-92)
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Panorama City CA
 *         (818) 891-4228
 *
 *
 * Disclaimer
 * ----------
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (818) 891-4228.
 *
 * Enjoy!     Samuel H. Smith
 *
 *)

{$DEFINE PCB14}

{$r-,s-}             (* enable range checking *)
{$v-}                (* allow variable length string params *)
{$M 50000,0,0}       {Stack, minheap, maxheap}


uses OpenShare,BufIO,Tools;

const
   version = 'v1.2';
   revdate = '03-13-92';
   pcb_version = '14.x';
   max_reward = 500;    {maximum number of users to reward}
   max_level = 100;     {maximum number of security level pairs in config}

type
   {yymmdd dates}
   yymmdd = char6;

   {level pair record}
   level_pair = record
      normal:  integer;
      bonus:   integer;
   end;

   {uploader information record}
   user_rec = record
      usernum:     word;
      name:        string[25];
      city:        string[25];
      date:        yymmdd;
      uploads:     word;
      level:       byte;
   end;

   {layout of the USERS file in PCBoard 14.x}
   pcb_user_rec = record
    {1  }name:          char25;
    {26 }city:          char24;
    {50 }passwd:        char12;         {no spaces allowed}
    {62 }busphone:      char13;
    {75 }phone:         char13;
    {88 }date:          yymmdd;         {yymmdd of last call}
    {94 }time:          char5;          {hh:mm  of last call}
    {99 }expert:        char;           {pcboard expert status Y or N}
    {100}protocol:      char;           {X, C, Y, N}
    {101}space1:        char;           {space - reserved}
    {102}filedate:      yymmdd;         {yymmdd of last file directory}
    {108}level:         byte;           {security level}
    {109}total_calls:   integer;        {number of times on system}
    {111}pagelen:       byte;           {page length}
    {112}uploads:       integer;        {number of uploads}
    {114}downloads:     integer;        {number of downloads}
    {116}downbytes:     double;         {daily download bytes so far}
    {124}usercomment:   char30;         {user entered comment field}
    {154}sysopcomment:  char30;         {sysop maintained comment field}
    {184}lastused:      integer;        {minutes used so far today}
    {186}expdate:       yymmdd;         {yymmdd expiration date}
    {192}explevel:      byte;           {expired security level}
    {193}curconf:       byte;           {current conference number}
    {194}conferences:   bitmap;         {area registration 1-39 (5 bytes)}
    {199}expconf:       bitmap;         {expired conference registration}
    {204}scanconf:      bitmap;         {user configured scan conferences}
    {209}downtotal:     double;         {total bytes downloaded, all calls}
    {217}uptotal:       double;         {total bytes uploaded, all calls}
    {225}dead:          char;           {positive delete flag, Y or N}

    {226}lastread:      array[0..39] of single;
                                        {last message pointer, main+39 conf's}

    {386}reserved:      char5;          {reserved for future use}

(*
 * THE FOLLOWING USERS FILE BYTES ARE TAKEN OVER BY PRODOOR
 * FOR STORAGE OF PRODOOR-SPECIFIC DATA FOR A USER.  OTHER DOOR
 * PROGRAMS SHOULD TAKE CARE TO NOT CONFLICT WITH THESE BYTE
 * POSITIONS!
 *)
    {391}extrarec:      word;           {record number for extra user record}

    {393}flags:         byte;           {prodoor user flag bits}

    {394}mailconf:      byte;           {conference user has mail in}
    {395}scratchnum:    byte;           {scratch file number - incremented for
                                         each use of a scratch file}
    {396}dooruse:       byte;           {times in prodoor, up to 255}
    {397}earned_k:      word;           {prodoor; earned kbytes}


    {399}reserve3:      word;           {used by qmail??}
    {total size: 400}
   end;


(* ----------------------------------------------------------- *)

{config file variables}
var
   headerfn:   filenames;
   trailerfn:  filenames;
   bltfn:      filenames;
   logfn:      filenames;
   userfn:     filenames;
   num_reward: integer;
   level:      array[1..max_level] of level_pair;
   levels:     integer;

{report files}
var
   logfd:      text;
   bltfd:      text;

{working storage}
var
   reward:     array[1..max_reward] of user_rec;
   rewards:    integer;

   usr:        pcb_user_rec;
   usrlevel:   integer;


(* ----------------------------------------------------------- *)
procedure load_config;
var
   fd:   text;
   i:    integer;
begin
   if paramcount <> 1 then
   begin
      writeln('Usage:   reward CONFIG_FILE');
      writeln('Example: reward reward.cnf');
      halt;
   end;

   assignText(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open config file: ',paramstr(1));
      halt;
   end;

   readln(fd,headerfn);
   readln(fd,trailerfn);
   readln(fd,bltfn);
   readln(fd,logfn);
   readln(fd,userfn);
   readln(fd,num_reward);

   readln(fd,levels);
   for i := 1 to levels do
      readln(fd,level[i].normal,level[i].bonus);

   close(fd);
end;

(* ----------------------------------------------------------- *)
function yymmdd_date: string6;
begin
   yymmdd_date := system_yy+system_mm+system_dd;
end;


(* ----------------------------------------------------------- *)
function expired: boolean;
begin
   expired := (usr.expdate <> '000000') and (usr.expdate < yymmdd_date);
end;


(* ----------------------------------------------------------- *)
procedure getlevel;
begin
   if expired then
      usrlevel := usr.explevel
   else
      usrlevel := usr.level;
end;


(* ----------------------------------------------------------- *)
procedure setlevel(level: integer);
begin
   if expired then
      usr.explevel := level
   else
      usr.level := level;
   usrlevel := level;
end;


(* ----------------------------------------------------------- *)
function expand_date(date: yymmdd): string8;
   {convert yymmdd to mm-dd-yy}
const
   tmp:  string8 = '  -  -  ';
begin
   tmp[1] := date[3];
   tmp[2] := date[4];
   tmp[4] := date[5];
   tmp[5] := date[6];
   tmp[7] := date[1];
   tmp[8] := date[2];
   expand_date := tmp;
end;


(* ----------------------------------------------------------- *)
function level_included(lev: integer; var entry: integer): boolean;
var
   i:       integer;

begin
   for i := 1 to levels do
      if (level[i].normal = lev) or (level[i].bonus = lev) then
      begin
         level_included := true;
         entry := i;
         exit;
      end;

   level_included := false;
end;


(* ----------------------------------------------------------- *)
procedure determine_rewards;
var
   fd:      buffered_file;
   entry:   integer;
   cnt:     word;

   procedure insert_user;
   var
      rec:  user_rec;
      i:    integer;
      j:    integer;

   begin
      if usr.uploads = 0 then
         exit;

      rec.usernum := btell(fd);
      rec.name := usr.name;
      rec.city := usr.city;
      rec.uploads := usr.uploads;
      rec.date := usr.date;
      rec.level := usrlevel;

      i := rewards;
      while (i > 0) and (usr.uploads > reward[i].uploads) do
         dec(i);

      if rewards = num_reward then
      begin
         if i = rewards then
            exit;
         for j := rewards-1 downto i+1 do
            reward[j+1] := reward[j];
      end
      else
      begin
         for j := rewards downto i+1 do
            reward[j+1] := reward[j];
         inc(rewards);
      end;

      reward[i+1] := rec;
   end;

begin
   bopen(fd,userfn,50,sizeof(usr));
   if berr then
   begin
      writeln('Can''t open user file ',userfn);
      halt;
   end;

   writeln('Scanning ',userfn);
   cnt :=0;
   rewards := 0;

   while not berr do
   begin
      inc(cnt);
      if (cnt mod 64) = 0 then
         write(cnt:7,' users'^M);

      bread(fd,usr);
      getlevel;

      if level_included(usrlevel,entry) then
         insert_user;
   end;

   bclose(fd);

   writeln(cnt:7,' users scanned.');
   writeln;

   writeln(logfd,'   ',cnt,' user records scanned, ',rewards,' will be rewarded for uploads.');
end;


(* ----------------------------------------------------------- *)
procedure give_rewards;
var
   fd:      buffered_file;
   rec:     word;
   upd:     word;
   entry:   integer;
   changed: boolean;

   procedure report_change( var fd: text; why: string);
   begin
      write(fd,'   ',usr.name,' ',usr.uploads:4,' U/L   ',why,' ',usrlevel);
      if expired then
         write(fd,' (exp ',usr.level,' ',expand_date(usr.expdate),')');
      writeln(fd);
   end;

   procedure update_user;
   var
      i: integer;
   begin
      changed := false;

      for i := 1 to rewards do
         if reward[i].usernum = rec then
         begin
            if usrlevel = level[entry].normal then
            begin
               setlevel(level[entry].bonus);

               report_change(logfd,'upgraded to');
               report_change(output,'upgraded to');
               changed := true;
            end
            else

            begin
               {report_change(logfd,' remains at');}
               report_change(output,'remains at');
            end;

            exit;
         end;


      {not in reward list, downgrade if needed}
      if usrlevel = level[entry].bonus then
      begin
         setlevel(level[entry].normal);
         report_change(logfd,'returned to');
         report_change(output,'returned to');
         changed := true;
      end;
   end;

begin
   bopen(fd,userfn,50,sizeof(usr));
   if berr then
   begin
      writeln('Can''t reopen user file ',userfn);
      halt;
   end;

   writeln('Updating ',userfn);
   upd := 0;

   while not berr do
   begin
      bread(fd,usr);
      getlevel;

      rec := btell(fd);

      if level_included(usrlevel,entry) then
      begin
         update_user;

         if changed then
         begin
            bseek(fd,rec-1);
            bwrite(fd,usr);
            inc(upd);
         end;
      end;

      if (rec mod 64) = 0 then
         write(rec:7,' users, ',upd,' updated.'^M);
   end;

   bclose(fd);
   writeln(rec:7,' users, ',upd,' updated.'^M);
   writeln(logfd,'   ',upd,' user records updated.');
   writeln;
end;


(* ----------------------------------------------------------- *)
procedure append_text(var fd: text; fn: filenames);
var
   ifd:  text;
   line: string;
begin
   assignText(ifd,fn);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t access text file: ',fn);
      exit;
   end;

   while not eof(ifd) do
   begin
      readln(ifd,line);
      writeln(fd,line);
   end;

   close(ifd);
end;


(* ----------------------------------------------------------- *)
procedure generate_blt;
var
   i: integer;
begin
   writeln('Generating ',bltfn);
   assignText(bltfd,bltfn);
   rewrite(bltfd);
   append_text(bltfd,headerfn);

   writeln(bltfd);
   writeln(bltfd,'  User Name               Calling From             Last On   # of UL''s  Level');
   writeln(bltfd,'  _________               ____________             ________  _________  _____');
   writeln(bltfd);

   for i := 1 to rewards do
   with reward[i] do
      writeln(bltfd,'  ',
                  copy(name,1,23):23,' ',
                  copy(city,1,23):23,'  ',
                  expand_date(date):8,' ',
                  uploads:8,
                  level:8);

   append_text(bltfd,trailerfn);
   close(bltfd);
end;


(* ----------------------------------------------------------- *)
procedure open_reports;
begin
   assignText(logfd,logfn);
   append(logfd);
   writeln(logfd,system_date,' ',system_time,' Reward ',version,' Execution Log');
end;


(* ----------------------------------------------------------- *)
procedure close_reports;
begin
   writeln(logfd,system_date,' ',system_time,' Reward Run Ended');
   writeln(logfd,'---------------------------------------------------');
   close(logfd);
   writeln('Reward Run Ended.');
end;



(* ----------------------------------------------------------- *)
(*
 * main program
 *
 *)

begin
   writeln;
   writeln('Reward ',version,' of ',revdate,' for PCBoard ',pcb_version);
   writeln('Copyright 1992 Samuel H. Smith;  Courtesy of The Tool Shop, (818) 891-6780');
   writeln;

   load_config;         {load config file, build list of levels
                         reward/normal to work with}

   open_reports;

   determine_rewards;   {pass through user file and build list of users
                         in configured security levels, keeping only the
                         top uploaders in the list}

   give_rewards;        {pass through user file again, addigning top
                         uploaders to reward level and returning others
                         to the normal level}

   generate_blt;

   close_reports;
end.

