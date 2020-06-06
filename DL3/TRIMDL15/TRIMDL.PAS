
(*
 * TrimDL - Trim DOWNLOAD.TXT file and produce report of
 *          unpopular and multiple-upload files.
 *
 * (C) 1987 Samuel H. Smith, 10-May-87 (rev. 16-Mar-89)
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Panorama City, CA
 *         (818) 891-6780
 *
 *
 * Disclaimer
 * ----------
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (818) 891-6780.
 *
 * Enjoy!     Samuel H. Smith
 *
 *)

{$M 20000,8000,640000}   {Stack, minheap, maxheap}
{$D+,L+}                {Produce debug information}
{$R+,S+}                {Rangecheck off, Stackcheck on}

uses dos, crt, crc32;

const
   version = 'v1.5 (02-02-94)';

   maxfiles = 160000;
   tables = 16;
   tablesize = maxfiles div tables;
   maxoverflow = 1000;

type
   filenames = string[12];
   anystring = string[80];

   dates = longint;

   varstring = ^string;

   dirptr = ^dirinfo;
   dirinfo = record
      fname:      filenames;
      ulwhoid:    word;
      uldate:     dates;
      ulcount:    byte;
      dlcount:    longint;
      dldate:     dates;
      next:       dirptr;
   end;

   whoptr = ^whoinfo;
   whoinfo = record
      who:  varstring;
      next: whoptr;
   end;

   hashtable = array[0..tablesize] of dirptr;

const
   tot_uls:    longint     = 0;
   tot_dls:    longint     = 0;
   uniq_dls:   longint     = 0;
   lnum:       longint     = 0;
   found:      longint     = 0;
   missing:    longint     = 0;

var
   cline:         anystring;
   fd:            text;
   buf:           array[1..10240] of char;

   cur_who:       word;
   cur_date:      dates;
   cur_fname:     filenames;
   cur_dlcount:   longint;
   cur_ulcount:   byte;
   cur_hash:      longint;

   hash:          array[0..tables-1] of ^hashtable;
   hashhits:      longint;
   spills:        integer;

const
   dirfiles:      dirptr = nil;
   whos:          whoptr = nil;
   lastwho:       whoptr = nil;


(* ------------------------------------------------------------ *)
function getwho(n: integer): anystring;
var
   ex:   whoptr;
begin
   ex := whos;
   while (ex <> nil) and (n > 1) do
   begin
      ex := ex^.next;
      dec(n);
   end;
   if ex = nil then
      getwho := ''
   else
      getwho := ex^.who^;
end;


(* ------------------------------------------------------------ *)
function findwho(who: anystring): integer;
var
   n:    integer;
   ex:   whoptr;
begin
   if whos = nil then
   begin
      new(whos);
      getmem(whos^.who,length(who)+1);
      whos^.who^ := who;
      whos^.next := nil;
      lastwho := whos;
      findwho := 1;
      exit;
   end;

   ex := whos;
   n := 1;
   while ex <> nil do
      if ex^.who^ = who then
      begin
         findwho := n;
         exit;
      end
      else
      begin
         inc(n);
         ex := ex^.next;
      end;

   new(ex);
   getmem(ex^.who,length(who)+1);
   ex^.who^ := who;
   ex^.next := nil;
   lastwho^.next := ex;
   lastwho := ex;
   findwho := n;
end;


(* ------------------------------------------------------------ *)
function gethash(fname: filenames): longint;
begin
   crc_out := 123;
   crcstr(fname[1],crc_out,length(fname));
   gethash := (crc_out and $3FFFFFFF) mod maxfiles;
end;


(* ------------------------------------------------------------ *)
function atoi(s: anystring): byte;
var
   b: integer;
   e: integer;
begin
   if s = '' then
      e := 1
   else
      {$i-} val(copy(s,1,2),b,e); {$i+}
{if uniq_dls > 10510 then writeln('atoi(',s,')->',b);}
   if e = 0 then
      atoi := (b and 127)
   else
      atoi := 0;
end;

function itoa2(i: byte): anystring;
begin
   itoa2 := chr((i div 10) + ord('0')) +
            chr((i mod 10) + ord('0'));
end;

procedure compress_date(ds: anystring; var dt: dates);
var
   dtm:  DateTime;
begin
   with dtm do
   begin
      {mm-dd-yyyy,hh:mm}
      {1234567890123456}
      month := atoi(copy(ds,1,2));
      day := atoi(copy(ds,4,2));
      year := 1900+atoi(copy(ds,9,2));
      hour := atoi(copy(ds,12,2));
      min := atoi(copy(ds,15,2));
      sec := 0;
   end;
   PackTime(dtm,dt);
