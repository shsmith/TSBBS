

(*
 * ls - file list program
 *
 * this is a general file-list processing program
 * it can process a comma seperated list of wildcards
 * into a sorted pathname list
 *
 * shs 8/3/85
 *
 *)

uses dos;

const
   version = 'LS, Unix-like file lister       v2.3 (19-oct-93, S.H.Smith)';
   maxnumfiles =  800;
   null =         #0;

type
   longstring =   string [80];
   filestring =   string [15];
   filearray =    array [1.. maxnumfiles] of filestring;

   daterec =      record
                     day:   INTEGER; {0..31}
                     month: INTEGER; {0..15}
                     year:  INTEGER; {0..127}
                     hour:  INTEGER; {0..31}
                     min:   INTEGER; {0..63}
                     sec:   INTEGER; {0..59}
                     jdate: real;
                  end;


const
   months: array[0..12] of filestring =
        ('???','Jan','Feb','Mar','Apr',
               'May','Jun','Jul','Aug',
               'Sep','Oct','Nov','Dec');

var
   reg:           registers;
   dta:           longstring;

   filetable:     filearray;
   filesize:      array [1.. maxnumfiles] of integer;
   filedate:      array [1.. maxnumfiles] of daterec;
   filecount:     integer;
   maxfiles:      integer;
   i,j,k:         integer;
   cols:          integer;
   lines:         integer;
   pattern:       longstring;
   param:         longstring;
   totalk:        integer;

   dashl:         boolean;   {long format output option}
   dasht:         boolean;   {sort by time option}
   dashr:         boolean;   {reverse order of sort}
   dash8:         boolean;   {list in 8 column format}
   dash6:         boolean;   {list in 6 column format}
   dash1:         boolean;   {list in 1 column format}
   dashk:         boolean;   {show sizes rounded to nearest cluster}

   cluster_size:  INTEGER;



procedure display_free_space(drive: longstring);
begin
   with reg do
   begin

      if drive[2] = ':' then
      begin
         write(upcase(drive[1]),': ');
         dx := ord(upcase(drive[1]))-ord('@');
      end

      else
         dx := 0;

      ax := $3600;
      msdos(reg);

      cluster_size := cx * ax;
      write(int(bx) * INT(Cluster_size) / 1024.0:0:0,'k or ');
      write(int(bx) / int(dx) * 100.0:0:0,'% free, out of ');
      writeln(int(dx) * INT(cluster_size) / 1024.0:0:0,'k total disk space');

   end;

end;


procedure sorttable(var fdir:     filearray;
                        first:     integer;
                        last:      integer);
var
   i:       integer;
   swapped: boolean;
   temp:    filestring;
   itemp:   integer;
   dtemp:   daterec;
   reversed:boolean;

begin

   repeat
      swapped := false;
      for i := first to last-1 do
      begin
         if not dasht then
            reversed := fdir[i] > fdir[i+1]
         else
            reversed := filedate[i].jdate > filedate[i+1].jdate;

         if dashr then
            reversed := not reversed;

         if reversed then
         begin
            temp := fdir[i];
            fdir[i] := fdir[i+1];
            fdir[i+1] := temp;

            itemp := filesize[i];
            filesize[i] := filesize[i+1];
            filesize[i+1] := itemp;

            dtemp := filedate[i];
            filedate[i] := filedate[i+1];
            filedate[i+1] := dtemp;
            swapped := true;
         end;
      end;

      last := last - 1;
   until (swapped = false) or (last < 2);

end;


procedure getfiles (patternlist:   longstring;  {list of patterns to match}
                    fattr:         integer;     {attribute to match}
                    var fdir:      filearray;   {output filename list}
                    var num:       integer);    {output number of files}
                        {-find files matching specified characteristics}

var
   i,
   cf:            byte;
   onedir:        filestring;
   listpos:       integer;
   pattern:       longstring;
   c:             char;
   prevnum:       integer;
   h,d,y,m:       byte;

