
/*
 * Yacc grammar for the "ADA" language.
 *
 * S.H.Smith, 18-Sep-86
 *
 */

%{
   #include "adasym.h"
   #include "adatree.h"

   #define YYSTYPE tree *      /* each production yields a parse tree
                                  node pointer */
%}


/* keywords */

%token ABORT      %token ABS        %token ACCEPT     %token ACCESS
%token ALL        %token AND        %token ARRAY      %token ASSOC
%token AT         %token BEGIN      %token BODY       %token BOX
%token CASE       %token CONSTANT   %token DECLARE    %token DELAY
%token DELTA      %token DIGITS     %token DO         %token ELSE
%token ELSIF      %token END        %token ENTRY      %token EXCEPTION
%token EXIT       %token FOR        %token FUNCTION   %token GENERIC
%token GOTO       %token IF         %token IN         %token IS
%token LIMITED    %token LOOP       %token MOD        %token NEW
%token NOT        %token NULL       %token OF         %token OR
%token OTHERS     %token OUT        %token PACKAGE    %token PRAGMA
%token PRIVATE    %token PROCEDURE  %token RAISE      %token RANGE
%token RECORD     %token REM        %token RENAMES    %token RETURN
%token REVERSE    %token SELECT     %token SEPARATE   %token SUBTYPE
%token TASK       %token TERMINATE  %token THEN       %token TYPE
%token USE        %token WHEN       %token WHILE      %token WITH
%token XOR


/* special character sequences */

%token BECOMES                      %token CHARACTER_LITERAL
%token DOTDOT                       %token GE
%token IDENTIFIER                   %token LE
%token NE                           %token NUMERIC_LITERAL
%token OPERATOR_STRING_LITERAL      %token PRIME
%token STARSTAR                     %token STRING_LITERAL


/* operator priorities (see 4.5) */

%left AND   %left OR   %left XOR
%left '='   %left NE   %left '<'   %left LE    %left '>'   %left GE
%left '+'   %left '-'  %left '&'
%left UMINUS
%left '*'   %left '/'
%left MOD   %left REM
%left ABS   %left NOT  %left STARSTAR


/* identifiers that require consultation of symbol tables */

%token ARGUMENT_identifier          %token BLOCK_name
%token COMPONENT_name               %token DISCRIMINANT_name
%token ENTRY_name                   %token EXCEPTION_name
%token FUNCTION_name                %token GENERIC_FUNCTION_name
%token GENERIC_PACKAGE_name         %token GENERIC_PROCEDURE_name
%token LABEL_name                   %token LOOP_name
%token OBJECT_name                  %token PACKAGE_name
%token PARAMETER_name               %token PARENT_UNIT_name
%token PROCEDURE_name               %token SUBPROGRAM_name
%token SUBTYPE_name                 %token TASK_name
%token TYPE_name                    %token UNIT_name
%token VARIABLE_name


/* other special token values */

%token UNDEFINED



/* the "start" symbol */

%start compilation

%%


/* 2.8 */

pragma
   : PRAGMA IDENTIFIER ';'
   | PRAGMA IDENTIFIER '(' argument_association
                           r.argument_association ')' ';' ;
r.argument_association
   : ',' argument_association r.argument_association | ;

argument_association
   : ARGUMENT_identifier ASSOC name
   | ARGUMENT_identifier ASSOC expression
   | name
   | expression ;

r.pragma
   : pragma r.pragma | ;


/* 3.1 */

basic_declaration
   : object_declaration         | number_declaration
   | type_declaration           | subtype_declaration
   | subprogram_declaration     | package_declaration
   | task_declaration           | generic_declaration
   | exception_declaration      | generic_instantiation
   | deferred_constant_declaration ;


/* 3.2 */

object_declaration
   : identifier_list ':'   object_specification ';'
   | PACKAGE IDENTIFIER    RENAMES SUBPROGRAM_name ';'
   | PACKAGE IDENTIFIER    RENAMES ENTRY_name ';' ;
