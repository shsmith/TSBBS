
%{

/*---------------------------------------------------
 * A3 - Yacc grammar for a simple ADA-like language
 *
 * S.H.Smith, 15-Sep-86
 *
 */


extern int listsrc;     /* listing source code? */
extern int traceact;    /* trace actions? */

#define ACTION(code) if (traceact) {code;}
#define action(code) if (traceact) printf(" {code}\n")


#include "a3sym.h"      /* symbol table definition */

%}

/* specify all tokens recognized by lexical analyzer */
%token AND
%token ASSOC
%token BECOMES
%token BEGIN
%token BOOLEAN
%token BYTE
%token CALL
%token CASE
%token CHARACTER
%token DEBUG
%token DOTDOT
%token ELSE
%token ELSIF
%token END
%token EXIT
%token FALSE
%token FLOAT
%token FOR
%token FUNCTION
%token GE
%token IF
%token IN
%token INTEGER
%token IS
%token LE
%token LIST
%token LIT_NUMBER
%token LIT_STRING
%token LOOP
%token NE
%token NOT
%token NULL
%token OF
%token OFF
%token ON
%token OR
%token OTHERS
%token OUT
%token PACKAGE
%token PRAGMA
%token PROCEDURE
%token RETURN
%token REVERSE
%token STRING
%token SUBTYPE
%token THEN
%token TO
%token TRACE
%token TRUE
%token TYPE
%token UNDEF_IDENTIFIER
%token UNIT_IDENTIFIER
%token USE
%token VAR_IDENTIFIER
%token WHEN
%token WHILE
%token WITH


/* specify priorities for expression operators */
%left NOT AND OR '=' NE '>' GE '<' LE
%left '+' '-' '&'
%left '*' '/'
%left UMINUS


/* specify possible production data types */
%union {
   int integer;   /* literal integers */

   char *text;    /* pointer to literal strings */

   symbol *sym;   /* pointer to symbol table entry */

   int none;      /* no value */
}


/* specify data types of value-returning productions */
%type <integer> on_off


/* specify data types of value-returning terminals */
%type <integer> LIT_NUMBER
%type <text>    LIT_STRING
%type <sym>     UNDEF_IDENTIFIER
%type <sym>     UNIT_IDENTIFIER
%type <sym>     VAR_IDENTIFIER
%type <sym>     any_identifier
%type <sym>     procedure_banner


/* define the 'start' symbol */
%start batchs

%%


/*---------------------------------------------------
 * Compiler options
 *
 */

pragma
   : PRAGMA DEBUG on_off ';'
            { yydebug=$3; }
   | PRAGMA LIST on_off ';'
            { listsrc=$3; }
   | PRAGMA TRACE on_off ';'
            { traceact=$3; }
   | PRAGMA any_identifier on_off ';'
            { yyerror("unknown pragma"); }
;

on_off
   : '(' ON ')'
            { $$ = 1; }
   | '(' OFF ')'
            { $$ = 0; }
;



/*---------------------------------------------------
 * The Start symbol - top level productions
 *
 */

batchs
   : batch batchs
   |
;

batch
   : package_declaration
   | procedure_declaration
   | pragma
   | with
   | use
;


package_declaration
   : PACKAGE UNDEF_IDENTIFIER IS
        declarations
        package_initialization
     END UNDEF_IDENTIFIER ';'
            {
              if ($2 != $7)
                 yyerror("identifier mismatch: <%s> <%s>",$2->id,$7->id);
              else {
                 $2->type = unit_sym;
                 action(package_declaration);
              }
            }
;

package_initialization
   : BEGIN
        statements
   |
;

with
   : WITH package_identifier more_package_identifiers ';'
 ;

use
   : USE package_identifier more_package_identifiers ';'
;


package_identifier
   : UNDEF_IDENTIFIER
   | UNIT_IDENTIFIER
;

more_package_identifiers
   : ',' package_identifier more_package_identifiers
   |
;



/*---------------------------------------------------
 * Data and procedure productions
 *
 */

declarations
   : declaration declarations
   |
;

declaration
   : procedure_declaration
   | data_declaration
   | use
   | pragma
   | error ';'
            {
              action(declaration_error_recoverey);
              yyerrok;
            }
;

data_declaration
   : UNDEF_IDENTIFIER ':' type_specification ';'
            {
              ACTION(printf("{define variable %s}\n",$1->id));
              $1->type = var_sym;
            }

   | TYPE UNDEF_IDENTIFIER IS type_specification ';'
            {
              ACTION(printf("{define type %s}\n",$2->id));
              $2->type = var_sym;
            }

   | SUBTYPE UNDEF_IDENTIFIER IS type_specification ';'
            {
              ACTION(printf("{define subtype %s}\n",$2->id));
              $2->type = var_sym;
            }
;

type_specification
   : INTEGER
   | CHARACTER
   | BOOLEAN
   | STRING
   | FLOAT
   | BYTE
   | discrete_range
;


procedure_declaration
   : procedure_banner ';'
           { action(forward_procedure_decl); }

   | procedure_banner IS
        declarations
     BEGIN
        statements
     END UNDEF_IDENTIFIER ';'
            { if ($1 != $7)
                 yyerror("identifier mismatch: <%s> <%s>",$1->id,$7->id);
              else {
                 $1->type = unit_sym;
                 action(procedure_decl);
              }
            }
