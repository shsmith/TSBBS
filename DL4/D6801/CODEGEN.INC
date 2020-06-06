
(*******************************************************
 *
 * Subsystem:   Generator - general code generator
 *
 * Overview
 * --------
 *
 *    Provides several services to the parser for
 *    the generation of object code.   Calls a
 *    target machine specific optimizer for
 *    final output handling.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *   12-dec-85 s.h.smith  moved target machine specifics to opcXXXX and optXXXX
 *
 *
 * Procedures
 * ----------
 *
 * gen(objectstr)
 *    generate a line of object code from a string.
 *    this should be used only from within the
 *    code generator.
 *
 * gencomment(integer,objectstr)
 *    generate a comment in the object file
 *
 * genheader(identstr)
 *    create a run-time library that precedes the object
 *    code for all programs.
 *
 * gentrailer(identstr)
 *    outputs any required object code to terminate
 *    a program unit.
 *
 * genproc(identstr)
 *    outputs object code to start a new procedure
 *
 * endproc(identstr)
 *    outputs object code to finish a new procedure
 *
 * genvariable(identstr,tokcode,integer)
 *    output object code to reserve space for
 *    a static variable.
 *
 * gencall(identstr)
 *    output object code to make a call to
 *    another program unit
 *
 * genliteral(identstr,tokcode)
 *    output object code to push a literal value
 *    on the top of the data stack
 *
 * genfetch(symptr,tokcode)
 *    output object code to fetch a (possibly subscripted)
 *    variable value and to place it on the top of the
 *    data stack.
 *
 * genstore(symptr,tokcode)
 *    output object code to store the value on top of the
 *    working data stack into a (possibly subscripted)
 *    variable.
 *
 * genoperator(tokcode,tokcode)
 *    outputs object code to perform a given operation
 *    on the values on top of the data stack.  the operation
 *    is performed for a specified data type.
 *    see ###### for a complete list of operation codes.
 *
 * newlabel: objlabel
 *    returns a new and unique label identifier
 *    for branches in generated object code.
 *
 * genlabel(objlabel)
 *    outputs object code to mark the current location
 *    (where the next gen() will go) with a given
 *    label identifier.   once marked, this can be
 *    used as the destination of a genjump*
 *
 * genjump(objlabel)
 *    outputs object code to make an unconditional
 *    jump to a given label identifier
 *
 * genjumpfalse(objlabel)
 *    outputs object code to jump to a given
 *    label identifier if the boolean value on
 *    top of the stack is false.
 *
 * genjumptrue(objlabel)
 *    outputs object code to jump to a given
 *    label identifier if the boolean value on
 *    top of the stack is true.
 *
 *)



(**)
(*******************************************************
 *
 * Procedure:    gen(objectstr)
 *
 * Description:  generate a line of object code from a string.
 *               this should be used only from within the
 *               code generator.
 *
 * Example:      gen(' ABX ');
 *
 * Inputs:       the object code string to generate
 *
 * Outputs:      object code is passed to the machine-specific
 *               optimizer.   spaces are mapped into fixed tabstops.
 *
 *)

procedure gen (object:      objectstr);
begin
   optimize(object);          { pass the output line too the optimizer }

   objlines := objlines + 1;
end;




(**)
(*******************************************************
 *
 * Procedure:    gencomment(integer,objectstr)
 *
 * Description:  generate a comment in the object file
 *
 * Example:      gencomment(linenum,'starting test section');
 *
 * Inputs:       line number to include in the comment.  0 for none.
 *               the text of the comment.
 *
 * Outputs:      the comment is passed directly to the object file.
 *
 *)

procedure gencomment (lineno:      integer;
                      linetext:    objectstr);
var
   numstr:    string [5];

begin
   if lineno > 0 then
      str(lineno:5, numstr)
   else
      numstr := '-----';

   gen(op_comment + numstr + '| ' + linetext);

   commentcount := commentcount + 1;
end;