o.expression
   : BECOMES expression | ;

object_specification
   : CONSTANT subtype_indication o.expression
   | CONSTANT constrained_array_definition o.expression
   | subtype_indication o.expression
   | subtype_indication  RENAMES OBJECT_name
   | constrained_array_definition o.expression
   | EXCEPTION RENAMES EXCEPTION_name

number_declaration
   : identifier_list ':' CONSTANT BECOMES UNIVERSAL_STATIC_expression ';' ;

identifier_list
   : IDENTIFIER r.identifier ;
r.identifier
   : ',' IDENTIFIER r.identifier | ;


/* 3.3.1 */

type_declaration
   : full_type_declaration
   | incomplete_type_declaration
   | private_type_declaration ;

full_type_declaration
   : TYPE IDENTIFIER discriminant_part IS type_definition ';' ;
   | TYPE IDENTIFIER IS type_definition ';' ;

type_definition
   : enumeration_type_definition  | integer_type_definition
   | real_type_definition         | array_type_definition
   | record_type_definition       | access_type_definition
   | derived_type_definition ;


/* 3.3.2 */

subtype_declaration
   : SUBTYPE IDENTIFIER IS subtype_indication ';' ;

subtype_indication
   : type_mark constraint
   | type_mark ;

type_mark
   : TYPE_name | SUBTYPE_name ;

constraint
   : range_constraint           | floating_point_constraint
   | fixed_point_constraint     | index_constraint
   | discriminant_constraint ;



/* 3.4 */

derived_type_definition
   : NEW subtype_indication ;


/* 3.5 */

range_constraint
   : RANGE range ;

range
   : RANGE_attribute
   | simple_expression DOTDOT simple_expression ;

STATIC_range
   : range
      { /* error if $1 is not static */ };


/* 3.5.1 */

enumeration_type_definition
   : '(' enumeration_literal_specification
         r.enumeration_literal_specification ')' ;
r.enumeration_literal_specification
   : ',' enumeration_literal_specification  r.enumeration_literal_specification
   | ;

enumeration_literal_specification
   : enumeration_literal ;

enumeration_literal
   : IDENTIFIER | CHARACTER_LITERAL ;


/* 3.5.4 */

integer_type_definition
   : range_constraint ;


/* 3.5.6 */

real_type_definition
   : floating_point_constraint | fixed_point_constraint ;


/* 3.5.7 */

floating_point_constraint
   : floating_accuracy_definition range_constraint
   | floating_accuracy_definition  ;

floating_accuracy_definition
   : DIGITS STATIC_simple_expression ;


/* 3.5.9 */

fixed_point_constraint
   : fixed_accuracy_definition range_constraint
   | fixed_accuracy_definition ;

fixed_accuracy_definition
   : DELTA STATIC_simple_expression ;


/* 3.6 */

array_type_definition
   : unconstrained_array_definition | constrained_array_definition ;

unconstrained_array_definition
   : ARRAY '(' index_subtype_definition r.index_subtype_definition ')'
     OF component_subtype_indication ;
r.index_subtype_definition
   : ',' index_subtype_definition r.index_subtype_definition | ;

constrained_array_definition
   : ARRAY index_constraint OF component_subtype_indication ;

component_subtype_indication
   : subtype_indication ;

index_subtype_definition
   : type_mark RANGE BOX ;

index_constraint
   : '(' discrete_range r.discrete_range ')' ;
r.discrete_range
   : ',' discrete_range r.discrete_range | ;

discrete_range
   : discrete_subtype_indication | range ;

discrete_subtype_indication
   : subtype_indication
      { /* error if $1 is not a discrete subtype */ };


/* 3.7 */

record_type_definition
   : RECORD
        component_list
     END RECORD ;

component_list
   : component_declaration r.component_declaration
   | r.component_declaration variant_part | NULL ';' ;
