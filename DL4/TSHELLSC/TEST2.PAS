
(*
 * tshell execution speed test-driver
 *
 *)

(******* dummy support declarations ****)
{$r-,k-,c-}
const max_define =   120;   {number of DEFINEs (should not be a power of 2)}
   keylen =        30;   {longest keyword length}
   replen =        70;   {longest replacement length}
type anystring = string[128];
   longstring = string[255];
   keystring = string[keylen];
   repstring = string[replen];
   define_entry = record
      key:          keystring;
      replacement:  ^repstring;
   end;
var define_table:   array[1..max_define] of define_entry;
   define_count:   integer;
   line_txt:       anystring;
#include <incdec.inc>
#include <strutil.inc>   {string utility macros}
#include "tshhash.inc"
procedure error(msg:anystring);
begin writeln(msg);
   halt;
end;
procedure init;
var i:integer; begin
   for i:=1 to max_define do with define_table[i] do
   begin key := ''; replacement := nil; end;
end;

(****** the module under examination ******)
#undef DEBUGGING
#include "tshmacr.inc"   {macro_replacement}


(****** the test driver *******)
procedure measure_speed;
var
   start:  real;
   time:   real;
   speed:  real;
   pass:   integer;
   index:  real;
   tline1: anystring;

const
   passes=500;
   basespeed=7692;
   #include <regpack.inc>
   #include <gettime.inc>

begin
   write(passes,' passes:  ');
   start:=get_time;

   tline1 := '                 writeln(time:0:2,'' sec,  '',rate:0:1,'' runs/min,  '',index:0:0,'' % change'');';

   for pass := 1 to passes do
   begin
      line_txt := tline1;
      macro_replacement;
   end;

   time:=get_time-start;
   speed:=passes/time*60.0;
   index:=speed/basespeed;
   writeln(time:0:2,' sec,  ',speed:0:0,' runs/min,  ',index:0:3,' index');
end;


begin
   init;
   measure_speed;
end.
