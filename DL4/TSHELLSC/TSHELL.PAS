
(*
 * TSHELL - Turbo Pascal Preprocessor "SHELL" program.
 *
 * S.H.Smith, 11-Dec-86 (rev. 17-Jul-87)
 *
 *)

{$c-,k-,r-}

program turbo_pascal_shell;

#undef SHAREWARE_RELEASE    {define for shareware signon message}
#undef DEBUGGING            {define to enable debugging code}

const tshell_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Preprocessor Shell (main) 1.1'#0;

const
   whoami =            'TSHELL';
   program_version =   'Version 1.31';
   last_update =       'Compiled: SYSTEM_DATE';
   longest_line =      127;

type
   anystring =         string [128];
   longstring =        string [255];

const
   progname: string[64] = 'TURBO.COM'; {default filename of turbo.com}

var
   line_txt:           anystring;     {string copy of current text line}
   error_count:        integer;


#include <strutil.inc>   {string utility macros}
#include <regpack.inc>   {register package declaration}
#include <stoz.inc>      {zero terminated string package}
#include <sysdate.inc>   {get system time/date}
#include <getfdate.inc>  {get file time/date}
#include <locfile.inc>   {locate file with PATH}
#include <rempath.inc>   {remove pathname prefix}
#include <incdec.inc>    {integer increment/decrement}
#include <stripspc.inc>  {strip leading/trailing spaces}
#include <stoupper.inc>  {map strings to upper case}

#include "tshptrs.inc"   {pascal interface, pointer tables}
#include "tshlog.inc"    {sourcefile logging}
#include "tsherror.inc"  {error handling}
#include "tshpp.inc"     {preprocessor functions}
#include "tshproc.inc"   {process turbo interrupts}
#include "tshint.inc"    {turbo interrupt procedures}



(*------------------------------------------
 *
 * Initialize
 *
 *)

procedure initialize;
begin

   case paramcount of
      0:  ;
      1:  progname := paramstr(1);

      else
         writeln(con,whoami,': Invalid command parameter');
         halt(1);
   end;

   progname := locate_file(progname) + #0;

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
   clrscr;
   lowvideo;
   put('');
   put('TSHELL - Turbo Pascal Shell');
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
   put('');
   put('Usage:  tshell             ;run with turbo.com');
   put(' or     tshell TURBX.COM   ;specify what version of turbo use');
   delay(1000);

#else    {for inhouse or commercial distribution}

   put('');
   put('Usage:  tshell             ;run with turbo.com');
   put(' or     tshell TURBX.COM   ;specify what version of turbo use');
   put('');

#endif

end;


(*------------------------------------------
 *
 * main
 *
 *)

begin
   signon;

   initialize;

   callturbo;    {Execute turbo with breaks on trapped functions
                  (does not return)}
end.
