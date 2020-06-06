(*******************************************************
 *
 * Procedure:     initialize
 *
 * Description:   perform all initializations to prepare the
 *                compiler for operation.
 *
 * Example:       initialize;
 *
 *)

 procedure initialize;
 var
    sym:  symptr;

begin
   global_variables := nil;   { no global variables }
   classes := nil;            { no classes }
   selectors := nil;          { no message selectors }

   sym := declare('self', sym_global_variable, global_variables);
   sym^.var_name := 's';

   outpos := 0;
   indentation := 0;

   linecount := 1;            { start on first source line }
   sourceline := '';          { no current source line }
   tk.code := unknown;
   tk.name := '';
   copysource := false;       { copy source to object as comments }

   writeln;
   writeln(compilerversion);  { sign on with compiler version banner }
   writeln;
 end;