r.component_declaration
   : r.component_declaration component_declaration | ;

component_declaration
   : identifier_list ':' component_subtype_definition o.expression ';' ;

component_subtype_definition
   : subtype_indication ;


/* 3.7.1 */

discriminant_part
   : '(' discriminant_specification r.discriminant_specification ')' ;
r.discriminant_specification
   : ';' discriminant_specification r.discriminant_specification | ;

discriminant_specification
   : identifier_list ':' type_mark o.expression ;


/* 3.7.2 */

discriminant_constraint
   : '(' discriminant_association r.discriminant_association ')' ;
r.discriminant_association
   : ',' discriminant_association r.discriminant_association | ;

discriminant_association
   : o.DISCRIMINANT_name expression ;
o.DISCRIMINANT_name
   : DISCRIMINANT_name r.DISCRIMINANT_name | ;
r.DISCRIMINANT_name
   : '|' DISCRIMINANT_name r.DISCRIMINANT_name | ;


/* 3.7.3 */

variant_part
   : CASE DISCRIMINANT_name IS
        variant
        r.variant
     END CASE ';' ;
r.variant
   : r.variant variant | ;

variant
   : WHEN choice r.choice ASSOC component_list ;
r.choice
   : '|' choice r.choice | ;

choice
   : simple_expression  | discrete_range
   | OTHERS             | COMPONENT_name ;


/* 3.8 */

access_type_definition
   : ACCESS subtype_indication ;


/* 3.8.1 */

incomplete_type_declaration
   : TYPE IDENTIFIER discriminant_part ';'
   | TYPE IDENTIFIER ';' ;


/* 3.9 */

/* declarative_part
   : r.basic_declarative_item r.later_declarative_item ;
r.basic_declarative_item
   : basic_declarative_item r.basic_declarative_item | ;
r.later_declarative_item
   : later_declarative_item r.later_declarative_item | ;
*/

declarative_part
   : r.declarative_part declarative_part | ;

r.declarative_part
   : pragma                   | basic_declaration
   | representation_clause    | use_clause
   | body  ;

body
   : proper_body | body_stub ;

proper_body
   : subprogram_body | package_body | task_body ;


/* 4.1 */

name
   : simple_name
   | CHARACTER_LITERAL   | operator_symbol
   | indexed_component   | slice
   | selected_component  | attribute ;

simple_name
   : IDENTIFIER ;

prefix
   : name | function_call ;


/* 4.1.1 */

indexed_component
   : prefix '(' expression r.expression ')' ;
r.expression
   : ',' expression r.expression | ;


/* 4.1.2 */

slice
   : prefix '(' discrete_range ')' ;


/* 4.1.3 */

selected_component
   : prefix '.' selector ;

selector
   : simple_name | CHARACTER_LITERAL | operator_symbol | ALL ;


/* 4.1.4 */

attribute
   : prefix PRIME attribute_designator ;

attribute_designator
   : simple_name '(' UNIVERSAL_STATIC_expression ')'
   | simple_name ;

RANGE_attribute
   : attribute
      { /* error if $1 is not RANGE attribute designator */ };


/* 4.3 */

aggregate
   : '(' component_association r.component_association ')' ;
r.component_association
   : ',' component_association r.component_association | ;

component_association
   : choice r.choice ASSOC expression
   | expression ;

record_aggregate
   : aggregate
      { /* error if $1 is not a record aggregate */ };


/* 4.4 */

expression
   : relation AND relation   | relation AND THEN relation
   | relation OR relation    | relation OR ELSE relation
   | relation XOR relation
   | relation ;

