

(*******************************************************
 *
 * Subsystem:   genexpr - Code generator for expressions
 *
 * Overview
 * --------
 *
 *    This subsystem contains the gen_ procedures called by
 *    the parsdecl subsystem.   Each gen_ procedure generates
 *    the pascal object code for a Smalltalk expression.
 *
 *)


procedure indent;
begin
   indentation := indentation + 2;
end;

procedure unindent;
begin
   indentation := indentation - 2;
end;


procedure genln (object: anystring);
begin
   if outpos < indentation then
      write (outfile,'':(indentation-outpos));

   writeln (outfile,object);
   outpos := 0;
end;


procedure gen (object: anystring);
begin
   if outpos < indentation then
   begin
      write (outfile,'':(indentation-outpos));
      outpos := indentation;
   end;

   outpos := outpos + length(object);
   write (outfile,object);
end;


procedure dclgen (object: anystring);
begin
   write (dclfile, object);
end;

procedure dclgenln (object: anystring);
begin
   writeln (dclfile, object);
end;



procedure gen_subexpression (meth:   symptr;
                             exp:    expptr);
begin

   case exp^.exptype of
      exp_assign:
         error('gen_subexpression: multiple assignments not implemented');

      exp_block:
         error('gen_subexpression: block expressions not implemented');

      exp_empty:
         gen ('nil {empty}');

      exp_literal:
         gen (exp^.litval);

      exp_variable:
         gen (exp^.varsym^.var_name);

      exp_message,
      exp_cascaded_message:
         while exp <> nil do
         begin
            if exp^.object^.symtype = sym_class then
               gen ('cf_' + exp^.object^.name +
                    '(s_' + exp^.selector^.name + ',nil,')
            else
               gen ('sendm (s_' + exp^.selector^.name + ',' +
                    exp^.object^.var_name + ',');

            if exp^.parameters <> nil then
               gen_subexpression (meth, exp^.parameters)
            else
               gen ('nil');

            gen (',nil,nil,nil)');

            exp := exp^.next;
         end;

      else
         error('gen_subexpression: invalid expression node type');

   end;

end;



procedure gen_return_expression (meth:   symptr;
                                 exp:    expptr);
begin

   gen ('cf_' + class^.class_name + ' := ');
   gen_subexpression (meth, exp);
   genln (';');
   genln ('exit;');

end;



procedure gen_statement_expression (meth:   symptr;
                                    exp:    expptr);
begin

   if exp^.exptype <> exp_assign then
   begin
      gen ('l0 := ');
      gen_subexpression (meth, exp);
      genln (';');
   end
   else

   begin
      gen (exp^.assign_variable^.var_name + ' := ');
      gen_subexpression (meth, exp^.assign_exp);
      genln (';');
   end;

end;


