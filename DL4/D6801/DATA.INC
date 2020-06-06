



(*******************************************************
 *
 * Subsystem:   Data - Global type and variable declarations
 *
 * Overview
 * --------
 *
 *    This file contains the declarations of all global data.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *
 *)




(**)
(*******************************************************
 *
 *   Global Constants
 *
 *)

 const

   compilerversion = 'D1 Compiler X0.0 21-Dec-85 S.H.Smith';

   maxidentlen = 31;          { only the first 31 chars saved }

   maxkeylen =   9;           { longest keyword }

   maxerrorlen = 35;          { longest error message }

   noobj = '!!!';             { value of Objects when no object code
                                is needed }




(**)
(*******************************************************
 *
 *   Global Data Types
 *
 *)

 type

   identstr =    string [maxidentlen];

   keystr =      string [maxkeylen];

   errorstr =    string [maxerrorlen];

   objectstr =   string [72];

   objlabel =    0..9999;



(*      ErrCode identifies error messages in the array ErrorList   *)

   errcode =     (disk,
                  qchar,
                  xpgm,
                  xident,
                  xnumber,
                  xvar,
                  xint,
                  xbool,
                  xcolon,
                  xtype,
                  xsemi,
                  xbegin,
                  xsemend,
                  xthen,
                  xdo,
                  xassgn,
                  xstmt,
                  dupdec,
                  undec,
                  match,
                  xfactor,
                  xparen,
                  xcomma,
                  xdot,
                  xto,
                  notimp,
                  unxeof);


(*      TokCode lists all symbols that can possibly be returned by the
 *          scanner. Null is a placeholder that can appear in a few fields
 *          of symbol-table entries. *)

   tokcode =     (null,          {non-keywords}
                  ident,
                  charstr,
                  number,

                  pgmsym,        {keywords}
                  varsym,
                  procsym,
                  beginsym,
                  endsym,
                  ifsym,
                  thensym,
                  elsesym,
                  whilesym,
                  repeatsym,
                  untilsym,
                  forsym,
                  tosym,
                  downtosym,
                  dosym,

                  intsym,        {TypeSet}
                  bytesym,
                  charsym,
                  boolsym,

                  truesym,       {TFSet}
                  falsesym,

                  eq,            {RelOps}
                  gt,
                  ge,
                  ne,
                  le,
                  lt,

                  plus,          {AddOps}
                  minus,
                  orsym,

                  times,         {MultOps}
                  divide,
                  andsym,
                  modsym,
                  notsym,

                  assignop,      {other special token types}
                  colon,
                  leftparen,
                  rightparen,
                  semi,
                  comma,
                  dot,
                  unminus,
                  readsym,
                  writesym);


   tokenrec =    record          { Definition of the mailbox where the
                                   scanner }

         name:         identstr;    { leaves dope on the current token
                                      and where }

         code:         tokcode;     { the parser picks it up. }

   end;


   symclass =    (variable,
                  proc);      { Every symbol must be one or the other. }

   symptr =      ^symbol;     { Points to a symbol-table entry. }



(*   Format of a symbol-table entry.  *)

   symbol =      record
         ident:        identstr;    { upcase symbol identifier (may not
                                      be unique }

         name:         identstr;    { formal name for code generation, will
                                      always be unique }

         class:        symclass;    { either Variable or Proc }

         vartype:      tokcode;     { either IntSym or BoolSym }

         subscripts:   integer;     { number of subscripts, 0 if none }

         subelements:  array[1..5]  { number of elements in each subscript }
                       of integer;

         scope:        integer;     { zero for global, then 1,2,3...}

         next:         symptr;      { pointer to next table entry }

   end;


(**)
(*******************************************************
 *
 *   Global Variables
 *
 *)

 var

   infile:       text[2048];  { source code }

   outfile:      text[4096];  { object code }

   tk:           tokenrec;    { where dope on the current token is stashed }

   ch:           char;        { current scanner input }

   linecount:    integer;     { number of lines in source text }

   sourceline:   string[128]; { the current source line }

   objlines:     integer;     { lines generated by code generator }

   outlines:     integer;     { output lines from optimizer }

   commentcount: integer;     { number of comment lines in object file }


                              { sets defined for convenience }
                              { in the parsing logic }
   typeset:      set of tokcode;
   numset:       set of tokcode;
   tfset:        set of tokcode;
   relopset:     set of tokcode;
   addopset:     set of tokcode;
   multopset:    set of tokcode;

   firstsym:     symptr;      { link to the start of the symbol-table chain }

   currentscope: integer;     { nesting depth of procedures }

   symbolnum:    integer;     { unique symbol number for table entries }

   keywords:     array [tokcode] of keystr;
   errorlist:    array [errcode] of errorstr;

   curlabel:     objlabel;    { current label last generated by GenLabel }

   prevobject:   objectstr;   { prevoious object line, which is waiting
                               to be output }


   nooptimize:   boolean;     { true if optimization has been turned off
                                by a command-line option }

   optmemory:    boolean;     { true if optimization is for smallest memory
                                usage }

   optspeed:     boolean;     { true if optimization is for speed }

   copysource:   boolean;     { true if source is copied to object
                                as comments }

