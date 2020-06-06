
(*
 * pmake - Make turbo pascal compile script
 *
 * This utility understands "include" files used in turbo
 * pascal and will generate a series of command lines to build a
 * final .COM file from it's lower level sources.  It will
 * do the minimum number of operations required.
 *
 * Author: S.H.Smith, 5-May-86
 *         derived from Jmake for janus/ada compiles
 *
 *
 * Rules for making updates:
 *
 *    file.COM depends on x.pas
 *             and on all include files
 *
 *)

{$V-        Allow variable length strings}
{$P128,d-   Send writes through standard output}
{$R-        Do Generate rangecheck code}


const
   whoami              = 'PMAKE';      {program name for messages}

   release_date        = 'v1.3  (LAST_UPDATE S.H.Smith)';
                                       {program release date}

   inctable_size       = 100;          {maximum number of "include" files
                                        for any single .PAS file}

   default_logfile = 'CON';

   namecache_size      = 300;          {maximum entries in name/date cache}

type
   anystring           = string[128];  {general purpose strings}

   filename            = string[65];   {a full filename}

   basename            = string[65];   {a filename without the .EXT}

   inctable            = array [1..inctable_size] of filename;
                                       {a table of filenames}

   namecache_rec = record
      cname:   filename;
      ctime:   real;
   end;

var
   batch_options:     anystring;       {tpbatch command line options}
   trace_mode:        boolean;         {trace all file checks}

   logfile:           anystring;
   logfd:             text;

   namecache:         array[1..namecache_size] of namecache_rec;
   names:             integer;


#include "\shs\tools\regpack.inc"  {Utility MSDOS register package data type}
#include "\shs\tools\filedate.inc" {Utility to get file modification times}
#include "\shs\tools\locfile.inc"  {Utility to use search paths to locate files}
#include "\shs\tools\getfiles.inc" {Utility to expand wildcards to filelists}


function file_time(name: filename): real;

                        {get file modification time}
var
   time:  real;
   i:     integer;
   c:     char;

begin

   if keypressed then
   begin
      read(kbd,c);
      if c = #27 then
      begin
         writeln(con,'** Aborted');
         halt(1);
      end;
   end;


(* look in the cache for the time/date for this file *)
   i := 1;
   while (i <= names) do
   with namecache[i] do
      if name = cname then
      begin
         file_time := ctime;
         exit;
      end
      else
         i := i + 1;

(* file not in cache; lookup time/date from dos and add to cache *)
   time := filedate(name);

   if names < namecache_size then
   begin
      names := names + 1;
      with namecache[names] do
      begin
         cname := name;
         ctime := time;
      end;
   end;

   if trace_mode then
      if time = 0.0 then
         writeln(logfd,'Can''t find ',name,'.')
      else
         writeln(logfd,name,' was last updated at ',time:11:4,'.');
   flush(logfd);

   file_time := time;

end;   {file_time}



procedure upcase_string (var str: anystring);

                        {map a string to upper case}
var
   i:  integer;
begin
   for i := 1 to length(str) do
      str[i] := upcase(str[i]);     {map the line to upper case}
end;



procedure make_include_list (name:       filename;
                             var names:  inctable;
                             var count:  integer);

                        {scan a pascal file and build a list of all
                         files referenced by include statements}
var
   fd:         text;
   line:       anystring;
   i:          integer;

