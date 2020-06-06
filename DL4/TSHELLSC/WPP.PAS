
(*
 * TSHELL - Turbo Pascal Preprocessor "SHELL" program.
 * TPP - Turbo Pascal Preprocessor (stand-alone version)
 * WPP - WordPerfect Preprocessor
 *
 * S.H.Smith, 11-Dec-86
 *
 *)

{$d-,k+,r-,v-}

program standalone_turbo_pascal_shell;

#define SHAREWARE_RELEASE      {define to make shareware/freeware version}
#undef DEBUGGING
#define STAND_ALONE

const tshell_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Stand-alone Preprocessor (main) 1.2'#0;

const
   program_version =   'Version 1.2';
   last_update =       'Compiled: SYSTEM_DATE';
   whoami =            'WPP';
   max_include =       6;
   maxlen      =       180;   {longest wp block to read}
   longest_line =      200;

type
   anystring =         string [255];
   longstring =        string [255];
   input_file =        file of byte;
   output_file =       file of byte;

var
   mainfile:           anystring;     {main file name}

   line_txt:           longstring;     {current source line}
   incfile:            longstring;     {include filename if any}

   inclevel:           integer;       {include nesting level}
   incfd:              array[1..max_include] of input_file;
   incname:            array[1..max_include] of string[64];
   incline:            array[1..max_include] of integer;

   lines:              integer;

   error_count:        integer;

   outfd:              output_file;

   endfile:            boolean;


#include <strutil.inc>   {string utility macros}
#include <regpack.inc>   {registerpackage declaration}
#include <sysdate.inc>   {get system time/date}
#include <getfdate.inc>  {get file time/date}
#include <locfile.inc>   {locate file with PATH}
#include <rempath.inc>   {remove pathname prefix}
#include <incdec.inc>    {integer increment/decrement}
#include <stripspc.inc>  {strip leading/trailing spaces}
#include <stoupper.inc>  {map strings to upper case}


(*------------------------------------------
 *
 * wordperfect interface
 *
 *)
procedure read_line(var fd: input_file; var line: longstring);
var
   b: byte;
begin
   TRUNC(line);
   endfile := false;

   repeat
{$i-}
      read(fd,b);
{$i+}
      if ioresult <> 0 then
         endfile := true
      else
         line := line + chr(b);
   until (b = 10) or (LEN(line) >= maxlen) or endfile;
end;

procedure write_line(line: longstring);
var
   i: integer;
   b: byte;
begin
   for i := 1 to LEN(line) do
   begin
      b := ord(line[i]);
      write(outfd,b);
   end;
end;



#include "textinc.inc"   {tshell extract include lines}
#include "tshlog.inc"    {tshell compilation logging}
#include "tsherror.inc"  {tshell error handling}
#include "tshpp.inc"     {tshell preprocessor functions}


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
   put('WPP - WordPerfect Preprocessor');
   put(program_version+',  '+last_update);

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
   put('    5119 N. 11th Ave 332            (603) 379-3673');
   put('    Phoenix, AZ 85013');
#endif

end;


(*------------------------------------------
 *
 * Initialize
 *
 *)

procedure initialize;
begin
   if paramcount <> 1 then
   begin
      signon;
      writeln(con,whoami,':  Missing source filename');
      writeln(con);
      writeln(con,'Usage:  ',whoami,' mainfile[.WP]');
      halt(1);
   end;

   mainfile := paramstr(1);
   if pos('.',mainfile) = 0 then
      mainfile := mainfile + '.WP';

   inclevel := 1;
   incname[inclevel] := mainfile;
   incline[inclevel] := 0;

   assign(incfd[inclevel],mainfile);
   {$i-} reset(incfd[inclevel]); {$i+}
   if ioresult <> 0 then
   begin
      writeln(con,whoami,': Can''t open main file: ',mainfile);
      halt(1);
   end;

   lines := 0;
   open_logfile(mainfile);

   assign(outfd,remove_ext(mainfile) + '.WPP');
   rewrite(outfd);

   writeln(con,'Creating ',remove_ext(mainfile),'.WPP');
   endfile := false;
end;


(*------------------------------------------
 *
 * pop_replacement
 *    pop the line from the top of the replacement stack
 *    into the turbo line input buffer
 *    (called by a patch into turbo's cseg)
 *)

procedure pop_replacement;
var
   trash:    replace_ptr;

begin
   {get the line off the stack}
   COPY_STR(line_txt,repstack^.line^);

   {dispose of the line and prepare for next line down}
   trash := repstack;
   repstack := repstack^.prior;
   freemem(trash^.line,LEN(trash^.line^));
   DECR(replevel);
end;



(*------------------------------------------
 *
 * main
 *
 *)

begin
   initialize;
   preprocess_initialize;
   preproc_current_file(mainfile);

   (* get first line *)
   read_line(incfd[inclevel],line_txt);
   INCR(incline[inclevel]);
   INCR(lines);

   (* process each line in the file *)
   repeat

      (* check for macros and preprocessor commands *)
      preprocess_source_line;

      (* check for includes *)
      extract_include;
      if LEN(incfile) <> 0 then
      begin
         INCR(inclevel);
         incname[inclevel] := incfile;
         incline[inclevel] := 0;
         preproc_current_file(incfile);

         assign(incfd[inclevel],incfile);
         {$i-} reset(incfd[inclevel]); {$i+}
         if ioresult <> 0 then
         begin
            flush(outfd);
            writeln(con,whoami,': Can''t open include file: ',incfile);
            halt(1);
         end;
      end

      (* write the processed line to output *)
      else
         write_line(line_txt);

      (* pop extra replacement lines *)
      if replevel <> 0 then
         pop_replacement
      else

      (* process end of file *)
      if endfile then
      begin
         close(incfd[inclevel]);
         DECR(inclevel);

         if inclevel > 0 then
            preproc_current_file(incname[inclevel]);

         TRUNC(line_txt);
      end
      else

      (* get next line to process *)
      begin
         read_line(incfd[inclevel],line_txt);
         INCR(incline[inclevel]);
         INCR(lines);
      end;

   until inclevel < 1;

   flush(outfd);
   close(outfd);
   close_logfile(0,lines);

end.
