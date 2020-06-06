
(*
 * TMAKE - Turbo Pascal "MAKE" Facility
 *         For use with TSHELL and TPP
 *
 * Written by Samuel H. Smith, 19-Mar-87
 *
 *)

{$p512,r-,c-,k+,v-}

program turbo_make_facility;

#define SHAREWARE_RELEASE
#undef DEBUGGING

const
   whoami = 'TMAKE';
   program_version = 'Version 1.1';
   last_compile = 'Compiled:  SYSTEM_DATE';
   maxfiles = 250;

type
   anystring = string[128];
   inctable = array[1..maxfiles] of string[65];

var
   trace: boolean;


#include <strutil.inc>   {string utility macros}
#include <incdec.inc>    {increment/decrement scalars}
#include <regpack.inc>   {register package declaration}
#include <filedate.inc>  {return file julian date}
#include <getfdate.inc>  {return file string date}
#include <rempath.inc>   {remove/manipulate file paths}
#include <reverse.inc>   {reverse order of characters in a string}
#include <locfile.inc>   {locate files with environment variables}
#include <getfiles.inc>  {get wildcard file lists}


function last_update(var name: anystring): real;
var
   date: real;
begin
   date := filedate(name);
   last_update := date;
   if trace then
      writeln(':   ',get_file_date(name),'  ',name);
end;



(*------------------------------------------
 *
 * rebuild_listfile
 *    scan a sourcefile; write a list of includes to
 *    the specified filelist file
 *
 *)

procedure rebuild_listfile(var source:   anystring;
                           var filelist: anystring);
var
   sfd:       text[2048];
   lfd:       text;
   line_txt:  anystring;     {current source line}
   incfile:   anystring;     {include filename if any}

#include "textinc.inc"   {extract turbo include lines}

begin
   writeln(con,'   Building include list for ',source);

(* make sure that the IFL (include filelist) subdirectory is present *)
   {$i-} mkdir( path_only(source) + 'IFL'); {$i+}
   if ioresult = 0 then
      writeln(con,'   ',path_only(source) + 'IFL subdirectory created');

(* open the listfile and the sourcefile *)
   assign(lfd,filelist);
   rewrite(lfd);
   assign(sfd,source);
   reset(sfd);

   while not eof(sfd) do
   begin
      readln(sfd,line_txt);          {add include statements to include list}

      extract_include;
      if LEN(incfile) <> 0 then
         writeln(lfd,incfile);
   end;

   close(sfd);
   close(lfd);
end;



(*------------------------------------------
 *
 * add_filelist
 *    add all files used by the specified sourcefile (and all of it's
 *    include files) to the includefile list.  builds filelist files
 *    when they are out of date.
 *
 *)

procedure add_filelist(var source: anystring;
                       var list:   inctable;
                       var count:  integer);
var
   filelist:     anystring;
   i:            integer;