(**)
(*******************************************************
 *
 * Procedure:    genheader(identstr)
 *
 * Description:  create a run-time library that precedes the object
 *               code for all programs.
 *
 * Example:      genheader('TESTPROG');
 *
 * Inputs:       the name of the program being started
 *
 *)

procedure genheader (pgmname:     identstr);
begin
   gencomment(0,compilerversion);
   gencomment(0,generatorversion);
   writeln(generatorversion);

   gen(op_start_module + pgmname);
   gen(op_include_libs);
   gencomment(0,'');
end;




(**)
(*******************************************************
 *
 * Procedure:    gentrailer(identstr)
 *
 * Description:  outputs any required object code to terminate
 *               a program unit.
 *
 * Example:      gentrailer(progname);
 *
 * Inputs:       the name of the program being ended
 *
 *)

procedure gentrailer (pgmname:     identstr);
begin
   gen(op_end_module + pgmname);
end;




(**)
(*******************************************************
 *
 * Procedure:    genproc(identstr)
 *
 * Description:  outputs object code to start a new procedure
 *
 * Example:      genproc(procname);
 *
 * Inputs:       the name of the procedure
 *
 *)

procedure genproc (procname:    identstr);
begin
   gencomment(0,'');
   gen(procname + op_equate);
end;



(**)
(*******************************************************
 *
 * Procedure:    endproc(identstr)
 *
 * Description:  outputs object code to finish a new procedure
 *
 * Example:      endproc(procname);
 *
 * Inputs:       the name of the procedure to terminate
 *
 *)

procedure genendproc (procname:    identstr);
begin
   gen(op_return + procname);
   gencomment(0,'');
end;




(**)
(*******************************************************
 *
 * Procedure:    genvariable(identstr,tokcode,integer)
 *
 * Description:  output object code to reserve space for
 *               a static variable.
 *
 * Example:      genvariable(name,type,number)
 *
 * Inputs:       the name of the variable
 *               the data type of the variable
 *               the number of elements of the basic type
 *
 *)

procedure genvariable (varident:    identstr;
                       vartype:     tokcode;
                       items:       integer);
var
   varsize:     integer;

begin

   case vartype of               { determine the item size and
                                   reserve space for it}

      intsym:
            gen(varident + op_reserve_bytes + itoa(2*items));

      bytesym, boolsym:
            gen(varident + op_reserve_bytes + itoa(items));

      charsym:
         begin                  { char variables always have a header byte
                                  containing the length of the string }

            gen(varident + op_define_bytes + itoa(items));
            gen(op_reserve_bytes + itoa(items));
         end;

      else  error(xtype);
   end;

end;




(**)
(*******************************************************
 *
 * Procedure:    gencall(identstr)
 *
 * Description:  output object code to make a call to
 *               another program unit
 *
 * Example:      gencall('subroutine');
 *
 * Inputs:       the identifier for the program unit to call
 *
 *)

procedure gencall (procident:   identstr);
begin
   gen(op_call + procident);
end;



procedure genliteral (valstr:      identstr;
                      vartype:     tokcode);
forward;



(**)
(*******************************************************
 *
 * Procedure:    genfetch(symptr,tokcode)
 *
 * Description:  output object code to fetch a (possibly subscripted)
 *               variable value and to place it on the top of the
 *               data stack.
 *
 * Example:      genfetch(sym, subscripttype);
 *
 * Inputs:       the variable's symbol table pointer
 *               the subscript data type token (null if none)
 *               the variable index value on top of the data stack (if any)
 *
 * Outputs:      leaves variable value on the stack
 *
 *)

procedure genfetch (sym:         symptr;
                    substype:    tokcode);
begin

   if substype <> null then   { if there is a subscript, then generate
                                code to calculate the variable address.
                                the optimizer may convert these calls into
                                inline code. }

   begin
      gen(op_lit_integer + sym^.name);

      gen(op_call + 'OP_' + keywords [sym^.vartype] + '_LOAD_' +
                            keywords [substype] + '_INDEX');


      case sym^.vartype of           { push the subscripted value }
         intsym:
            gen(op_push_integer);

         bytesym, boolsym:
            gen(op_push_byte);

         else  error(xtype);
      end;
      exit;
   end;


   case sym^.vartype of               { fetch un-subscripted variable }

      intsym, charsym:
            begin
               gen(op_load_integer + sym^.name);
               gen(op_push_integer);
            end;

      bytesym, boolsym:
            begin
               gen(op_load_byte + sym^.name);
               gen(op_push_byte);
            end;

      else  error(xtype);
   end;
