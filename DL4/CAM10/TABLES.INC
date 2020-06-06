

(*
 * tables - table manipulation utilities
 *
 * S.H.Smith, 6-May-86
 *
 *)


procedure enter_template (el:      element);
                           {process a define() as() element to add a new
                            entry to the template list}

var
   tem:     element;

begin

   assert(el <> nil, 'enter template');

   tem := new_element;
   tem^:= el^;                {make a copy of the element}

   tem^.next := template_table;
   template_table := tem;     {link the element into the head of the template
                                table}
end;



function find_template (el:      element): element;
                           {locate a template that matches the current
                             element; return a pointer to it. signal
                             an error if not found}
var
   tem:     element;

begin

   assert(el <> nil, 'find template');

   tem := template_table;

   while tem <> nil do
   begin

      if tem^.par [1]^.ident = el^.ident then
      begin
         find_template := tem;
         exit;
      end
      else
         tem := tem^.next;
   end;

   find_template := nil;
end;



procedure enter_binding (var bindings: element;
                         example:      element;
                         actual:       element);
                           {enter a new element binding into a binding table}

var
   el:      element;

begin

   assert(example <> nil, 'enter binding (example)');

   el := new_element;
   el^ := example^;

   if actual = nil then
      actual := el;
   el^.par[1] := actual;

   el^.next := bindings;
   bindings := el;

   if trace then
      writeln('Enter binding, ident=',example^.ident,
                        ', bound to=',actual^.ident);
end;



function find_binding (el:      element;
                       bindings: element): element;
var
   tem:     element;

begin

   assert(el <> nil,  'find binding');

   tem := bindings;

   while tem <> nil do
   begin

      if el^.ident = tem^.ident then
      begin
         find_binding := tem;
         exit;
      end
      else
         tem := tem^.next;
   end;

   find_binding := nil;
end;



function lowest_binding(el:       element;
                        bindings: element): element;
                             {chase bindings and return the lowest one}
var
   param:  element;
   value:  element;
   damper: integer;

begin

   assert(el <> nil, 'lowest binding (nil el)');

   param := el;
   value := find_binding (param, bindings);

   damper := 100;
   while (value <> nil) and (value <> param) and (damper > 0) do
   begin
      param := value^.par[1];
      value := find_binding (param, bindings);
      damper := damper - 1;
   end;

{   assert(damper > 0, 'lowest binding (circular binding)'); }

   lowest_binding := param;
end;



procedure remove_bindings(var bindings:    element;
                          outer_bindings:  element);
                           {remove all bindings until bindings is
                            restored to outer_bindings}
var
   el:  element;

begin

   while bindings <> outer_bindings do
   begin

      el := bindings;
      bindings := bindings^.next;

      if trace then
         writeln('Remove binding for ',el^.ident,' (',el^.par[1]^.ident,')');

      dispose(el);
   end;

end;


