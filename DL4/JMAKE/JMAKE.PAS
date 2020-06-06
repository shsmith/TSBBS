
(*
 * jmake - Make Janus/ada compile script
 *
 * This utility understands "withing" used in Janus/ada
 * and will generate a series of command lines to build a
 * final .COM file from it's lower level sources.  It will
 * do the minimum number of operations required.
 *
 * Author: S.H.Smith, 31-Mar-86
 *
 * NOTE:  THIS PROGRAM MUST BE COMPILED WITH 'MIN HEAP' AND 'MAX HEAP'
 *        SET TO 300!!!!
 *
 *
 * Rules for making updates:
 *
 *    file.COM depends on x.JRL
 *    x.JRL    depends on x.SYM, x.PKG
 *    x.SYM    depends on x.LIB, {y.SYM}  (recursive relationship)
 *
 *)

{$V-        Allow variable length strings}
{$P128,d-   Send writes through standard output}
{$R-        Dont Generate rangecheck code}


const
   whoami              = 'JMAKE';      {program name for messages}

   release_date        = 'v1.2  (28-Jul-86 S.H.Smith)';
                                       {program release date}

   filetable_size      = 20;           {maximum number of "WITHed" files
                                        for any single .LIB or .PKG file}

   max_updates         = 100;          {maximum number of uptodate files
                                        in a single jmake run}


   compiler_command    = 'janus';      {janus/ada compiler command}

   default_compiler_options = '/sd';


   linker_command      = 'jlink';      {janus/ada linker command}

   default_linker_options = '';

   default_updated_file_list = 'jmake.upd';
                                       {default file lists packages that are
                                        known to be up to date and should
                                        not be checked}


type
   anystring           = string[128];  {general purpose strings}

   filename            = string[65];   {a full filename}

   basename            = string[20];   {a filename without the .EXT}

   filetable           = array [1..filetable_size] of basename;
                                       {a table of filenames}


var
   minram:    integer;                 {minimum amount of free ram}


   uptodate:  array [1..max_updates] of basename;
                                       {list of files that are known
                                        to be up-to-date}

   updcnt:    integer;                 {count of files that are uptodate}


   prev_name: filename;                {previous filename used in file_time}

   prev_time: real;                    {previous time used in file_time}


   indent:  integer;                   {current trace message indentation}


   compiler_options:  anystring;       {command line options for the compiler}

   linker_options:    anystring;       {command line options for the linker}

   trace_mode:        boolean;         {trace all file checks}

   quiet_mode:        boolean;         {suppress various commentary messages}

   memcheck_mode:     boolean;         {check free memory at times}

   updated_file_list: anystring;       {filename containing list of files
                                        known to be up to date}



{$I \shs\tools\regpack.inc    Utility MSDOS register package data type}

{$I \shs\tools\filedate.inc   Utility to get file modification times}

{$I \shs\tools\subproc.inc    Utility to execute DOS subprocesses}

{$I \shs\tools\locfile.inc    Utility to use search paths to locate files}



function file_time(name: filename): real;

                        {get file modification time.  does not call
                         dos when the same file is used more than once}
begin

   if prev_name <> name then
   begin
      prev_time := filedate(name);

      if trace_mode then
         if prev_time = 0.0 then
            writeln('':indent,'Can''t find ',name,'.')
         else
            writeln('':indent,name,' was last updated at ',prev_time:11:6,'.');
      flush(output);
   end;

   prev_name := name;
   file_time := prev_time;

end;   {file_time}



procedure has_been_updated(name:  filename);

                        {record the fact that the specified file has
                         been verified as up to date.  this is used
                         to prevent multiple checks on the same file}
var
   i:  integer;

