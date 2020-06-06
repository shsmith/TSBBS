

(*******************************************************
 *
 * Subsystem:   Utility - utility and initialization procedures
 *
 * Overview
 * --------
 *
 *    Provides initialization, file handling and error
 *    reporting services for the rest of the compiler.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *
 *
 * Procedures
 * ----------
 *
 * error(errcode)
 *    display an error message based on error code, display
 *    the source line being processed and the current
 *    token type.   a better version of this procedure
 *    might also report what tokens were expected at
 *    the time of the error.
 *
 * initkeywords
 *    provides initial values for all keywords
 *    in the token keyword array.  also initializes
 *    some token code sets.  must be called
 *    before the lexical analyzer is called.
 *
 * initerrorlist
 *    provides initial values for all error
 *    code error messages.   must be called
 *    before the lexical analyzer is called.
 *
 * initialize
 *    perform all initializations to prepare the
 *    compiler for operation.
 *
 * openfiles
 *    decode command line parameters and determine
 *    input and output file names.   opens these
 *    files if they are valid.   also decodes any
 *    command line options.
 *
 * closefiles
 *    flush and close all files in preparation
 *    for termination of the compiler.  also prints
 *    final compile statistics.
 *
 *)


 procedure optflush; forward;



(**)
(*******************************************************
 *
 * Procedure:     error(errcode)
 *
 * Description:   display an error message based on error code, display
 *                the source line being processed and the current
 *                token type.   a better version of this procedure
 *                might also report what tokens were expected at
 *                the time of the error.
 *
 * Example:       error(xparen);
 *
 * Inputs:        error message code
 *
 * Outputs:       compile is aborted
 *
 *)

 procedure error (problem:      errcode);
 begin
   optflush;
   writeln;
   writeln('Error in line ', linecount, ':  ', errorlist [problem]);
   writeln('Source: ', sourceline);
   writeln('Type:   ', keywords[tk.code]);
   writeln;
   writeln('COMPILATION ABORTED');
   halt;
 end;





(**)
(*******************************************************
 *
 * Procedure:    initkeywords
 *
 * Description:  provides initial values for all keywords
 *               in the token keyword array.  also initializes
 *               some token code sets.  must be called
 *               before the lexical analyzer is called.
 *
 * Example:      initkeywords;
 *
 *)

 procedure initkeywords;
 begin

   keywords[null     ] := '<NULL>';
   keywords[ident    ] := '<IDENT>';
   keywords[charstr  ] := '<STRING>';
   keywords[number   ] := '<NUMBER>';

   keywords[pgmsym   ] := 'PROGRAM';
   keywords[varsym   ] := 'VAR';
   keywords[procsym  ] := 'PROCEDURE';
   keywords[beginsym ] := 'BEGIN';
   keywords[endsym   ] := 'END';
   keywords[ifsym    ] := 'IF';
   keywords[thensym  ] := 'THEN';
   keywords[elsesym  ] := 'ELSE';
   keywords[whilesym ] := 'WHILE';
   keywords[repeatsym] := 'REPEAT';
   keywords[untilsym ] := 'UNTIL';
   keywords[forsym   ] := 'FOR';
   keywords[tosym    ] := 'TO';
   keywords[downtosym] := 'DOWNTO';
   keywords[dosym    ] := 'DO';

   keywords[intsym   ] := 'INTEGER';
   keywords[bytesym  ] := 'BYTE';
   keywords[charsym  ] := 'CHAR';
   keywords[boolsym  ] := 'BOOLEAN';

   keywords[truesym  ] := 'TRUE';
   keywords[falsesym ] := 'FALSE';

   keywords[eq       ] := 'EQ';
   keywords[gt       ] := 'GT';
   keywords[ge       ] := 'GE';
   keywords[ne       ] := 'NE';
   keywords[le       ] := 'LE';
   keywords[lt       ] := 'LT';

   keywords[plus     ] := 'ADD';
   keywords[minus    ] := 'SUB';
   keywords[orsym    ] := 'OR';

   keywords[times    ] := 'MUL';
   keywords[divide   ] := 'DIV';
   keywords[notsym   ] := 'NOT';
   keywords[andsym   ] := 'AND';
   keywords[modsym   ] := 'MOD';

   keywords[assignop ] := ':=';
   keywords[colon    ] := ':';
   keywords[leftparen] := '(';
   keywords[rightparen]:= ')';
   keywords[semi     ] := ';';
   keywords[dot      ] := '.';
   keywords[comma    ] := ',';
   keywords[unminus  ] := 'NEG';

   keywords[readsym  ] := 'READLN';
   keywords[writesym ] := 'WRITELN';

   typeset   := [intsym..boolsym];     {set of all variable data types}
   numset    := [intsym..bytesym];     {set of all binary numeric types}
   tfset     := [truesym, falsesym];
   relopset  := [eq..lt];
   addopset  := [plus..orsym];
   multopset := [times..modsym];
 end;




