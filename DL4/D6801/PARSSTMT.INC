


(*******************************************************
 *
 * Subsystem:   Parsstmt - Statement Parser subsystem
 *
 * Overview
 * --------
 *
 *    This is the heart of the compiler.   This subsystem contains the
 *    parse* procedures which parse each element of the D1 language
 *    and make calls to the code generator to generate code.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *
 *
 *)



(*       Each routine calls on GetTK (the scanner).  Statements haveing to do
 *       with parsing proper are interleaved with those for type checking
 *       and code generation.    *)

procedure parsestatement; forward;



(*      If the current token is not "var," there are no variables and
 *      the routine exits.  Otherwise each declaration is checked for
 *      proper form and object code for the variable is generated.
 *      This version will allow a single subscript.  The rest of the
 *      parser will work with any number of subscripts, when this
 *      procedure is finished to fill in the needed information
 *      in the symbol table.
 *
 *      variable declarations have the general form:
 *         var   identifier (optional subscript):  type (optional type size);
 *)

procedure parsevariables;
var
   holdvar:  identstr;
   holdtype: tokcode;
   elements: integer;
   subs:     integer;
   junk:     integer;
   sym:      symptr;
   size:     integer;

begin

   if tk.code = varsym then   { else no variables in this context }

   begin
      gettk;                     { consume the "var" token }

      repeat                        { loop for arbitrary number of variables }

         if tk.code <> ident then
            error(xident);          { must be a variable identifier }

         holdvar := tk.name;        { save the identifier }

         gettk;                     { consume the identifier token }

         subs := 0;
         elements := 1;

         if tk.code = leftparen then
         begin
            gettk;                     { parse optional subscript declaration }

            if tk.code <> number then
               error(xnumber);         { missing element count }

            val(tk.name, elements, junk);
                                       { put the element count into the
                                         symbol table }
            subs := 1;
            gettk;

            if tk.code <> rightparen then
               error(xparen);          { syntax error? this is where multiple
                                         subscript declarations will
                                         someday be handled }
            gettk;
         end;


         if tk.code <> colon then
            error(xcolon);          { check for the required ":" }

         gettk;                     { consume the ":" }


         if not (tk.code in typeset) then
            error(xtype);           { must be a legal variable type code }

         holdtype := tk.code;       { save the variable type code }

         gettk;                     { consume the type code }


         if tk.code = leftparen then
         begin
            gettk;                     { parse the optional type size }

            if tk.code <> number then
               error(xnumber);         { missing element count }

            val(tk.name, size, junk);  { find the size }

            case holdtype of           { change the data type code according
                                         to the specified size }
               intsym, bytesym:
                  case size of
                     1:   holdtype := bytesym;     { integer(1) -> byte }
                     2:   holdtype := intsym;      { byte(2) -> integer }
                     else error(xtype);
                  end;

               charsym:                { char(n) -> string length n }
                  elements := elements * size;

               else  error(xtype);
            end;


            gettk;                     { consume the number }

            if tk.code <> rightparen then
               error(xparen);          { check for matching paren }

            gettk;                     { consume the paren }

         end;


         sym := declare (holdvar, variable, holdtype);
                                    { install in symbol table}

         sym^.subscripts := subs;
         sym^.subelements [1]:= elements;
                                    { install description of subscripts }

         genvariable(sym^.name, sym^.vartype, elements);
                                    { generate code to handle the variable }


         if tk.code <> semi then
            error(xsemi);           { check for the final required ";"}

         gettk;                     { consume the ";" }

      until (tk.code in [procsym, beginsym]);
                                 { no more variables }

   end;
end;


(*       Parsebegin parses compound statements in the form
 *       begin ...; ... end   *)

procedure parsebegin;
begin
   gettk;                     { consume the "BEGIN" }

   while tk.code <> endsym do { loop while stmts }
   begin
      parsestatement;            { calls itself }

      if not (tk.code in [semi, endsym]) then
         error(xsemend);         { delimiter expected }

      if tk.code = semi then
         gettk;                  { go back for another}
   end;

   gettk;                     { TK must be "END"; consume it }

