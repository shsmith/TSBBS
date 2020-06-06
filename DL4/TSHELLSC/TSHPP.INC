
const tshpp_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Preprocessor procedures 1.1'#0;
#log Preprocessor procedures 1.1

(*
 * tshpp - tshell preprocessor procedures
 *
 * This preprocessor allows you to imbed a number of c-like preprocessor
 * statements in a source file.  It interprets the statements and
 * passes the processed text on for further processing (or compilation).
 *
 * The following preprocessor directives are understood:
 *
 *    #define NAME STRING    ;replace all instances of NAME with STRING
 *    #undef NAME            ;delete definition of NAME
 *    #ifdef NAME{|NAME}     ;compile only if NAME is defined
 *    #ifndef NAME           ;compile if NAME is not defined
 *    #else                  ;compile otherwise
 *    #endif                 ;resume normal compilation
 *    #pragma NOEXPAND       ;do not expand #defines in following lines
 *    #pragma EXPAND         ;resume #define expansion
 *    #pragma LIST           ;list preprocessed lines to screen
 *    #pragma NOLIST         ;stop listing
 *    #include "filename"    ;include specified file (nesting ok)
 *    #include <filename>    ;search TPATH environment for include files
 *    #log REST OF LINE      ;place REST OF LINE in logfile
 *
 *
 * The following special keywords are predefined:
 *
 *    SYSTEM_DATE            ;the time/date when compile was started
 *    LAST_UPDATE            ;last modification time of current file
 *    CURRENT_FILE           ;name of current file
 *    CURRENT_PATH           ;full path of current file
 *
 *
 * s.h.smith, 21-jan-86 - initial coding
 * s.h.smith, 11-mar-87 - first working version
 *
 *)

const

#ifdef STAND_ALONE
   max_define =   400;   {number of DEFINEs (should not be a power of 2)}
#else
   max_define =   120;   {number of DEFINEs (should not be a power of 2)}