end;




(**)
(*******************************************************
 *
 * Procedure:    genstore(symptr,tokcode)
 *
 * Description:  output object code to store the value on top of the
 *               working data stack into a (possibly subscripted)
 *               variable.
 *
 * Example:      genstore(sym, subscripttype);
 *
 * Inputs:       the variable's symbol table pointer
 *               the subscript data type token (null if none)
 *               the value to store on top of the data stack
 *               the variable index value on next stack location (if any)
 *
 *)

procedure genstore (sym:         symptr;
                    substype:    tokcode);
begin

   if substype <> null then   { if there is a subscript, then generate
                                code to calculate the variable address.
                                the optimizer may convert these calls into
                                inline code. }
   begin
      gen(op_lit_integer + sym^.name);
      gen(op_call + 'OP_' + keywords [sym^.vartype] + '_STORE_' +
                            keywords [substype] + '_INDEX');
      exit;
   end;

   case sym^.vartype of               { store un-subscripted variable }

      intsym:
            begin
               gen(op_pop_integer);
               gen(op_store_integer + sym^.name);
            end;

      bytesym, boolsym:
            begin
               gen(op_pop_byte);
               gen(op_store_byte + sym^.name);
            end;

      charsym:
            begin             { code generated for string store:
                                   push-int rvalue pointer (source)
                                   lit-int  lvalue pointer (destination)
                                   lit-byte lvalue maximum size
                                   OP_CHAR_STORE }

               gen(op_lit_integer + sym^.name);
               gen(op_lit_byte + itoa(sym^.subelements[1]));
               gen(op_call + 'OP_' + keywords[sym^.vartype] + '_STORE');
            end;

      else  error(xtype);
   end;
end;




(**)
(*******************************************************
 *
 * Procedure:    genoperator(tokcode,tokcode)
 *
 * Description:  outputs object code to perform a given operation
 *               on the values on top of the data stack.  the operation
 *               is performed for a specified data type.
 *               see ###### for a complete list of operation codes.
 *
 * Example:      genoperator(plus,intsym);
 *
 * Inputs:       the operation token
 *               the input data type token
 *               (0,1 or 2 values on top of data stack)
 *
 * Outputs:      result value on top of data stack, if any
 *
 *)

procedure genoperator (oprcode:     tokcode;  {operation code}
                       vartype:     tokcode); {input data types}
begin

   if oprcode <> readsym then    { no value to fetch on readln calls }

   case vartype of               { help out the optimizer by fetching
                                   one of the parameters for the operator }

      intsym, charsym:
            gen(op_pop_integer);

      bytesym, boolsym:
            gen(op_pop_byte);

      null: ;

      else  error(xtype);
   end;

   gen(op_call + 'OP_' + keywords [vartype]+ '_' + keywords [oprcode]);
                              { generate a call to a runtime support procedure
                                named OP_type_operation. the optimizer
                                makes some of these calls into inline
                                code }


   case oprcode of               { help out the optimizer by pushing the
                                   return value of operator }

      eq..lt:                    { relational operators return a boolean }
            gen(op_push_byte);

      writesym:                  { writeln has no return value }
            ;

      else                       { all others return the same type as
                                   they take for inputs }

            case vartype of
               intsym, charsym:
                     gen(op_push_integer);

               bytesym, boolsym:
                     gen(op_push_byte);

               else  error(xtype);
            end;
   end;
end;




(**)
(*******************************************************
 *
 * Function:     newlabel: objlabel
 *
 * Description:  returns a new and unique label identifier
 *               for branches in generated object code.
 *
 * Example:      endblock := newlabel;
 *
 * Outputs:      a unique label identifier that can be
 *               used with genlabel and genjump* procedures.
 *
 *)

