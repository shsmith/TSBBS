

(*******************************************************
 *
 * Subsystem:   Data - Global type and variable declarations
 *
 * Overview
 * --------
 *
 *    This file contains the declarations of all global data.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 shs  initial coding
 *   09-mar-86 shs  made smalltalk-80 version
 *
 *)



(*******************************************************
 *
 *   Global Constants
 *
 *)

 const

   compilerversion = 'STP v0.1 (12-Mar-86 S.H.Smith)';


   maxidentlen = 31;          { longest identifier/token }


   binary_selectors  = '-+/\*~<>=@%|&?!';
                              { binary selector characters }

   binary_mnemonic_1 = 'MPFBSNLGEAPVAQB';
   binary_mnemonic_2 = 'ILSSTOTTQTCBNMA';
                              { first and second character of mnemonics for
                                each of the binary selectors }


(**)
(*******************************************************
 *
 *   Global Data Types
 *
 *)

 type
   identstr =    string [maxidentlen];
   anystring =   string [128];



(*      TokCode lists all symbols that can possibly be
 *      returned by the scanner. *)

type
   tokcode =     (unknown,
                  identifier,
                  digits,
                  string_constant,
                  character_constant,
                  binary_selector,
                  assign,
                  left_paren,
                  right_paren,
                  left_bracket,
                  right_bracket,
                  special_character,
                  end_of_file,
                  first_keyword,
                  k_class_name,
                  k_superclass,
                  k_instance_variable_names,
                  k_instance_methods,
                  k_class_variable_names,
                  k_class_methods,
                  k_include_file,
                  last_keyword);

const
   keywords: array [tokcode] of identstr =
                 ('unknown',
                  'identifier',
                  'digits',
                  'string_constant',
                  'character_constant',
                  'binary_selector',
                  'assign',
                  'left_paren',
                  'right_paren',
                  'left_bracket',
                  'right_bracket',
                  'special_character',
                  'end_of_file',
                  '<first keyword>',
                  'class_name',
                  'superclass',
                  'instance_variable_names',
                  'instance_methods',
                  'class_variable_names',
                  'class_methods',
                  'include_file',
                  '<last keyword>');


type
   tokenrec =    record          { Definition of the mailbox where the
                                   scanner }

         name:         identstr;    { leaves dope on the current token
                                      and where }

         code:         tokcode;     { the parser picks it up. }

   end;


(*   Symbol table entry types.  *)

type
   symtypes = (sym_undefined,
               sym_local_variable,
               sym_pseudo_variable,
               sym_instance_variable,
               sym_class_variable,
               sym_global_variable,
               sym_method,
               sym_selector,
               sym_class);


type

(*   Format of a symbol-table entry.  *)

   clasptr =     ^class_rec;  { Points to a class description entry. }
   symptr =      ^symbol;     { Points to a symbol-table entry. }

   symbol =      record
         name:         identstr;    { the symbol name }

         next:         symptr;      { pointer to next table entry }


         case symtype: symtypes of  { symbol types }

            sym_undefined:  ();                      { an undefined table
                                                       entry }

            sym_selector:   ();                      { a message selector }

            sym_class:      (class_data:  clasptr);  { a class definition }

            sym_local_variable,
            sym_pseudo_variable,
            sym_instance_variable,
            sym_class_variable,
            sym_global_variable:
                            (class:       symptr;    { the class of the
                                                       variable }
                             var_name:    identstr); { the variable name to
                                                       use during code
                                                       generation }

            sym_method:     (parameters:  symptr;    { the symbol table of
                                                       parameters for this
                                                       method }

                             locals:      symptr);   { the symbol table of
                                                       local variables for
                                                       this method}
   end;


(*   Expression node types.  *)

   expnodes = (exp_assign,
               exp_variable,
               exp_literal,
               exp_block,
               exp_message,
               exp_cascaded_message,
               exp_empty);


(*   Format of an expression description record.  *)

   expptr = ^expression_rec;

   expression_rec = record

      class:                  symptr;      { the calss of the expression
                                             result }


      case exptype: expnodes of            { type of the expression node }

         exp_assign:
            (assign_variable: symptr;  { an assignment of an expression to a
                                         variable. }
             assign_exp:      expptr);

         exp_variable:
            (varsym:          symptr); { a primary reference to
                                         a variable }

         exp_literal:
            (litval:          anystring); { a primary reference to
                                            a literal value }

         exp_block:
            (block:           symptr); { a primary reference to
                                         a block (local method) }

         exp_cascaded_message,
         exp_message:
            (object:           symptr;  { the message object
                                          description (primary) }

             selector:         symptr;  { the method selector }

             parameters:       expptr;  { the table of parameter
                                          expressions }

             next:             expptr); { link to the next
                                          message for the same
                                          object (cascaded
                                          messages only) }
         exp_empty:
            ();

   end;



(*   Information known about a class definition.  *)

   class_rec = record

         class_name:          identstr;    { the class name }

         superclass:          symptr;      { the superclass name }

         class_variables:     symptr;      { the symbol table of class
                                             variable names }

         class_methods:       symptr;      { the symbol table of class
                                             methods (selectors) }

         instance_variables:  symptr;      { the symbol table of instance
                                             variables in this class }

         instance_methods:    symptr;      { the symbol table of instance
                                             methods (selectors) }
   end;



(**)
(*******************************************************
 *
 *   Global Variables
 *
 *)

 var

   infile:       text[2048];  { source code file }

   incfile:      text[2048];  { include source code file }

   include:      boolean;     { are we reading an include file? }

   linecount:    integer;     { number of lines in source text }

   sourceline:   anystring;   { the current source line }

   copysource:   boolean;     { true if source is copied to object
                                as comments }


   outfile:      text[4096];  { object code file }

   indentation:  integer;     { amount of indentation in code generator }

   outpos:       integer;     { current code generator output line position }


   dclfile:      text[512];   { global declaration file }


   tk:           tokenrec;    { where dope on the current token is stashed }

   ch:           char;        { current scanner input }

   class:        clasptr;     { the current class description }

   classes:      symptr;      { the table of classes }

   global_variables: symptr;  { the table of global variables }

   selectors:    symptr;      { the table of message selectors }