#endif

   max_ifnest =    10;   {number of levels of #if nesting}
   keylen =        30;   {longest keyword length, static allocation}
   replen =       128;   {longest replacement length, dynamic allocation}

type
   ifdef_modes = (ifdef, ifndef);

   keystring = string[keylen];
   repstring = string[replen];

   replace_ptr = ^replace_entry;
   replace_entry = record
      line:         ^repstring;
      prior:        replace_ptr;
   end;

   define_entry = record
      key:          keystring;
      last:         replace_ptr;
   end;

   ifstack_entry = record
      compiling: boolean;
      active:    boolean;
   end;

var
   define_table:   array[1..max_define] of define_entry;
   define_count:   integer;

   ifstack:        array[0..max_ifnest] of ifstack_entry;
   if_level:       integer;

   list_source:    integer;
   noexpand:       integer;

   repstack:       replace_ptr;
   current_entry:  integer;

const
   replevel:       integer = 0;   {must be in cseg}



#include "tshhash.inc"   {keyword hashing function}
#include "tshkey.inc"    {keyword table manipulation}
#include "tshmacr.inc"   {macro_replacement}



(*------------------------------------------
 *
 * proproc_ifdef
 *    stop compilation if symbol is not defined
 *
 *)

procedure preproc_ifdef(mode: ifdef_modes;
                        sym:  anystring);
var
   defined: boolean;
   p:       integer;
   key:     anystring;


   procedure getkey;
   begin
      p := pos('|',sym);
      if p = 0 then
      begin
         key := sym;
         sym := '';
      end
      else

      begin
         key := copy(sym,1,p-1);
         sym := copy(sym,p+1,255);
      end;
   end;

begin
   defined := false;

   strip_leading_spaces(sym);      {remove leading spaces from the keyword}
   strip_trailing_spaces(sym);     {remove trailing spaces and comments}

   while (not defined) and (sym <> '') do
   begin
      getkey;
      if lookup_keyword(key) <> 0 then
         defined := true;
   end;

   if (mode = ifndef) then
      defined := not defined;

   with ifstack[if_level] do
   if (not compiling) or (not active) then
   begin
      INCR(if_level);
      ifstack[if_level].compiling := false;
      ifstack[if_level].active := false;
   end
   else

   begin
      INCR(if_level);
      ifstack[if_level].compiling := defined;
      ifstack[if_level].active := true;
   end;

   line_txt := '';
end;


(*------------------------------------------
 *
 * preproc_else
 *
 *)

procedure preproc_else;
begin
   with ifstack[if_level] do
      if active then
         compiling := not compiling;

   line_txt := '';
end;


(*------------------------------------------
 *
 * preproc_endif
 *
 *)

procedure preproc_endif;
begin
   if if_level > 0 then
      DECR(if_level);       {resume compilation}

   line_txt := '';
end;



(*------------------------------------------
 *
 * preproc_pragma
 *    process the various preprocessor pragmas (or switches)
 *
 *)

procedure preproc_pragma(tail: anystring);
begin
   TRUNC(line_txt);
   if not ifstack[if_level].compiling then
      exit;

   strip_leading_spaces(tail);      {remove leading spaces}

   strip_trailing_spaces(tail);     {remove trailing spaces and comments}

   if tail = 'NOEXPAND' then
      INCR(noexpand)
   else

   if tail = 'EXPAND' then
      DECR(noexpand)
   else

   if tail = 'LIST' then
      INCR(list_source)
   else

   if tail = 'NOLIST' then
      DECR(list_source)
   else

      error('Invalid pragma: "'+tail+'"');
end;


(*------------------------------------------
 *
 * preproc_include
 *    translate a C style include statement into
 *    a valid Turbo include statement.
 *    searches for includes if <name> is used.
 *
 *)

procedure preproc_include(tail: anystring);
var
   name:    anystring;
   search:  boolean;
   fd:      file;

begin
   if not ifstack[if_level].compiling then
   begin
      TRUNC(line_txt);
      exit;
   end;

   COPY_STR(line_txt, tail);
   macro_replacement;                      {expand macros in include name}
   COPY_STR(tail, line_txt);

   strip_leading_spaces(tail);             {remove leading spaces}
   strip_trailing_spaces(tail);            {remove trailing spaces & comments}

   name := copy(tail,2,length(tail)-2);    {get raw filename}

   if tail[1] = '<' then                   {search TPATH paths if <name>}
      name := locate_file_env(name,';' + get_environment_var('TPATH='));
                          

   stoupper(name);                         {make the name all upper case}
   assign(fd,name);

   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      error('Missing include file: '+name)
   else

   begin
      close(fd);
      log_sourcefile(name);
      line_txt := '{$I ' + name + ' }';       {emit code for turbo to process}
   end;
end;



(*------------------------------------------
 *
 * preproc_log
 *    place a message into the logfile
 *
 *)

procedure preproc_log(tail: anystring);
var
   name:    anystring;
   search:  boolean;
   fd:      file;

begin
   TRUNC(line_txt);
   if not ifstack[if_level].compiling then
      exit;

   COPY_STR(line_txt, tail);
   macro_replacement;
   log_message(line_txt);

   TRUNC(line_txt);
end;



(*------------------------------------------
 *
 * preprocess_source_line
 *    apply the preprocessor to the
 *    current source line before it
 *    is compiled by turbo
 *
 *)

procedure preprocess_source_line;
var
   p: integer;

begin

   {find first non-blank on line}
   p := 1;
   while (line_txt[p] = ' ') do
      p := p + 1;

   {process define continuation lines, when needed}
   if current_entry <> 0 then
   begin
      link_replacement(current_entry, line_txt);
      TRUNC(line_txt);
   end
   else

   {is this a preprocessor directive?}
   if (line_txt[p] = '#') and (LEN(line_txt) > p) then
   begin
      if copy(line_txt,p,7) = '#ifdef ' then
         preproc_ifdef(ifdef,copy(line_txt,p+7,255))
      else

      if copy(line_txt,p,8) = '#ifndef ' then
         preproc_ifdef(ifndef,copy(line_txt,p+8,255))
      else

      if copy(line_txt,p,5) = '#else' then
         preproc_else
      else

      if copy(line_txt,p,6) = '#endif' then
         preproc_endif
      else

      if copy(line_txt,p,8) = '#define ' then
         preproc_define(copy(line_txt,p+8,255))
      else

      if copy(line_txt,p,7) = '#undef ' then
         preproc_undef(copy(line_txt,p+7,255))
      else

      if copy(line_txt,p,8) = '#pragma ' then
         preproc_pragma(copy(line_txt,p+8,255))
      else

      if copy(line_txt,p,9) = '#include ' then
         preproc_include(copy(line_txt,p+9,255))
      else

      if copy(line_txt,p,4) = '#log' then
         preproc_log(copy(line_txt,p+5,255))
      else
         error('Invalid preprocessor directive: "'+line_txt+'"');

   end
   else

   {if compilation is stopped, don't allow anything to pass through}
   if (not ifstack[if_level].compiling) or (LEN(line_txt) = 0) then
      TRUNC(line_txt)
   else

   {not a preprocessor directive; check for macro replacement}
   if noexpand = 0 then
      macro_replacement;

   {list processed text if pragma LIST specified}
   if list_source > 0 then
   begin
      write(#13);
      clreol;
      writeln(con,'TPP: ',line_txt);
   end;

end;


(*------------------------------------------
 *
 * preproc_current_file
 *    specify the current source file
 *    updates CURRENT_FILE and LAST_UPDATE definitions
 *
 *)

procedure preproc_current_file(name: anystring);
begin

#pragma NOEXPAND
   preproc_define('CURRENT_FILE ' + remove_path(name));
   preproc_define('CURRENT_PATH ' + name);
   preproc_define('LAST_UPDATE ' + get_file_date(name));
#pragma EXPAND

end;



(*------------------------------------------
 *
 * preprocess_initialize
 *
 *)

procedure preprocess_initialize;
begin
   initialize_table;
   current_entry := 0;
   if_level := 0;
   ifstack[0].compiling := true;
   ifstack[0].active := true;
   error_count := 0;

{provide defaults for #pragma switches}
   noexpand := 0;

#ifdef DEBUGGING
   list_source := 1;
#else
   list_source := 0;
#endif

{provide predefined macros.  the NOEXPAND pragmas are required to prevent
 the definitions of these keywords from being expanded!}

#pragma NOEXPAND
   preproc_define('SYSTEM_DATE ' + system_date + ' ' + system_time);
#pragma EXPAND

end;

