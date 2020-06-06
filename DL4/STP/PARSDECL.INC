

(*******************************************************
 *
 * Subsystem:   Parsdecl - Declaration Parser subsystem
 *
 * Overview
 * --------
 *
 *    This is the heart of the compiler.   This subsystem contains the
 *    parse* procedures which Smalltalk declaration sections.
 *
 *)



(*       Each routine calls on GetTK (the scanner).  Statements haveing to do
 *       with parsing proper are interleaved with those for type checking
 *       and code generation.    *)


(*
 * Parse_include_file parses the include_file FILENAME declaration
 * statement type.   Include files cannot be nested.
 *
 *)

procedure parse_include_file;
begin
   gettk;      { consume the include_file keyword }

   if tk.code <> string_constant then
      error('include filename exected');

   if include = true then
      error('include files cannot be nested');

   tk.name := copy(tk.name,2,length(tk.name)-2);
   assign(incfile,tk.name);
{$I-}
   reset(incfile);
{$I+}
   if ioresult <> 0 then
      error('can''t open include file: '+tk.name);

   include := true;

   gettk;      { consume the filename token }
end;


(*
 * Parse_class_name parses the class name declaration section.
 *
 *)

procedure parse_class_name;
var
   sym: symptr;

begin

   gettk;      { consume the 'class name' token }

   if tk.code <> identifier then
      error ('class identifier expected');

   new (class);
   class^.class_name := tk.name;

   gettk;      { consume the class name token }

   class^.superclass := nil;
               { initialize the superclass to default to 'Object' }

   class^.class_variables := nil;
   class^.class_methods := nil;
   class^.instance_variables := nil;
   class^.instance_methods := nil;
               { initialize the class tables to empty }

   sym := declare(class^.class_name, sym_class, classes);
   sym^.class_data := class;
   sym^.var_name := class^.class_name;
   sym^.class := sym;
               { enter the class into the global table }

end;



(*
 * Parse_class_variable_names parses the declaration section for
 * class variables.
 *
 *)

procedure parse_class_variable_names;
var
   sym:  symptr;

begin

   gettk;      { consume the 'class variable names' keyword }

   while tk.code = identifier do
   begin       { add each identifier to the class variables
                 table for the current class }

      sym := declare (tk.name, sym_class_variable, class^.class_variables);
      sym^.var_name := class^.class_name+'_cv.'+tk.name;
      sym^.class := global_variables;  {STUB}

      gettk;   { consume the identifier }
   end;

end;



(*
 * Parse_superclass parses the superclass declaration section.
 *
 *)

procedure parse_superclass;
var
   sym:  symptr;

begin
   gettk;      { consume the 'superclass' token }

   if tk.code <> identifier then
      error ('superclass identifier expected');

   sym := find(tk.name, classes);
   if sym = nil then
      error ('undefined superclass');

   class^.superclass := sym;

   gettk;      { consume the class name token }

end;



(*
 * Parse_instance_variable_names parses the declaration section for
 * instance variable names.
 *
 *)

procedure parse_instance_variable_names;
var
   sym:  symptr;

begin

   gettk;      { consume the 'instance variable names' keyword }

   while tk.code = identifier do
   begin       { add each identifier to the instance variables
                 table for the current class }

      sym := declare (tk.name, sym_instance_variable, class^.instance_variables);
      sym^.var_name := 'self^.' + tk.name;
      sym^.class := global_variables;  {STUB}

      gettk;   { consume the identifier }
   end;

end;



(*
 * Parse_declaration is the top level of the translator.  It selects the
 * main declaration parsing procedures.  Each call to parse_declaration
 * results in exactly 1 complete class being parsed.
 *
 *)

procedure parse_declaration;
begin

   case tk.code of
      k_include_file:             parse_include_file;

      k_class_name:               parse_class_name;

      k_superclass:               parse_superclass;

      k_class_variable_names:     parse_class_variable_names;

      k_instance_variable_names:  parse_instance_variable_names;

      k_class_methods,
      k_instance_methods:
         begin
            gen_class_start;

            while tk.code in [k_class_methods, k_instance_methods] do
            case tk.code of
               k_class_methods:     parse_class_methods;     {in parsmeth.inc}
               k_instance_methods:  parse_instance_methods;  {in parsmeth.inc}
            end;

            gen_class_finish;
         end;

      else  error('declaration expected');
   end;

end;

