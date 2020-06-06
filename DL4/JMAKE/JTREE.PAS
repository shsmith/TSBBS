
(*
 * jtree - Print a package/object file dependancy tree for a
 *         Janus/ada source file
 *
 * This utility understands "withing" used in Janus/ada
 * and will generate a graphic tree showing what a given
 * source file depends on.
 *
 * Author: S.H.Smith, 14-Aug-86
 *
 *)

{$V-        Allow variable length strings}
{$P128,d-   Send writes through standard output}
{$R-        Dont Generate rangecheck code}


const
   whoami              = 'JTREE';      {program name for messages}

   release_date        = 'v1.0  (14-Aug-86 S.H.Smith)';
                                       {program release date}

   nametable_size      = 20;           {maximum number of "WITHed" files
                                        for any single .LIB or .PKG file}

   max_updates         = 100;          {maximum number of uptodate files
                                        in a single jmake run}


   default_updated_file_list = 'jmake.upd';
                                       {default file lists packages that are
                                        known to be up to date and should
                                        not be checked}


type
   anystring           = string[128];  {general purpose strings}

   filename            = string[65];   {a full filename}

   basename            = string[20];   {a filename without the .EXT}

   nametable           = array [1..nametable_size] of basename;
                                       {a table of filenames}


var
   uptodate:  array [1..max_updates] of basename;
                                       {list of files that are known
                                        to be up-to-date}

   updcnt:    integer;                 {count of files that are uptodate}

   updated_file_list: anystring;       {filename containing list of files
                                        known to be up to date}

   path_mode:  boolean;                {printing full pathnames?}

   formfeed:   boolean;                {print formfeed at end?}

   notrim_mode: boolean;               {stop trimming repeated branches?}

   condcomp_mode: boolean;             {conditional compile on?}


{$I \shs\tools\regpack.inc    Utility MSDOS register package data type}

{$I \shs\tools\filedate.inc   Utility to get file modification times}

{$I \shs\tools\locfile.inc    Utility to use search paths to locate files}

{$I \shs\tools\treelib.inc    Utility to format trees for output}

{$I \shs\tools\getfiles.inc   Utility to expand wildcards}




function file_exists(fname: filename): boolean;
                        {does file exist?}
var
   fd: file;