end;


(*       Parseif parses if-then statements in the form
 *       if <boolean expression> then <statement>
 *                               [else <statement>] *)

procedure parseif;
var
   endbody:  objlabel;        { label for end of body of conditional block }

   elsepart: objlabel;        { label for start of else block of if-then-else }


begin
   gettk;                     { consume the "IF" }

   if not (boolsym = parseexpression (boolsym)) then
      error(xbool);           { parse expr & ck type, only boolean allowed}

   endbody := newlabel;
   elsepart := newlabel;
   genjumpfalse(elsepart);    { jump to else part if the boolean condition
                                is false }

   if tk.code <> thensym then
      error(xthen);           { must have then part }

   gettk;                     { if present, consume it }

   parsestatement;            { parse the conditional statement }

   if tk.code = elsesym then
   begin                         { if else present }

      genjump(endbody);          { jump around the else part }

      genlabel(elsepart);
      gettk;                     { and consume else the token }

      parsestatement;            { parse the else statement }
   end
   else
      genlabel(elsepart);     { label the empty else part }

   genlabel(endbody);         { label the end of the if }

end;


(*       Parsewhile parses while statements in the form
 *       while <boolean expression> do <statement> *)

procedure parsewhile;
var
   endbody:  objlabel;        { label for end of body of conditional block }

   startbody: objlabel;       { label for start of body of a block }


begin
   startbody := newlabel;     { mark the condition test }

   genlabel(startbody);       { so it can be checked again }

   endbody := newlabel;       { will need to know where the loop ends
                                when condition is false }

   gettk;                     { consume WHILE tok }

   if not (boolsym = parseexpression (boolsym)) then
      error(xbool);           { parse and check type, must be boolean }

   if tk.code <> dosym then
      error(xdo);             { must have Do part }

   gettk;                     { consume the DO }

   genjumpfalse(endbody);     { if false, branch out of loop }

   parsestatement;            { parse the repeated statement }

   genjump(startbody);        { branch back and check condition }

   genlabel(endbody);         { mark the exit point for the loop }

end;


(*       Parserepeat parses repeat statements in the form
 *       repeat <statement> ; ... until <boolean expression>  *)

procedure parserepeat;
var
   startbody: objlabel;       { label for start of body of a block }


begin
   startbody := newlabel;     { mark the condition test }

   genlabel(startbody);       { so it can be checked again }

   gettk;                     { skip the REPEAT token }

   repeat
      parsestatement;            { parse the repeated statement }

      if not (tk.code in [semi, endsym]) then
         error(xsemend);         { delimiter expected }

      if tk.code = semi then
         gettk;

   until tk.code = untilsym;

   gettk;                     { skip the UNTIL token }

   if not (boolsym = parseexpression (boolsym)) then
      error(xbool);           { parse and check type, must be boolean }

   genjumpfalse(startbody);    { if false, repeat again }

end;


(*       Parsefor parses for statements in the form
 *       for <variable> := <expression> [down]to <expression>
 *       do <statement> *)

procedure parsefor;
var
   endbody:  objlabel;        { label for end of body of conditional block }

   startbody: objlabel;       { label for start of body of a block }

   sym:      symptr;          { used to check symbol table }

   substype: tokcode;         { data type of subscript index expression }

   updown:   tokcode;         { is loop direction TO or DOWNTO? }


