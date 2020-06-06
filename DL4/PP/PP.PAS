


(*
 * paspp - pascal prettyprinter and debug generator
 *
 * 9/9/85 shs
 *
 *)
{$p5120,g512,c-,d-}


program paspp (input,
               output);
const
   defidentsize = 20;         {identifier size for data type alignment}

   deflevelindent =3;         {spaced of indentation per logic level}

   maxparam =     15;         {max number of parameters to process}

   lastcodecol =  79;         {last column of code before wrapping}

   splitboolean = 40;         {split boolean expressions after this column}
   
   lastcmtcol =   69;         {last column to start a new word in a comment}
   
   commentcol =   27;         {offset from code level for comment alignment}

   linelen =      128;        {longest line length}

   newline =      ^J;

type
   anystring =    string [linelen];
   paramlist =    array [1..maxparam] of anystring;

   toktypes =     (number,
                   identifier,
                   strng,
                   comment,
                   unknown);
   
var
   firstonline:   boolean;
   level:         integer;
   ltok:          anystring;
   outpos:        integer;
   ptok:          anystring;
   ptoktype:      toktypes;
   simple:        boolean;
   tok:           anystring;
   toktype:       toktypes;
   unchrflag:     char;
   utok:          anystring;
   untokflag:     boolean;
   utoktype:      toktypes;
   unitname:      anystring;
   curtype:       anystring;
   outdebug:      boolean;
   outparams:     boolean;
   doinclude:     boolean;
   outcomment:    boolean;
   incfile:       text [512];
   incname:       anystring;
   include:       boolean;
   line:          integer;
   identsize:     integer;
   levelindent:   integer;
   maplower:      boolean;


(*
 * token output and formatting handlers
 *
 *)

procedure outspace;
begin
   write(' ');
   outpos := outpos + 1;
end;

procedure indentto (pos:           integer);
begin

   outspace;
   while outpos < pos do
      outspace;
   
   firstonline := true;
end;

procedure nextline;
var
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
   
   writeln;
   outpos := 0;
   if level > 0 then
      indentto(level);
   firstonline := true;
end;

procedure addneededspace;
begin

   if toktype <> unknown then
   begin

      if ptoktype <> unknown then
         outspace
      else

         case ptok [1] of              {space before ident unless previous
                                         special is in this list}

            '.', '^', '(', '[':        {do nothing}
                           ;

            else           outspace;
         end;
   end
   else

   if ptoktype <> unknown then
   begin

      case ltok [1] of              {space after ident unless special
                                      is in this list}

         '.', '^', ']', ')', ';', ',':
                                    {do nothing}
                        ;
         
         else           outspace;
      end;
   end;