relation
   : simple_expression '=' simple_expression
        { $$ = make_tree(OP_EQ,NULL,2,$1,$3); }

   | simple_expression NE  simple_expression
        { $$ = make_tree(OP_NE,NULL,2,$1,$3); }

   | simple_expression '<' simple_expression
        { $$ = make_tree(OP_LT,NULL,2,$1,$3); }

   | simple_expression LE  simple_expression
        { $$ = make_tree(OP_LE,NULL,2,$1,$3); }

   | simple_expression '>' simple_expression
        { $$ = make_tree(OP_GT,NULL,2,$1,$3); }

   | simple_expression GE  simple_expression
        { $$ = make_tree(OP_GE,NULL,2,$1,$3); }

   | simple_expression NOT IN range
   | simple_expression NOT IN type_mark
   | simple_expression IN range
   | simple_expression IN type_mark
   | simple_expression ;

simple_expression
   : s.term '+' simple_expression
        { $$ = make_tree(OP_ADD,NULL,2,$1,$3); }

   | s.term '-' simple_expression
        { $$ = make_tree(OP_SUB,NULL,2,$1,$3); }

   | s.term '&' simple_expression
        { $$ = make_tree(OP_CAT,NULL,2,$1,$3); }

   | s.term ;

s.term
   : '+' term %prec UMINUS
        { $$ = $2; }

   | '-' term %prec UMINUS
        { $$ = make_tree(OP_NEG,NULL,1,$2); }

   | term ;

term
   : factor '*' term
        { $$ = make_tree(OP_MUL,NULL,2,$1,$3); }

   | factor '/' term
        { $$ = make_tree(OP_DIV,NULL,2,$1,$3); }

   | factor MOD term
        { $$ = make_tree(OP_MOD,NULL,2,$1,$3); }

   | factor REM term
        { $$ = make_tree(OP_REM,NULL,2,$1,$3); }

   | factor ;

factor
   : primary STARSTAR primary
        { $$ = make_tree(OP_EXP,NULL,2,$1,$3); }

   | ABS primary
        { $$ = make_tree(OP_ABS,NULL,1,$2); }

   | NOT primary
        { $$ = make_tree(OP_NOT,NULL,1,$2); }

   | primary ;

primary
   : aggregate
   | name
   | allocator
   | function_call
   | type_conversion
   | qualified_expression
   | '(' expression ')'
   | NUMERIC_LITERAL
   | STRING_LITERAL
   | NULL ;


STATIC_simple_expression
   : simple_expression
      { /* error if $1 is not static */ };

UNIVERSAL_STATIC_expression
   : expression
      { /* error if $1 is not static */ };

BOOLEAN_expression
   : expression
      { /* error if $1 is not boolean */ };



/* 4.5 */

/******
logical_operator               : AND | OR | XOR ;
relational_operator            : '=' | NE | '<' | LE | '>' | GE ;
binary_adding_operator         : '+' | '-' | '&' ;
unary_adding_operator          : '+' | '-' ;
multiplying_operator           : '*' | '/' | MOD | REM ;
highest_precedence_operator    : STARSTAR | ABS | NOT ;
******/


/* 4.6 */

type_conversion
   : type_mark '(' expression ')' ;


/* 4.7 */

qualified_expression
   : type_mark PRIME '(' expression ')'
   | type_mark PRIME aggregate ;


/* 4.8 */

allocator
   : NEW subtype_indication
   | NEW qualified_expression ;


/* 5.1 */

sequence_of_statements
   : statement r.statement ;
r.statement
   : statement r.statement | ;

statement
   : label simple_statement | label compound_statement
   | simple_statement       | compound_statement ;

simple_statement
   : null_statement       | pragma
   | assignment_statement | procedure_call_statement
   | exit_statement       | return_statement
   | goto_statement       | entry_call_statement
   | delay_statement      | abort_statement
   | raise_statement      | code_statement ;

compound_statement
   : if_statement         | case_statement
   | loop_statement       | block_statement
   | accept_statement     | select_statement ;

label
   : '<' '<' LABEL_name '>' '>' ;

null_statement
   : NULL ';' ;


/* 5.2 */

assignment_statement
   : VARIABLE_name BECOMES expression ';' ;


