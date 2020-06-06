
(*
 * this program demonstrates and tests the facilities of TSHELL 1.0
 *
 *)

program tshell_tester;

{this statement will place a "signature" into the .com file where it can
 be detected and used for configuration management}

const example_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Example program 1.0'#0;

{this statement puts a message into the compilation logfile}
#log Sample program, Main file (version 1.0)

{define some macros}
#define WHOAMI test program 1
#define DEBUG     {this macro will control generation of debug code}
#define LEV2      {this macro will enable low level debug code}


{define increment and decrement macros - these can be called with 1 actual
 parameter, which will be substituted where %1 is used in the definition}
#define INCR %1 := succ(%1)
#define DECR %1 := pred(%1)

#define DISP writeln('%1=',%1)


var
   i:  integer;

begin

#pragma LIST
   #define TWOLINES     \
      writeln('line1'); \
      writeln('line2')

   writeln('twoline test:');
   {before;} TWOLINES; {after;}
   writeln('end twoline test');
   {nospace} DISP(i);
   {space}   DISP (i);
   {mspace}  DISP     ( i )  ;
#pragma NOLIST

   i := 0;
   while i < 5 do
   begin
      DISP(i);
      INCR(i);
   end;


{test preprocessed source listing}
#pragma LIST
  {This will show during compilation}
  writeln('whoami=WHOAMI');
#pragma NOLIST


{the following writeln should NOT be expanded}
#pragma NOEXPAND
  writeln('whoami=WHOAMI (shouldn''t say "test program 1")');
#pragma EXPAND


{test predefined symbols}
  writeln('system_date=SYSTEM_DATE (date last compiled)');
  writeln('last_update=LAST_UPDATE (date last updated)');
  writeln('current_filename=CURRENT_FILE (source filename)');


{test conditional compilation}
#ifdef DEBUG
   writeln('debug enabled');

   #ifdef LEV2
      writeln('debug lev2');

      #ifdef LEV3
         writeln('debug lev3');
      #endif

   #else
      writeln('debug not lev2');
   #endif

#else
   writeln('not debugging');

   #ifdef LEV2
      writeln('not debug lev2');
   #else
      writeln('not debug not lev2');
   #endif
#endif


{test the #undef command}

#define TEST1 Test-1
   writeln('test1="TEST1" <-- should say Test-1');

#undef TEST1
   writeln('test1="TEST1" <-- should say TEST1');

end.