end;

function expand_date(dt: dates): anystring;
var
   dtm:  DateTime;
begin
   UnpackTime(dt,dtm);
   with dtm do
   begin
      expand_date := itoa2(month) + '-' +
                     itoa2(day) + '-' +
                     itoa2(year div 100) + itoa2(year mod 100) + ',' +
                     itoa2(hour) + ':' +
                     itoa2(min);
   end;
end;

function expand_date2(dt: dates): anystring;
var
   dtm:  DateTime;
begin
   UnpackTime(dt,dtm);
   with dtm do
   begin
      expand_date2 := itoa2(year div 100) + itoa2(year mod 100) + '-' +
                      itoa2(month) + '-' +
                      itoa2(day) + ',' +
                      itoa2(hour) + ':' +
                      itoa2(min);
   end;
end;


(* ------------------------------------------------------------ *)
procedure parse_line;
   {parse the current input line producing 'cur'}
var
   i:       integer;
   fun:     char;
   count:   word;
   str:     anystring;

begin
   readln(fd,cline);
{if uniq_dls > 10510 then writeln(^m,cline);}
   inc(lnum);
   str := cline;

   fun := str[2];

   str := copy(str,5,80);
   i := pos(',',str);
   cur_who := findwho(copy(str,1,i-1));

   str := copy(str,i+1,80);

   {mm-dd-yyyy,hh:mm}
   {1234567890123456}
   if (str[3] <> '-') or (str[6] <> '-') or (str[11] <> ',') or (str[14] <> ':') then
   begin
      cur_dlcount := 0;
      cur_ulcount := 0;
      exit;
   end;

   compress_date(copy(str,1,16),cur_date);

   str := copy(str,18,80);
   i := pos(',',str);
   cur_fname := copy(str,1,i-1);
   cur_hash := gethash(cur_fname);

   str := copy(str,i+1,80);
   if str[1] = '?' then
      val(copy(str,5,20),count,i)
   else
      count := 1;

   cur_dlcount := 0;
   cur_ulcount := 0;
   if fun = 'D' then
      cur_dlcount := count
   else
      cur_ulcount := count;
end;


(* ------------------------------------------------------------ *)
procedure process_file;
var
   node: dirptr;
   i:    integer;

   procedure process_match;
   begin
      if cur_dlcount > 0 then
      begin
         if node^.dlcount = 0 then
            inc(uniq_dls);
         inc(node^.dlcount,cur_dlcount);
         node^.dldate := cur_date;
      end;

      if cur_ulcount > 0 then
      begin
         node^.ulwhoid := cur_who;
         node^.uldate := cur_date;
         node^.ulcount := 1;
      end;

      inc(found);
   end;

begin
   if (cur_dlcount = 0) and (cur_ulcount = 0) then
      exit;

   i := 1;
   repeat
      node := hash[ cur_hash mod tables]^[ cur_hash div tables ];
      if (node <> nil) and (node^.fname = cur_fname) then
      begin
         inc(hashhits);
         process_match;
         exit;
      end;

      cur_hash := (cur_hash+1) mod maxfiles;
      inc(i);
   until (hash[ cur_hash mod tables]^[cur_hash div tables] = nil) or (i >= maxoverflow);

   if spills > 0 then
   begin
      node := dirfiles;
      while node <> nil do
      begin
         if (node^.fname = cur_fname) then
         begin
            process_match;
            exit;
         end
         else
            node := node^.next;
      end;
   end;

   inc(missing);
end;


(* ------------------------------------------------------------ *)
procedure generate_new_download_txt;
var
   node: dirptr;
begin
   assign(fd,'DOWNLOAD.NEW');
   rewrite(fd);
   setTextBuf(fd,buf);

   node := dirfiles;
   while node <> nil do
   begin
      if node^.ulcount <> 0 then
         writeln(fd,'(U),',
                 getwho(node^.ulwhoid),',',
                 expand_date(node^.uldate),',',
                 node^.fname,',?,0,',
                 node^.ulcount);

      if node^.dlcount > 0 then
         writeln(fd,'(D),',node^.dlcount,' D/Ls,',
                 expand_date(node^.dldate),',',
                 node^.fname,',?,0,',
                 node^.dlcount);

      node := node^.next;
   end;

   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure generate_unpop_listing;
var
   node: dirptr;
