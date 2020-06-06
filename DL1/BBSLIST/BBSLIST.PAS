
(*
 * Copyright 1993 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)


{!!!IMPORTANT!!! F5 WON'T WORK WITHOUT THE FOLLOWING LINE}
{$M 9000,22000,22000}  {Stack, minheap, maxheap}
{$S-,R-}
{$L+,D+}


Program bbs_list;

Uses
   Dos,
   Crt,        {sound/nosound/delay}
   MiniCrt,    {BIOS-only crt functions}
   OpenShare,  {Shared text files}
   MdosIO,     {Dos-level random access files}
   BufIO,      {Buffered record i/o}
   qRead,      {Quick string qReadLn procedure}
   Tools,      {Various utilities}
   ProData,    {ProDoor/pcboard data}
   ProRoot,    {ProKit main support library}
   ProSysf,    {ProKit Status display, function keys, system functions}
   ProScan,    {File display and colorization}
   ProUtil,    {ProKit utility library #1}
   ProUtil2,   {proKit utility library #2}
   KitInit;    {ProKit initialization/deinit}

const
   door_version = 'BBS List Maintenance DOOR v1.0 (12/24/93)';
   bufcount = 50;
   introfile = 'BBSLIST.INT';
   listfile = 'BBSLIST.DAT';
   bakfile = 'BBSLIST.BAK';
   lockfile = 'BBSLIST.LCK';
   delete_flag = '*';

type
   char20 = array[1..20] of char;
   char21 = array[1..21] of char;
   char22 = array[1..22] of char;
   char23 = array[1..23] of char;
   char64 = array[1..64] of char;

   {layout of the master bbslist file}
   bbslist_rec = record  
      bbsphone:   char14;
      bbsname:    char23;
      bbsloc:     char20;
      bbssysop:   char25;
      bbstype:    char13;
      maxspeed:   char5;
      username:   char25;
      descr:      char64;
      revdate:    char6;
      crlf:       char2;
   end;

var
   listname:   string65;      {name/title of the bbslist}
   maxage:     word;          {maximum age of entries to be retained}
   bltfn:      string65;      {filename for "long" listing bulletin}
   bltfn2:     string65;      {filename for "short" listing bulletin}
   oldest:     char6;         {date of oldest listing to retain}
   rec:        bbslist_rec;   {current bbs listing record}
   uname:      char25;        {current username}

(* --------------------------------------------------------- *)
procedure error(s: string);
begin
   writeln(^G'ERROR: ',s);
end;

{$i msgio.inc}    {pcb 14 message i/o routines}

(* --------------------------------------------------------- *)
procedure format_header;
begin
   fillchar(header,sizeof(header),0);
   header.statusCode := '*';
   header.readTime := '     ';
   header.hasReplys := ' ';
   header.status := live_msg;
   header.echoFlag := ' ';
   ftos(0,header.number);
   ftos(0,header.referTo);
   ftos(0,header.readDate);
   fill_chars(header.date,system_date,8);
   fill_chars(header.time,system_time,5);
   header.whoTo := rec.username;
   fill_chars(header.whoFrom,'SYSOP',25);
   fill_chars(header.subject,'EXPIRED BBS LISTING',25);
end;

(* --------------------------------------------------------- *)
procedure leave_message;
begin
   lines[1] := 'Your BBS list entry was automatically purged because it has';
   lines[2] := 'been over '+itoa(maxage)+' days since you updated it.';
   lines[3] := 'Please open the BBSLIST door and re-enter your BBS ';
   lines[4] := 'information if you still wish to be listed.';
   lines[5] := 'Remember to open the BBSLIST door every month or so to';
   lines[6] := 'renew your listing and avoid being purged in the future.';
   lines[7] := '---';
   lines[8] := ' * ' + door_version;
   linecnt := 8;
   format_header;
   open_conference;
   write_message;
   close_conference;
end;

(* ---------------------------------------------------------------- *)
function date(yymmdd: string): string20;
var
   temp: string20;
begin
   temp := expdate(yymmdd);
   temp[3] := '/';
   temp[6] := '/';
   date := temp;
end;

(* ---------------------------------------------------------------- *)
function yesno(prompt: string): boolean;
begin

   repeat
      no_hotkeys;
      pdisp('$GREEN$'+prompt+' (YES/NO)? ');

      par := '';
      line_input(par,3,true,false);
      if dump_user then exit;
      cmdline := '';
      newline;
      par[1] := upcase(par[1]);

      ok := (par > '') and ((par[1] = 'Y') or (par[1] = 'N'));
      if not ok then
         pdispln('$WHITE$Please answer Y or N!');
   until ok;

   yesno := par[1] = 'Y';
end;

(* ------------------------------------------------------------ *)
procedure get_chars(prompt: string80;
                    var dest;
                    size: integer);
var
   i:    integer;
   src:  array[1..200] of char absolute dest;
   damp: integer;

begin
   {copy src to cmdline}
   cmdline[0] := chr(size);
   for i := 1 to size do
      cmdline[i] := src[i];
   delete_trailing_spaces(cmdline);

   damp := damp_count;
   dampen(0);

   repeat
      dampen(10);
      if dump_user then exit;

      disp_margin(length(prompt)+1,size);
      pdisp('$YELLOW$'+prompt+'? ');

      no_hotkeys;
      line_input(cmdline,size,true,false);
      newline;

   until (cmdline <> '');

   remove_variables(cmdline);
   fill_chars(dest,cmdline,size);

   damp_count := damp;
end;


(* ---------------------------------------------------------------- *)
procedure load_config;
var
   fd:         text;
   yy,mm,dd:   integer;
   i:          integer;
const
   monthdays:  array[1..12] of integer =
      (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

begin
   assignText(fd,config_file);
   {$i-} reset(fd); {$i+}
   ok := ioresult = 0;
   if not ok then
      file_missing(10000);

   readln(fd);
   readln(fd,listname);
   readln(fd,maxage);
   readln(fd,bltfn);
   readln(fd,bltfn2);
   close(fd);

   {determine purge date}
   fill_chars(oldest,todays_date_yymmdd,sizeof(oldest));
   yy := atoi(copy(oldest,1,2));
   mm := atoi(copy(oldest,3,2));
   dd := atoi(copy(oldest,5,2));

   for i := 1 to maxage do
   begin
      dec(dd);
      if dd < 1 then
      begin
         dec(mm);
         if mm < 1 then
         begin
            dec(yy);
            mm := 12;
         end;
         dd := monthdays[mm];
      end;
   end;

   oldest[1] := chr((yy div 10)+ord('0'));
   oldest[2] := chr((yy mod 10)+ord('0'));
   oldest[3] := chr((mm div 10)+ord('0'));
   oldest[4] := chr((mm mod 10)+ord('0'));
   oldest[5] := chr((dd div 10)+ord('0'));
   oldest[6] := chr((dd mod 10)+ord('0'));
end;

(* ---------------------------------------------------------------- *)
procedure update_bulletin;
var
   ifd:  buffered_file;
   bfd:  text;
   bfd2: text;
   temp: string80;

const
   dashes = '---------------------------------------------';

begin
   newline;
   pdispln('$WHITE$Updating BBS list bulletins ...');

   bopen(ifd,listfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;
   bseekeof(ifd);
   temp := itoa(btell(ifd))+' boards listed '+
           'as of '+date(todays_date_yymmdd)+' '+copy(system_time,1,5);
   bseek(ifd,0);

   assign(bfd,bltfn);
   {$i-}rewrite(bfd);{$i+}
   if ioresult <> 0 then
   begin
      make_log_entry('Rewrite('+bltfn+') failed!',false);
      assign(bfd,'nul');
      rewrite(bfd);
   end;

   assign(bfd2,bltfn2);
   {$i-}rewrite(bfd2);{$i+}
   if ioresult <> 0 then
   begin
      make_log_entry('Rewrite('+bltfn2+') failed!',false);
      assign(bfd2,'nul');
      rewrite(bfd2);
   end;

   writeln(bfd);
   writeln(bfd,'':40-(length(listname) div 2),listname);
   writeln(bfd,'':40-(length(temp) div 2),temp);
   writeln(bfd);

   writeln(bfd2);
   writeln(bfd2,'':40-(length(listname) div 2),listname);
   writeln(bfd2,'':40-(length(temp) div 2),temp);
   writeln(bfd2);

   fill_chars(rec.bbsphone,'PHONE',sizeof(rec.bbsphone));
   fill_chars(rec.bbsname,'BOARD NAME',sizeof(rec.bbsname));
   fill_chars(rec.bbsloc,'LOCATION',sizeof(rec.bbsloc));
   fill_chars(rec.bbstype,'BBS TYPE',sizeof(rec.bbstype));
   fill_chars(rec.maxspeed,'SPEED',sizeof(rec.maxspeed));
   writeln(bfd,rec.bbsphone,' ', rec.bbsloc,' ', rec.bbsname,' ',
               rec.bbstype,' ', rec.maxspeed);
   writeln(bfd2,rec.bbsphone,' ', rec.bbsloc,' ', rec.bbsname,' ',
               rec.bbstype,' ', rec.maxspeed);

   fill_chars(rec,' ',sizeof(bbslist_rec));
   fill_chars(rec.bbsphone,dashes,sizeof(rec.bbsphone));
   fill_chars(rec.bbsname,dashes,sizeof(rec.bbsname));
   fill_chars(rec.bbsloc,dashes,sizeof(rec.bbsloc));
   fill_chars(rec.bbstype,dashes,sizeof(rec.bbstype));
   fill_chars(rec.maxspeed,dashes,sizeof(rec.maxspeed));
   temp := rec.bbsphone+' '+ rec.bbsloc+' '+ rec.bbsname+' '+
           rec.bbstype+' '+ rec.maxspeed;

   writeln(bfd2,temp);

   while not beof(ifd) do
   begin
      bread(ifd,rec);
      writeln(bfd,temp);
      writeln(bfd,rec.bbsphone,' ', rec.bbsloc,' ', rec.bbsname,' ',
                  rec.bbstype,' ', rec.maxspeed);
      writeln(bfd,'               ',rec.descr);
      writeln(bfd,'               Sysop: ',rec.bbssysop,
                  '               Updated: ',date(rec.revdate));
      writeln(bfd2,rec.bbsphone,' ', rec.bbsloc,' ', rec.bbsname,' ',
                  rec.bbstype,' ', rec.maxspeed);
   end;

   bclose(ifd);
   close(bfd);
   close(bfd2);
end;

(* ---------------------------------------------------------------- *)
procedure purge_listings;
var
   ifd:  buffered_file;
   ofd:  buffered_file;
   fd:   file;

begin
   make_log_entry('Purging entries older than '+date(oldest),true);

   load_cnames_file;          {locate or create CONFINFO file}
   load_conf(0);              {locate main message file, enables @NUMCALLS@}
   mbfile := conf_info.conf_msgfile;
   load_conf(current_conf);   {load current conference into conf_info}

   dos_unlink(bakfile);

   assign(fd,listfile);
   {$i-}rename(fd,bakfile);{$i+}
   if ioresult <> 0 then
      exit;

   bopen(ifd,bakfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;

   bcreate(listfile);
   bopen(ofd,listfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;

   while not beof(ifd) do
   begin
      bread(ifd,rec);
      if rec.revdate >= oldest then
         bwrite(ofd,rec)
      else
      begin
         make_log_entry('Purged: '+rec.bbsname+' '+rec.username,true);
         leave_message;
      end;
   end;

   bclose(ifd);
   bclose(ofd);
   update_bulletin;
end;

(* ---------------------------------------------------------------- *)
procedure lookup_listing;
var
   ifd:  buffered_file;
   i:    integer;
begin

   {if the user is a sysop (level >= 110) allow selection of any user
    name for update or data entry.  This allows the sysop to edit existing
    users entries or to entry new entries (under different names).}
   uname := pcbsys.name;
   if userlevel >= 110 then
      get_chars('Select User Name',uname,sizeof(uname));
   for i := 1 to sizeof(uname) do
      uname[i] := upcase(uname[i]);

   fill_chars(rec,' ',sizeof(bbslist_rec));
   rec.crlf := ^M^J;
   bopen(ifd,listfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;

   while not beof(ifd) do
   begin
      bread(ifd,rec);
      if rec.username = uname then
      begin
         bclose(ifd);
         exit;
      end;
   end;

   fill_chars(rec,' ',sizeof(bbslist_rec));
   rec.crlf := ^M^J;
   bclose(ifd);
end;

(* ---------------------------------------------------------------- *)
procedure update_alarm;
var
   loops:   integer;
   i,j,k:   integer;
begin
   if local or (pcbsys.alarm[1] = ' ') then
      loops := 1
   else
      loops := 7;

   for i := 1 to loops do
      for j := 10 downto 1 do
      begin
         sound((j*200)+(i*50));
         delay(80);
         nosound;
      end;
end;


(* ---------------------------------------------------------------- *)
procedure add_alarm;
var
   loops:   integer;
   i,j,k:   integer;
begin
   if local or (pcbsys.alarm[1] = ' ') then
      loops := 1
   else
      loops := 7;

   for i := 1 to loops do
      for j := 10 downto 1 do
      begin
         sound((j*200)+(i*50));
         delay(40);
         sound((j*200)+((11-i)*50));
         delay(40);
         nosound;
      end;
end;


(* ---------------------------------------------------------------- *)
procedure merge_listing;
var
   ifd:  buffered_file;
   ofd:  buffered_file;
   irec: bbslist_rec;
   fd:   file;
begin
   pdispln('$WHITE$Updating BBS list database ...');

   dos_unlink(bakfile);

   if not dos_exists(listfile) then
      bcreate(listfile);

   assign(fd,listfile);
   rename(fd,bakfile);

   bopen(ifd,bakfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;

   bcreate(listfile);
   bopen(ofd,listfile,bufcount,sizeof(bbslist_rec));
   if berr then
      exit;

   fill_chars(rec.revdate,todays_date_yymmdd,sizeof(rec.revdate));
   rec.username := uname;

   while not beof(ifd) do
   begin
      bread(ifd,irec);
      if (irec.username = rec.username) then
      begin
         irec := rec;
         rec.username[1] := ' ';
         if irec.bbsphone[1] = delete_flag then
            make_log_entry('Deleted: '+irec.bbsname,true)
         else
            make_log_entry('Updated: '+rec.bbsname,true);
         update_alarm;
      end;

      if irec.bbsphone[1] <> delete_flag then
         bwrite(ofd,irec);
   end;

   if (rec.username[1] <> ' ') and (rec.bbsphone[1] <> delete_flag) then
   begin
      irec := rec;
      bwrite(ofd,irec);
      make_log_entry('Added: '+rec.bbsname,true);
      add_alarm;
   end;

   bclose(ifd);
   bclose(ofd);
   update_bulletin;
end;

(* ---------------------------------------------------------------- *)
procedure update_listings;
begin
   display_file(introfile);
   force_enter;

   pdispln('$WHITE$Searching BBS list for your listing ...');

   lookup_listing;
   newline;

   if rec.username[1] = ' ' then
   begin
      pdispln('$RED$You do not currently have a listing in the BBS list.');
      if not yesno('Do you want to add your BBS to the listing') then
         exit;
   end
   else
   begin
      pdispln('$GREEN$Here is your current BBS list entry:');
      pdisp('$YELLOW$        Phone: $WHITE$'); displn(rec.bbsphone);
      pdisp('$YELLOW$   Board Name: $WHITE$'); displn(rec.bbsname);
      pdisp('$YELLOW$     Location: $WHITE$'); displn(rec.bbsloc);
      pdisp('$YELLOW$        Sysop: $WHITE$'); displn(rec.bbssysop);
      pdisp('$YELLOW$ BBS Software: $WHITE$'); displn(rec.bbstype);
      pdisp('$YELLOW$Highest Speed: $WHITE$'); displn(rec.maxspeed);
      pdisp('$YELLOW$  Description: $WHITE$'); displn(rec.descr);
      pdisp('$YELLOW$ Last Updated: $WHITE$'); displn(date(rec.revdate));

      newline;
      if yesno('Do you want to DELETE your BBS from the listing') then
      begin
         rec.bbsphone[1] := delete_flag;
         newline;
         merge_listing;
         exit;
      end;
   end;

   newline;
   if (rec.bbsphone[1] = ' ' ) or yesno('Do you want to modify your BBS listing') then
      repeat
         newline;
         pdispln('$GREEN$Please enter new information for your BBS listing:');
         newline;
         pdispln('$WHITE$Enter phone numbers in XXX-XXX-XXXX format.');
         get_chars('        Phone',rec.bbsphone,sizeof(rec.bbsphone));
         if dump_user then exit;
         get_chars('   Board Name',rec.bbsname,sizeof(rec.bbsname));
         if dump_user then exit;
         get_chars('     Location',rec.bbsloc,sizeof(rec.bbsloc));
         if dump_user then exit;
         get_chars('        Sysop',rec.bbssysop,sizeof(rec.bbssysop));
         if dump_user then exit;
         get_chars(' BBS Software',rec.bbstype,sizeof(rec.bbstype));
         if dump_user then exit;
         get_chars('Highest Speed',rec.maxspeed,sizeof(rec.maxspeed));
         if dump_user then exit;
         newline;
         pdispln('$WHITE$Please enter a one line (64 character) description of your board.');
         get_chars(' Description',rec.descr,sizeof(rec.descr));
         if dump_user then exit;
         newline;
      until yesno('Is this information correct');

   newline;

   merge_listing;
end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}
   progname := 'BBSlist';        {program name on status line}

   load_config;

   newline;
   pdispln('$WHITE$'+door_version);
   displn('Copyright 1993 Samuel H. Smith');
   newline;

   if dos_exists(lockfile) then
   begin
      pdispln('$RED$The BBS list file is currently being updated by another user!');
      pdispln('Please try again in a few minutes ...');
      newline;
   end
   else
   begin
      bcreate(lockfile);
      if paramstr(paramcount-1) = 'PURGE' then
         purge_listings
      else
         update_listings;
   end;

   dos_unlink(lockfile);
   uninit;   {must be last - closes com port and updates database}
end.


