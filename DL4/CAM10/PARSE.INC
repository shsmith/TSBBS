
(*
 * parse - statement element parser
 *
 * S.H.Smith, 6-May-86
 *
 *)


function parse_element(level: integer): element;
                             {parse a language element and return the
                              element node that describes it}
var
   el:  element;

begin
   el := new_element;
   with el^ do
   begin

      while not (toktype in [end_of_file, right_paren]) do
      begin

         case toktype of
            keyword, special:
               begin
                  ident := ident + '.' + token;
                  get_token;
               end;

            identifier, literal, number:
               begin
                  ident := ident + '()';
                  parcount := parcount + 1;
                  par[parcount] := new_element;
                  par[parcount]^.ident := token;
                  par[parcount]^.eltype := variable;
                  get_token;
               end;

            left_paren:
               begin
                  ident := ident + '()';
                  parcount := parcount + 1;
                  get_token;

                  par[parcount] := parse_element(level+1);
                  if toktype <> right_paren then
                     error('")" expected');

                  get_token;
               end;

            semicolon:
               begin
                  get_token;
                  next := parse_element(level);
               end;

            else
               error('unexpected token type');

         end; {case}


         if toktype = comma then
            get_token;

         if parcount >= maxpar then
            error('too many params');

      end; {while}

   end; {with}

   parse_element := el;
end;


