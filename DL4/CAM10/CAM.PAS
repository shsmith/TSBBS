

(*
 * CAM - Yet another language
 *
 * This language processor has no "framework" in the sense of ordinary
 * languages.  Rather, it contains only the "define" mechanism for
 * introducing user-defined language constructs.
 *
 * Author: S. H. Smith, 6-May-86
 *
 *)


{$p80,d-,r+}

(*
 * language definition syntax:
 *
 *  DEFINE (EXAMPLE) AS (BODY)
 *
 *
 * this would be represented internally as:
 *
 *    element^  .ident = 'DEFINE_AS_'
 *              .eltype = template
 *              .parcount = 2
 *              .par[1] =  element for EXAMPLE
 *              .par[2] =  element for BODY
 *)


const
   trace = false;

   program_version = 'CAM V1.0, 10-May-86, S.H.Smith';
   whoami = 'CAM';

   maxpar = 5;                        {maximum number of parameters for
                                       any language element}

   eof_ch = #26;


type
   anystring = string[128];

   element_types = (template,         {a template for statements}
                    primitive,        {a primitive (builtin) language element}
                    variable,         {a data reference}
                    unknown);         {an unknown element}


const
   typename: array [element_types] of string[10] = (
                   'Template',
                   'Primitive',
                   'Variable',
                   'Unknown');

type
   element = ^element_rec;            {pointer to an element description}

   element_rec = record               {element description node}
      ident:     anystring;              {the element identifier; built up of
                                          keywords and underscores.
                                          an underscore is used for each
                                          variable part (parameter)}

      eltype:    element_types;          {the type of element that this
                                          node describes}

      parcount:  integer;                {the number of parameters}

      par:       array [1..maxpar]
                 of element;             {table of element nodes for each
                                          parameter, if any}

      next:      element;                {link to another element that
                                          is at the same level as this
                                          element}
   end;


   toktypes =     (number,               {lexical token types}
                   identifier,
                   keyword,
                   literal,
                   left_paren,
                   right_paren,
                   semicolon,
                   comma,
                   special,
                   end_of_file);


var
   in_fd:     text;         {input file}

   next_ch:   char;         {next input character}

   token:     anystring;    {current token string}

   toktype:   toktypes;     {current token type}

   template_table:
              element;      {table of templates}

   source_lines:
              integer;




{$I utility.inc    Utility procedures}

{$I tables.inc     Table management procedures}

{$I lex.inc        Lexical analyzer}

{$I parse.inc      Parser}

{$I code.inc       Emit code file}

{$I generate.inc   Code generator}



procedure usage;
begin
   writeln(con,'Usage:  cam SOURCEFILE [>DESTFILE]');
   halt;
end;


(*
 * main program
 *
 *)

var
   body:     element;
   bindings: element;

begin

   writeln;
   writeln(program_version);
   flush(output);

   if paramcount <> 1 then
      usage;

   lex_init(paramstr(1));
   template_table := nil;
   bindings := nil;

   body := parse_element(1);
   writeln(con);

   code_newline;
   gen_statement(body,bindings,1);
   code_newline;

   writeln(con,maxavail shr 6,' K free ram');
   dispose_element(body);
end.

