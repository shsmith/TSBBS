
/*
 * lexical analysis for the ADA language
 *
 * This scanner always looks 1 character ahead in the input
 * stream.  On return, 'scanc' holds the next (unused) input character.
 *
 * S.H.Smith, 21-Sep-86
 *
 */

#include <ctype.h>
#include <stdio.h>

#include "adasym.h"
#include "adatree.h"
#include "ada.h"


extern char *strdup();

tree yylval;             /* yacc lex token values */

int listsrc = 1;         /* listing source code? */
int traceact = 1;        /* trace actions? */
extern int yydebug;      /* trace parser actions? */

#define TOKLEN 80        /* longest token/literal length */
char toktext[TOKLEN];    /* the text of the token */
char *tokptr;

int  tokcode;            /* the token code */

int  scanc = ' ';        /* the current scan character */

int lineno = 1;          /* the current input line number */

int error_count = 0;     /* count of errors reported by yyerror */


struct token_table {     /* a token/keyword table entry */
   char *text;
   int code;
};


/* table of all keywords and associated token codes */
struct token_table *tok, keywords[] = {
   {"ABORT",               ABORT},
   {"ABS",                 ABS},
   {"ACCEPT",              ACCEPT},
   {"ACCESS",              ACCESS},
   {"ALL",                 ALL},
   {"AND",                 AND},
   {"ARRAY",               ARRAY},
   {"ASSOC",               ASSOC},
   {"AT",                  AT},
   {"BEGIN",               BEGIN},
   {"BODY",                BODY},
   {"BOX",                 BOX},
   {"CASE",                CASE},
   {"CONSTANT",            CONSTANT},
   {"DECLARE",             DECLARE},
   {"DELAY",               DELAY},
   {"DELTA",               DELTA},
   {"DIGITS",              DIGITS},
   {"DO",                  DO},
   {"ELSE",                ELSE},
   {"ELSIF",               ELSIF},
   {"END",                 END},
   {"ENTRY",               ENTRY},
   {"EXCEPTION",           EXCEPTION},
   {"EXIT",                EXIT},
   {"FOR",                 FOR},
   {"FUNCTION",            FUNCTION},
   {"GENERIC",             GENERIC},
   {"GOTO",                GOTO},
   {"IF",                  IF},
   {"IN",                  IN},
   {"IS",                  IS},
   {"LIMITED",             LIMITED},
   {"LOOP",                LOOP},
   {"MOD",                 MOD},
   {"NEW",                 NEW},
   {"NOT",                 NOT},
   {"NULL",                NULL},
   {"OF",                  OF},
   {"OR",                  OR},
   {"OTHERS",              OTHERS},
   {"OUT",                 OUT},
   {"PACKAGE",             PACKAGE},
   {"PRAGMA",              PRAGMA},
   {"PRIVATE",             PRIVATE},
   {"PROCEDURE",           PROCEDURE},
   {"RAISE",               RAISE},
   {"RANGE",               RANGE},
   {"RECORD",              RECORD},
   {"REM",                 REM},
   {"RENAMES",             RENAMES},
   {"RETURN",              RETURN},
   {"REVERSE",             REVERSE},
   {"SELECT",              SELECT},
   {"SEPARATE",            SEPARATE},
   {"SUBTYPE",             SUBTYPE},
   {"TASK",                TASK},
   {"TERMINATE",           TERMINATE},
   {"THEN",                THEN},
   {"TYPE",                TYPE},
   {"USE",                 USE},
   {"WHEN",                WHEN},
   {"WHILE",               WHILE},
   {"WITH",                WITH},
   {"XOR",                 XOR},
   {"BECOMES",             BECOMES},
   {0,                     0} };



/* table of non-keyword descriptions and associated token codes */
struct token_table tokens[] = {
   {"<ARGUMENT_identifier>",    ARGUMENT_identifier},
   {"<BLOCK_name>",             BLOCK_name},
   {"<CHARACTER_LITERAL>",      CHARACTER_LITERAL},
   {"<COMPONENT_name>",         COMPONENT_name},
   {"<DISCRIMINANT_name>",      DISCRIMINANT_name},
   {"<DOTDOT>",                 DOTDOT},
   {"<END_OF_FILE>",            0},
   {"<ENTRY_name>",             ENTRY_name},
   {"<EXCEPTION_name>",         EXCEPTION_name},
   {"<FUNCTION_name>",          FUNCTION_name},
   {"<GE>",                     GE},
   {"<GENERIC_FUNCTION_name>",  GENERIC_FUNCTION_name},
   {"<GENERIC_PACKAGE_name>",   GENERIC_PACKAGE_name},
   {"<GENERIC_PROCEDURE_name>", GENERIC_PROCEDURE_name},
   {"<IDENTIFIER>",             IDENTIFIER},
   {"<LABEL_name>",             LABEL_name},
   {"<LE>",                     LE},
   {"<LOOP_name>",              LOOP_name},
   {"<NE>",                     NE},
   {"<NUMERIC_LITERAL>",        NUMERIC_LITERAL},
   {"<OBJECT_name>",            OBJECT_name},
   {"<OPERATOR_STRING_LIT>",    OPERATOR_STRING_LITERAL},
   {"<PACKAGE_name>",           PACKAGE_name},
   {"<PARAMETER_name>",         PARAMETER_name},
   {"<PARENT_UNIT_name>",       PARENT_UNIT_name},
   {"<PRIME>",                  PRIME},
   {"<PROCEDURE_name>",         PROCEDURE_name},
   {"<STARSTAR>",               STARSTAR},
   {"<STRING_LITERAL>",         STRING_LITERAL},
   {"<SUBPROGRAM_name>",        SUBPROGRAM_name},
   {"<SUBTYPE_name>",           SUBTYPE_name},
   {"<TASK_name>",              TASK_name},
   {"<TYPE_name>",              TYPE_name},
   {"<UNIT_name>",              UNIT_name},
   {"<VARIABLE_name>",          VARIABLE_name},
   {0,                          0} } ;