begin
   num := 0;
   totalk := 0;
   prevnum := 1;
   listpos := 1;

   while listpos <= length (patternlist) do
   begin
      pattern := '';
      c := patternlist [listpos];

      while (c <> ',') and (listpos <= length (patternlist)) do
      begin
         pattern := pattern + c;
         listpos := listpos + 1;
         c := patternlist [listpos];
      end;
      listpos := listpos + 1;

      if pattern[length(pattern)] in [':','/','\'] then
         pattern := pattern + '*.*';

      pattern := pattern + null;
      reg.ax := $1a00;
      reg.ds := seg (dta [1]);
      reg.dx := ofs (dta [1]);
      msdos(reg);              {set dta address}

      reg.cx := fattr;
      reg.ax := $4e00;
      reg.ds := seg (pattern [1]);
      reg.dx := ofs (pattern [1]);
      msdos(reg);              {find first matching file}

      cf := reg.flags and 1;

      while ((cf <> 1) and (num < maxnumfiles)) do
      begin
         i := ord (dta [22]);

         if (i = fattr) or ((fattr <> 16) and
               (i < fattr)) then
         begin                       {get subdir or file name}

            onedir := '';
            i := 0;

            repeat
               c := dta [31 + i];
               if (c >= 'A') and (c <= 'Z') then
                  c := chr(ord(c) + 32);

               if c <> null then
                  onedir := onedir + c;

               i := i + 1;
            until c = null;          {throw out the . and .. entries}


            if onedir [1]<> '.' then
            begin
               num := num + 1;
               fdir[num]:= onedir;

               m:=Ord(dta[27]);
               h:=Ord(dta[28]);
               d:=Ord(dta[29]);

               y:=Ord(dta[30]);

               filesize[num] := trunc(int((m+256.0*(h+256.0*(d+256.0*y)))/
                                         int(cluster_size)+0.999) *
                                         int(cluster_size)/1024.0);

               totalk := totalk + filesize[num];

               if (ord(dta [22]) and $10) <> 0 then
                  fdir[num] := ' ' + fdir[num];

               with filedate[num] do
               begin
                  m := ord (dta [25]);
                  d := ord (dta [26]);
                  day := m and 31;
                  month :=(m shr 5)+ ((d and 1) shl 3);
                  year :=(d shr 1)+ 80;

                  m := ord (dta [23]);
                  d := ord (dta [24]);
                  sec :=(m and 31) shl 1;
                  min :=(m shr 5)+ ((d and 7) shl 3);
                  hour := d shr 3;

                  jdate := int((year-80)*385 + (month-1)*32 + (day-1)) +
                           int(hour*100 + min) / 10000.0 +
                           int(sec) / 1000000.0;
               end;
            end;
         end;

         reg.ax := $4f00;
         reg.ds := seg (dta [1]);
         reg.dx := ofs (dta [1]);
         msdos(reg);              {keep searching for next file}

         cf := reg.flags and 1;
      end;

      sorttable(fdir,prevnum,num); {sort each part of list seperately}
      prevnum := num + 1;
   end;

   if num >= maxnumfiles then
   begin
      writeln('warning: files in excess of ',
            maxnumfiles, ' ignored');
   end;
end;                     {getfiles}



procedure usage;
begin
   writeln(version);
   writeln;
   writeln('Usage:  ls [OPTION] PATTERN {,PATTERN}');
   writeln;
   writeln('Where OPTION is one or more of:');
   writeln(' -K       ;report sizes based on clusters used');
   writeln(' -T       ;sorted by time/date');
   writeln(' -R       ;reverse order of sort');
   writeln(' -M       ;limit listing to first 40 files');
   writeln(' -L       ;long format');
   writeln(' -1       ;one file per line format');
   writeln(' -6       ;short 6 column format');
   writeln(' -8       ;clipped 8 column format');
   writeln;
   writeln('Examples:');
   writeln('   LS -L');
   writeln('   LS -RT *.COM');
   writeln('   LS -6 *.COM,*.EXE');
   writeln('   LS /DOS/,/MISC/UTILITY/');
   writeln;
   halt;
end;


procedure process_command_line;
begin

   pattern := '';
   dashl := false;
   dasht := false;
   dashr := false;
   dash8 := false;
   dash6 := false;
   dash1 := false;
   dashk := false;
   maxfiles := maxnumfiles;

   for i := 1 to paramcount do
   begin
      param := paramstr(i);

      if param[1] = '-' then
         for j := 2 to length(param) do
         begin
            case upcase(param[j]) of
               'K':  dashk := true;
               'L':  dashl := true;
               'T':  dasht := true;
               'R':  dashr := true;
               'M':  maxfiles := 40;
               '1':  dash1 := true;
               '6':  dash6 := true;
               '8':  dash8 := true;
               else  usage;
            end;
         end

      else

      if pattern <> '' then
         pattern := pattern + ',' + param

      else
         pattern := param;
   end;


   if pattern = '' then
      pattern := '*.*';


   if (not (pattern[1] in ['/','\'])) and (pattern[2] <> ':') then
   begin
      getdir(0,param);
      if param[length(param)] <> '\' then
         param := param + '/';
      pattern := param + pattern;
   end;

   for i := 1 to length(pattern) do
      if pattern[i] = '\' then
         pattern[i] := '/'
      else
      if pattern[i] in ['A'..'Z'] then
         pattern[i] := chr(ord(pattern[i]) + $20);

   if pos('.',pattern) = 0 then
      if pattern[length(pattern)] in ['/',':'] then
         pattern := pattern + '*.*'
      else
         pattern := pattern + '.*';
end;



function intstr(i: integer): longstring;
begin
   intstr := chr(((i div 10) mod 10) + ord('0')) +
             chr((i mod 10) + ord('0'));
end;



function date_time(date: daterec): longstring;
var
   str:  longstring;

begin
   with date do
   begin
      str := intstr(day) + '-' + months[month] + '-' + intstr(year) + ' ';
      str := str + intstr(hour) + ':' + intstr(min) + ':' + intstr(sec);
   end;

   date_time := str + '  ';
end;



procedure display_entry(k: integer);
var
   len: integer;

begin
   len := length(filetable[k]);

   if dash8 then
   begin

      if filetable[k][1] <> ' ' then
         write(copy(filetable[k],1,9))
      else
         write(copy(filetable[k],2,8),'/');

      if len < 9 then
         write('':9-len);
   end
   else

   if dash6 then
   begin
      if filetable[k][1] <> ' ' then
         write(filetable[k])
      else
         write(copy(filetable[k],2,99),'/');

      write('':12-len);
   end
   else

   if dashl then
      if filetable[k][1] <> ' ' then
         write(filetable[k], '':12-len,
                       filesize[k]:5,'k ',
                       date_time(filedate[k]))
      else
         write(copy(filetable[k],2,80),'/','':13-len,
                       '     ',
                       date_time(filedate[k]))
   else

   begin
      if filetable[k][1] <> ' ' then
         write(filesize[k]:5,'k ',filetable[k])
      else
         write('  ',filetable[k],'/    ');

      write('':12-len);
   end;

end;



begin {main}

   process_command_line;

   writeln;
   if dash6 or dash8 then
      cluster_size := 1024
   else
      display_free_space(pattern);

   if not dashk then
      cluster_size := 1024;

   getfiles(pattern, $37, filetable, filecount);

   write('Total of ',totalk,'k used by ',filecount,' files in ');
   writeln(pattern);

   if filecount > maxfiles then
   begin
      filecount := maxfiles;
      writeln('Listing only the first ',maxfiles,' files.');
   end;

   writeln;


   if dash1 then
      cols := 1
   else
   if dash6 then
      cols := 6
   else
   if dash8 then
      cols := 8
   else
   if dashl then
      cols := 2
   else
      cols := 4;

   lines := ((filecount+cols-1) div cols);
   for i := 1 to lines do
   begin

      k := i;

      for j := 1 to cols do
      begin

         if k <= filecount then
         begin
            display_entry(k);

            if j <> cols then
               write(' ');
         end;

         k := k + lines;
      end;

      writeln;
   end;

   halt(0);
end.
