

(*******************************************************
 *
 * Subsystem:   gendecl - Code generator for Declrations
 *
 * Overview
 * --------
 *
 *    This subsystem contains the gen_ procedures called by
 *    the parsdecl subsystem.   Each gen_ procedure generates
 *    the pascal object code for a Smalltalk declaration section.
 *
 *)


procedure gen_class_name_decl;
begin
   genln ('');
   genln ('function cf_' + class^.class_name +
          ' (sel: sels;  s,p1,p2,p3,p4: objptr): objptr;');

   genln ('');
end;


procedure gen_class_variable_names_decl;
var
   sym:  symptr;

begin

   dclgenln ('');
   dclgenln ('var');
   dclgenln ('   '+class^.class_name + '_cv: record');

   sym := class^.class_variables;
   while sym <> nil do
   begin
      dclgenln ('      ' + sym^.name + ': objptr;');
      sym := sym^.next;
   end;

   dclgenln ('   end;');
end;


procedure gen_superclass_decl;
begin
end;


procedure gen_instance_variable_names_decl;
var
   sym:  symptr;

begin

   dclgenln ('');
   dclgenln ('type');
   dclgenln ('   '+class^.class_name+'_ivptr = ^'+class^.class_name+'_iv;');
   dclgenln ('   '+class^.class_name+'_iv = record');

   if class^.superclass = nil then
      dclgenln ('      super_iv: byte;')
   else
      dclgenln ('      super_iv: '+class^.superclass^.name+'_iv;');

   sym := class^.instance_variables;
   while sym <> nil do
   begin
      dclgenln ('      ' + sym^.name + ': objptr;');
      sym := sym^.next;
   end;

   dclgenln ('   end;');
end;


procedure gen_class_prelude;
begin

   genln ('{local and special variables}');
   genln ('var');
   genln ('   self: '+class^.class_name+'_ivptr absolute s;');
   genln ('   l0,l1,l2,l3,l4: objptr;');

   genln ('');
   genln ('begin');

   indent;
   genln ('case sel of');

   indent;

end;


procedure gen_method_start (meth: symptr);
var
   par:   symptr;

begin
   gotoxy(40,wherey);
   write(meth^.name);
   clreol;

   genln ('s_' + meth^.name + ':  begin');
   indent;

   par := meth^.parameters;
   if par <> nil then
   begin
      gen('{method parameters:');

      while par <> nil do
      begin
         gen (' ' + par^.name);
         par := par^.next;
      end;

      genln ('}');
   end;

   par := meth^.locals;
   if par <> nil then
   begin
      gen ('{method locals:');

      while par <> nil do
      begin
         gen (' ' + par^.name);
         par := par^.next;
      end;

      genln ('}');
   end;

end;


procedure gen_method_finish;
begin
   gotoxy(40,wherey);
   clreol;

   unindent;
   genln ('end;');
   genln ('');

end;


procedure gen_class_start;
begin

   gotoxy(20,wherey);
   write(class^.class_name);
   clreol;

   gen_class_name_decl;

   gen_superclass_decl;

   gen_class_variable_names_decl;

   gen_instance_variable_names_decl;

   gen_class_prelude;

end;


procedure gen_class_finish;
begin
   gotoxy(20,wherey);
   clreol;

   genln ('else');

   indent;
   genln ('{message not handled here; pass it to the superclass}');

   if class^.superclass = nil then
      genln ('serror(''invalid message selector'');')
   else
      genln ('l0 := cf_'+class^.superclass^.name + '(sel,s,p1,p2,p3,p4);');

   unindent;
   unindent;
   genln ('end;');
   genln ('');
   genln ('cf_' + class^.class_name + ' := l0;');

   unindent;
   genln ('end;');
   genln ('');
   genln ('');

end;


procedure gen_selectors;
var
   sym:  symptr;

begin

   dclgenln ('');
   dclgenln ('type sels = (');

   sym := selectors;
   while sym <> nil do
   begin
      dclgen ('      s_'+sym^.name);
      sym := sym^.next;
      if sym = nil then
         dclgenln ( ');')
      else
         dclgenln ( ',');
   end;

end;


procedure gen_class_list;
var
   sym:  symptr;

begin

   dclgenln ('');
   dclgenln ('type');
   dclgenln ('   class_ptr = ^class_codes;');
   dclgenln ('   class_codes = (');

   sym := classes;
   while sym <> nil do
   begin

      dclgen ('      cl_'+sym^.name);
      sym := sym^.next;
      if sym = nil then
         dclgenln (');')
      else
         dclgenln (',');
   end;

end;


procedure gen_sendm;
var
   sym:  symptr;

begin

   dclgenln ('');
   dclgenln ('function sendm (sel: sels; s,p1,p2,p3,p4: objptr): objptr;');
   dclgenln ('   forward;');
   dclgenln ('');

   genln ('function  sendm {forward};');
   genln ('var');
   genln ('   object_class:  class_ptr absolute s;');
   genln ('begin');
   genln ('   if s = nil then serror(''nil object'');');
   genln ('   case object_class^ of');

   sym := classes;
   while sym <> nil do
   begin
      genln ('      cl_'+sym^.name+': ');
      genln ('         sendm := cf_'+sym^.name+'(sel,s,p1,p2,p3,p4);');
      sym := sym^.next;
   end;

   genln ('      else');
   genln ('         serror(''invalid object class'');');
   genln ('   end;');
   genln ('end;');
   genln ('');

end;


procedure gen_finis;
begin

   gen_selectors;
   gen_class_list;
   gen_sendm;

end;