begin
   count := 0;

   assign(fd,name);
   {$I-}  reset(fd); {$I+}
   if ioresult <> 0 then
      exit;

   while (not eof(fd)) do
   begin

      readln(fd,line);                   {read a line of source}

      i := 1;
      while (i < ord(line[0])) and (line[i] <> '$') and (line[i] <> '#') do
         i := i + 1;

      if (line[i] = '$') then
      begin
         if (line[i-1] in ['{','*']) and (upcase(line[i+1]) = 'I') then
         begin
            i := i + 2;
            while line[i] = ' ' do
               i := i + 1;

            count := count + 1;
            names[count] := '';

            while line[i] in ['\','/','a'..'z','A'..'Z',
                              '_','0'..'9','-','.'] do
            begin
               names[count] := names[count] + upcase(line[i]);
               i := i + 1;
            end;
         end
      end
      else

      if (line[i] = '#') then
      begin
         if (copy(line,i,9) = '#include ') then
         begin
            i := i + 9;
            if line[i] in ['<','"',''''] then
               i := i + 1;

            count := count + 1;
            names[count] := '';

            while line[i] in ['\','/','a'..'z','A'..'Z',
                              '_','0'..'9','-','.'] do
            begin
               names[count] := names[count] + upcase(line[i]);
               i := i + 1;
            end;
         end;
      end;
   end;

   close(fd);

end;  {make_include_list}




procedure make_com_file(name:           basename);
                        {make sure that the .COM file for a program
                         is up to date.  this involves checking all
                         include files and possibly running the compiler}
var
   i:             integer;
   include_files: inctable;
   include_count: integer;
   time:          real;
   pastime:       real;
   comtime:       real;
   newest:        real;
   uptodate:      boolean;

begin

   i := pos('.',name);
   if i > 0 then
      name := copy(name,1,i-1);

   pastime := file_time(name+'.PAS');
   if pastime = 0 then
      exit;

   writeln(logfd);
   writeln(logfd,'Checking ',name,'.PAS');

   make_include_list(name+'.PAS', include_files, include_count);
                                   {find all "included" files}

   uptodate := true;
   comtime := file_time(name+'.COM');

   if comtime <> 0.0 then
   for i := 1 to include_count do
   begin
      time := file_time(include_files[i]);
      if time > comtime then
      begin
         writeln(logfd,'   ',include_files[i], ' last updated ',time:11:4);
         uptodate := false;
      end;
   end;

   if pastime > comtime then
   begin
      uptodate := false;           {check to see if the program body
                                    has changed}
      writeln(logfd,'   ',name, '.PAS last updated ',pastime:11:4);
  end;

   if not uptodate then
   begin                           {if file is newer than the .COM file,
                                    a compile run needs to be made}
      writeln;
      writeln('ctime Turbo Compile: ',name,' >>\tmp\joblog.prn');
      writeln('command/c tpbatch ', name, ' ',batch_options);
      flush(output);
   end
   else
      writeln(logfd,'   up to date');

end;    {make_com_file}



procedure make_prog(name:           basename);
var
   i: integer;

begin

   upcase_string(name);
   i := pos('.',name);
   if i = 0 then
      name := name + '.PAS';

   getfiles(name,filetable,filecount);
   if filecount = 0 then
      make_com_file(name)
   else
   for i := 1 to filecount do
      make_com_file(filetable[i]);

end;



procedure usage;        {print pmake command usage and halt}
begin
   writeln(con);
   writeln(con,whoami,' ',release_date);
   writeln(con);
   writeln(con,'Pmake will build a batchfile to compile FILE.COM using the ');
   writeln(con,'Batch Turbo Pascal.  Compilation commands will be generated only');
   writeln(con,'if a source file has been changed since the last compile.');
   writeln(con);
   writeln(con,'Usage:    pmake FILE {OPTIONS} ... FILEn');
   writeln(con,'  or      pmake @SCRIPT {OPTIONS} ... FILEn');
   writeln(con);
   writeln(con,'FILE is the base filename of the program to check.');
   writeln(con,'@SCRIPT specifies a file containing a list of files to be checked.');
   writeln(con);

   writeln(con,'Options:  -T              ;trace file checks and accesses');
   writeln(con,'          -Bstring        ;use "string" for tpbatch batch options');
   writeln(con,'          -Ofile          ;output update list to "file"');
   writeln(con);
   writeln(con,'Examples: pmake tqsort >temp.bat -Oprn');
   writeln(con,'          temp');
   writeln(con);
   writeln(con,'          pmake taskdemo -t -coa0800^mq');
   halt(1);

end;  {usage}



(*
 * main program
 *
 *)

var
   i:         integer;
   comfile:   anystring;
   par:       anystring;
   line:      anystring;
   fd:        text;

begin

   if paramcount = 0 then     {print usage instructions, if needed}
      usage;

   names := 0;
   batch_options := '';
   trace_mode := false;
   logfile := default_logfile;
   comfile := '';

   for i := 1 to paramcount do    {scan all command line parameters}
   begin
      par := paramstr(i);
      if par[1] = '-' then

         case upcase(par[2]) of
            'B':  batch_options := copy(par,3,length(par));
            'T':  trace_mode := true;
            'O':  logfile := copy(par,3,99);
            else
               writeln(con,whoami,':  Invalid command line option: ',par);
               halt;
         end
      else

      begin
         if comfile <> '' then
         begin
            writeln(con,whoami,':  Too many files listed on command line.');
            writeln(con,'source = ',par);
            halt(1);
         end;

         comfile := par;
      end;
   end;

   if comfile = '' then
      usage;

   assign(logfd,logfile);
   rewrite(logfd);

(* process single file *)
   if comfile[1] <> '@' then
      make_prog(comfile)
   else

(* read script and process all files listed *)
   begin
      assign(fd,copy(comfile,2,99));
      reset(fd);

      while not eof(fd) do
      begin
         readln(fd,comfile);
         make_prog(comfile);
      end;

      close(fd);
   end;

   close(logfd);
end.

