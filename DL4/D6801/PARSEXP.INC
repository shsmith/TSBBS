


(*******************************************************
 *
 * Subsystem:   Parsexp - Expression Parser subsystem
 *
 * Overview
 * --------
 *
 *    This subsystem is the expression parser that is used widely
 *    by the statement parser.   Calls are made to the code
 *    generator as the expression is being processed.   The recursive
 *    nature of this parses allows direct generation of object code
 *    without making an intermediate parse tree.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *
 *)


(*       Each routine calls on GetTK (the scanner).  Statements haveing to do
 *       with parsing proper are interleaved with those for type checking
 *       and code generation.    *)


(*       All the routines on down to ParseExpression are defined as
 *       functions rather than procedures.  They return the type (integer
 *       or boolean) deduced from the operations specified.  The "HoldOp"
 *       variables are needed to delay code generation for postfix notation.
 *       The "HoldType" variables record the type of the first operand so
 *       that it can be compared with the type of the second operand.  *)

 function parseexpression(exptype: tokcode): tokcode; forward;


(*       ParseSubscripts will expect subscripts in the current context,
 *       will generate code to evaluate the subscripts and to leave the
 *       index into the variable on the stack (index of 0=first element).
 *       Does not leave anything on the stack if number of subscripts=0.  *)

 function parsesubscripts(sym: symptr): tokcode;
 var
    i:        integer;
    multstr:  string[5];
    holdtype: tokcode;

 begin

   parsesubscripts := null;
   if sym^.subscripts = 0 then
      exit;


   if tk.code <> leftparen then
      error(xparen);

   holdtype := bytesym;         { try to make 8 bit subscript calculations,
                                  but switch to 16 bit if needed }

   gettk;                       { parse subscript declaration as
                                  ident(sub[,sub]): type }


   for i := 1 to sym^.subscripts do    { for each required subscript }
   begin
      holdtype := parseexpression(holdtype);

      if not (tk.code in [comma, rightparen]) then
         error(xparen);            { syntax error?  this is where
                                     multiple subscript declarations
                                     will someday be handled }

      if i < sym^.subscripts then  { if there are more subscripts, then
                                     multiply this by the number of elements
                                     in this subscript }
      begin
         str(sym^.subelements[i]:0, multstr);
         genliteral(multstr, holdtype);

         genoperator(times, holdtype);
      end;

      gettk;
   end;


   parsesubscripts := holdtype;     { return data type of the index value }

 end;



