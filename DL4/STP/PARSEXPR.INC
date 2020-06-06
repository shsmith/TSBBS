
(*******************************************************
 *
 * Subsystem:   Parsexpr - Method expression Parser subsystem
 *
 * Overview
 * --------
 *
 *    This subsystem contains the parse* procedures which parse
 *    statements within a method body.
 *
 *
 * Revision history
 * ----------------
 *
 *   9-mar-86 shs initial coding
 *
 *)

function parse_expression (meth: symptr): expptr;  forward;



(*  locate_identifier looks in the various symbol tables for a given
 *  identifier.  If the identifier is found in any table, the symbol entry
 *  pointer is returned.  *)

function locate_identifier(name: identstr;
                           meth: symptr): symptr;
var
   sym:  symptr;

begin
   sym := find(name,meth^.locals);

   if sym = nil then
      sym := find(name,meth^.parameters);

   if sym = nil then
      sym := find(name,class^.instance_variables);

   if sym = nil then
      sym := find(name,class^.class_variables);

   if sym = nil then
      sym := find(name,global_variables);

   if sym = nil then
      sym := find(name,classes);

   if sym = nil then
      error('Can''t locate identifier: '+name);

   locate_identifier := sym;
end;



(* parse_message_expression parses an expression with an identifier
 * followed by another identifier.  This is the form of a message
 * being sent to the identifier.  *)

function parse_message_expression (meth: symptr;
                                   sym:  symptr): expptr;
var
   sel:  identstr;
   exp:  expptr;

begin
   new (exp);
   exp^.exptype := exp_message;
   exp^.object := sym;
   exp^.class := exp^.object^.class;
   exp^.next := nil;

   sel := tk.name;
   gettk;                     { consume the initial message token }

   if tk.name = ':' then      { does this message have a paramater? }
   begin
      sel := sel + '_';
      gettk;                  { consume the colon }

      exp^.parameters := parse_expression (meth);
   end
   else
      exp^.parameters := nil;

   exp^.selector := find (sel, selectors);
   if exp^.selector = nil then
      exp^.selector := declare (sel, sym_selector, selectors);
                              { create the selector if needed.  this should
                                probably generate an error in a fuller
                                implementation of messages. }


   parse_message_expression := exp;
end;



(* parse_binary_message_expression parses an expression with an identifier
 * followed by another identifier.  This is the form of a message
 * being sent to the identifier.  *)

function parse_binary_message_expression (meth: symptr;
                                          sym:  symptr): expptr;
begin
   error('diag: binary messages stubbed');
end;



(* parse_ident_expression parses an expression starting with an
 * identifier.  These expressions are either assignments or
 * messages.   *)

function parse_ident_expression (meth: symptr): expptr;
var
   sym:  symptr;
   exp:  expptr;

begin
   sym := locate_identifier(tk.name,meth);

   gettk;      { consume the identifier }

   case tk.code of
      assign:             { form is ident := expression }
         begin
            gettk;        { consume the := }
            new (exp);
            exp^.exptype := exp_assign;
            exp^.assign_variable := sym;
            exp^.assign_exp := parse_expression (meth);
            exp^.class := exp^.assign_exp^.class;
         end;

      identifier:         { form is ident message ... }
         exp := parse_message_expression (meth, sym);

      binary_selector:    { form is ident +-/*=... }
         exp := parse_binary_message_expression (meth, sym);

      else
         begin            { must be a simple identifier reference }
            new (exp);
            exp^.exptype := exp_variable;
            exp^.varsym := sym;
            exp^.class := sym^.class;
         end;
   end;

   parse_ident_expression := exp;
end;



(* parse_left_bracket_expression parses procedure block literals that
 * start with "[".  *)

function parse_left_bracket_expression (meth: symptr): expptr;
begin
   error('diag: parse [ expression stubbed');
end;



(* parse_expression is the top level of the Smalltalk expression parser.
 * It takes a pointer to the method being processed.  The return is a
 * pointer to an expression description record.  This expression record
 * should be consumed and disposed by the caller.  *)

function parse_expression {forward (meth: symptr): expptr};
begin

   case tk.code of
      identifier:
         parse_expression := parse_ident_expression (meth);

      left_paren:
         begin
            gettk;      { consume the ( }

            parse_expression := parse_expression (meth);
            if tk.code <> right_paren then
               error(') expected');

            gettk;      { consume the ) }
         end;

      left_bracket:
         parse_expression := parse_left_bracket_expression (meth);

      else
         error('Unknown first token in parse_expression');

   end;

end;

