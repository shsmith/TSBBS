


(*
 * loc - locate a string in a group of files, output in single line
 *       format for sorting purposes
 *
 * shs 8/5/85
 *
 *)

{$p128,d-}

const
   line_width = 60;

type
   anystring =    string [128];

var
   searchstring:  anystring;


(*
 *
 * poll keyboard so turbo can notice user abort
 *
 *)

procedure abortpoll;
var
   c: char;
begin
   if keypressed then
      read(kbd,c);
end;



(*
 *
 * file list processing module
 *
 *)
   
const
   maxnumfiles =  100;
   null =         #0;

type
   filestring =   string [64];
   filearray =    array [1.. maxnumfiles] of filestring;
   regpack =      record
                     ax,
                     bx,
                     cx,
                     dx,
                     bp,
                     si,
                     di,
                     ds,
                     es,
                     flags:         Integer;
                  end;


var
   reg:           regpack;
   dta:           anystring;
   filetable:     filearray;
   filecount:     integer;
   i:             integer;


(*
 *
 * sort a portion of a file table
 *
 *)


procedure sorttable (var fdir:      filearray;
                     first:         integer;
                     last:          integer);
var
   i:             integer;
   swapped:       boolean;
   temp:          filestring;
   
begin

   repeat
      swapped := false;

      for i := first to last - 1 do
      begin

         if fdir [i]> fdir [i + 1] then
         begin
            temp := fdir [i];
            fdir[i]:= fdir [i + 1];
            fdir[i + 1]:= temp;
            swapped := true;
         end;
      end;
   until swapped = false;
end;


(*
 *
 * expand a comma-seperated wildcard list into
 * a list of full pathnames.
 * sort files going with each wildcard, but otherwise
 * preserve file order
 *
 *)

procedure getfiles (patternlist:   anystring;
                    var fdir:      filearray;
                    var num:       integer);
var
   i,
   cf:            byte;
   onedir:        filestring;
   listpos:       integer;
   pattern:       filestring;
   curdir:        filestring;
   c:             char;
   prevnum:       integer;

begin
   num := 0;
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
      curdir := pattern;

      while (curdir [length (curdir)]<> '\') and
            (curdir [length (curdir)]<> ':') and
            (length (curdir)> 0) do
         curdir[0]:= pred (curdir [0]);

      pattern := pattern + null;
      reg.ax := $1a00;
      reg.ds := seg (dta [1]);
      reg.dx := ofs (dta [1]);
      msdos(reg);              {set dta address}

      reg.ax := $4e00;
      reg.cx := 39;
      reg.ds := seg (pattern [1]);
      reg.dx := ofs (pattern [1]);
      msdos(reg);              {find first matching file}

      cf := reg.flags and 1;

      if (cf <> 0) then
         writeln('warning:  no files matched  ',pattern);

      while ((cf <> 1) and (num < maxnumfiles)) do
      begin
         abortpoll;

         onedir := '';
         i := 0;

         repeat
            c := dta [31 + i];

            if c <> null then
               onedir := onedir + c;

            i := i + 1;
         until c = null;          {throw out the . and .. entries}


         if onedir [1]<> '.' then
         begin
            num := num + 1;
            fdir[num]:= curdir + onedir;
         end;

         reg.ax := $4f00;
         reg.ds := seg (dta [1]);
         reg.dx := ofs (dta [1]);
         msdos(reg);              {keep searching for next file}

         cf := reg.flags and 1;
      end;

      sorttable(fdir, prevnum, num);
                               {sort each part of list seperately}

      prevnum := num + 1;
   end;
   
   if num >= maxnumfiles then
   begin
      writeln('warning:  files in excess of ',maxnumfiles, ' ignored');
   end;
end;                     {getfiles}



(*
 * end of file list processing
 *
 *)


(*
 *
 * return the string equivelant of an integer value
 * with leading zeroes for a minimum width of 2
 *
 *)

function strval (int:           integer): anystring;
var
   tstr:          anystring;

begin
   str(int, tstr);

   if length (tstr)= 1 then
      strval := '0' + tstr
   else
      strval := tstr;
end;


(*
 *
 * given a valid filename, returns modification date and time
 *
 *)

procedure filedate (filename:      anystring;
                    var info:      anystring);
const
   month : array [1..12] of string[3]
           = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

var
   cf,
   b1,
   b2,
   hr,
   mn,
   m,
   d,
   y:             integer;
   dta:           array [1..512] of byte;
   sval:          string [2];
   reg:           regpack;

begin                       {set up disk transfer area}

   reg.ax := $1a00;
   reg.ds := seg (dta [1]);
   reg.dx := ofs (dta [1]);
   msdos(reg);              {fill up dta}

   filename := filename + null;
   reg.ax := $4e00;
   reg.cx := 39;
   reg.ds := seg (filename [1]);
   reg.dx := ofs (filename [1]);
   msdos(reg);
   cf := reg.flags and 1;

   if cf = 1 then
      info := '00-000-00 00:00'
   else
   begin
      b1 := ord (dta [25]);
      b2 := ord (dta [26]);
      d := b1 and 31;
      m :=(b1 shr 5)+ 8 *(b2 and 1);
      y :=(b2 shr 1)+ 80;
      b1 := ord (dta [23]);
      b2 := ord (dta [24]);
      mn :=(b1 shr 5)+ 8 *(b2 and 7);
      hr := b2 shr 3;
      info := strval (d)+ '-' + month [m]+ '-' + strval (y)+ ' ' +
              strval (hr)+ ':' + strval (mn);
   end;
end;




(*
 *
 * print a single file
 * displays status on standard output while printing
 *
 *)

procedure procfile (name:          anystring);
var
   infile:        text [1024];
   linenum:       integer;
   line:          anystring;
   i:             integer;
   matchpos:      integer;

begin
   write(con,name);
   assign(infile, name);
   reset(infile);

   linenum := 0;


   while not eof (infile) do
   begin
      readln(infile, line);
      linenum := linenum + 1;

      matchpos := pos(searchstring,line);
      if matchpos <> 0 then
      begin
         writeln(line,' ':line_width-length(line),linenum:4,' ',name);
         flush(output);
      end;

      abortpoll;
   end;

   close(infile);
   flush(output);
   write(con,#13);
   clreol;
end;


(*
 *
 * main program
 *
 *)
begin                       {main}

   if paramcount < 2 then
   begin
      writeln(con,'usage:    loc FILENAME-LIST STRING');
      writeln(con,'example:  loc *.pas,*.inc procedure |sort >prn');
      halt;
   end;

   getfiles(paramstr (1), filetable, filecount);
                            {get full list of files}

   searchstring := paramstr(2);
   i := 3;
   while i <= paramcount do
   begin
      searchstring := searchstring + ' ' + paramstr(i);
      i := i + 1;
   end;


   for i := 1 to filecount do
                            {process each file}
      procfile(filetable [i]);

   flush(output);

   halt(0);                 {return to dos}
end.
