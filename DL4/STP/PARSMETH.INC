

(*******************************************************
 *
 * Subsystem:   Parsmeth - Method declaration Parser subsystem
 *
 * Overview
 * --------
 *
 *    This subsystem contains the parse* procedures which parse
 *    individual class and instance method declarations.
 *
 *)



(*
 * Parse_statement parses a single statement within the
 * body of a method declaration.
 *
 *)

procedure parse_statement (var meth: symptr);
var
   exp:  expptr;

begin

   if tk.name = '^' then
   begin
      gettk;      { consume the return-expression token }

      exp := parse_expression (meth);
                  { parse the return value expression }

      gen_return_expression (meth, exp);
                  { generate object code to set return value to expression
                    value and to exit current method }
   end
   else

   begin
      exp := parse_expression (meth);
                  { parse an expression }

      gen_statement_expression (meth, exp);
                  { generate object code to evaluate an expression }
   end;

end;




(*
 * Parse_method_body parses the declaration of a method body.
 *
 *)

procedure parse_method_body (var meth: symptr);
var
   sym:   symptr;
   locno: integer;

begin

   meth^.locals := nil;
               { initialize empty local table for this method }


   if tk.name = '|' then
               { process local method variables, if any }
   begin

      gettk;      { consume the | token }

      locno := 1;

      while tk.name <> '|' do
      begin
         if tk.code <> identifier then
            error('method local variable identifier expected');

         sym := declare(tk.name, sym_local_variable, meth^.locals);
         sym^.var_name := 'l'+itoa(locno);
         sym^.class := global_variables;  {STUB}

         locno := locno + 1;
                     { enter the symbol into the local variable
                       symbol table for this method }

         gettk;      { consume the identifier }
      end;

      gettk;      { consume the matching | token }
   end;


   gen_method_start (meth);

   repeat         { process several "." seperated expressions as the
                    body of the expression. }

      if tk.name = '.' then
         gettk;         { consume the expression seperator.  this might
                          let an extra . at the start of a method body
                          slip through without an error message. }

      parse_statement (meth);
                        { parse a body method statement }

   until tk.name <> '.';

   gen_method_finish;
end;



(*
 * Parse_method_protocol parses the method protocol specification
 * that heads each method declaration.   The syntax of a method
 * protocol specification is:
 *     {keyword}
 *     {keyword: parameter ...}
 *
 * The "{" and "}" are required in the specification.  This is not
 * used in the Smalltalk Language book.  It is needed here because there
 * is only a single "font" for all declarations.
 *
 *)

procedure parse_method_protocol (var table: symptr);
var
   meth:  symptr;
   par:   symptr;
   parno: integer;

begin

   gettk;      { consume the start-protocol-specification character }


   meth := declare ('', sym_method, table);
   meth^.class := global_variables;  {STUB}
               { make a dummy entry in the method table.  the real
                 method identifier will be filled in as the full
                 protocol specification is processed.  this way of
                 handling the table will not detect methods with
                 duplicate method selectors. }

   meth^.parameters := nil;
   parno := 1;

   while tk.name <> '}' do
   begin
      if tk.code <> identifier then
         error ('method protocol identifier expected');

      meth^.name := meth^.name + tk.name;
                  { build the method name (selector) }

      gettk;      { consume the identifier }

      if tk.name = ':' then
      begin
         meth^.name := meth^.name + '_';
                     { add a replacement for the : to the name }

         gettk;      { consume the : token }

         if tk.code <> identifier then
            error ('method protocol pseudo-variable identifier expected');

         par := declare (tk.name, sym_pseudo_variable, meth^.parameters);
         par^.var_name := 'p' + itoa(parno);
         par^.class := global_variables;  {STUB}
         parno := parno + 1;
                     { enter the parameter pseudo-variable name into the
                       parameter symbol table for this method }

         gettk;      { consume the identifier }
      end;

   end;

   par := find (meth^.name, selectors);
   if par = nil then
      par := declare (meth^.name, sym_selector, selectors);
                              { create the selector if needed. }


   gettk;      { consume the end-protocol-specification character }

end;



(*
 * Parse_class_methods parses the declaration sections that start
 * with the 'class methods' header.
 *
 *)

procedure parse_class_methods;
var
   sym:  symptr;

begin

   gettk;      { consume the 'methods' keyword }

   while tk.name = '{' do
   begin
      parse_method_protocol (class^.class_methods);

      parse_method_body (class^.class_methods);
   end;

end;



(*
 * Parse_instance_methods parses the declaration sections that start
 * with the 'instance methods' header.
 *
 *)

procedure parse_instance_methods;
var
   sym:  symptr;

begin

   gettk;      { consume the 'methods' keyword }

   while tk.name = '{' do
   begin
      parse_method_protocol (class^.instance_methods);

      parse_method_body (class^.instance_methods);
   end;

end;