begin
   if (not quiet_mode) or trace_mode then
      writeln('':indent,name,' is up to date.');
   flush(output);

   i := pos('\',name);      {remove any directory prefix from the name}
   while i > 0 do
   begin
      name := copy(name,i+1,length(name));
      i := pos('\',name);
   end;

   updcnt := updcnt + 1;    {add the name to the uptodate file list}
   uptodate[updcnt] := name;

   if updcnt > max_updates then
   begin
      writeln(whoami,':  Too many updated files.');
      halt(1);
   end;

end;   {has_been_updated}



function is_uptodate(name:  filename): boolean;

                        {see if the specified file has already been
                         checked and is up to date}
var
   i:  integer;

begin
   if minram > maxavail shr 6 then
      minram := maxavail shr 6;


   i := pos('\',name);      {remove any directory prefix from the name}
   while i > 0 do
   begin
      name := copy(name,i+1,length(name));
      i := pos('\',name);
   end;


   for i := 1 to updcnt do

      if uptodate[i] = name then
      begin
         is_uptodate := true;

         if trace_mode and (not quiet_mode) then
            writeln('':indent,name,' is already known to be up to date.');

         exit;
      end;


   is_uptodate := false;

   if trace_mode then
   begin
      writeln;
      writeln('':indent,'Make sure that ',name,' is up to date.');
      flush(output);
   end;

end;   {is_uptodate}



function execute (command:  anystring;
                  onfile:   anystring;
                  options:  anystring): boolean;

                       {execute a dos command; return TRUE if any
                        errorlevel type errors}
var
   i:       integer;
   cdir:    anystring;
   ndir:    anystring;

begin
   writeln;

   getdir(0,cdir);     {get current directory path}
   ndir := '';         {find out what dir the workfile is in}

   while pos('\',onfile) > 0 do
   begin
      ndir := ndir + copy(onfile,1,pos('\',onfile));
      onfile := copy(onfile,pos('\',onfile)+1,length(onfile));
   end;

   if ndir <> '' then
   begin
      if ndir[length(ndir)] = '\' then
         ndir[0] := pred(ndir[0]);

{$I-}
      chdir(ndir);
{$I+}
      if ioresult <> 0 then
         writeln(whoami,':  Chdir to ',ndir,' failed');
   end;


   flush(output);
   write(con,whoami,':  Executing "',command,' ',onfile,' ',options,'"',#13);
   write(whoami,':  Executing "',command,' ',onfile,' ',options,'"');
   if ndir <> '' then
      write(' from ',ndir);
   writeln;


   command := command + '.COM';         {locate the program file; prompt for
                                         a disk change if needed}
   repeat

      command := locate_file(command);

      if file_time(command) = 0 then
      begin
         flush(output);
         write(con,whoami,':  Can''t locate ',command,
                          ',  insert program disk and press ENTER:');
         readln;
      end;

   until file_time(command) > 0.0;


   writeln;
   flush(output);

   i := subprocess(command+' '+onfile+' '+options);
                                  {execute program and get return status}
   if i <> 0 then
      execute := true    {command failed}
   else
      execute := false;  {command worked}


   chdir(cdir);          {change back to the original directory}

   if minram > maxavail shr 6 then
      minram := maxavail shr 6;

   flush(output);
   write(con,#13);
   clreol;

end;   {execute}



procedure cant_make (name:  filename);

                        {display a message and abort jmake if one of
                         the required files cannot be updated}
var
   fd:  file;

begin

   writeln(whoami+':  Can''t make ',name,'.');

   assign(fd,name);
   {$I-} erase(fd); {$I+}

   if ioresult = 0 then
      writeln(whoami,':  Faulty ',name,' has been deleted.');

   if memcheck_mode then
      writeln(minram,'K unused memory.');

   halt(1);

end;   {cant_make}



procedure upcase_string (var str: anystring);

                        {map a string to upper case}
var
   i:  integer;
begin
   for i := 1 to length(str) do
      str[i] := upcase(str[i]);     {map the line to upper case}
end;



procedure get_source_line (var fd:    text;
                           var line:  anystring);

                        {get a line of source file a file, map it to
                         upper case and remove ada style comments}
var
   i:  integer;

begin
   readln(fd,line);                   {read a line of source}

   upcase_string(line);

   i := pos('--',line);
   if i > 0 then
      line := copy(line,1,i-1);       {remove any comment from the line}

   line := line + ' ';                {make sure there is a delimiter at
                                       the end of the line}
end;  {get_source_line}



procedure skip_whitespace (var fd:      text;
                           var line:    anystring;
                           var i:       integer);

   {skip over all white space starting at line[i].  returns
    with line[i] as the first non-blank character.  skips blank
    lines when needed}

begin
   while line[i] <= ' ' do
   begin
      if i = length(line) then
      begin
         get_source_line(fd, line);
         i := 1;
      end
      else
         i := i + 1;
   end;
end;


procedure extract_filenames (var fd:      text;
                             line:        anystring;
                             var names:   filetable;
                             var count:   integer);

                        {extract a list of filenames from line.  the expected
                         format is that of an ada WITH statement.  the list
                         is delimited by commas and ends with a semicolon.
                         file lists are allowed to span multiple lines}
var
   i:     integer;
   name:  basename;

begin
   i := 1;

   repeat
      skip_whitespace (fd, line, i);

      name := '';                {extract the next filename}

      while line[i] in ['A'..'Z','0'..'9','_'] do
      begin
            if length(name) < 8 then
               name := name + line[i];
            i := i + 1;
      end;

      if count = filetable_size then
      begin
         writeln;
         writeln(whoami,':  Too many "WITHed" files.');
         writeln('source = ',line);
         exit;
      end;

      count := count + 1;      {add name to the table}
      names[count] := name;


      skip_whitespace (fd, line, i);

      case line[i] of
         ',':
            i := i + 1;       {skip over delimiters after the name}

         ';','A'..'Z':
            ;

         else
            writeln;
            writeln(whoami,':  Unexpected character in WITH statement;');
            writeln('source = ',line);
            halt(1);
      end;

   until line[i] = ';';          {stop scanning at end of statement}

end;  {extract_filenames}



procedure make_with_list (name:       filename;
                          var names:  filetable;
                          var count:  integer);

                        {scan an ada source file and build a list of all
                         files referenced by WITH statements}
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


   i := 0;
   while (not eof(fd)) and (i = 0) do
   begin

      get_source_line(fd,line);          {get a line of source}

      i := pos('WITH ',line);            {if this line contains a with
                                          statement, then parse the filenames
                                          that are listed after it}
      if i > 0 then
         extract_filenames (fd, copy(line,i+4,length(line)), names, count);


      i := pos('PACKAGE ',line);

      if i = 0 then
         i := pos('GENERIC ',line);

      if i = 0 then
         i := pos('PROCEDURE ',line);     {stop looking when PACKAGE, GENERIC
                                           or PROCEDURE statement is seen
                                           (WITHs allowed only outside
                                           the package body/spec}
   end;

   close(fd);

   if trace_mode and (count > 0) then
   begin
      writeln('':indent,'Packages "WITHed" by ',name,':');
      for i := 1 to count do
         writeln('':indent,'   ',names[i]);
   end;

end;  {make_with_list}




procedure make_sym_file (name:           basename;
                         var newest_sym: real;
                         var newest_jrl: real);

forward;



procedure make_jrl_file(name:           basename;
                        var newest_sym: real;
                        var newest_jrl: real);

                        {make sure that the .JRL file for a package
                         is up to date.  this involves updating the
                         .SYM file, all WITHed .SYM files, and then
                         compiling the package body, if needed}
var
   i:          integer;
   with_files: filetable;
   with_count: integer;
   sym_times:  real;
   pkgname:    filename;
   jrlname:    filename;

begin

   if is_uptodate(name+'.JRL') then
      exit;

   indent := indent + 3;


   pkgname := locate_file(name+'.PKG');
   make_with_list(pkgname, with_files, with_count);
                                   {find all "WITHed" packages used
                                    by the .PKG file}

   sym_times := 0;
   for i := 1 to with_count do
      make_sym_file(with_files[i],sym_times,newest_jrl);
                                   {make sure there is a .SYM file
                                    for each one of the WITHed
                                    packages (recursive)}


   if sym_times > newest_sym then
      newest_sym := sym_times;     {keep track of what's newest}


   if file_time(pkgname) > newest_sym then
      newest_sym := file_time(pkgname);
                                   {check to see if the package body
                                    has changed and needs to be recompiled}


   jrlname := locate_file(name+'.JRL');
   if newest_sym > file_time(jrlname) then
   begin                           {if any .SYM or the .PKG file is
                                    newer than the .JRL file,
                                    a body compile run needs to
                                    be made to make a new .JRL file}

      if trace_mode then
         writeln('':indent,'The newest file used by ',jrlname,
                           ' was updated at ',newest_sym:11:4,'.');

      if execute (compiler_command,pkgname,compiler_options) then
         cant_make(jrlname);

      jrlname := locate_file(name+'.JRL');
      if newest_sym > file_time(jrlname) then
         cant_make(jrlname);
   end;


   if file_time(jrlname) > newest_jrl then
      newest_jrl := file_time(jrlname)
   else

   if file_time(jrlname) = 0 then
      cant_make(jrlname+'  ('+pkgname+' not found)');
                                   {if source files are missing,
                                    the .JRL file can't be made!}


   has_been_updated(jrlname);      {flag that we now know that this .JRL
                                    file is up to date}
   indent := indent - 3;

end;    {make_jrl_file}




procedure make_sym_file {(name:           basename;
                          var newest_sym: real;
                          var newest_jrl: real)};

                        {make sure that the .SYM file is up to date for
                         a given package.  this involves checking that
                         all of the WITHed packages are also up to date}
var
   i:          integer;
   with_files: filetable;
   with_count: integer;
   sym_times:  real;
   libname:    filename;
   symname:    filename;

begin

   if is_uptodate(name+'.SYM') then
      exit;

   indent := indent + 3;

   libname := locate_file(name+'.LIB');
   make_with_list(libname, with_files, with_count);
                                   {find all "WITHed" packages used
                                    by the .LIB file}

   sym_times := 0;
   for i := 1 to with_count do
      make_sym_file(with_files[i],sym_times,newest_jrl);
                                   {make sure there is a .SYM file
                                    for each one of the WITHed
                                    packages (recursive)}


   if file_time(libname) > sym_times then
      sym_times := file_time(libname);
                                   {check to see if the package specification
                                    has changed and needs to be recompiled}


   symname := locate_file(name+'.SYM');
   if sym_times > file_time(symname) then
   begin                           {if some of the files were newer than the
                                    .SYM file, a specification compile
                                    to make a new .SYM file}

      if trace_mode then
         writeln('':indent,'The newest file used by ',symname,
                           ' was updated at ',sym_times:11:4,'.');

      if execute (compiler_command,libname,compiler_options) then
         cant_make(symname);

      symname := locate_file(name+'.SYM');
      if sym_times > file_time(symname) then
         cant_make(symname);
   end;


   if file_time(symname) > sym_times then
      sym_times := file_time(symname);

   if sym_times > newest_sym then
      newest_sym := sym_times;

   has_been_updated(symname);


   indent := indent - 3;

   make_jrl_file(name,sym_times,newest_jrl);
                             {make sure there is a .JRL file for
                              this package}

end;  {make_sym_file}





procedure make_com_file(name: basename);

                        {make sure that a .COM file is up to date.  this
                         involves updating the .JRL file and running
                         the linker, if needed}
var
   comname:    filename;
   newest_jrl: real;
   newest_sym: real;

begin

   if pos('.',name) > 0 then
      name := copy(name,1,pos('.',name)-1);

   writeln;
   upcase_string(name);
   comname := locate_file(name+'.COM');

   writeln(comname,':');


   newest_jrl := 0;
   newest_sym := 0;
   make_sym_file(name,newest_sym,newest_jrl);
                                    {make the .SYM and .JRL files for
                                     the "root" package}


   comname := locate_file(name+'.COM');
   if newest_jrl > file_time(comname) then
   begin                           {if some of the files were newer than the
                                    .COM file, a link run needs to be made
                                    to make a new .COM file}
      if trace_mode then
         writeln('':indent,'The newest file used by ',comname,
                           ' was updated at ',newest_jrl:11:4,'.');

      if execute (linker_command,name,linker_options) then
         cant_make(comname);

      comname := locate_file(name+'.COM');
      if newest_jrl > file_time(comname) then
         cant_make(comname);
   end;

   has_been_updated(comname);

end;   {make_com_file}



procedure load_updated_file_list;   {load in a file containing a
                                     list of files that are known to
                                     already be up to date.  this file
                                     list is used to speed up checks where
                                     standard libraries never change}
var
   fd: text;
   line: anystring;
   name: anystring;

begin
   name := locate_file(updated_file_list);
   assign(fd,name);

   {$I-} reset(fd); {$I+}

   if ioresult = 0 then
   begin

      while not eof(fd) do
      begin
         readln(fd,line);
         has_been_updated(line);
      end;

      close(fd);
   end;
end;



procedure usage;
                        {print jmake command usage and halt}
begin
   writeln;
   writeln(whoami,' ',release_date);
   writeln;
   writeln('Jmake will try to make FILE.COM using the Janus/ADA');
   writeln('compiler and linker.  Jmake understands "WITH" statements');
   writeln('and will determine the best order of commands needed to');
   writeln('produce a fully up to date .COM file.');
   writeln;
   writeln('Usage:    jmake FILE {OPTIONS} ... FILEn');
   writeln;
   writeln('Options:  -t              ;trace file checks and accesses');
   writeln('          -q              ;quiet mode - suppress most messages');
   writeln('          -cSTRING        ;use STRING for compiler options');
   writeln('          -lSTRING        ;use STRING for linker options');
   writeln('          -uFILENAME      ;known up-to-date file list');
   writeln;
   writeln('Examples: jmake tqsort');
   writeln('          jmake taskdemo -t -c/sc/q/w -l/p');
   halt(1);

end;  {usage}



(*
 * main program
 *
 *)

var
   i:         integer;
   comfiles:  filetable;
   comcount:  integer;
   par:       anystring;

begin

   if paramcount = 0 then     {print usage instructions, if needed}
      usage;

   updcnt := 0;               {do initialization}
   prev_name := '';
   indent := 0;
   minram := maxavail shr 6;

   compiler_options := default_compiler_options;
   linker_options := default_linker_options;
   trace_mode := false;
   quiet_mode := false;       {provide defaults for command options}
   memcheck_mode := false;
   updated_file_list := default_updated_file_list;

   comcount := 0;
   for i := 1 to paramcount do {scan all command line parameters}
   begin
      par := paramstr(i);
      if par[1] = '-' then

         case upcase(par[2]) of
            'C':  compiler_options := copy(par,3,length(par));
            'L':  linker_options := copy(par,3,length(par));
            'T':  trace_mode := true;
            'Q':  quiet_mode := true;
            'M':  memcheck_mode := true;
            'U':  updated_file_list := copy(par,3,length(par));
            else
               writeln(whoami,':  Invalid command line option: ',par);
               halt;
         end
      else

      begin
         if comcount = filetable_size then
         begin
            writeln(whoami,':  Too many files listed on command line.');
            writeln('source = ',par);
            halt(1);
         end;

         comcount := comcount + 1;  {not an option; take it as a file to make}
         comfiles[comcount] := par;
      end;
   end;

   if memcheck_mode then
      if execute ('memchk','','') then ;

   if quiet_mode then
      load_updated_file_list
   else
   begin
      quiet_mode := true;
      load_updated_file_list;
      quiet_mode := false;
   end;

   for i := 1 to comcount do         {make all of the listed COM files}
      make_com_file(comfiles[i]);

   if memcheck_mode then
      writeln(minram,'K unused memory.');
end.