function newlabel: objlabel;
begin
   curlabel := curlabel + 1;
   newlabel := curlabel;
end;




(**)
(*******************************************************
 *
 * Procedure:    genlabel(objlabel)
 *
 * Description:  outputs object code to mark the current location
 *               (where the next gen() will go) with a given
 *               label identifier.   once marked, this can be
 *               used as the destination of a genjump*
 *
 * Example:      genlabel(endblock);
 *
 * Inputs:       the object label identifier for the label
 *               to be generated.
 *)


procedure genlabel (labelid:     objlabel);
begin
   gen('L' + itoa(labelid) + op_equate);
end;




(**)
(*******************************************************
 *
 * Procedure:     genjump(objlabel)
 *
 * Description:   outputs object code to make an unconditional
 *                jump to a given label identifier
 *
 * Example:       genjump(endblock);
 *
 * Inputs:        the object label identifier of the target of
 *                the unconditional branch
 *
 *)

procedure genjump (labelid:     objlabel);
begin
   gen(op_jump + 'L' + itoa(labelid));
   gencomment(0,'');
end;




(**)
(*******************************************************
 *
 * Procedure:     genjumpfalse(objlabel)
 *
 * Description:   outputs object code to jump to a given
 *                label identifier if the boolean value on
 *                top of the stack is false.
 *
 * Example:       genjumpfalse(endblock);
 *
 * Inputs:        the object label identifier of the target of
 *                the conditional branch
 *
 *)

procedure genjumpfalse (labelid:     objlabel);
begin

   gen(op_pop_byte);          { pop the boolean condition }

   gen(op_test_zero);         { test it for true/false }

   gen(op_jump_zero + 'L' + itoa(labelid));
                              { generate branch if false (a=0) }
   gencomment(0,'');
end;




(**)
(*******************************************************
 *
 * Procedure:     genjumptrue(objlabel)
 *
 * Description:   outputs object code to jump to a given
 *                label identifier if the boolean value on
 *                top of the stack is true.
 *
 * Example:       genjumptrue(endblock);
 *
 * Inputs:        the object label identifier of the target of
 *                the conditional branch
 *
 *)

procedure genjumptrue (labelid:     objlabel);
begin

   gen(op_pop_byte);          { pop the boolean condition }

   gen(op_test_zero);         { test it for true/false }

   gen(op_jump_not_zero + 'L' + itoa(labelid));
                              { generate branch if true (a<>0) }
   gencomment(0,'');
end;





(**)
(*******************************************************
 *
 * Procedure:    genliteral(identstr,tokcode)
 *
 * Description:  output object code to push a literal value
 *               on the top of the data stack
 *
 * Example:      genliteral('100',intsym);
 *
 * Inputs:       the text value of the literal
 *               the data type token
 *
 * Outputs:      leaves the value on top of the data stack
 *
 *)

procedure genliteral {forward (valstr:      identstr;
                               vartype:     tokcode)};
var
   datlab:    objlabel;
   over:      objlabel;
   i:         integer;

begin

   case vartype of
      intsym:
            begin
               gen(op_lit_integer + valstr);
               gen(op_push_integer);
            end;

      bytesym, boolsym:
            begin
               gen(op_lit_byte + valstr);
               gen(op_push_byte);
            end;

      charsym:
            begin
               datlab := newlabel;
               over := newlabel;
               genjump(over);

               gen('L' + itoa(datlab) + op_define_bytes +
                                        itoa(length(valstr)-2));
                                           { generate string length first }

               for i := 2 to length(valstr)-1 do
                  gen(op_define_bytes + itoa(ord(valstr[i])) + ' ' +
                      op_comment + valstr[i]);
                                          { generate define-byte for each
                                            char in the string }

               genlabel(over);
               gen(op_lit_integer + 'L' + itoa(datlab));
               gen(op_push_integer);      { push address of this string on
                                            the stack as the final result }
            end;

      else  error(xtype);
   end;
end;