;

procedure_banner
   : PROCEDURE UNDEF_IDENTIFIER formal_param_list
           { $$ = $2; }

   | FUNCTION UNDEF_IDENTIFIER formal_param_list RETURN type_specification
           { $$ = $2; }
;

formal_param_list
   : '(' formal_param more_formal_params ')'
           { action(formal_param_list); }
   |
;

formal_param
   : formal_param_identifier more_formal_param_identifiers
        ':' in_out type_specification
           { action(formal_param); }
;

formal_param_identifier
   : UNDEF_IDENTIFIER
;

more_formal_param_identifiers
   : ',' formal_param_identifier more_formal_param_identifiers
           { action(more_formal_param_idents); }
   |
;

more_formal_params
   : ';' formal_param
           { action(more_formal_params); }
   |
;

in_out
   : IN OUT
   | IN
   | OUT
   |
;



/*---------------------------------------------------
 * Statement productions
 *
 */

statements
   : statement statements
   | statement
;

statement
   : if_then
   | assignment
   | call
   | return
   | while_loop
   | for_loop
   | loop
   | case
   | exit
   | null
   | pragma
   | error ';'
           {
             action(statement_error_recoverey);
             yyerrok;
           }
;

if_then
   : IF condition THEN statements elsif ELSE statements END IF ';'
           { action(if_then_else); }

   | IF condition THEN statements elsif END IF ';'
           { action(if_then); }
;

elsif
   : ELSIF condition THEN statements elsif
           { action(elsif); }
   |
;

assignment
   : lvalue BECOMES expression ';'
           { action(assignment); }
;

call
   : UNIT_IDENTIFIER param_list ';'
           { action(call); }
;

return
   : RETURN expression ';'
           { action(return_expr); }

   | RETURN ';'
           { action(return); }
;

while_loop
   : WHILE condition LOOP
        statements
     END LOOP ';'
           { action(while_loop); }
;

for_loop
   : FOR lvalue IN discrete_range LOOP
        statements
     END LOOP ';'
           { action(for_loop); }

   | FOR lvalue IN REVERSE discrete_range LOOP
        statements
     END LOOP ';'
           { action(for_loop_reverse); }
;


loop
   : LOOP
        statements
     END LOOP ';'
           { action(loop); }
;

case
   : CASE expression IS
        whens
     END CASE ';'
           { action(case_is); }
;

whens
   : when whens
   |
;

when
   : WHEN static_expression ASSOC statements
           { action(when); }
   | WHEN OTHERS ASSOC statements
           { action(when_others); }
;

exit
   : EXIT WHEN condition ';'
           { action(exit_when); }
   | EXIT ';'
           { action(exit); }
;

null
   : NULL ';'
;


/*---------------------------------------------------
 * Supporting productions
 *
 */

lvalue
   : VAR_IDENTIFIER param_list
           { action(lvalue); }
;

discrete_range
   : expression DOTDOT expression
           { action(discrete_range); }
;

param_list
   : '(' expression param_list_tail ')'
           { action(expr_param_list); }
   |
;

param_list_tail
   : ',' expression param_list_tail
           { action(expr_param_tail); }
   |
;


any_identifier
   : UNDEF_IDENTIFIER
   | VAR_IDENTIFIER
   | UNIT_IDENTIFIER
;



/*---------------------------------------------------
 * Expressions
 *
 */

/* constant-value expressions */
static_expression
   : expression
;


/* boolean-valued expressions */
condition
   : expression
;


/* any-valued expressions */
expression
   : NOT expression
           { action(unot_exp); }
   | expression AND expression
           { action(exp_and_exp); }
   | expression OR expression
           { action(exp_or_exp); }
   | expression '=' expression
           { action(exp_eq_exp); }
   | expression NE expression
           { action(exp_ne_exp); }
   | expression '>' expression
           { action(exp_gt_exp); }
   | expression GE expression
           { action(exp_ge_exp); }
   | expression '<' expression
          { action(exp_lt_exp); }
   | expression LE expression
          { action(exp_le_exp); }
   | expression '+' expression
          { action(exp_add_exp); }
   | expression '-' expression
          { action(exp_sub_exp); }
   | expression '*' expression
          { action(exp_mul_exp); }
   | expression '/' expression
          { action(exp_div_exp); }
   | expression '&' expression
          { action(exp_cat_exp); }

   | '-' expression          %prec UMINUS
           { action(uminus_exp); }
   | '(' expression ')'
           { action(subexpression); }

   | literal
   | function_call
   | variable_deref
;

literal
   : LIT_NUMBER
           { action(lit_number); }
   | LIT_STRING
           { action(lit_string); }
   | TRUE
           { yyval.integer = 1; }
   | FALSE
           { yyval.integer = 0; }
;

variable_deref
   : lvalue
           { action(variable_deref); }
;

function_call
   : UNIT_IDENTIFIER param_list
           { action(function_call); }
;

%%

/* lexical analysis is in a3lex.c */