/* 5.3 */

if_statement
   : IF condition THEN
        sequence_of_statements
     r.elsif.condition
     o.else
     END IF ';' ;
r.elsif.condition
   : ELSIF condition THEN
        sequence_of_statements
     r.elsif.condition | ;
o.else
   : ELSE sequence_of_statements | ;

condition
   : BOOLEAN_expression


/* 5.4 */

case_statement
   : CASE expression IS
        case_statement_alternative
        r.case_statement_alternative
     END CASE ';' ;
r.case_statement_alternative
   : case_statement_alternative r.case_statement_alternative | ;

case_statement_alternative
   : WHEN choice r.choice ASSOC sequence_of_statements ;


/* 5.5 */

loop_statement
   : LOOP_name ':'
        iteration_scheme LOOP
           sequence_of_statements
        END LOOP LOOP_name ';'

   | iteration_scheme LOOP
        sequence_of_statements
     END LOOP ';' ;

iteration_scheme
   : WHILE condition | FOR loop_parameter_specification | ;

loop_parameter_specification
   : IDENTIFIER IN REVERSE discrete_range
   | IDENTIFIER IN discrete_range ;


/* 5.6 */

block_statement
   : BLOCK_name ':'
       o.DECLARE
       BEGIN
          sequence_of_statements
       o.EXCEPTION
       END BLOCK_name ';'

   | o.DECLARE
     BEGIN
          sequence_of_statements
     o.EXCEPTION
     END  ';' ;

o.DECLARE
   : DECLARE declarative_part | ;
o.EXCEPTION
   : EXCEPTION exception_handler r.exception_handler ;
r.exception_handler
   : exception_handler r.exception_handler | ;


/* 5.7 */

exit_statement
   : EXIT LOOP_name WHEN condition ';' ;
   | EXIT LOOP_name ';' ;
   | EXIT WHEN condition ';'
   | EXIT ';'


/* 5.8 */

return_statement
   : RETURN expression ';'
   | RETURN ';' ;


/* 5.9 */

goto_statement
   : GOTO LABEL_name ';' ;


/* 6.1 */

subprogram_declaration
   : subprogram_specification ;

subprogram_specification
   : PROCEDURE IDENTIFIER formal_part
   | PROCEDURE IDENTIFIER
   | FUNCTION designator formal_part RETURN type_mark
   | FUNCTION designator RETURN type_mark ;

designator
   : IDENTIFIER | operator_symbol ;

operator_symbol
   : OPERATOR_STRING_LITERAL ;

formal_part
   : '(' parameter_specification  r.parameter_specification ')' ;
r.parameter_specification
   : ';' parameter_specification r.parameter_specification | ;

parameter_specification
   : identifier_list ':' mode type_mark o.expression ;

mode
   : IN OUT | IN | OUT | ;


/* 6.3 */

subprogram_body
   : subprogram_specification IS
        declarative_part
     BEGIN
        sequence_of_statements
     o.EXCEPTION
     END o.designator ';' ;

o.designator
   : designator | ;


/* 6.4 */

procedure_call_statement
   : PROCEDURE_name actual_parameter_part ';'
   | PROCEDURE_name ';' ;

function_call
   : FUNCTION_name actual_parameter_part
   | FUNCTION_name ;

actual_parameter_part
   : parameter_association r.parameter_association ;
r.parameter_association
   : parameter_association r.parameter_association | ;

parameter_association
   : formal_parameter ASSOC actual_parameter
   | actual_parameter ;

formal_parameter
   : PARAMETER_name ;

actual_parameter
   : expression | VARIABLE_name | type_mark '(' VARIABLE_name ')' ;


/* 7.1 */

package_declaration
   : package_specification ';' ;

package_specification
   : PACKAGE IDENTIFIER IS
        declarative_part
     o.private_part
     END PACKAGE_name ;
o.private_part
   : PRIVATE declarative_part | ;