begin
   gettk;                     { consume the FOR token }

   sym := find (tk.name);
                              { look up in table }

   if sym = nil then
      error(undec);           { can't find it }

   if not (sym^.vartype in numset) then
      error(xtype);            { must be a numeric variable }

   gettk;

   if tk.code <> assignop then
      error(xassgn);          { must have := sign }

   gettk;                     { if so, consume it }

   if not (sym^.vartype = parseexpression (sym^.vartype)) then
      error(match);           { parse init expr & ck type, report mismatch }

   if not (tk.code in [tosym, downtosym]) then
      error(xto);

   updown := tk.code;         { remember the loop direction }

   gettk;
   startbody := newlabel;     { mark the condition test }

   genlabel(startbody);       { so it can be checked again }

   genstore(sym, null);
                              { code to store current value }

   if not (sym^.vartype = parseexpression (sym^.vartype)) then
      error(match);           { parse end expr & ck type, report mismatch }

   genfetch(sym, null);
                              { compare variable to exit value }
   if updown = tosym then
      genoperator(lt, sym^.vartype)
   else
      genoperator(gt, sym^.vartype);

   endbody := newlabel;       { branch out of loop if > top }

   genjumptrue(endbody);


   if tk.code <> dosym then
      error(xdo);             { check for the DO }

   gettk;                     { skip the DO }

   parsestatement;            { parse the body of the loop }

   genfetch(sym, null);
                              { get the control variable }

   genliteral('1', sym^.vartype); { get the loop step constant }

   if updown = tosym then     { and add it to the index variable }
      genoperator(plus, sym^.vartype)
   else
      genoperator(minus, sym^.vartype);

   genjump(startbody);        { branch back to test for exit }

   genlabel(endbody);         { label the end of the loop }

end;


(*       Parseident parses for assignments and procedure calls.
 *       The symbol table is consulted to decide if this is
 *       a procedure call.  Only procedures can be called, only
 *       variables can be assigned.
 *       Calls have the form:  <ident>;
 *       Assignments have the form:  <variable> := <expression> *)

procedure parseident;
var
   sym:      symptr;          { used to check symbol table }

   substype: tokcode;         { data type of subscript index expression }


begin
   sym := find (tk.name);
                              { look up in table }
   if sym = nil then
      error(undec);           { can't find it }

   if sym^.class = variable then
                              { this must be an assignment }
   begin
      gettk;
      substype := parsesubscripts (sym);
                                 { look for and generate subscript index }

      if tk.code <> assignop then
         error(xassgn);          { must have := sign }

      gettk;                     { if so, consume it }

      if not (sym^.vartype = parseexpression (sym^.vartype)) then
         error(match);           { parse expr & ck type, report mismatch }

      genstore(sym, substype);
                                 { code to store value, uses index already
                                   on stack, if needed }

   end
   else                       { this must be a proc call }

   begin
      gencall(sym^.name);
      gettk;
   end;

end;


(*       Parseread parses the "builtin" read function with the form
 *       readln <variable>  *)

procedure parseread;
var
   sym:      symptr;          { used to check symbol table }

   substype: tokcode;         { data type of subscript index expression }


begin
   gettk;                     { consume READLN token }

   if tk.code <> leftparen then
      error(xparen);          { check for the "(" }

   gettk;

   sym := find (tk.name);     { look up in table }

   if sym^.class <> variable then
      error(xvar);            { must be a variable }


   substype := parsesubscripts (sym);
                              { parse any needed subscripts }

   genoperator(readsym, sym^.vartype);
                              { operator to read data on to the
                                top of stack }

   genstore(sym, substype);
                              { store the value into the destination }

   gettk;                     { consume the Ident }

   if tk.code <> rightparen then
      error(xparen);          { make sure there is a ")" }

   gettk;                     { consume the paren }
end;


(*       Parsewrite parses the "builtin" write function with the form
 *       writeln <expression>  *)

procedure parsewrite;
var
   holdtype: tokcode;         { hold while exp. type is checked }


begin
   gettk;                     { consume WRITELN token }

   holdtype := parseexpression (null);
                              { parse the value expression and save the
                                data type }

   genoperator(writesym, holdtype);
                              { operator to write an value from the top
                                of stack }

end;


(*       ParseStatement determines the statement type and calls the
 *       appropriate parser for it.  *)

procedure parsestatement;
begin

   case tk.code of
      beginsym:   parsebegin;          { compound statements }

      ifsym:      parseif;             { conditional if...then...else }

      whilesym:   parsewhile;          { while ... do ... }

      repeatsym:  parserepeat;         { repeat ... ; ... until ... }

      forsym:     parsefor;            { for <id> := n [down]to m do ... }

      ident:      parseident;          { assignment or call }

      readsym:    parseread;           { readln <id> }

      writesym:   parsewrite;          { writeln <expression> }

      else        error(xstmt);        { if none of the above }
   end;

end;


(*       ParseBlock has two parts.  It first checks for a procedure declar-
 *       ation; if it finds one, it parses the header and calls itself again.
 *       Ultimately, the BEGIN symbol that marks the statement part of a block
 *       must be reached.  Each statement is then processed in turn (by Parse-
 *       Statement) until the matching END is reached.  The possible nesting
 *       of blocks within blocks is accommodated automatically by the re-
 *       cursive organization of the routines.  Recall that ParseBlock is passed
 *       an identifier as an argument, namely the Ident of the procedure or
 *       program that issued the call.  This Ident is written into the code as
 *       the designator of a Object word when "begin" is reached.   *)

procedure parseblock (caller:   identstr);
                           { "Caller" will be the Ident gen-}
var                        { erated when "begin" is reached.}

   holdid:   identstr;
   sym:      symptr;

begin                         { ParseBlock }

   currentscope := currentscope + 1;
                              { bump up nesting count }

   while tk.code = procsym do { proc declarations }
   begin
      gettk;                     { consume "procedure" token }

      if tk.code <> ident then
         error(xident);          { proc must have name }

      sym := declare (tk.name, proc, null);
                                 { put in table as proc name }

      holdid := sym^.name;       { save to pass to next level }

      gettk;                     { consume the Ident }

      if tk.code <> semi then
         error(xsemi);           { must have a semi }

      gettk;                     { throw the semi away }

      parsevariables;            { do the local variable declarations }

      parseblock(holdid);        { call again, pass proc name }

      if tk.code <> semi then
         error(xsemi);           { proc block must have semi }

      gettk;                     { consume it }
   end;


   if tk.code <> beginsym then
      error(xbegin);          { block begins "BEGIN" }

   genproc(caller);           { start object program unit }

   gettk;                     { consume the "BEGIN" }


   while tk.code <> endsym do { loop for all statements }

   begin
      parsestatement;            { call for each stmt }

      if not (tk.code in [semi, endsym]) then
         error(xsemend);         { separator or terminator... need after
                                   each one }

      if tk.code = semi then
         gettk;                  { if semi, consume & go back }

   end;                       { TK must have been "END" }


   gettk;                     { consume the END }

   genendproc(caller);        { end Object unit def }

   blot;                      { clean up symbol table }

end;


(*       ParseProgram sets the entire compiler in motion.  It first handles
 *       the program header, saving the program name, if given.
 *       The program is declared in the symbol
 *       table as a procedure like any other, except that its scope field
 *       has a value of zero, which no other procedure can have.  ParseProgram
 *       then calls ParseVariables and ParseBlock, which process the body
 *       of the program.  Finally there is a check for the final dot.   *)

procedure parseprogram;
var
   holdid:   identstr;        { hangs onto the program name }

   sym:      symptr;

begin                         { ParseProgram }

   read(infile, ch);
   ch := upcase (ch);         { get first char for scanner }

   gettk;                     { and first token for parser }

   if tk.code = pgmsym then
   begin                      { if there is a "PROGRAM" header }

      gettk;                     { consume the PROGRAM token }

      if tk.code <> ident then
         error(xident);          { program must have a name }

      holdid := tk.name;         { save the name }

      gettk;                     { consume the name }

      if tk.code <> semi then
         error(xsemi);           { header must end with semi }

      gettk;                     { consume the semi }
   end

   else                       { else no PROGRAM header, provide default }
      holdid := 'NONAME';


   sym := declare (holdid, proc, null);
                              { install program name in symbol table }

   holdid := sym^.name;       { save the formal name of the program }

   genheader(holdid);         { output the object prelude }

   parsevariables;            { do the global declarations }

   parseblock(holdid);        { parse all procedures and "main" block }

   if not (tk.code in [dot,semi]) then
      error(xdot);            { not done until "." read }

   gentrailer(holdid);        { terminate the Object file }
end;