(* add a file to the current filelist (only if not already on list *)
   procedure add_to_list(var incfile:    anystring);
   var
      i: integer;

   begin
      for i := 1 to LEN(incfile) do
         incfile[i] := upcase(incfile[i]);

      for i := 1 to count do
         if list[i] = incfile then
            exit;

      count := count + 1;
      COPY_STR(list[count], incfile);
   end;


   procedure read_listfile;
   var
      fd:       text[1024];
      incfile:  anystring;

   begin
      assign(fd,filelist);
      {$i-} reset(fd); {$i+}

      if ioresult <> 0 then
      begin
         if trace then
            writeln(con,'   Missing include file: ',source);
         exit;
      end;

      while not eof(fd) do
      begin
         readln(fd,incfile);
         add_to_list(incfile);
         add_filelist(incfile,list,count);
      end;

      close(fd);
   end;


(* add_filelist *)
begin

(* check for abort *)
   if keypressed then
   begin
      writeln(con,'** ABORTED');
      halt;
   end;

(* build the filelist filename - this is in the ./IFL subdirectory and
   bears a "reversed" filename and extention of the source file.  this
   convention allows multiple source files with the same basename and
   different extentions to be used. *)

   filelist := path_only(source) + 'IFL\' +
               reverse_string( remove_ext(remove_path(source)) ) + '.' +
               reverse_string( ext_only(source) );

(* a file depends on its'self *)
   add_to_list(source);

(* rebuild filelist if needed *)
   if last_update(source) > last_update(filelist) then
      rebuild_listfile(source,filelist);

(* load the filelist into the file table *)
    read_listfile;
end;




(*------------------------------------------
 *
 * turbo_make
 *    check all include files and generate a compile command
 *    if any of them are newer than the comfile
 *
 *)

procedure turbo_make(var source: anystring);
var
   object:   anystring;
   filelist: anystring;
   list:     inctable;
   count:    integer;
   uptodate: boolean;
   i:        integer;
   objdate:  real;


   procedure updated(name: anystring);
   begin
      writeln(con,'   Updated ',get_file_date(name),' ',name);
   end;

   procedure recompile(name: anystring);
   begin
      writeln;
      writeln('command/c tpbatch ',name);
   end;

begin
   source := remove_ext(source) + '.PAS';
   object := locate_file_env(remove_ext(source) + '.COM','PATH=');

   writeln(con);
   writeln(con,'Checking ',source);

   count := 0;
   add_filelist(source,list,count);

   objdate := last_update(object);
   uptodate := true;

   for i := 1 to count do
      if last_update(list[i]) > objdate then
      begin
         uptodate := false;
         updated(list[i]);
      end;

   if not uptodate then
      recompile(source)
   else
      writeln(con,'   Up to date');

end;



(*------------------------------------------
 *
 * use_script
 *    read the list of files in a make-stript and run turbo_make
 *    on each of them.
 *
 *)

procedure use_script(name: anystring);
var
   line:  anystring;
   fd:    text;

begin
   assign(fd,name);
   reset(fd);

   while not eof(fd) do
   begin
      readln(fd,line);
      turbo_make(line);
   end;

   close(fd);
end;


(*------------------------------------------
 *
 * signon
 *
 *)

procedure signon;
const
   copyright: anystring
      = 'Copyright (C) 1987 Samuel H. Smith;  All Rights Reserved.';

   procedure put(s: anystring);
   begin
      writeln(con,s);
   end;

begin
   put('');
   put('TMAKE - Turbo Pascal "MAKE" Utility.');
   put(program_version+',  '+last_compile);

#ifdef SHAREWARE_RELEASE    {for shareware or freeware distribution}
   put(copyright);
   put('');
   put('You may copy and distribute this program freely, provided that:');
   put('    1)   No fee is charged for such copying and distribution, and');
   put('    2)   It is distributed ONLY in its original, unmodified state.');
   put('');
   put('If you like this program, and find it of use, then your contribution');
   put('of $10 will be appreciated.');
   put('');
   put('Please refer all inquiries to:');
   put('    Samuel H. Smith             The Tool Shop PCBoard');
   put('    5119 N. 11th Ave 332           (602) 279-2673');
   put('    Phoenix, AZ 85013');
#endif

   put('');
   put('Usage:  '+whoami+' [-t] FILE ... FILE >temp.bat');
   put('        temp');
   put('');
   put('FILE assumes ".PAS"  (wildcards OK)');
   put('@FILE.TAB causes file list to be loaded from FILE.TAB');
end;


(*------------------------------------------
 *
 * main program
 *
 *)

var
   i,j: integer;
   par: anystring;

begin
   if paramcount = 0 then
   begin
      signon;
      halt;
   end;

   trace := false;

   for i := 1 to paramcount do
   begin
      par := paramstr(i);
      if par[1] = '-' then
         case upcase(par[2]) of
            'T':  trace := true;
            else
               begin
                  signon;
                  writeln(con,whoami,': Invalid option: ',par);
               end;
         end
      else

      if par[1] = '@' then
         use_script(copy(par,2,99))
      else

      begin
         par := remove_ext(par) + '.PAS';
         getfiles(par,filetable,filecount);

         if filecount = 0 then
            turbo_make(par)
         else

         for j := 1 to filecount do
            turbo_make(filetable[j]);
      end;
   end;
end.