end;


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
      
      if include then
      begin
         
         if eof (incfile) then
         begin
            close(incfile);
            include := false;
            read(input, c);
            write(con, #13, line : 5);
            clreol;
         end
         else
            read(incfile, c);
      end
      else
      begin
         
         if eof (input) then
         begin
            writeln(con, ' input lines');
            halt;
         end
         else
            read(input, c);
      end;
      
      if c = newline then
      begin
         line := line + 1;
         
         if (line mod 16)= 1 then
            write(con, #13, line : 5);
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
      
      '0'..'9', '#': scannumber;
      
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

procedure cmtwrite (s:             anystring);
begin
   
   if outcomment then
      write(s);
end;

procedure skipcurlycomment;
var
   c:             char;
   pc:            char;
   startcol:      integer;
   
begin
   
   if (ptoktype = comment) and outcomment then
      nextline;
   
   if outpos >= commentcol + level then
   begin
      nextline;
      indentto(commentcol + level);
   end
   else

   if outpos > level then
      indentto(commentcol + level);

   cmtwrite('{');
   c := getchar;
   
   if c = '$' then
   begin
      pc := getchar;
      c := getchar;
      
      if (upcase (pc)= 'I') and (c = ' ')
            and (doinclude) then
      begin
         incname := '';
         c := getchar;
         
         while c <> '}' do
         begin
            incname := incname + c;
            c := getchar;
         end;
         
         include := true;
         write(con, #13, line : 5, ' ', incname);
         clreol;
         assign(incfile, incname);
         reset(incfile);
         toktype := comment;
         cmtwrite('include ' + incname + '}');
         exit;
      end
      else
         cmtwrite('$' + pc);
   end;
   
   outpos := outpos + 1;
   startcol := outpos + 1;
   cmtwrite(c);
   
   while c <> '}' do
   begin
      pc := c;
      c := getchar;
      
      if (c =^M) or (c =^J) then
         c := ' ';
      
      if (pc = ' ') and (c <> ' ') and (c <> '}')
            and (outcomment) and (outpos >= lastcmtcol) then
      begin
         nextline;
         indentto(startcol);
      end;
      
      if ((c <> ' ') or (pc <> ' ')) and (c <> '}') then
      begin
         cmtwrite(c);
         outpos := outpos + 1;
      end;
   end;
   
   cmtwrite(c);
   toktype := comment;
   
   if outcomment then
      nextline;
end;

procedure skipparencomment;
var
   c:             char;
   
begin
   
   if outcomment then
   begin
      writeln;
      writeln;
      writeln;
      write('(*');
   end;
   
   repeat
      c := getchar;
      cmtwrite(c);
      
      if c = '*' then
      begin
         c := getchar;
         
         if c = ')' then
            toktype := comment
         else
            ungetchar(c);
      end;
   until toktype = comment;
   
   cmtwrite(c);
end;

procedure gettok;
var
   i:             integer;
   c:             char;
   
begin
   
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
      
      repeat
         ptoktype := toktype;
         scantok;
         
         if ltok = '{' then
            skipcurlycomment;
         
         if ltok = '(' then
         begin
            c := getchar;
            
            if c = '*' then
               skipparencomment
            else
               ungetchar(c);
         end;
      until toktype <> comment;
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
   include := false;
   line := 0;
end;


function stolower(s: anystring): anystring;
var
  i:  integer;

begin
   for i := 1 to length(s) do
      if (s[i] >= 'A') and (s[i] <= 'Z') then
         s[i] := chr(ord(s[i])+32);

   stolower := s;
end;


procedure nexttoken;
begin

   if untokflag = false then
   begin

      if (outpos + length (ltok))> lastcodecol then
      begin
         nextline;
         indentto(level + 6);
      end;

      if firstonline = false then
         addneededspace;

      if maplower and (toktype = identifier) then
         write(stolower(ltok))
      else
         write(ltok);
      outpos := outpos + length (ltok);
   end;

   gettok;
   firstonline := false;
end;


(*
 * pascal parser and output formatting
 *
 *)

procedure pblock; forward;

procedure pstatement; forward;

procedure pstatement_no_nextline; forward;

procedure punit; forward;

procedure pvar; forward;

procedure syntax (message:       anystring);
begin
   writeln(con);
   writeln(con, '****** ', message, ',  token="', tok, '"');
end;


(*
 * process a nested substatement
 * don't indent if statement is compound
 *
 *)

procedure psubstatement;
begin

   if tok = 'BEGIN' then
      pstatement
   else
   begin
      level := level + levelindent;

      pstatement;

      level := level - levelindent;
   end;
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
   simple := true;
   nextline;
   
   repeat
      nexttoken;
   until tok = 'DO';
   
   nexttoken;
   psubstatement;
   simple := false;
end;

procedure pwhile;
begin
   simple := true;
   nextline;
   
   repeat
      
      if (outpos > splitboolean) then
      begin
         
         if (tok = 'AND') or (tok = 'OR') then
         begin
            nextline;
            indentto(level + 6);
         end;
      end;
      
      nexttoken;
   until tok = 'DO';
   
   nexttoken;
   psubstatement;
   simple := false;
end;

procedure pwith;
begin
   simple := true;
   nextline;
   
   repeat
      nexttoken;
   until tok = 'DO';

   nexttoken;
   pstatement;
   simple := false;
end;

procedure prepeat;
begin
   simple := true;
   nextline;
   level := level + levelindent;
   nexttoken;
   
   while tok <> 'UNTIL' do
   begin
      pstatement;
      nexttoken;
      
      if tok = ';' then
         nexttoken;
   end;
   
   level := level - levelindent;
   nextline;
   
   repeat
      nexttoken;
   until (tok = ';') or (tok = 'END') or (tok = 'ELSE');
   
   ungettoken;
   simple := false;
end;

procedure pcase;
begin
   simple := true;
   nextline;

   repeat
      nexttoken;
   until tok = 'OF';
   
   level := level + levelindent;
   nexttoken;
   
   repeat
      nextline;
      
      if tok <> 'ELSE' then
         
         repeat
            nexttoken;
         until tok = ':';
      
      ptoktype := unknown;       {force no space before ':'}
      simple := true;

      nexttoken;                 {need handler on seperate line?}


      level := level + 2*levelindent;

      if outpos >= level then
         pstatement
      else

      begin
         indentto(level);
         pstatement_no_nextline;
      end;

      level := level - 2*levelindent;

      nexttoken;
      
      if tok = ';' then
         nexttoken;
      
      if tok <> 'END' then
         nextline;
   until tok = 'END';
   
   level := level - levelindent;
   nextline;
   simple := false;
end;

procedure pif;
begin
   simple := true;
   nextline;
   
   repeat
      
      if (outpos > splitboolean) then
      begin
         
         if (tok = 'AND') or (tok = 'OR') then
         begin
            nextline;
            indentto(level + 6);
         end;
      end;
      
      nexttoken;
   until tok = 'THEN';

   nexttoken;
   psubstatement;

   nexttoken;

   if tok = 'ELSE' then
   begin
      simple := true;
      nextline;
      nexttoken;

      if tok = 'IF' then
         pstatement
      else
         psubstatement;
   end
   else
      ungettoken;
   
   simple := false;
end;

procedure pident;
begin

   if simple = false then
      nextline;

   simple := true;

   if outdebug and (tok = 'EXIT') then
   begin
      write('BEGIN DEBUG_EXIT; EXIT END; IF (FALSE) THEN');
      nextline;
      exit;
   end;


   nexttoken;                 {get ^, ., :, [, or (}


   case ltok [1] of
      '^', '.', '[', '(':
         ptoktype := unknown;    {prevent unwanted space}

   end;

   while (tok <> ';') and (tok <> 'END') and (tok <> 'ELSE') do
   begin
      nexttoken;

      if ((outpos+length(tok)+5) > lastcodecol) and (ptok = ',') then
      begin
         nextline;
         indentto(level + 6);
      end;

      if (outpos > splitboolean) then
      begin

         if (tok = 'AND') or (tok = 'OR') then
         begin
            nextline;
            indentto(level + 6);
         end;
      end;
   end;
   
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

procedure pstatement_no_nextline;
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

procedure pstatement;
begin
   nextline;
   pstatement_no_nextline;
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
   simple := true;

   if curtype = 'PROGRAM' then {special case for MAIN}
   begin
      nextline;
      nextline;
      nextline;
      curtype := 'MAIN';
   end;

   level := level + levelindent;
   nexttoken;                 {get first token of first statement}


   while tok <> 'END' do
   begin
      pstatement;                {process the statement}

      nexttoken;                 {get the seperator}


      if (tok <> ';') and (tok <> 'END') then
         syntax('; or END expected');

      if tok = ';' then
         nexttoken;              {get first token of next statement}

   end;

   level := level - levelindent;
   nextline;
end;


(*
 * process pascal data type specifications
 *
 *)

procedure pdatatype (ind:           integer);
begin
   ptoktype := unknown;
   nexttoken;
   indentto(ind);
   
   if tok = 'RECORD' then
   begin
      level := level + levelindent;
      pvar;
      level := level - levelindent;
      nextline;
      nexttoken;
      ungettoken;
   end
   else
   
   if tok = '(' then
   begin
      level := level + identsize + 1;
      nexttoken;
      
      repeat
         nexttoken;
         
         if tok = ',' then
         begin
            nexttoken;
            nextline;
         end;
      until tok = ')';
      
      nexttoken;
      ungettoken;
      level := level - identsize - 1;
   end
   else
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
   level := level + levelindent;
   nextline;
   
   while (tok <> 'VAR') and (tok <> 'TYPE')
         and (tok <> 'CONST') and (tok <> 'LABEL')
         and (tok <> 'BEGIN') and (tok <> 'PROCEDURE') and (tok <> 'OVERLAY')
         and (tok <> 'FUNCTION') do
   begin
      nexttoken;
      
      if (ptok = ',') or (tok = ';') then
      begin
         nexttoken;
         nextline;
      end;
      
      if tok = '=' then
      begin
         nexttoken;
         indentto(level + identsize);
         
         repeat
            nexttoken;
         until tok = ';';
         
         ungettoken;
      end;
   end;
   
   level := level - levelindent;
end;

procedure ptype;
begin
   nexttoken;
   level := level + levelindent;
   nextline;
   
   while (tok <> 'VAR') and (tok <> 'TYPE')
         and (tok <> 'CONST') and (tok <> 'LABEL')
         and (tok <> 'BEGIN') and (tok <> 'PROCEDURE') and (tok <> 'OVERLAY')
         and (tok <> 'FUNCTION') do
   begin
      nexttoken;
      
      if (tok = ',') or (tok = ';') then
      begin
         nexttoken;
         nextline;
      end;
      
      if tok = '=' then
      begin
         nexttoken;
         ungettoken;
         pdatatype(level + identsize);
      end;
   end;
   
   level := level - levelindent;
end;

procedure pvar;
begin
   nexttoken;
   level := level + levelindent;
   nextline;
   
   while (tok <> 'VAR') and (tok <> 'TYPE')
         and (tok <> 'CONST') and (tok <> 'LABEL')
         and (tok <> 'BEGIN') and (tok <> 'PROCEDURE') and (tok <> 'OVERLAY')
         and (tok <> 'FUNCTION') and (tok <> 'END') do
   begin
      nexttoken;
      
      if (tok = ',') or (tok = ';') then
      begin
         nexttoken;
         
         if tok <> 'END' then
            nextline;
      end;
      
      if tok = ':' then
         pdatatype(level + identsize);
   end;
   
   level := level - levelindent;
end;

procedure plabel;
begin
   nextline;
   
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

   if tok = 'OVERLAY' then
   begin
      nexttoken;
      punit;
   end
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

procedure punitheader(var paramcnt: integer;
                      var paramtab: paramlist);
var
   argspos:       integer;

begin
   nexttoken;                 {skip unit type}

   unitname := ltok;          {save current unit name}

   nexttoken;                 {skip unit identifier}

   paramcnt := 0;
   
   if tok = '(' then
   begin
      argspos := outpos + 2;
      
      while tok <> ')' do
      begin
         nexttoken;
         
         if outparams and ((tok = ',') or (tok = ':')) then
         begin
            paramcnt := paramcnt + 1;
            paramtab[paramcnt]:= ptok + ',sizeof(' + ptok + ')';
         end;
         
         if (tok = ';') or (tok = ',') then
         begin
            nexttoken;
            nextline;
            indentto(argspos);
         end;

         if (tok = ':') then
            pdatatype(argspos + identsize);
      end;
      
      nexttoken;                 {get final ; or :}
      
   end;
   
   if tok = ')' then
      nexttoken;              {kludge - why?}
   
end;


(*
 * process body of program unit
 *   handles all declaration sections
 *   and a single begin...end
 *   recursively handles procedure declarations
 *   ends with tok=;
 *)

procedure punitbody(var paramcnt: integer;
                    var paramtab: paramlist);
var
   i:             integer;
   inunit:        anystring;

begin
   nexttoken;

   if tok <> 'FORWARD' then
   begin

      inunit := unitname;
      repeat

         if tok = ';' then
            nexttoken;

         if outdebug and (tok = 'BEGIN') then
         begin
            nextline;
            write('BEGIN DEBUG_ENTER(''', inunit, ''',',paramcnt,');');

            for i := 1 to paramcnt do
            begin
               nextline;
               write('DEBUG_PARAM(', paramtab [i], ');');
            end;

            nextline;
            psection;
            write(';DEBUG_EXIT; END;');
            nextline;
         end
         else
         begin
            nextline;
            psection;
         end;
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
   prevtype:      anystring;
   paramcnt:      integer;
   paramtab:      paramlist;

begin
   prevtype := curtype;
   curtype := tok;

   if (prevtype <> 'PROGRAM') and (prevtype <> 'MAIN') then
      level := level + levelindent;

   nextline;
   punitheader(paramcnt,paramtab);

   if tok = ':' then
      pdatatype(outpos + 2);

   punitbody(paramcnt,paramtab);

   if (prevtype <> 'PROGRAM') and (prevtype <> 'MAIN') then
      level := level - levelindent;

   curtype := prevtype;
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
      
      nextline;
      psection;
   until tok = '.';
   
   writeln('.');
end;

function atoi (s:             anystring): integer;
var
   i:             integer;
   v:             integer;
   
begin
   v := 0;
   
   for i := 1 to length (s) do
   begin
      
      if s [i] in ['0'..'9'] then
         v := v * 10 + ord (s [i])- ord ('0')
      else
      begin
         writeln(con, 'Invalid number: ', s);
         halt;
      end;
   end;
   
   atoi := v;
end;
var
   i:             integer;
   



begin                         {main}
   


(* provide default options *)
   outdebug := false;
   outparams := false;
   doinclude := false;
   outcomment := true;
   identsize := defidentsize;
   levelindent := deflevelindent;
   maplower := false;


(* get command line options, if any *)
   i := 1;

   while i <= paramcount do
   begin

      if paramstr (i)= '-debug' then
         outdebug := true
      else

      if paramstr (i)= '-params' then
         outparams := true
      else

      if paramstr (i)= '-include' then
         doinclude := true
      else
      
      if paramstr (i)= '-nocomment' then
         outcomment := false
      else

      if paramstr (i)= '-indent' then
      begin
         i := i + 1;
         levelindent := atoi (paramstr (i));
      end
      else

      if paramstr (i)= '-identlen' then
      begin
         i := i + 1;
         identsize := atoi (paramstr (i));
      end
      else

      if paramstr (i)= '-lower' then
         maplower := true
      else
      begin
         writeln(con, 'Invalid option: ', paramstr (i));
         writeln(con);
         writeln(con, 'Usage: paspp <INFILE >OUTFILE [option]');
         writeln(con, 'options:  -debug         [out debug enter/exit calls]');
         writeln(con, '          -params        [out debug param calls]');
         writeln(con, '          -include       [process all include files]');
         writeln(con, '          -nocomment     [strip all comments]');
         writeln(con, '          -indent N      [indent each block N spaces]');
         writeln(con, '          -identlen N    [identifiers are N columns wide]');
         writeln(con, '          -lower         [map idents to lower case]');
         halt;
      end;
      
      i := i + 1;
   end;


(* do other initializations *)
   
   scaninit;
   level := 0;
   outpos := 0;
   firstonline := true;
   simple := true;
   curtype := 'PROGRAM';
   unitname := 'MAIN';


(* process the source file(s) *)
   pprogram;
   writeln;
   writeln(con, ' input lines');
end.

