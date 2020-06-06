

(*
 * pstyle - pascal style measurement utility
 *          reports lines of code and comments,
 *          word counts, etc.
 *
 * usage:
 *       pstyle <FILE.PAS >PRN
 *
 * shs 8/28/85
 *
 *)

{$g1024,p128,d-,c-}


program pascalstyle (input,
                   output);
const
   identsize =    40;         {identifier size for data type alignment}

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
   srclines:      integer;
   cmtlines:      integer;
   cmtwords:      integer;
   units:         integer;
   tokens:        integer;
   statements:    integer;

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

(*
 * increment an integer
 *
 *)

procedure inc(var v: integer);
begin
   v := v + 1;
end;



(*
 * print style summary report
 *
 *)

procedure printsummary;
begin
   writeln(con, #13, srclines, ' source lines ');

   writeln;
   writeln;
   writeln('Total source lines:   ',srclines:5);
   writeln('Program units:        ',units:5);
   writeln('Pascal statements:    ',statements:5);
   writeln('Pascal tokens:        ',tokens:5);
   writeln('Lines of comments:    ',cmtlines:5);
   writeln('Comment words:        ',cmtwords:5);
   writeln;

   if units > 0 then
   begin
      writeln('Statements/unit:   ',int(statements)/int(units):8:2);
      writeln('Tokens/unit:       ',int(tokens)/int(units):8:2);
      writeln('Source lines/unit: ',int(srclines)/int(units):8:2);
   end;

   if statements > 0 then
   begin
      writeln('Tokens/Statement:  ',int(tokens)/int(statements):8:2);
      writeln('Comments/Statement:',int(cmtlines)/int(statements):8:2);
      writeln('Source lines/Stmt: ',int(srclines)/int(statements):8:2);
   end;

end;



(*
 * pascal lexical scanner
 *
 *)


procedure ungetchar (c:             char);
   begin
      unchrflag := c;
   end;


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
            printsummary;
            halt;
         end;

         read(input, c);

         if (c = newline) then
         begin
            inc(srclines);
            if (srclines mod 16) = 1 then
               write(con, #13, srclines);
         end;

         getchar := c;
      end;
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

procedure skipcurlycomment;
   var
      pc,c:          char;
      echo:          boolean;

   begin

      echo := false;
      inc(cmtlines);
      c := '{';

      repeat
         pc := c;
         c := getchar;
         if echo then
            write(c);

         if (c = '{') or
            ((pc = '(') and (c = '*')) then
         begin
            writeln;
            writeln('WARNING: nested comments:');
            echo := true;
         end;

         if c = newline then
            inc(cmtlines);

         if c = ' ' then
         begin
            inc(cmtwords);
            while c = ' ' do
               c := getchar;

            ungetchar(c);
            c := ' ';
         end;

      until c = '}';

      toktype := comment;
   end;

procedure skipparencomment;
   var
      pc,c:          char;
      echo:          boolean;

   begin

      echo := false;
      inc(cmtlines);
      pc := ' ';

      repeat
         pc := c;
         c := getchar;
         if echo then
            write(c);

         if (c = '{') or
            ((pc = '(') and (c = '*')) then
         begin
            writeln;
            writeln('WARNING: nested comments:');
            echo := true;
         end;

         if c = newline then
            inc(cmtlines);

         if c = ' ' then
         begin
            inc(cmtwords);
            while c = ' ' do
               c := getchar;

            ungetchar(c);
            c := ' ';
         end;

         if (pc = '*') and (c = ')') then
            toktype := comment

      until toktype = comment;
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
         inc(tokens);

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

      srclines := 0;
      cmtlines := 0;
      cmtwords := 0;
      units := 0;
      tokens := 0;
      statements := 0;

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
         nexttoken;
      until tok = 'DO';

      nexttoken;
      pstatement;
   end;

procedure pwhile;
   begin

      repeat
         nexttoken;
      until tok = 'DO';

      nexttoken;
      pstatement;
   end;

procedure pwith;
   begin

      repeat
         nexttoken;
      until tok = 'DO';
      
      nexttoken;
      pstatement;
   end;

procedure prepeat;
   begin
      nexttoken;
      
      while tok <> 'UNTIL' do
      begin
         pstatement;
         nexttoken;
         
         if tok = ';' then
            nexttoken;
      end;
      
      repeat
         nexttoken;
      until (tok = ';') or (tok = 'END') or (tok = 'ELSE');

      ungettoken;
   end;

procedure pcase;
   begin
      
      repeat
         nexttoken;
      until tok = 'OF';
      
      nexttoken;
      
      repeat
         
         if tok <> 'ELSE' then
            
            repeat
               nexttoken;
            until tok = ':';
         
         nexttoken;
         pstatement;
         nexttoken;
         
         if tok = ';' then
            nexttoken;
      until tok = 'END';
   end;

procedure pif;
   begin
      
      repeat
         nexttoken;
      until tok = 'THEN';
      
      nexttoken;
      pstatement;
      nexttoken;
      
      if tok = 'ELSE' then
      begin
         nexttoken;
         pstatement
      end
      else
         ungettoken;
   end;

procedure pident;
   begin
      nexttoken;

      while (tok <> ';') and (tok <> 'END') and (tok <> 'ELSE') do
         nexttoken;
      
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
      inc(statements);

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
            
            inc(statements);
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

         if tok = ';' then
            inc(statements);
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

         if tok = ';' then
            inc(statements);
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

      if tok = 'OVERLAY' then
         nexttoken
      else

      if tok = '.' then
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
      nexttoken;                 {skip unit type}

      nexttoken;                 {skip unit identifier}


      if tok = '(' then          {process parameter list}

      begin

         while tok <> ')' do
         begin
            nexttoken;

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
   begin
      inc(units);

      punitheader;               {parse procedure header and set new
                                   proc name}


      if tok = ':' then
         pdatatype;              {process return types for functions}


      punitbody;                 {process the body of the unit}
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




begin                         {main}

   if paramcount <> 0 then
   begin
      writeln(con,'Usage: pstyle <INFILE >OUTFILE');
      halt;
   end;

   scaninit;
   pprogram;
end.
