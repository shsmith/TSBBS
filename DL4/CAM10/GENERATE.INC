

(*
 * generate - generate code
 *
 * S.H.Smith, 6-May-86
 *
 *)


procedure gen_emit (el:            element;
                    var bindings:  element);
                           {generate code to emit native code}

var
   i:       integer;
   param:   element;
   value:   element;
begin

   for i := 1 to el^.parcount do
   begin
      param := lowest_binding(el^.par[i], bindings);
      code_string(param^.ident);
   end;

   code_newline;
end;



procedure gen_declare (el:           element;
                       var bindings: element);
                           {declare a nil binding}

var
   variable: element;
   param:    element;

begin

   variable := new_element;
   param := lowest_binding(el^.par[1], bindings);
   variable^.ident := param^.ident;

   enter_binding(bindings, variable, nil);
                              {link the declared variable into the
                               the local bindings and bind it to
                               an initial value of 'nil'}
end;



procedure gen_new_label (el:           element;
                         var bindings: element);
                           {generate a new unique label and bind it
                            to a bound variable}

const
   unique: integer = 0;
var
   param:    element;
   variable: element;
   value:    element;
   val:      anystring;

begin

   param := lowest_binding (el^.par[1], bindings);
   if param = nil then
      error('(new label) No binding for: '+el^.par[1]^.ident);

   variable := new_element;
   variable^.ident := param^.ident;

   value := new_element;
   unique := unique + 1;
   str(unique,val);
   value^.ident := '"LAB' + val + '"';

   enter_binding(bindings, variable, value);

end;



procedure gen_define_as (el:      element);
                           {process a define() as() element to add a new
                             entry to the template list}

begin
   enter_template(el);     {link the element into the head of the template
                                table}

end;



procedure gen_debug(bindings: element);
begin

   writeln('; debug - binding dump------');

   while bindings <> nil do
   begin
      writeln(';',bindings^.ident:20,' bound to ',bindings^.par[1]^.ident);
      bindings := bindings^.next;
   end;
end;



procedure gen_statement (el:           element;
                         var bindings: element;
                         level:        integer);
                           {generate code for a statement element}

var
   i:               integer;
   tem:             element;
   example:         element;
   body:            element;
   param:           element;
   outer_bindings:  element;

begin

   outer_bindings := bindings;

   while el <> nil do
   begin

      with el^ do

      if (ident = '.define().as()') then
         gen_define_as(el)             {define new templates}
      else

      if (ident = '.emit()') or (ident = '.emit()()') then
         gen_emit(el, bindings)        {emit code string}
      else

      if (ident = '.declare()') then
         gen_declare(el, bindings)     {declare local bindings}
      else

      if (ident = '().=.new.label') then
         gen_new_label(el, bindings)   {bind unique label to identifier}
      else

      if (ident = '') then
         code_string('')               {null statements}
      else

      if (ident = '.debug') then
         gen_debug(bindings)           {debug (binding dump)}
      else

      if (ident = '()') then           {dereference bound statements}
      begin
         tem := find_binding (par [1], bindings);
         if tem = nil then
            error('(element) No binding for: '+par[1]^.ident);

         gen_statement(tem^.par [1], bindings, level+1);
      end
      else

      if (ident = '.begin()') then     {main block}
         gen_statement(par [1], bindings, level+1)
      else

      if (ident[1] in ['A'..'Z']) then
      begin                            {dereference bound elements}
         tem := lowest_binding (el, bindings);
         if tem = nil then
            error('(element) No binding for: '+ident);

         gen_statement(tem^.par [1], bindings, level+1);
      end
      else

      if (ident[1] in ['0'..'9','"']) then
      begin
         code_string(' literal '+ident);  {literal data}
         code_newline;
      end
      else

      begin
         tem := find_template (el);       {user-defined templates}
         if tem = nil then
            error('(statement) No matching template: '+el^.ident);

         example := tem^.par [1];

         for i := 1 to example^.parcount do
            enter_binding(bindings, example^.par[i], el^.par[i]);
                           {link all formal parameters into into
                            the local bindings and bind each
                            to the actual paramter}

         body := tem^.par [2];

         gen_statement(body, bindings, level+1);
                              {generate each statement in body}

      end; {with}

      el := el^.next;

   end; {while}

   remove_bindings(bindings, outer_bindings);
                              {unlink bindings that are no longer valid}
end;


