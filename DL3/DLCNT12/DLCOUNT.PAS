
(*
 * DlCount - Produce download count from DOWNLOAD.TXT file
 *
 * Copyright (C) 1993 Samuel H. Smith
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Panorama City, CA
 *         (818) 891-1344
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

{$m 8000,60000,600000}

{$D+,L+}                {Produce debug information}
{$R-,S-}                {Rangecheck off, Stackcheck on}

uses dos, {crt,} qread;

{$i crc16.inc}

{procedure clreol; begin write('    '^H^H^H^H); end;}

const
   version = 'v1.25 (03-19-94)';

   hashfiles = 21500;
   maxoverflow = hashfiles div 2;
   countfile = 'DLCOUNT.DAT';
   insert_blanks = true;      {insert blank line after each file entry}
type
   packed_ptr = record
      b1,b2,b3: byte;
   end;

   file_buffer = array[1..2048] of char;
   filenames = string[10];
   anystring = string[80];
   dates = word;

   dirptr = ^dirinfo;
   dirinfo = record
      fname:      filenames;
      dldate:     dates;
      dlcount:    word;
      next:       packed_ptr;
   end;

   hashtable = array[0..hashfiles] of packed_ptr;

const
   spills:     longint = 0;
   saved_cnt:  longint = 0;
   tot_dls:    longint = 0;
   uniq_dls:   longint = 0;
   lnum:       longint = 0;
   found:      longint = 0;
   missing:    longint = 0;

var
   fd:            text;
   inbuf:         ^file_buffer;
   outbuf:        ^file_buffer;

   cur_fname:     filenames;
   cur_dlcount:   word;
   cur_dldate:    dates;
   cur_hash:      word;

   hash:          ^hashtable;
   hashhits:      longint;

const
   dirfiles:      dirptr = nil;


(* ------------------------------------------------------------ *)
procedure packptr(realptr: dirptr; var pcked: packed_ptr);
begin
   pcked.b1 := lo(seg(realptr^));
   pcked.b2 := hi(seg(realptr^));
   pcked.b3 := ofs(realptr^);
end;


(* ------------------------------------------------------------ *)
function unpackptr(pcked: packed_ptr): dirptr;
var
   longbytes: array[1..4] of byte;
   unpcked: dirptr absolute longbytes;
begin
   longbytes[3] := pcked.b1;
   longbytes[4] := pcked.b2;
   longbytes[1] := pcked.b3;
   longbytes[2] := 0;
   unpackptr := unpcked;
end;


(* ------------------------------------------------------------ *)
function atoi(s: anystring): byte;
var
   b: integer;
begin
   atoi := (ord(s[1])-ord('0'))*10 +
           (ord(s[2])-ord('0'));
end;


(* ------------------------------------------------------------ *)
function itoa2(i: byte): anystring;
begin
   itoa2 := chr((i div 10) + ord('0')) +
            chr((i mod 10) + ord('0'));
end;

(* ------------------------------------------------------------ *)
function compress_date(ds: anystring): dates;
begin
   {mm-dd-yyyy,hh:mm}
   {1234567890123456}

   compress_date :=
      {day}    (atoi(copy(ds,4,2))-1) +
      {month}  (atoi(copy(ds,1,2))-1) * 32 +
      {year}   (atoi(copy(ds,9,2))-1) * 32*12;
end;

(* ------------------------------------------------------------ *)
function expand_date(dt: dates): anystring;
var
   m,d,y:   integer;
begin
   y := dt div (32*12); dt := dt - y*32*12;
   m := dt div 32;      dt := dt - m*32;
   d := dt;
   expand_date := itoa2(m+1) + '-' +
                  itoa2(d+1) + '-' +
                  itoa2(y+1);
end;


(* ------------------------------------------------------------ *)
function gethash(fname: filenames): word;
begin
   crc_out := 123;
   crcstr(fname[1],length(fname));
   gethash := crc_out mod hashfiles;
end;


(* ------------------------------------------------------------ *)
procedure load_filelist;
var
   fd:      text;
   line:    string;
   DirInfo: SearchRec;
   node:    dirptr;
   last:    dirptr;
   num:     word;
   i:       integer;
   h:       word;
temp: packed_ptr;
begin
   assign(fd,paramstr(2));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t read configuration file: ',paramstr(2));
      halt;
   end;

   hashhits := 0;

   num := 0;
   dirfiles := nil;
   last := nil;

   while not eof(fd) do
   begin
      qReadLn(fd,line,sizeof(line));

      if line[length(line)] = '\' then
         dec(line[0]);

      write(^M'Scanning ',line,', ',memavail div 1024,'k free   ');

      FindFirst(line+'\*.*',$21,DirInfo);
      while DosError = 0 do
      begin
         new(node);
{
packptr(node,temp);
writeln('node=',seg(node^),':',ofs(node^),
        ' test=',seg(unpackptr(temp)^),':',ofs(unpackptr(temp)^));
}

         node^.fname := DirInfo.name;
         node^.dlcount := 0;
         node^.dldate := 0;

         if dirfiles = nil then
            dirfiles := node
         else
            packptr(node,last^.next);

         last := node;
         packptr(nil,node^.next);

         h := gethash(node^.fname);
         i := 1;
         while (unpackptr(hash^[h]) <> nil) and (i < maxoverflow) do
         begin
            h := (h+1) mod hashfiles;
            inc(i);
         end;

         if i = maxoverflow then
            inc(spills)
         else
            packptr(node,hash^[h]);

         FindNext(DirInfo);
         inc(num);
      end;
   end;

   write(^M,num,' files in all download directories.');
   if spills <> 0 then
      write(' (',spills,')');
   writeln('  ',memavail div 1024,'k free');
   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure process_download_file;
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
         if cur_dldate > node^.dldate then
            node^.dldate := cur_dldate;
      end;

      inc(found);
      inc(tot_dls,cur_dlcount);
   end;

begin
   cur_hash := gethash(cur_fname);
   i := 1;
   repeat
      node := unpackptr(hash^[ cur_hash ]);
      if (node <> nil) and (node^.fname = cur_fname) then
      begin
         inc(hashhits);
         process_match;
         exit;
      end;

      cur_hash := (cur_hash+1) mod hashfiles;
      inc(i);
   until (unpackptr(hash^[cur_hash]) = nil) or (i >= maxoverflow);

   if spills <> 0 then
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
            node := unpackptr(node^.next);
      end;
   end;

   inc(missing);
end;


(* ------------------------------------------------------------ *)
procedure parse_download_txt_line;
   {parse the current input line producing 'cur'}
var
   i:       integer;
   fun:     char;
   count:   word;
   str:     string;

begin
   {(D),DOWNLOADED 4 TIMES,08-24-1993,12:33,360X480.ZIP,?,0,4}

   qreadln(fd,str,sizeof(str));
   inc(lnum);

   fun := str[2];

   str := copy(str,5,80);     {str=name,date,time,fname,proto,err,count}
   i := pos(',',str);
   str := copy(str,i+1,80);   {str=date,time,fname,proto,err,count}
   cur_dldate := compress_date(str);

   str := copy(str,18,80);    {str=fname,proto,err,count}

   i := pos(',',str);
   cur_fname := copy(str,1,i-1);

   {cur_hash := gethash(cur_fname);}

   str := copy(str,i+1,80);   {str=proto,err,count}
   if str[1] = '?' then
      val(copy(str,5,20),count,i)
   else
      count := 1;

   cur_dlcount := 0;
   if fun = 'D' then
      cur_dlcount := count;
end;


(* ------------------------------------------------------------ *)
procedure scan_download_txt;
var
   count:   longint;
   line:    string;
begin
   writeln;
   write('Scanning ',paramstr(1),' ...');
   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open ',paramstr(1));
      halt;
   end;

   setTextBuf(fd,inbuf^);

   count := saved_cnt;
   while (not eof(fd)) and (count > 0) do
   begin
      dec(count);
      qreadln(fd,line,sizeof(line));
      if (count mod 1000) = 0 then
         write('.');
   end;

   writeln;
   count := saved_cnt;
   while not eof(fd) do
   begin
      inc(saved_cnt);
      inc(count);
      parse_download_txt_line;
      process_download_file;

      if (count mod 100) = 0 then
      begin
         write(^M,tot_dls,' downloads (',uniq_dls,' unique),  ',
               missing,' missing   ');
      end;
   end;
   close(fd);

   write(^M,tot_dls,' downloads (',uniq_dls,' unique),  ',
               missing,' missing   ');
   writeln;
end;


(* ------------------------------------------------------------ *)
procedure parse_download_cnt_line;
   {parse the current input line producing 'cur'}
var
   i,j:     integer;
   str:     string;

begin
   {#,FNAME}

   qreadln(fd,str,sizeof(str));
   inc(lnum);

   i := pos(',',str);
   val(copy(str,1,i-1),cur_dlcount,j);
   str := copy(str,i+1,80);

   i := pos(',',str);
   val(copy(str,1,i-1),cur_dldate,j);

   cur_fname := copy(str,i+1,80);
end;


(* ------------------------------------------------------------ *)
procedure load_download_cnt;
var
   count:   longint;
begin
   assign(fd,countfile);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      exit;

   writeln;
   writeln('Loading ',countfile,' ...');

   setTextBuf(fd,inbuf^);
   readln(fd,saved_cnt);

   count := 0;
   while not eof(fd) do
   begin
      inc(count);
      parse_download_cnt_line;
      process_download_file;

      if (count mod 100) = 0 then
      begin
         write(^M,tot_dls,' downloads (',uniq_dls,' unique)   ');
      end;
   end;
   close(fd);

   writeln(^M,tot_dls,' downloads (',uniq_dls,' unique)   ');
end;


(* ------------------------------------------------------------ *)
procedure save_download_cnt;
var
   node: dirptr;
begin
   writeln;
   writeln('Writing download counts to ',countfile,' ...');

   assign(fd,countfile);
   rewrite(fd);
   setTextBuf(fd,outbuf^);

   writeln(fd,saved_cnt);

   node := dirfiles;
   while node <> nil do
   begin
      if node^.dlcount <> 0 then
         writeln(fd,node^.dlcount,',',node^.dldate,',',node^.fname);
      node := unpackptr(node^.next);
   end;

   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure lookup_dlcount;
var
   node: dirptr;
   i:    integer;

begin
   cur_hash := gethash(cur_fname);
   cur_dlcount := 0;
   i := 1;
   repeat
      node := unpackptr(hash^[ cur_hash ]);
      if (node <> nil) and (node^.fname = cur_fname) then
      begin
         cur_dlcount := node^.dlcount;
         cur_dldate := node^.dldate;
         exit;
      end;

      cur_hash := (cur_hash+1) mod hashfiles;
      inc(i);
   until (unpackptr(hash^[cur_hash]) = nil) or (i >= maxoverflow);

   node := dirfiles;
   while node <> nil do
   begin
      if (node^.fname = cur_fname) then
      begin
         cur_dlcount := node^.dlcount;
         cur_dldate := node^.dldate;
         exit;
      end
      else
         node := unpackptr(node^.next);
   end;
end;


(* ------------------------------------------------------------ *)
procedure update_dirfile(inname: string);
var
   infd,outfd: text;
   line:       string;

   procedure write_dlcount;
   begin
      if cur_dlcount <> 0 then
      begin
         write(outfd,'                               | Download Count: ',
                        cur_dlcount);
         if cur_dlcount < 10 then write(outfd,' ');
         if cur_dlcount < 100 then write(outfd,' ');
         if cur_dlcount < 1000 then write(outfd,' ');
         writeln(outfd,' Last Download: ',
                        expand_date(cur_dldate));

         cur_dlcount := 0;
         if insert_blanks then
            writeln(outfd,'                               |');
      end;
   end;

begin
   writeln('Updating ',inname,' ...');
   assign(infd,inname);
   {$i-} reset(infd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open ',inname);
      exit;
   end;

   settextbuf(infd,inbuf^);

   assign(outfd,'temp.!!!');
   rewrite(outfd);
   settextbuf(outfd,outbuf^);
   cur_dlcount := 0;

   while not eof(infd) do
   begin
      qreadln(infd,line,sizeof(line));

      if (length(line) <= 33) and (copy(line,32,1) <> '|') then
         write_dlcount
      else

      if (line[29] = '-') then
      begin
         write_dlcount;

         cur_fname := copy(line,1,12);
         while cur_fname[length(cur_fname)] = ' ' do
            dec(cur_fname[0]);

         lookup_dlcount;
      end;

      if (copy(line,32,17) = '| Download Count:') then
         {remove any pre-existing download count lines}
      else
      if (length(line) < 35) and (copy(line,32,1) = '|') then
         {remove any blank file_id.diz lines}
      else
         {preserve all other DIR file lines}
         writeln(outfd,line);
   end;

   write_dlcount;

   close(infd);
   close(outfd);

   erase(infd);
   rename(outfd,inname);
end;


(* ------------------------------------------------------------ *)
procedure update_dirfiles;
type
   fname_ptr = ^fname_node;
   fname_node = record
      fname: string[65];
      next:  fname_ptr;
   end;

var
   DirInfo:       SearchRec;
   list:          fname_ptr;
   node:          fname_ptr;
   i:             integer;
   path:          string[65];

begin
   list := nil;
   writeln;

   for i := 3 to paramcount do
   begin
      path := paramstr(i);
      while (path <> '') and (path[length(path)] <> ':')
                         and (path[length(path)] <> '\') do
         dec(path[0]);

      FindFirst(paramstr(i),$21,DirInfo);
      while (DosError = 0) do
      begin
         new(node);
         node^.fname := path+DirInfo.name;
         node^.next := list;
         list := node;
         FindNext(DirInfo);
      end;
   end;

   node := list;
   while node <> nil do
   begin
      update_dirfile(node^.fname);
      node := node^.next;
   end;
end;


(* ------------------------------------------------------------ *)
procedure usage;
begin
   writeln('You must the full path to your DOWNLOAD.TXT and DLPATH.LST files.');
   writeln;
   writeln('Example:  DlCount DOWNLOAD.TXT DLPATH.LST dirfile ... dirfile');
   writeln;
   writeln('The DLPATH.LST file must list ALL download directories, one per line.');
   writeln('You can specify your DLPATH.LST file if it does NOT contain any');
   writeln('@ or % index file references.');
   writeln;
   writeln('You may specify any number of DIR files to be updated.  Wildcards are');
   writeln('allowed.  Each specified DIR file will be updated to reflect the current');
   writeln('download count for all listed files.');
   halt;
end;


(* ------------------------------------------------------------ *)
begin
   writeln;
   writeln('DlCount ',version,'  Copyright (C) 1994 Samuel H. Smith');
   writeln('Courtesy of:  The Tool Shop BBS (818) 891-1344');
   writeln;
   writeln('This utility analyzes your DOWNLOAD.TXT and records the number');
   writeln('of times each available file has been downloaded.  This information');
   writeln('is optionally placed into any number of DIR listing files.');
   writeln;

   if paramcount < 2 then
      usage;

   new(inbuf);
   new(outbuf);
   new(hash);
   fillchar(hash^,sizeof(hash^),0);

{writeln('Room for ',memavail div sizeof(dirinfo),' files.');}
   load_filelist;
   load_download_cnt;
   scan_download_txt;
   save_download_cnt;
   update_dirfiles;

   writeln;
   writeln('Process completed.');
end.