begin
   assign(fd,'UNPOP');
   rewrite(fd);
   setTextBuf(fd,buf);

   node := dirfiles;
   while node <> nil do
   begin
      if node^.dlcount = 0 then
      begin
         if node^.ulcount <> 0 then
            writeln(fd,
                 expand_date2(node^.uldate),' ',
                 node^.fname,'':14-length(node^.fname),
                 getwho(node^.ulwhoid))
         else
            writeln(fd,
                 expand_date2(node^.uldate),' ',
                 node^.fname,'':14-length(node^.fname),
                 ' UNKNOWN');
      end;

      node := node^.next;
   end;

   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure usage;
begin
   writeln('You must specify a configuration file on the command line.');
   writeln;
   writeln('Example:  trimdl trimdl.cnf');
   writeln;
   writeln('The config file must list ALL download directories, one per line.');
   halt;
end;


(* ------------------------------------------------------------ *)
procedure load_filelist;
var
   fd:      text;
   line:    anystring;
   DirInfo: SearchRec;
   node:    dirptr;
   last:    dirptr;
   num:     word;
   i:       integer;
   h:       longint;

begin
   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t read configuration file: ',paramstr(1));
      halt;
   end;

   hashhits := 0;
   for i := 0 to tables-1 do
   begin
      new(hash[i]);
      fillchar(hash[i]^,sizeof(hash[i]^),0);
   end;

   spills := 0;
   num := 0;
   dirfiles := nil;
   last := nil;

   while not eof(fd) do
   begin
      readln(fd,line);

      if line[length(line)] = '\' then
         dec(line[0]);

      write(^M'Scanning ',line,'  ',memavail div 1024,'k free'); clreol;
      FindFirst(line+'\*.*',$21,DirInfo);
      while DosError = 0 do
      begin
         new(node);

         node^.fname := DirInfo.name;

         node^.ulcount := 0;
         node^.uldate := DirInfo.time;

         node^.dlcount := 0;

         if dirfiles = nil then
            dirfiles := node
         else
            last^.next := node;
         last := node;
         node^.next := nil;

         h := gethash(node^.fname);
         i := 1;
         while (hash[h mod tables]^[h div tables] <> nil) and (i < maxoverflow) do
         begin
            h := (h+1) mod maxfiles;
            inc(i);
         end;
         if i = maxoverflow then
            inc(spills);
         hash[h mod tables]^[h div tables] := node;

         FindNext(DirInfo);
         inc(num);
      end;
   end;

   write(^M,num,' files in all download directories. (',spills,')');
   clreol;
   writeln;
   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure scan_download_txt;
var
   count:   longint;
begin
   writeln;
   writeln('Loading DOWNLOAD.TXT ...');
   assign(fd,'DOWNLOAD.TXT');
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open DOWNLOAD.TXT');
      halt;
   end;

   setTextBuf(fd,buf);

   count := 0;
   while not eof(fd) do
   begin
      inc(count);
      parse_line;
      process_file;
      inc(tot_dls,cur_dlcount);
      inc(tot_uls,cur_ulcount);

      if (count mod 10) = 9 then
         write(^M,tot_uls,' U/L,  ',
               tot_dls,' D/L (',uniq_dls,' unique),  ',
               missing,' missing,  ',
              {found,' found, ', }
               memavail div 1024,'k free, ',
               (100*hashhits) div count,'% hits');
      clreol;
   end;
   close(fd);

   writeln(^M,tot_uls,' U/L,  ',
               tot_dls,' D/L (',uniq_dls,' unique),  ',
               missing,' missing,  ',
              {found,' found, ', }
               memavail div 1024,'k free, ',
               (100*hashhits) div count,'% hits');
end;


(* ------------------------------------------------------------ *)
begin
   writeln;
   writeln('TrimDL ',version,'  Copyright (C) 1987-1994 Samuel H. Smith');
   writeln('Courtesy of:  The Tool Shop BBS (818) 891-1344');
   writeln;
   writeln('This utility compresses your DOWNLOAD.TXT file by "trimming" out');
   writeln('multiple download entries for the same file.  It also removes files');
   writeln('that are no longer present on the system for downloading.');
   writeln;

   if paramcount <> 1 then
      usage;

   load_filelist;

   scan_download_txt;

   writeln;
   writeln('Writing trimmed download listing to DOWNLOAD.NEW ...');
   generate_new_download_txt;

   writeln;
   writeln('Generating listing of files never downloaded to UNPOP ...');
   generate_unpop_listing;

   writeln;
   writeln('Process completed.');
   writeln('You can now replace DOWNLOAD.TXT with DOWNLOAD.NEW.');
end.