(*       ParseFactor is the lowest-level routine in the parser.  For a factor
 *       to be recognized as valid it must be either a boolean literal (TRUE
 *       of FALSE), a numeric literal, an identifier that designates a var-
 *       iable or a parenthesized expression.  The case statement considers
 *       each of these possibilities in turn.  *)

 function parsefactor(exptype: tokcode): tokcode;
 var
   sym:          symptr;      { needed to consult the symbol table }
   subtype:      tokcode;     { data type of subscript index }

 begin

   case tk.code of
      truesym, falsesym:
            begin
               parsefactor := boolsym;    { return type boolean }

               genliteral(tk.name, boolsym);
               gettk;                     { Gen TRUE or FLASE }

            end;

      number:
            begin
               if exptype = boolsym then  { numbers can't be boolean }
                  error(match);

               parsefactor := exptype;    { return type is expression type }

               genliteral(tk.name, exptype);
               gettk;                     { Gen numeric literal }

            end;

      charstr:
            begin

               parsefactor := charsym;      { return type is string }

               genliteral(tk.name, charsym);
                                           { get string literal }
               gettk;

            end;


      ident:
            begin
               sym := find (tk.name);
                                          { look up the name }
               if sym = nil then
                  error(undec)               { not found? }

               else
               begin

                  {get a value in an expression - add code here to
                   call functions when they are implemented}

                  if sym^.class <> variable then
                                             { can only fetch variables }
                     error(xvar)
                  else

                  begin
                     parsefactor := sym^.vartype;

                     gettk;
                     subtype := parsesubscripts(sym);
                                                { parse any subscripts
                                                  and push index, if any }

                     genfetch(sym, subtype);
                                                { generate code to fetch, may
                                                  use stacked subscript }
                  end;
               end;
            end;

      leftparen:
            begin                         { call ParseExpression recursively }

               gettk;                     { and return the type }

               parsefactor := parseexpression(exptype);
                                          { that it returns }


               if tk.code <> rightparen then
                  error(xparen);

               gettk;                     { consume the ")" }

            end;

      else  error(xfactor);      { if none of above, not a valid factor }

   end;
 end;


(*       ParseSignedFactor is introduced into the chain of expression-
 *       parsing functions merely to handle a unary plus, minus or logical
 *       NOT preceding a factor.  If none of these is found, the code drops
 *       through directly to ParseFactor.  If one of them is found, the
 *       appropriate code is generated after ParseFactor returns, thereby
 *       converting the notation to postfix form.   *)

 function parsesignedfactor(exptype: tokcode): tokcode;
 var
   holdtype:     tokcode;

 begin                        {ParseSignedFactor}


   case tk.code of
      plus: begin
               gettk;                     { consume the + sign }

               holdtype := parsefactor(exptype);   { parse & get type }


               if holdtype = boolsym then
                  error(xint)                { +boolean illegal }

               else
                  parsesignedfactor := holdtype;
                                          { HoldType=Int }

            end;

      minus:
            begin
               gettk;                     { consume the - sign }

               holdtype := parsefactor(exptype);   { parse & get type }


               if holdtype = boolsym then
                  error(xint)                { -boolean illegal }

               else
               begin
                  parsesignedfactor := holdtype;
                                             { HoldType = Int }
                  genoperator(unminus,holdtype);
                                             { unary minus }

               end;
            end;

      notsym:
            begin
               gettk;                     { consume NOT symbol }

               holdtype := parsefactor(exptype);   { parse & get type }

               if holdtype <> boolsym then
                  error(xbool)               { NOT number illegal}

               else
               begin
                  parsesignedfactor := boolsym;
                                             { HoldType = boolean}
                                             { code to invert }
                  genoperator(notsym,boolsym);
               end;
            end;

      else  parsesignedfactor := parsefactor(exptype);
                                 { no +, -, NOT found}

   end;
 end;


(*       ParseTerm recognizes either "SignedFactor" or a subexpression of
 *       the form "SignedFactor MultOp Term".  Thus it will always call
 *       ParseSignedFactor, and if the next token is a MultOp, it will
 *       also call itself recursively.   *)

 function parseterm(exptype: tokcode): tokcode;
 var
   holdmultop:   tokcode;
   holdtype:     tokcode;

 begin                        {ParseTerm}

   holdtype := parsesignedfactor(exptype);
                              { parse & get type of first operand }

   if (tk.code in multopset) then
                              { TK = *, /, OR? }
   begin
      holdmultop := tk.code;     { save the Op for postfix }

      gettk;                     { and consume it }


      if not (holdtype = parseterm(holdtype)) then
                                 { parse & get type of 2d operand }
         error(match);           { 1st & 2d operands same type? }


      genoperator(holdmultop, holdtype);
                              { issue the saved operator }

   end;

   parseterm := holdtype;     { return the operand type }

 end;


(*      ParseSimpleExpr recognizes either "Term" or a subexpression of
 *       the form "Term AddOp SimpleExpr".  It always calls ParseTerm
 *       and if the next token is an AddOp, it also calls itself.   *)

 function parsesimpleexpr(exptype: tokcode): tokcode;
 var
   holdaddop:    tokcode;
   holdtype:     tokcode;

 begin                        {ParseSimpleExpr}

   holdtype := parseterm(exptype);     { parse & get type 1st operand }


   if (tk.code in addopset) then
                              { TK = +, -, AND? }
   begin
      holdaddop := tk.code;      { save the Op for postfix }

      gettk;                     { and consume it }


      if not (holdtype = parsesimpleexpr(holdtype)) then
                                 { parse & get type of 2d operand }
         error(match);           { 1st & 2d operands same type? }


      genoperator(holdaddop, holdtype);
                                 { issue the save operator }

   end;

   parsesimpleexpr := holdtype;
                              { return the operand type }

 end;


(*       ParseExpression recognizes either "SimpleExpr" or a sub-
 *       expression of the form "SimpleExpr RelOp SimpleExpr." It always
 *       calls ParseSimpleExpr once, and if the next token is a RelOp, it
 *       also makes a second call to ParseSimpleExpr.  Note that this scheme
 *       is slightly different from the recursive pattern in the lower-
 *       level functions.  On that model one would expect "SimpleExpr RelOp
 *       Expression," so that to parse the second operand the function would
 *       call itself.  Such a construction, however, would allow expressions
 *       of the form A > B < C = D, and so on.  It would be easy enough to
 *       assign a meaning to these expressions, but the language definition
 *       does not supply one.   *)

 function parseexpression {forward(ExpType: TokCode): TokCode};
 var
   holdrelop:    tokcode;
   holdtype:     tokcode;

 begin                        {ParseExpression}

   holdtype := parsesimpleexpr(exptype);
                              { parse & get type 1st operand }


   if (tk.code in relopset) then
                              { TK is >, <, =, etc.  ? }

   begin
      holdrelop := tk.code;      { save operator for postfix }

      gettk;                     { and consume it }


      if not (holdtype = parsesimpleexpr(holdtype)) then
                                 { parse & get type 2d operand }
         error(match);           { 1st & 2d operands same type ? }


      parseexpression := boolsym;
                                 { if Expr has Relop, type = bool }

      genoperator(holdrelop, holdtype);
                                 { issue the saved operator }

   end
   else
      parseexpression := holdtype;
                              { type to be returned if no RelOp }


 end;

