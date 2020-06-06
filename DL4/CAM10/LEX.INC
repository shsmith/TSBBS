
(*
 * lexical analyzer
 *
 * S.H.Smith, 6-May-86
 *
 *)

procedure get_token;         {get next token; leaves token string in
                              'token' and token type code in 'toktype'}

   procedure get_char;          {get next input character}
   begin
      if eof(in_fd) then
         next_ch := eof_ch
      else
         read(in_fd, next_ch);

      if next_ch = ^M then
      begin
         source_lines := source_lines + 1;
         if (source_lines mod 8) = 0 then
            write(con,#13,source_lines:4,' lines');
      end;

      if next_ch = eof_ch then
         write(con,#13,source_lines:4,' lines');

   end;

   procedure recognize(tt: toktypes);
                                {recognize the current character as part of
                                 a token and consume it}
   begin
      toktype := tt;
      token := token + next_ch;
      get_char;
   end;


begin
   while next_ch in [^I,^M,^J,' '] do
      get_char;                 {skip over white space}

   token := '';
   toktype := special;

   case next_ch of
      'A'..'Z':              {an identifier starts with upcase}
         begin
            recognize(identifier);

            while next_ch in ['a'..'z','_','A'..'Z','0'..'9'] do
               recognize(identifier);
         end;

      'a'..'z':              {a keyword starts with lcase}
         begin
            recognize(keyword);

            while next_ch in ['a'..'z','_','A'..'Z','0'..'9'] do
               recognize(keyword);
         end;

      '0'..'9':
         while next_ch in ['0'..'9'] do
            recognize(number);

      '"':
         begin
            repeat
               recognize(literal);
            until next_ch in ['"',eof_ch];

            recognize(literal);
         end;

      '(':
         recognize(left_paren);

      ')':
         recognize(right_paren);

      ';':
         recognize(semicolon);

      ',':
         recognize(comma);

      '-':
         begin
            recognize(special);

            if next_ch = '-' then      {comments are -- to line end}
            begin
               repeat
                  get_char;
               until next_ch in [eof_ch, ^M, ^J];

               get_token;
            end;
         end;

      eof_ch:
         recognize(end_of_file);

      else
         recognize(special);
   end;
end;



procedure lex_init(name: anystring);
begin
   token := '';
   toktype := special;
   next_ch := ' ';
   source_lines := 0;

   if pos('.',name) = 0 then
      name := name + '.CAM';

   assign(in_fd,name);
   {$I-} reset(in_fd); {$I+}

   if ioresult <> 0 then
   begin
      writeln(con,whoami,':  Can''t open input file, ',name);
      halt;
   end;

   get_token;    {get initial token}
end;

