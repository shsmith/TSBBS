

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
 *   09-mar-86 shs  made smalltalk-80 version
 *
 *)



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
 *        corresponds to one clause of the case statement.  Since GetTK
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

      if include then
         if eof(incfile) then
         begin
            include := false;
            close(incfile);
            read(infile,ch);
         end
         else
            read(incfile,ch)
      else

      if eof (infile) then
         ch := #0
      else
         read(infile, ch);       { get next if possible}


      if ch = #10 then           { end of line? }
      begin
         if copysource then
            writeln(outfile,'{'+sourceline+'}');

         sourceline := '';
         linecount := linecount + 1;
         if (linecount mod 6) = 0 then
            write(#13,linecount:4);
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
      tk.name := tk.name + ch;
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
      getch;                  { toss out the white space }

   tk.name := '';             { reset the identifier string to null }
   tk.code := unknown;

   case ch of                 { look at the current char from stream }

      'a'..'z', 'A'..'Z', '_':
            begin                         { Ident or keyword}

               while (ch in ['a'..'z', 'A'..'Z', '_', '0'..'9']) do
                                          { add chars to the}
                  recognize(identifier);  { TK.Name string }

               for i := first_keyword to last_keyword do
                  if keywords[i] = tk.name then
                     tk.code := i;        { lookup keywords }
            end;


      '0'..'9':
               while (ch in ['0'..'9']) do
                  recognize(digits);         { numeric literal}


      ':':  begin
               recognize(special_character);
               if ch = '=' then
                  recognize(assign);
            end;


      '-','+','/','\','*','~','<','>','=','@','%','|','&','?','!':
            begin
               recognize(binary_selector);
               if ch in ['-','+','/','\','*','~','<','>','=','@','%','|','&','?','!'] then
                  recognize(binary_selector);
            end;


      '$':  begin
               recognize(character_constant);
               recognize(character_constant);
            end;

      '(':  recognize(left_paren);

      ')':  recognize(right_paren);

      '[':  recognize(left_bracket);

      ']':  recognize(right_bracket);


      '''': begin              { scan literal strings.  allow lower case }
               repeat
                  recognize(string_constant);
               until ch = '''';
               recognize(string_constant);
            end;


      '"':  begin              { comments }
               repeat
                  getch;
               until ch = '"';
               getch;
               gettk;
            end;


      '`':  begin              { inline pascal code }
               getch;
               while ch <> #13 do
               begin
                  write(outfile,ch);
                  getch;
               end;
               writeln(outfile);
               gettk;
            end;


      '^','.','#','{','}':
            recognize(special_character);

      #0:   recognize(end_of_file);

      else  error('unknown character');      { bad character }

   end;

 end;

