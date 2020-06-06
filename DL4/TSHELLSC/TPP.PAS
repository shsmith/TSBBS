
(*
 * TSHELL - Turbo Pascal Preprocessor "SHELL" program.
 * TPP - Turbo Pascal Preprocessor (stand-alone version)
 *
 * S.H.Smith, 11-Dec-86
 *
 *)

{$g1,p16384,d-,k+,r-,v+}

program standalone_turbo_pascal_shell;

#define SHAREWARE_RELEASE      {define to make shareware/freeware version}
#undef DEBUGGING
#define STAND_ALONE

const tshell_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Stand-alone Preprocessor (main) 1.2'#0;

const
   program_version =   'Version 1.2';
   last_update =       'Compiled: SYSTEM_DATE';
   whoami =            'TPP';
   max_include =       6;
   longest_line =      127;

type
   anystring =         string [128];
   longstring =        string [255];

var
   mainfile:           anystring;     {main file name}

   line_txt:           anystring;     {current source line}
   incfile:            anystring;     {include filename if any}

   inclevel:           integer;       {include nesting level}
   incfd:              array[1..max_include] of text[2048];
   incname:            array[1..max_include] of string[64];
   incline:            array[1..max_include] of integer;

   lines:              integer;

   error_count:        integer;


#include <strutil.inc>   {string utility macros}
#include <regpack.inc>   {registerpackage declaration}
#include <sysdate.inc>   {get system time/date}
#include <getfdate.inc>  {get file time/date}
#include <locfile.inc>   {locate file with PATH}
#include <rempath.inc>   {remove pathname prefix}
#include <incdec.inc>    {integer increment/decrement}
#include <stripspc.inc>  {strip leading/trailing spaces}
#include <stoupper.inc>  {map strings to upper case}

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
   put('TPP - Turbo Pascal Preprocessor (STAND-ALONE)');
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
   put('    Samuel H. Smith              The Tool Shop PCBoard');
   put('    5119 N. 11th Ave 332            (602) 279-2673');
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
      writeln(con,'Usage:  ',whoami,' mainfile[.pas] >outfile');
      halt(1);
   end;

   mainfile := paramstr(1);
   if pos('.',mainfile) = 0 then
      mainfile := mainfile + '.PAS';

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
   open_logfile('con');
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
   preproc_define('IN_TPP 1');

   (* get first line *)
   readln(incfd[inclevel],line_txt);
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
            flush(output);
            writeln(con,whoami,': Can''t open include file: ',incfile);
            halt(1);
         end;

         writeln(output,'{#line 1 "',incfile, '"}');
      end

      (* write the processed line to output *)
      else
         writeln(output,line_txt);

      (* pop extra replacement lines *)
      if replevel <> 0 then
         pop_replacement
      else

      (* process end of file *)
      if eof(incfd[inclevel]) then
      begin
         close(incfd[inclevel]);
         DECR(inclevel);

         if inclevel > 0 then
         begin
            preproc_current_file(incname[inclevel]);
            writeln(output,'{#line ',incline[inclevel],
                           ' "',incname[inclevel],'"}');
         end;

         TRUNC(line_txt);
      end
      else

      (* get next line to process *)
      begin
         readln(incfd[inclevel],line_txt);
         INCR(incline[inclevel]);
         INCR(lines);
      end;

   until inclevel < 1;

   flush(output);
   close_logfile(0,lines);

end.
