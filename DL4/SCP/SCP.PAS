
(*
 * cp - unix like file copy
 *
 * shs 8/5/85
 * version 2, shs 5/14/86
 * version 3, shs 8/10/87
 *
 *
 * (C) 1987 Samuel H. Smith, 8/5/85 (rev. 10-Aug-87)
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Phoenix, Az
 *         (602) 279-2673
 *
 * This program uses many of the building-blocks in the Tool Shop Library,
 * which is available for download from the Tool Shop.   Compile using
 * TSHELL 1.2, also available from the Tool Shop.
 *
 *
 * Disclaimer
 * ----------
 *
 * This software is completely FREE.   I ask only for your comments,
 * suggestions and bug reports.   If you modify this program, I would
 * appreciate a copy of the new source code.   Please don't delete my
 * name from the program.
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (602) 279-2673.
 *
 * Enjoy!     Samuel H. Smith
 *
 *
 *)


const
   version = 'sCP - Unix-like file copy, (slow v3.1, SYSTEM_DATE)';
   buf_size = 4608;


type
   anystring = string[80];


#include <regpack.inc>    {DOS register package}
#include <dosio.inc>      {DOS I/O function library}
#include <getfiles.inc>   {Get file list from wildcard}
#include <int2real.inc>   {Convert unsigned int to real}
#include <tolower.inc>    {Convert string to lower case}


var
   buf:      array[0..$7FFF] of byte;
   cur_dir:  anystring;



procedure translate(var str: anystring; old: char; new: char);
var
   i: integer;
begin
   for i := 1 to length(str) do
      if str[i] = old then
         str[i] := new
      else
         str[i] := upcase(str[i]);
end;


procedure makepath(var name: anystring; dir: anystring);
var
   i:    integer;
   rest: anystring;

begin

(* make sure device is specified in pathname *)
   if name[1] = '/' then
      name := copy(dir,1,2) + name
   else

(* make sure pathname is absolute *)
   if name[2] <> ':' then
      name := dir + name;

(* remove references to current directory *)
   i := pos('/./',name);
   while i > 0 do
   begin
      name := copy(name,1,i) + copy(name,i+3,length(name));
      i := pos('/./',name);
   end;

(* remove references to parent directory *)
   i := pos('/../',name);
   while i > 0 do
   begin
      rest := copy(name,i+4,length(name));
      i := i - 1;

      while (name[i] <> '/') and (i > 2) do
         i := i - 1;

      name := copy(name,1,i) + rest;

      i := pos('/../',name);
   end;

(* change absolute into relative if possible *)
   if copy(name,1,length(cur_dir)) = cur_dir then
      name := copy(name,length(cur_dir)+1,length(name));
end;


procedure copyfile(input: anystring;  output: anystring);
var
   infd:    integer;
   outfd:   integer;
   length:  real;
   total:   real;
   incnt:   integer;
   outcnt:  integer;
   time:    integer;
   date:    integer;

begin

   if input = output then
   begin
      writeln;
      writeln('cp: input and output names must be different');
      exit;
   end;

   infd := dos_open(input, open_read);

   dos_file_times(infd, time_get, time, date);

   length := dos_lseek(infd, seek_end, 0);

   if dos_lseek(infd, seek_start, 0) <> 0 then
   begin
      writeln;
      writeln('cp: input seek error');
      halt;
   end;

   outfd := dos_create(output, 0);
   if outfd = dos_error then
   begin
      writeln;
      writeln('cp: can''t create output');
      halt;
   end;


   total := 0;
   repeat
      incnt := dos_read(infd, buf, buf_size);

      if incnt <> 0 then
      begin
         outcnt := dos_write(outfd, buf, incnt);
         total := total + int_to_real(outcnt);
         write('.');
      end;

   until (incnt <> buf_size);

   if total <> length then
   begin
      writeln;
      writeln('cp: copy size error');
      halt;
   end;

   if dos_close(infd) = dos_error then
   begin
      writeln;
      writeln('cp: input close failed');
      halt;
   end;

   dos_file_times(outfd, time_set, time, date);

   if dos_close(outfd) = dos_error then
   begin
      writeln;
      writeln('cp: output close failed');
      halt;
   end;
end;


procedure procfile(source:   anystring;
                   dest:     anystring);
var
   outfile:    file;
   infile:     file;
   outname:    anystring;
   bufcnt:     integer;
   i:          integer;
   len:        integer;

begin

   translate(source,'\','/');
   outname := '';              {build destination filename}
   i := length(source);
   while (i > 0) and (source[i] <> '/') and (source[i] <> ':') do
   begin
      outname := source[i] + outname;
      i := i - 1;
   end;

   len := length(outname);

   makepath(outname,dest);

   source := tolower(source);
   outname := tolower(outname);
   write(source,'':12-len,' -> ', outname,' ','':12-len);

   copyfile(source, outname);

   writeln;

end;


procedure procparam(pattern: anystring;
                    dest:    anystring);
var
   i:   integer;

begin
   translate(dest,'\','/');
   if (dest[length(dest)] <> '/') and
      (dest[length(dest)] <> ':') then
         dest := dest + '/';
   makepath(dest,cur_dir);

   translate(pattern,'\','/');
   makepath(pattern,cur_dir);

   translate(pattern,'/','\');
   getfiles(pattern,filetable,filecount);

   for i := filecount downto 1 do
      procfile(filetable[i],dest);
end;


procedure usage;
begin
   writeln;
   writeln(version);
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
   writeln;
   writeln('Usage:');
   writeln('  cp SOURCE DEST');
   writeln('  cp SOURCE1 SOURCE2 ... SOURCEn DEST');
   writeln('  cp SOURCE');
   writeln;
   writeln('Examples:');
   writeln('  cp a:*.arc             ;copies all .arc files into current dir');
   writeln('  cp /pcb/main/*.* /pcb/gen/*.* d:/backup');
   writeln;
   writeln('Cp works just like the DOS copy command, with the following exceptions:');
   writeln('  - Both / and \ are allowed as directory delimiters');
   writeln('  - Multiple source files may be specified');
   writeln('  - Network file sharing is supported');
   writeln('  - Files cannot be renamed during a copy (I.E. DEST must be a directory)');
   flush(output);
   halt(1);
end;


var
   i:     integer;
   dest:  anystring;

begin
   clreol;

   if paramcount = 0 then
      usage;

   getdir(0,cur_dir);
   translate(cur_dir,'\','/');
   if cur_dir[length(cur_dir)] <> '/' then
      cur_dir := cur_dir + '/';

   if paramcount = 1 then
      procparam(paramstr(1),'.')
   else

   for i := 1 to paramcount-1 do
      procparam(paramstr(i),paramstr(paramcount));

   flush(output);
end.