package_body
   : PACKAGE BODY PACKAGE_name IS
        declarative_part
     o.BEGIN
     o.EXCEPTION
     END PACKAGE_name ';' ;
o.BEGIN
   : BEGIN sequence_of_statements | ;


/* 7.4 */

private_type_declaration
   : TYPE IDENTIFIER o.discriminant_part IS o.LIMITED PRIVATE ';' ;
o.discriminant_part
   : discriminant_part | ;
o.LIMITED
   : LIMITED | ;


deferred_constant_declaration
   : identifier_list ':' CONSTANT type_mark ';' ;


/* 8.4 */

use_clause
   : USE PACKAGE_name r.PACKAGE_name ';' ;
r.PACKAGE_name
   : ',' PACKAGE_name r.PACKAGE_name | ;



/* 9.1 */

task_declaration
   : task_specification ';' ;

task_specification
   : TASK o.TYPE IDENTIFIER IS
        r.entry_declaration
        r.representation_clause
     END TASK_name ;
o.TYPE
   : TYPE | ;
r.entry_declaration
   : entry_declaration r.entry_declaration | ;
r.representation_clause
   : representation_clause r.representation_clause | ;

task_body
   : TASK BODY TASK_name IS
        declarative_part
     BEGIN
        sequence_of_statements
     o.EXCEPTION
     END TASK_name ';' ;


/* 9.5 */

entry_declaration
   : ENTRY IDENTIFIER '(' discrete_range ')' o.formal_part ';'
   | ENTRY IDENTIFIER o.formal_part ';' ;

entry_call_statement
   : ENTRY_name actual_parameter_part ';'
   | ENTRY_name ';' ;

accept_statement
   : ACCEPT ENTRY_name '(' entry_index ')' o.formal_part o.DO ';'
   | ACCEPT ENTRY_name o.formal_part o.DO ';'
o.DO
   : DO sequence_of_statements END ENTRY_name | ;
o.formal_part
   : formal_part | ;

entry_index
   : expression ;


/* 9.6 */

delay_statement
   : DELAY simple_expression ';' ;


/* 9.7 */

select_statement
   : selective_wait
   | conditional_entry_call
   | timed_entry_call ;


/* 9.7.1 */

selective_wait
   : SELECT select_alternative
     o.OR.select_alternative
     o.ELSE.sequence_of_statements
     END SELECT ';' ;
o.OR.select_alternative
   : OR select_alternative | ;
o.ELSE.sequence_of_statements
   : ELSE sequence_of_statements | ;

select_alternative
   : WHEN condition ASSOC selective_wait_alternative
   | selective_wait_alternative ;

selective_wait_alternative
   : accept_alternative | delay_alternative | terminate_alternative ;

accept_alternative
   : accept_statement sequence_of_statements
   | accept_statement ;

delay_alternative
   : delay_statement sequence_of_statements
   | delay_statement ;

terminate_alternative
   : TERMINATE ';' ;


/* 9.7.2 */

conditional_entry_call
   : SELECT entry_call_statement o.sequence_of_statements
     ELSE sequence_of_statements
     END SELECT ';' ;
o.sequence_of_statements
   : sequence_of_statements | ;


/* 9.7.3 */

timed_entry_call
   : SELECT entry_call_statement o.sequence_of_statements
     OR delay_alternative
     END SELECT ';' ;


/* 9.10 */

abort_statement
   : ABORT TASK_name r.TASK_name ';' ;
r.TASK_name
   : ',' TASK_name r.TASK_name | ;


/* 10.1 */

compilation
   : compilation_unit compilation | ;

compilation_unit
   : r.pragma context_clause r.pragma comp_unit ;

comp_unit
   : library_unit | secondary_unit ;

library_unit
   : subprogram_declaration
   | package_declaration
   | generic_declaration
   | generic_instantiation
   | subprogram_body ;

secondary_unit
   : library_unit_body
   | subunit ;