/* lexical analyzer called by yacc parser */
yylex()
{
   adalex();

/* if (traceact)
      printf("<code=%d text='%s'>\n",tokcode,toktext);
*/

   return tokcode;
}

adalex()
{
   extern double atof();
   tokptr = toktext;
   *tokptr = 0;                   /* initially token text is null */

   yylval.value.d = 0;            /* default no lexval */


   /* skip over whitespace */
   while (isspace(scanc))
      scanc = nextchar();


   /* check for and skip over comments */
   if (scanc == '-') {
      recognize(scanc);

      if (scanc == '-') {         /* comment seen - skip to end of line */
         while (scanc != '\n')
            scanc = nextchar();

         return adalex();         /* use tail recursion to scan next token */
      }
      else return tokcode;        /* otherwise it's just a dash */
   }


   /* recognize literal numbers */
   if (isdigit(scanc)) {
      while (isdigit(scanc) || (scanc == '.'))
         recognize(NUMERIC_LITERAL);

      yylval.value.d = atof(toktext);
      return NUMERIC_LITERAL;
   }


   /* recognize literal strings */
   if (scanc == '"') {
      recognize(STRING_LITERAL);

      while (scanc != '"')
         recognize(STRING_LITERAL);

      recognize(STRING_LITERAL);
      yylval.value.s = strdup(toktext);
      return STRING_LITERAL;
   }


   /* recognize keywords and identifiers */
   if (isalpha(scanc)) {
      while (isalnum(scanc) || (scanc == '_'))
         recognize(scanc);

      /* consult keyword table */
      for (tok = keywords; tok->text; tok++)
         if (!strcmpl(toktext,tok->text))
            return tokcode = tok->code;

      /* if not a keyword, must be an identifier */
      /* determine what kind by consulting the symbol table */

      yylval.sym = lookup_symbol(toktext);

      return tokcode = yylval.sym->code;
   }


   /* macro to recognize a twin character keyword */
   #define twin(c1,c2,code) \
      if (scanc == c1) { \
         recognize(scanc); \
         if (scanc == c2) return recognize(code); \
         else return tokcode; \
      }


   /* recognize any special twin character sequences */
   twin('.','.',DOTDOT);
   twin('>','=',GE);
   twin('<','=',LE);
   twin('/','=',NE);
   twin(':','=',BECOMES);
   twin('=','>',ASSOC);
   twin('*','*',STARSTAR);


   /* special case for end-of-file (Yacc requires this) */
   if (scanc == EOF)
      return tokcode = 0;


   /* all other characters are recognized as themselves */
   return recognize(scanc);
}



/*
 * consume the current character and recognize current token as
 * the specified token type code
 */
recognize(code)
int code;
{
   *tokptr++ = scanc;      /* append current scan char to token text */
   *tokptr = 0;

   scanc = nextchar();     /* consume the character and get next one */

   tokcode = code;         /* set and return the recognized token code */
   return code;
}


/*
 * get next input character
 * echo to screen (when testing)
 */
nextchar()
{
   int c;
   c = getchar();
   if (c == '\n') lineno++;
   if (listsrc) putchar(c);
   return c;
}



/*
 * return a description of a given token code
 *
 */
char *describe(code)
int code;
{
   /* consult token description table */
   for (tok = tokens; tok->text; tok++)
      if (tok->code == code)
         return tok->text;

   /* consult keyword table */
   for (tok = keywords; tok->text; tok++)
      if (tok->code == code)
         return "keyword";

   /* not in tables; must be a special character */
   return "special";
}



/*
 * yacc parse error handler
 */
yyerror(msg,p1,p2)
char *msg;
{
   /* print an error message banner */
   ++error_count;

   printf("\n** ");
   printf(msg,p1,p2);

   printf(", line %d, text '%s', token %d, %s\n",
              lineno,toktext,tokcode,describe(tokcode));
}


/*
 * top-level main program
 *
 */
main(argc,argv)
int argc;
char *argv[];
{
   yydebug = 1;   /* enable parser debugging */

   if (argc == 2) {
      if (freopen(argv[1],"r",stdin) == 0) {
         printf("can't open input: %s\n",argv[1]);
         exit(1);
      }
   }
   else {
      printf("usage: parse_ada SOURCEFILE [>LISTFILE]\n");
      exit(1);
   }

   initialize_symbol_table();

   if (yyparse()) {
      printf("Parse failed.\n");
      dump_symbol_table();
      exit(1);
   }
   else {
      printf("Parse completed.  %d errors detected.\n",error_count);
      exit(error_count);
   }
}


