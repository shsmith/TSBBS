



(*******************************************************
 *
 * Subsystem:   Scanner - Scanner or Lexical Analyzer subsystem
 *
 * Overview
 * --------
 *
 *    This subsystem provides the low-level text scanning
 *    function gettk, which scans source text and returns
 *    token codes and other token information in the TK record.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 shs  initial coding
 *
 *)


(**)
(*******************************************************
 *
 * Procedure:    gettk
 *
 * Description:  scans next input token and returns a description
 *               of it in the TK record.   always scans one character
 *               ahead of the actual token.
 *
 * Example:      gettk;  if tk.code <> ...
 *
 * Outputs:      tk.code    the token code
 *               tk.name    the text of the token
 *
 *)

(*        Procedure GetTK constitutes the scanner, or lexical analyzer.  It
 *        calls on GetCH to read the next character from the input stream
 *        and uses Recognize to set up the two global-variable fields
 *        TK.Code and TK.Name.  The main routine first strips out all com-
 *        ments and whitespace characters and then enters a state deter-
 *        mined by the first character of the remaining input.  Each state
 *        corresponds to one clause of the case statement.  Note that GetCH
 *        converts all alphabetic characters to upper case, so that the
 *        compiler in insensitive to case.  Two errors can be issued by the
 *        scanner.  Error(QChar) is called if a character outside the recog
 *        nized set appears in the input (except in comments).  Error(UnXEOF)
 *        is reported if the scanner encounters end-of-file.  Since GetTK
 *        is not called after the final period marking the end of a pro-
 *        gram, the scanner should never read the end of the file.

 *        NOTE: Each time the scanner is called, it goes to work on the
 *        character already in variable CH, not on the next character
 *        from the stream.  When GetTK exits, CH holds the first char-
 *        acter beyond the token returned.  In other words, the file
 *        pointer is pre-incremented.   *)



 procedure gettk;   {get token}
 var
   i:            tokcode;     { used in a FOR loop to check for keywords }
   pc:           char;


   procedure getch;
   begin

      if eof (infile) then
         ch := #0
      else
         read(infile, ch);       { get next if possible}


      if ch = #10 then           { end of line? }
      begin
         if copysource then
            gencomment(linecount,sourceline);

         linecount := linecount + 1;
         sourceline := '';
      end
      else

      if ch <> #13 then
         sourceline := sourceline + ch;

   end;


   procedure recognize (tok:          tokcode);
                              { Called once for each character }
   begin                         { scanned, adding it to the string }

      tk.code := tok;            { in TK.Name and recording the
                                   current analysis in TK.Code.  Note
                                   that TK.Code is not actually
                                   valid until GetTK returns. }

      tk.name := tk.name + upcase(ch);
                                 { make all token "names" uppercase }
      getch;
   end;



(*       The first section of GetTK strips out comments and the whitespace
 *       characters #9 (tab), #10 (line feed), #12 (form feed), #13 (carriage
 *       return) and #32 (space).  For comments any characters following a
 *       left brace are ignored up to the first right brace.  Note that this
 *       means comments cannot be nested: Any number of opening braces will
 *       be canceled by the first closing brace.  The nested while loops are
 *       needed because comments and whitespace can be interspersed in any
 *       sequence.     *)

 begin                        { GetTK }

   while (ch in [#9, #10, #12, #13, #32]) do
      getch;                     { toss out the white space }

   tk.name := '';             { reset the identifier string to null }

   case upcase(ch) of         { look at the current char from stream }

      'A'..'Z','_':
            begin                         { Ident or keyword}

               while (upcase(ch) in ['A'..'Z', '_', '0'..'9']) do
                                          { add chars to the}
                  recognize(ident);       { TK.Name string }

               for i := pgmsym to writesym do
                                          { An Ident unless }
                  if keywords[i]= tk.name then
                     tk.code := i;        { listed here }
            end;


      '0'..'9':
            while (ch in ['0'..'9']) do
               recognize(number);
                                 { numeric literal}


      '>':  begin
               recognize(gt);             { With two-symbol oper- }
               if ch = '=' then
                  recognize(ge);          { ators, start by assum-}
            end;                          { ing the one-symbol }


      '<':  begin                         { form and then revise }
               recognize(lt);             { the verdict if the }

               if ch = '>' then
                  recognize(ne)              { second character is }
               else

               if ch = '=' then
                  recognize(le)              { found.  }
            end;


      ':':  begin
               recognize(colon);

               if ch = '=' then
                  recognize(assignop);
            end;


      '''': begin
               repeat      { scan literal strings.  allow lower case }

                  tk.name := tk.name + ch;
                  getch;

               until ch = '''';
               recognize(charstr);
            end;


      '=':  recognize(eq);


      '{':  begin
               repeat
                  getch;
               until ch = '}';

               getch;
               gettk;      { scan the token following the comment }
            end;


      '(':  begin
               recognize(leftparen);
               if ch = '*' then
               begin

                  repeat
                     pc := ch;
                     getch;
                  until (pc = '*') and (ch = ')');

                  getch;
                  gettk;      { scan the token following the comment }
               end;
            end;

      ')':  recognize(rightparen);

      '+':  recognize(plus);

      '-':  recognize(minus);

      '*':  recognize(times);

      '/':  recognize(divide);

      ';':  recognize(semi);

      '.':  recognize(dot);

      ',':  recognize(comma);

      #0:   error(unxeof);       { Program has ended without a period }

      else  error(qchar);        { Queer character; can't digest it }

   end;

 end;

