

(*
 * mcrf - MPL cross reference utility
 *        for use with output filters
 *
 * usage:
 *       mpp FILE.MPL | mcrf | crfprn >PRN
 *            for a procedure crossreference listing
 *
 *       mpp FILE.MPL | mcrf | ph >PRN
 *            for a procedure heriarchy listing
 *
 * shs 9/9/85
 *
 *)

{$g1024,p128,d-,c-}


program MPLcrf (input,
                   output);
const
   identsize =    40;         {identifier size for data type alignment}
                              {must match 'ph' ident size}

   linelen =      128;        {longest line length}
   
   newline =      ^J;
   
type
   anystring =    string [linelen];
   toktypes =     (number,
                   identifier,
                   strng,
                   comment,
                   unknown);
   
var
   ltok:          anystring;
   ptok:          anystring;
   ptoktype:      toktypes;
   tok:           anystring;
   toktype:       toktypes;
   unchrflag:     char;
   utok:          anystring;
   untokflag:     boolean;
   utoktype:      toktypes;
   inproc:        anystring;
   line:          integer;
   srcline:       integer;
   crfall:        boolean;
   crfdata:       boolean;

(*
 * pascal lexical scanner
 *
 *)
   

function getchar: char;
   var
      c:             char;
      
   begin
      
      if unchrflag <> chr (0) then
      begin
         getchar := unchrflag;
         unchrflag := chr (0);
      end
      else
      begin
         
         if eof (input) then
         begin
            writeln(con, #13, srcline, ' source lines, ',
                              line,    ' crf lines written');
            halt;
         end;

         read(input, c);

         if c = newline then
         begin
            srcline := srcline + 1;
            if (srcline mod 16) = 1 then
               write(con, #13, srcline);
         end;

         getchar := c;
      end;
   end;

procedure ungetchar (c:             char);
   begin
      unchrflag := c;
   end;

procedure scanident;
   var
      c:             char;

   begin
      toktype := unknown;

      repeat
         c := getchar;

         case c of
            'a'..'z', 'A'..'Z', '0'..'9', '_':
               ltok := ltok + c;

            else           toktype := identifier;
         end;
      until toktype = identifier;

      ungetchar(c);
   end;

procedure scannumber;
   var
      c:             char;

   begin
      toktype := unknown;
      
      repeat
         c := getchar;
         
         case c of
            '0'..'9', '.': ltok := ltok + c;
            
            else           toktype := number;
         end;
      until toktype = number;
      
      ungetchar(c);
   end;

procedure scanstring;
   var
      c:             char;
      
   begin
      toktype := unknown;

      repeat
         c := getchar;
         ltok := ltok + c;
         
         if c = '''' then
         begin
            c := getchar;
            
            if c = '''' then
               ltok := ltok + c
            else
            begin
               ungetchar(c);
               toktype := strng;
            end;
         end;
      until toktype = strng;
   end;

procedure scanhex;
   var
      c:             char;

   begin
      c := getchar;
      
      while c in ['0'..'9', 'A'..'F', 'a'..'f'] do
      begin
         ltok := ltok + c;
         c := getchar;
      end;
      
      ungetchar(c);
      toktype := number;
   end;

procedure scantok;
   var
      c:             char;
      
   begin
      
      repeat
         c := getchar;


         case c of
            ' ',^I,^M,^J,^@,^L:
               c := newline;
         end;
      until c <> newline;
      
      ltok := c;
      
      case c of
         'a'..'z', '_', 'A'..'Z':
                        scanident;

         '0'..'9':      scannumber;

         '''':          scanstring;

         '$':           scanhex;

         else           toktype := unknown;
      end;
   end;

procedure ungettoken;
   var
      i:             integer;
      
   begin
      untokflag := true;
      utoktype := toktype;
      utok := ltok;
      toktype := ptoktype;
      ltok := ptok;
      tok := ptok;
      
      for i := 1 to length (tok) do
         tok[i]:= upcase (tok [i]);
   end;

procedure gettok; forward;

procedure skipcurlycomment;
   var
      c:             char;
      
   begin

      repeat
         c := getchar;
      until c = ^J;

      toktype := comment;
   end;


procedure gettok;
   var
      i:             integer;
      c:             char;
      
   begin
      
      if keypressed then
      begin
         read(kbd, c);

         if c =^C then
         begin
            writeln(con, '** ^C');
            halt;
         end;
      end;

      if untokflag then
      begin
         untokflag := false;
         toktype := utoktype;
         ltok := utok;
         tok := utok;

         for i := 1 to length (tok) do
            tok[i]:= upcase (tok [i]);
      end
      else
      begin
         ptok := ltok;
         ptoktype := toktype;
         scantok;
      end;

      tok := ltok;

      if toktype = identifier then

         for i := 1 to length (ltok) do
            tok[i]:= upcase (ltok [i]);
   end;

procedure scaninit;
   begin
      ltok := '';
      ptok := '';
      tok := '';
      toktype := unknown;
      untokflag := false;
      unchrflag := chr (0);
      line := 0;
      srcline := 0;
      inproc := 'MAIN';
   end;

procedure nexttoken;
   begin
      gettok;
   end;


(*
 * pascal parser and output formatting
 *
 *)

procedure pblock; forward;

procedure pstatement; forward;

procedure punit; forward;

procedure pvar; forward;

procedure syntax (message:       anystring);
   begin
      writeln(con);
      writeln(con, '****** ', message, ',  token="', tok, '"');
   end;


(*
 * output a token to crf stream unless it is a
 * pascal reserved word
 *
 *)

procedure crf_output (lt:            anystring);
   var
      i:             integer;
      t:             anystring;

   const
      nkey = 21;
      keyword: array[1..nkey] of anystring =
          ('AND',     'BIN',       'CONST',       'DCL',         'DEC',
           'DECLARE', 'DEF',       'DEFINED',     'DO',
           'ELSE',    'END',       'GIVING',      'GOTO',
           'IF',      'INIT',      'NOT',         'OR',
           'PROC',    'PROCEDURE', 'RETURN',      'THEN');
   begin
      t := lt;

      for i := 1 to length (t) do
         t[i]:= upcase (t [i]);

      for i := 1 to nkey do
      begin
         if keyword[i] > t then
         begin
            writeln(lt, '' : identsize - length (lt), inproc);
            line := line + 1;
            exit;
         end;


         if keyword[i] = t then
            exit;
      end;

      writeln(lt, '' : identsize - length (lt), inproc);
      line := line + 1;
   end;


(*
 * get next token and decide if any output
 * to the crf stream is needed
 *
 *)

procedure crf_nexttoken;
   begin
      nexttoken;

      if crfdata then
      begin                        {generate crossreference for all
                                    identifiers that don't look like procedure
                                    references}

         if (tok <> '(') and (ptoktype = identifier) then
            crf_output(ptok);

      end
      else

      if crfall then
      begin                         {generate corssreference for all
                                      identifiers}
         if toktype = identifier then
            crf_output(ltok);
      end
      else                       {crossreference only procedure and function
                                   calls. note that this will not find
                                   function calls in an expression that
                                   do not have parameters}


      if (tok = '(') and (ptoktype = identifier) then
         crf_output(ptok);

   end;


(*
 * control statement processors
 *    for, while, repeat, with, idents
 *
 * all expect tok to be keyword
 * all exit at end of statement with next nexttoken as ; or end
 *
 *)

procedure pfor;
   begin

      repeat
         crf_nexttoken;
      until tok = 'DO';

      crf_nexttoken;
      pstatement;
   end;

procedure pwhile;
   begin

      repeat
         crf_nexttoken;
      until tok = 'DO';

      crf_nexttoken;
      pstatement;
   end;

procedure pwith;
   begin

      repeat
         crf_nexttoken;
      until tok = 'DO';
      
      crf_nexttoken;
      pstatement;
   end;

procedure prepeat;
   begin
      crf_nexttoken;
      
      while tok <> 'UNTIL' do
      begin
         pstatement;
         crf_nexttoken;

         if tok = ';' then
            crf_nexttoken;
      end;
      
      repeat
         crf_nexttoken;
      until (tok = ';') or (tok = 'END') or (tok = 'ELSE');

      ungettoken;
   end;

procedure pcase;
   begin
      
      repeat
         crf_nexttoken;
      until tok = 'OF';
      
      crf_nexttoken;
      
      repeat

         if tok <> 'ELSE' then
            
            repeat
               crf_nexttoken;
            until tok = ':';
         
         crf_nexttoken;
         pstatement;
         crf_nexttoken;
         
         if tok = ';' then
            crf_nexttoken;
      until tok = 'END';
   end;

procedure pif;
   begin
      
      repeat
         crf_nexttoken;
      until tok = 'THEN';
      
      crf_nexttoken;
      pstatement;
      crf_nexttoken;

      if tok = 'ELSE' then
      begin
         crf_nexttoken;
         pstatement
      end
      else
         ungettoken;
   end;

procedure pident;
   begin
      crf_nexttoken;             {get seperator token and decide if this
                                  is a procedure call with no parameters
                                  that will be missed by crf_nexttoken}

      if (tok = ';') and (not crfall) and (not crfdata) then
         crf_output(ptok);
      
      while (tok <> ';') and (tok <> 'END')
            and (tok <> 'ELSE') do
         crf_nexttoken;
      
      ungettoken;
   end;


(*
 * process single statement
 *
 * expects tok to be first token of statement
 * processes nested blocks
 * exits with tok as end of statement
 *
 *)

procedure pstatement;
   begin
      
      if tok = ';' then
         ungettoken
      else
      
      if tok = 'BEGIN' then
         pblock
      else

      if tok = 'FOR' then
         pfor
      else

      if tok = 'WHILE' then
         pwhile
      else

      if tok = 'WITH' then
         pwith
      else

      if tok = 'REPEAT' then
         prepeat
      else

      if tok = 'CASE' then
         pcase
      else

      if tok = 'IF' then
         pif
      else
         pident;
   end;


(*
 * process begin...end blocks
 *
 * expects tok to be begin
 * exits with tok = end
 *
 *)

procedure pblock;
   begin
      crf_nexttoken;                 {get first token of first statement}


      while tok <> 'END' do
      begin
         pstatement;                {process the statement}

         crf_nexttoken;                 {get the seperator}
         
         
         if (tok <> ';') and (tok <> 'END') then
            syntax('; or END expected');
         
         if tok = ';' then
            crf_nexttoken;              {get first token of next statement}
         
      end;
   end;


(*
 * process pascal data type specifications
 *
 *)

procedure pdatatype;
   begin
      nexttoken;

      if tok = 'RECORD' then     {process record types}

      begin
         pvar;
         nexttoken;
         ungettoken;
      end
      else

      if tok = '(' then          {process enumeration types}

      begin
         nexttoken;

         repeat
            nexttoken;
         until tok = ')';
         
         nexttoken;
         ungettoken;
      end
      else                       {process simple types (recursive)}
      
      begin
         
         repeat
            nexttoken;
         until (tok = ';') or (tok = ')');
         
         ungettoken;
      end;
   end;


(*
 * declaration section processors
 *   const, type, var, label
 *
 * all enter with tok=section type
 * exit with tok=new section or begin or proc or func
 *
 *)

procedure pconst;
   begin
      nexttoken;
      
      while (tok <> 'VAR') and (tok <> 'TYPE')
            and (tok <> 'CONST') and (tok <> 'LABEL')
            and (tok <> 'BEGIN') and (tok <> 'PROCEDURE')
            and (tok <> 'FUNCTION') do
      begin
         nexttoken;
         
         if tok = '=' then          {process value clause}
         
         begin
            nexttoken;
            
            repeat
               nexttoken;
            until tok = ';';
            
            ungettoken;
         end;
      end;
   end;

procedure ptype;
   begin
      nexttoken;
      
      while (tok <> 'VAR') and (tok <> 'TYPE')
            and (tok <> 'CONST') and (tok <> 'LABEL')
            and (tok <> 'BEGIN') and (tok <> 'PROCEDURE')
            and (tok <> 'FUNCTION') do
      begin
         nexttoken;
         
         if tok = '=' then          {process type value clause}
         
            pdatatype;
      end;
   end;

procedure pvar;
   begin
      nexttoken;
      
      while (tok <> 'VAR') and (tok <> 'TYPE')
            and (tok <> 'CONST') and (tok <> 'LABEL')
            and (tok <> 'BEGIN') and (tok <> 'PROCEDURE')
            and (tok <> 'FUNCTION') and (tok <> 'END') do
      begin
         nexttoken;
         
         if tok = ':' then          {process variable type clause}
         
            pdatatype;
      end;
   end;

procedure plabel;
   begin
      
      while tok <> ';' do
         nexttoken;
      
      nexttoken;
   end;


(*
 * process generic declaration section
 *   dispatches to const, type, var, proc, func
 *   enter with tok=section type
 *   exit with tok=next section type
 *
 *)

procedure psection;
   begin

      if tok = 'PROGRAM' then
         punit
      else

      if tok = 'PROCEDURE' then
         punit
      else

      if tok = 'FUNCTION' then
         punit
      else
      
      if tok = 'CONST' then
         pconst
      else

      if tok = 'TYPE' then
         ptype
      else

      if tok = 'VAR' then
         pvar
      else

      if tok = 'LABEL' then
         plabel
      else

      if tok = 'BEGIN' then
         pblock
      else

      if tok = 'END' then
         nexttoken
      else

      if tok = '.' then
         nexttoken
      else

      if tok = 'FORWARD' then
         nexttoken
      else

      begin
         syntax('section header expected');
         nexttoken;
      end;
   end;


(*
 * process argument declarations to
 *    program, procedure, function
 *
 * enter with header as tok
 * exits with next nexttoken as ; or :
 *
 *)

procedure punitheader;
   begin
      crf_nexttoken;                 {skip unit type}

      inproc := ltok;
      crf_output(ltok);          {put unit definition in crf}

      nexttoken;                 {skip unit identifier}


      if tok = '(' then          {process parameter list}

      begin

         while tok <> ')' do
         begin
            crf_nexttoken;

            if (tok = ':') then
               pdatatype;
         end;
         
         nexttoken;                 {get final ; or :}
         
      end;
      
      if tok = ')' then
         nexttoken;
   end;


(*
 * process body of program unit
 *   handles all declaration sections
 *   and a single begin...end
 *   recursively handles procedure declarations
 *   ends with tok=;
 *)

procedure punitbody;
   begin
      nexttoken;

      if tok <> 'FORWARD' then
      begin

         repeat

            if tok = ';' then
               nexttoken;

            psection;                  {process each section of the unit
                                         body}

         until tok = 'END';
      end;

      nexttoken;                 {skip END}
      
      nexttoken;                 {get seperator ; or .}
      
   end;


(*
 * process program, procedure and function declaration
 *
 * enter with tok=function
 * exit with tok=;
 *
 *)

procedure punit;
   var
      outerproc:     anystring;

   begin
      outerproc := inproc;       {stack the previous procedure name}

      punitheader;               {parse procedure header and set new
                                   proc name}


      if tok = ':' then
         pdatatype;              {process return types for functions}
      
      
      punitbody;                 {process the body of the unit}
      
      inproc := outerproc;       {unstack the previous proc name}
      
   end;


(*
 * process main program
 *
 *  expects program head
 *  optional declarations
 *  block of main code
 *  .
 *
 *)

procedure pprogram;
   begin
      nexttoken;
      
      repeat
         
         if (tok = ';') then
            nexttoken;
         
         psection;                  {process each section in the program}
         
      until true=false;   {program detects eof in scanner}

   end;
var
   option:        anystring;




begin                         {main}
   


(* get command line options, if any *)
   
   if paramcount = 1 then
      option := paramstr (1)
   else
   
   if paramcount = 0 then
      option := ''
   else
      option := '-?';


(* decode any options listed *)
   
   crfall := false;
   crfdata := false;

   if option = '-all' then
      crfall := true
   else

   if option = '-data' then
      crfdata := true
   else

   if option <> '' then
   begin
      writeln(con, 'Usage: pcrf <INFILE >OUTFILE [option]');
      writeln(con, 'options:  -all    [generate crf for all identifiers]');
      writeln(con, '          -data   [generate crf for all data]');
      writeln(con);
      writeln(con, 'The default is to generate crf only for procedure and');
      writeln(con, 'function calls.');
      writeln(con);
      writeln(con, 'Examples:');
      writeln(con, '  pcrf <FILE.PAS | ph       [generate heriarchy listing]');
      writeln(con);
      writeln(con, '  plist <MAIN.PAS | pcrf -all | sort | crfprn');
      writeln(con, '                            [generate crossreference for');
      writeln(con, '                             MAIN and all include files]');
      halt;
   end;

   scaninit;
   pprogram;
end.