library_unit_body
   : subprogram_body
   | package_body ;


/* 10.1.1 */

context_clause
   : with_clause context_clause
   | use_clause  context_clause | ;

with_clause
   : WITH UNIT_name r.UNIT_name ';' ;
r.UNIT_name
   : ',' UNIT_name r.UNIT_name | ;


/* 10.2 */

body_stub
   : subprogram_specification IS SEPARATE ';'
   | PACKAGE BODY PACKAGE_name IS SEPARATE ';'
   | TASK BODY TASK_name IS SEPARATE ';' ;

subunit
   : SEPARATE '(' PARENT_UNIT_name ')' proper_body ;


/* 11.1 */

exception_declaration
   : identifier_list ':' EXCEPTION ';' ;


/* 11.2 */

exception_handler
   : WHEN exception_choice r.exception_choice ASSOC
          sequence_of_statements ;
r.exception_choice
   : '|' exception_choice r.exception_choice | ;

exception_choice
   : EXCEPTION_name | OTHERS ;


/* 11.3 */

raise_statement
   : RAISE EXCEPTION_name ';'
   | RAISE ';' ;


/* 12.1... */

generic_declaration
   : generic_specification ';' ;

generic_specification
   : generic_formal_part subprogram_specification
   | generic_formal_part package_specification ;

generic_formal_part
   : GENERIC r.generic_parameter_declaration ;
r.generic_parameter_declaration
   : generic_parameter_declaration r.generic_parameter_declaration | ;

generic_parameter_declaration
   : identifier_list ':' mode type_mark o.expression ';'
   | TYPE IDENTIFIER IS generic_type_definition ';'
   | private_type_declaration
   | WITH subprogram_specification IS name ';'
   | WITH subprogram_specification IS BOX ';'
   | WITH subprogram_specification ';' ;

generic_type_definition
   : '(' BOX ')' | RANGE BOX | DIGITS BOX | DELTA BOX
   | array_type_definition   | access_type_definition ;


/* 12.3 */

generic_instantiation
   : PACKAGE IDENTIFIER IS
        NEW GENERIC_PACKAGE_name o.generic_actual_part ';'
   | PROCEDURE IDENTIFIER IS
        NEW GENERIC_PROCEDURE_name o.generic_actual_part ';'
   | FUNCTION designator IS
        NEW GENERIC_FUNCTION_name o.generic_actual_part ';' ;

o.generic_actual_part
   : '(' generic_association r.generic_association ')' | ;
r.generic_association
   : ',' generic_association r.generic_association | ;

generic_association
   : generic_formal_parameter ASSOC generic_actual_parameter
   | generic_actual_parameter ;

generic_formal_parameter
   : PARAMETER_name | operator_symbol ;

generic_actual_parameter
   : expression      | VARIABLE_name
   | SUBPROGRAM_name | ENTRY_name | type_mark ;


/* 13.1 */

representation_clause
   : type_representation_clause | address_clause ;

type_representation_clause
   : length_clause
   | enumeration_representation_clause
   | record_representation_clause ;


/* 13.2 */

length_clause
   : FOR attribute USE simple_expression ';' ;


/* 13.3 */

enumeration_representation_clause
   : FOR TYPE_name USE aggregate ';' ;


/* 13.4 */

record_representation_clause
   : FOR TYPE_name USE
        RECORD
           o.alignment_clause
           o.component_clause
        END RECORD ';' ;

o.alignment_clause
   : AT MOD STATIC_simple_expression ';'
   | ;

o.component_clause
   : COMPONENT_name AT STATIC_simple_expression
                    RANGE STATIC_range ';'
   | ;


/* 13.5 */

address_clause
   : FOR simple_name USE AT simple_expression ';' ;


/* 13.8 */

code_statement
   : type_mark PRIME record_aggregate ';'

%%

/* lexical analysis done by adalex.c */
/* symbol table handling done by adasym.c */