begin
   {$I-}
   assign(fd,fname);
   reset(fd);
   {$I+}

   if ioresult = 0 then
   begin
      file_exists := true;
      close(fd);
   end
   else
      file_exists := false;

   write(con,#13,'Checking: ',fname);
   clreol;

end;   {file_exists}



procedure have_seen(fname:  filename);

                        {record the fact that the specified file has
                         been seen already}
var
   i:  integer;

begin
   if notrim_mode then exit;

   i := pos('\',fname);      {remove any directory prefix from the name}
   while i > 0 do
   begin
      fname := copy(fname,i+1,length(fname));
      i := pos('\',fname);
   end;

   updcnt := updcnt + 1;    {add the name to the uptodate file list}
   uptodate[updcnt] := fname;

   if updcnt > max_updates then
   begin
      writeln(con);
      writeln(con,whoami,':  Too many updated files.');
      halt(1);
   end;

end;   {have_seen}



function has_been_seen(fname:  filename): boolean;

                        {see if the specified file has already been
                         seen}
var
   i:  integer;

begin

   i := pos('\',fname);      {remove any directory prefix from the name}
   while i > 0 do
   begin
      fname := copy(fname,i+1,length(fname));
      i := pos('\',fname);
   end;


   for i := 1 to updcnt do

      if uptodate[i] = fname then
      begin
         has_been_seen := true;
         exit;
      end;

   has_been_seen := false;

end;   {has_been_seen}



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

   if condcomp_mode = false then
   begin
      i := pos('@',line);
      if i > 0 then
         line := copy(line,1,i-1);    {remove any conditionals from the line}
   end;

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
                             var names:   nametable;
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

      if count = nametable_size then
      begin
         writeln(con);
         writeln(con,whoami,':  Too many "WITHed" files.');
         writeln(con,'source = ',line);
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
            writeln(con);
            writeln(con,whoami,':  Unexpected character in WITH statement;');
            writeln(con,'source = ',line);
            halt(1);
      end;

   until line[i] = ';';          {stop scanning at end of statement}

end;  {extract_filenames}



procedure make_with_list (name:       filename;
                          var names:  nametable;
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

end;  {make_with_list}




procedure tree_lib_file (node:           node_ptr;
                         fname:          basename);

forward;



procedure tree_pkg_file(node:           node_ptr;
                        fname:          basename);

                        {tree a .PKG file for a package.
                         this involves updating checking
                         .LIB file, all WITHed files}
var
   i:          integer;
   with_files: nametable;
   with_count: integer;
   pkgname:    filename;
   nodename:   filename;

begin

   pkgname := locate_file(fname+'.PKG');

   if file_exists(pkgname) then

      with node^ do                 {add filename to the node, if ok}
      begin
         if count = 0 then new(subs);
         count := count + 1;
         subs^[count] := new_node;

         if path_mode then
            nodename := pkgname
         else
            nodename := fname + '.PKG';

         if has_been_seen(pkgname) then
         begin
            subs^[count]^.name := nodename + '...';
            exit;
         end
         else
            subs^[count]^.name := nodename;
      end;


   make_with_list(pkgname, with_files, with_count);
                                   {find all "WITHed" packages used
                                    by the .PKG file}

   for i := 1 to with_count do
      with node^ do
         tree_lib_file(subs^[count],with_files[i]);
                                   {find all used LIB files}

   have_seen(pkgname);      {flag that we have been here before}

end;    {tree_pkg_file}




procedure tree_lib_file {(node:           node_ptr;
                          fname:          basename)};

                        {tree the .LIB file date for a given package.
                         this involves checking all of the WITHed
                         packages}
var
   i:          integer;
   with_files: nametable;
   with_count: integer;
   libname:    filename;
   nodename:   filename;

begin

   libname := locate_file(fname+'.LIB');

   if file_exists(libname) then

      with node^ do                 {add filename to the node, if ok}
      begin
         if count = 0 then new(subs);
         count := count + 1;
         subs^[count] := new_node;

         if path_mode then
            nodename := libname
         else
            nodename := fname + '.LIB';

         if has_been_seen(libname) then
         begin
            subs^[count]^.name := nodename + '...';
            exit;
         end
         else
            subs^[count]^.name := nodename;
      end;


   make_with_list(libname, with_files, with_count);
                                   {find all "WITHed" packages used
                                    by the .LIB file}

   for i := 1 to with_count do
      with node^ do
         tree_lib_file(subs^[count],with_files[i]);
                                   {find all .LIB files that are used}

   tree_pkg_file(node,fname);      {find all .PKG files that are used}

   have_seen(libname);      {flag that we have been here before}

end;  {tree_lib_file}





procedure tree_program(fname: basename);

                        {build and print the tree for an entire program}
var
   root:       node_ptr;

begin

   if pos('.',fname) > 0 then
      fname := copy(fname,1,pos('.',fname)-1);
   upcase_string(fname);

   root := new_node;
   root^.name := '';

   tree_lib_file(root,fname);       {tree the .LIB and .PKG files for
                                     the "root" package}

   write(con,#13);
   clreol;
   writeln;

   if root^.count = 1 then
      put_tree(output,root^.subs^[1])
   else
      put_tree(output,root);

   writeln;
   if formfeed then
      write(^L);

   flush(output);

   dispose_tree(root);

end;   {tree_program}



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
         have_seen(line);
      end;

      close(fd);
   end;
end;



procedure usage;
                        {print jmake command usage and halt}
begin
   writeln(con);
   writeln(con,whoami,' ',release_date);
   writeln(con);
   writeln(con,'Jtree will print a module tree for a Janus/ADA');
   writeln(con,'source file.  Jtree understands "WITH" statements');
   writeln(con,'and will determine which sources are needed to');
   writeln(con,'produce a .COM file.');
   writeln(con);
   writeln(con,'Usage:    jtree FILE {OPTIONS} ... FILEn');
   writeln(con);
   writeln(con,'Options:  -uFILENAME      ;known up-to-date file list');
   writeln(con,'          -p              ;include full pathnames');
   writeln(con,'          -c              ;include conditional compiles');
   writeln(con,'          -n              ;no trimming of repeated branches');
   writeln(con,'          -f              ;formfeed appended to output');
   writeln(con);
   writeln(con,'Example: jtree tqsort');
   halt(1);

end;  {usage}



(*
 * main program
 *
 *)

var
   i,j:       integer;
   comfiles:  nametable;
   comcount:  integer;
   par:       anystring;

begin

   if paramcount = 0 then     {print usage instructions, if needed}
      usage;


   updcnt := 0;               {do initialization}

   updated_file_list := default_updated_file_list;
   formfeed := false;
   path_mode := false;
   notrim_mode := false;
   condcomp_mode := false;

   comcount := 0;
   for i := 1 to paramcount do {scan all command line parameters}
   begin
      par := paramstr(i);
      if par[1] = '-' then

         case upcase(par[2]) of
            'U':  updated_file_list := copy(par,3,length(par));
            'F':  formfeed := true;
            'P':  path_mode := true;
            'N':  notrim_mode := true;
            'C':  condcomp_mode := true;
            else
               writeln(con,whoami,':  Invalid command line option: ',par);
               halt;
         end
      else

      begin
         if comcount = nametable_size then
         begin
            writeln(con,whoami,':  Too many files listed on command line.');
            writeln(con,'source = ',par);
            halt(1);
         end;

         comcount := comcount + 1;  {not an option; take it as a file to make}

         if pos('.',par) = 0 then
            par := par + '.PKG';
         comfiles[comcount] := par;
      end;
   end;

   load_updated_file_list;

   for i := 1 to comcount do         {make all of the listed COM files}
   begin
      getfiles(comfiles[i],filetable,filecount);
      for j := 1 to filecount do
         tree_program(filetable[j]);
   end;

end.