(**)
(*******************************************************
 *
 * Procedure:    initerrorlist
 *
 * Description:  provides initial values for all error
 *               code error messages.   must be called
 *               before the lexical analyzer is called.
 *
 * Example:      initerrorlist;
 *
 *)

 procedure initerrorlist;
 begin
   errorlist[disk    ] := 'TROUBLE WITH FILE OR DISK';
   errorlist[qchar   ] := 'UNRECOGNIZED CHARACTER IN INPUT';
   errorlist[xpgm    ] := '"PROGRAM" EXPECTED';
   errorlist[xident  ] := 'IDENTIFIER EXPECTED';
   errorlist[xnumber ] := 'NUMBER EXPECTED';
   errorlist[xvar    ] := 'VARIABLE EXPECTED';
   errorlist[xint    ] := 'INTEGER VALUE EXPECTED';
   errorlist[xbool   ] := 'BOOLEAN VALUE EXPECTED';
   errorlist[xcolon  ] := '":" EXPECTED';
   errorlist[xtype   ] := 'INVALID DATA TYPE';
   errorlist[xsemi   ] := '";" EXPECTED';
   errorlist[xbegin  ] := '"BEGIN" EXPECTED';
   errorlist[xsemend ] := '";" OR "END" EXPECTED';
   errorlist[xthen   ] := '"THEN" EXPECTED';
   errorlist[xdo     ] := '"DO" EXPECTED';
   errorlist[xassgn  ] := '":=" EXPECTED';
   errorlist[xstmt   ] := 'STATEMENT EXPECTED';
   errorlist[dupdec  ] := 'DUPLICATE DECLARATION';
   errorlist[undec   ] := 'UNDECLARED VARIABLE OR PROCEDURE';
   errorlist[match   ] := 'TYPE MISMATCH';
   errorlist[xfactor ] := 'FACTOR EXPECTED';
   errorlist[xparen  ] := '"(" OR ")" EXPECTED';
   errorlist[xcomma  ] := '"," EXPECTED';
   errorlist[xdot    ] := '"." EXPECTED';
   errorlist[xto     ] := '"TO" OR "DOWNTO" EXPECTED';
   errorlist[notimp  ] := 'FEATURE NOT IMPLEMENTED';
   errorlist[unxeof  ] := 'UNEXPECTED END OF FILE';
 end;





(**)
(*******************************************************
 *
 * Procedure:     initialize
 *
 * Description:   perform all initializations to prepare the
 *                compiler for operation.
 *
 * Example:       initialize;
 *
 *)

 procedure initialize;
 begin
   initerrorlist;             { init error message list }
   initkeywords;              { init keyword list and keyword sets }

   symbolnum := 0;            { unique symbol number in symbol table }
   curlabel := 0;             { initial label number for GenLabel }
   prevobject := noobj;       { no objects held by optimizer }
   firstsym := nil;           { make pointer point nowhere }
   currentscope := 0;         { at start scope is global }
   linecount := 1;            { start on first source line }
   objlines := 0;             { object code lines from code generator }
   outlines := 0;             { output lines from optimizer }
   commentcount := 0;         { count of comment lines in object output }
   sourceline := '';          { no current source line }
   tk.code := null;
   tk.name := '';

   nooptimize := false;       { enable optimizer by default }
   optmemory  := false;       { optimize for memory size }
   optspeed   := false;       { optimize for speed }
   copysource := false;       { copy source to object as comments }

   writeln;
   writeln(compilerversion);  { sign on with compiler version banner }
 end;





(**)
(*******************************************************
 *
 * Procedure:     openfiles
 *
 * Description:   decode command line parameters and determine
 *                input and output file names.   opens these
 *                files if they are valid.   also decodes any
 *                command line options.
 *
 * Example:       openfiles;
 *
 *)

 procedure openfiles;
 var
   fileok:       boolean;
   infilename:   string [65];
   outfilename:  string [65];
   i:            integer;
   param:        string [80];

 begin

   if paramcount = 0 then
   begin
      writeln('Usage: COMPILE cource [object] [options]');
      writeln('options:  -N     ;No optimization');
      writeln('          -S     ;Optimize for speed');
      writeln('          -M     ;Optimize for memory usage');
      writeln('          -C     ;Copy source to object as comments');
      halt;
   end;


   infilename := paramstr(1);
   if pos('.', infilename) = 0 then
      infilename := infilename + '.D';

   assign(infile, infilename);
{$I-}
   reset(infile);
{$I+}

   fileok :=(ioresult = 0);

   if not fileok then
      error(disk);


   outfilename := infilename + 'O';


   for i := 2 to paramcount do
   begin
      param := paramstr(i);
      if param[1] <> '-' then
         outfilename := param
      else

      case upcase(param[2]) of
         'N':  nooptimize := true;
         'M':  optmemory  := true;
         'S':  optspeed   := true;
         'C':  copysource := true;

         else
            writeln('Invalid parameter: ',param);
            halt;
      end;
   end;


   assign(outfile, outfilename);
{$I-}
   rewrite(outfile);
{$I+}

   fileok :=(ioresult = 0);

   if not fileok then
      error(disk);

 end;




(**)
(*******************************************************
 *
 * Procedure:     closefiles
 *
 * Description:   flush and close all files in preparation
 *                for termination of the compiler.  also prints
 *                final compile statistics.
 *
 * Example:       closefiles;
 *
 *)

 procedure closefiles;
 begin
   close(infile);

   optflush;
   close(outfile);

   writeln;
   writeln(linecount:4,' source lines');
   writeln(symbolnum:4,' symbols');
   writeln(curlabel:4,' generated labels');
   writeln(objlines-commentcount:4, ' object lines');

   if outlines<>objlines then
      writeln(outlines-commentcount:4, ' object lines after optimization');
 end;





(**)
(*******************************************************
 *
 * Function:     itoa(integer): identstr
 *
 * Description:  function to convert an integer into an
 *               ascii string
 *
 * Example:      write('L' + itoa(labelnum));
 *
 * Inputs:       the integer to convert
 *
 * Outputs:      the converted string
 *
 *)

function itoa(i: integer): identstr;
var
   a:  identstr;

begin
   str(i:0, a);
   itoa := a;
end;

