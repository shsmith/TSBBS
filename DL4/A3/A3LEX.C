
/*
 * lexical analysis for the A3 language
 *
 * This scanner always looks 1 character ahead in the input
 * stream.  On return, 'scanc' holds the next (unused) input character.
 *
 * S.H.Smith, 15-Sep-86
 *
 */

#include <ctype.h>
#include <stdio.h>
#include "a3sym.h"
#include "a3.h"


extern char *strdup();

YYSTYPE yylval;          /* yacc lex token values */

int listsrc = 0;         /* listing source code? */
int traceact = 0;        /* trace actions? */
extern int yydebug;      /* trace parser actions? */

#define TOKLEN 80        /* longest token/literal length */
char toktext[TOKLEN];    /* the text of the token */
char *tokptr;

int  tokcode;            /* the token code */

int  scanc = ' ';        /* the current scan character */

int lineno = 1;          /* the current input line number */

int error_count = 0;     /* count of errors reported by yyerror */


struct token_table {
   char *text;
   int code;
};


/* table of all keywords and associated token codes */
struct token_table *tok, keywords[] = {
      {"AND",        AND},
      {"BEGIN",      BEGIN},
      {"BOOLEAN",    BOOLEAN},
      {"BYTE",       BYTE},
      {"CALL",       CALL},
      {"CASE",       CASE},
      {"CHARACTER",  CHARACTER},
      {"DEBUG",      DEBUG},
      {"DECLARE",    FOR},
      {"ELSE",       ELSE},
      {"ELSIF",      ELSIF},
      {"END",        END},
      {"EXIT",       EXIT},
      {"FALSE",      FALSE},
      {"FLOAT",      FLOAT},
      {"FOR",        FOR},
      {"FUNCTION",   FUNCTION},
      {"IF",         IF},
      {"IN",         IN},
      {"INTEGER",    INTEGER},
      {"IS",         IS},
      {"LIST",       LIST},
      {"LOOP",       LOOP},
      {"NOT",        NOT},
      {"NULL",       NULL},
      {"OF",         OF},
      {"OFF",        OFF},
      {"ON",         ON},
      {"OR",         OR},
      {"OUT",        OUT},
      {"OTHERS",     OTHERS},
      {"PACKAGE",    PACKAGE},
      {"PRAGMA",     PRAGMA},
      {"PROCEDURE",  PROCEDURE},
      {"RETURN",     RETURN},
      {"REVERSE",    REVERSE},
      {"STRING",     STRING},
      {"SUBTYPE",    SUBTYPE},
      {"THEN",       THEN},
      {"TO",         TO},
      {"TRACE",      TRACE},
      {"TRUE",       TRUE},
      {"TYPE",       TYPE},
      {"USE",        USE},
      {"WHEN",       WHEN},
      {"WHILE",      WHILE},
      {"WITH",       WITH},
      {0,            0} };


/* table of non-keyword descriptions and associated token codes */
struct token_table tokens[] = {
      {"LIT_NUMBER",           LIT_NUMBER},
      {"LIT_STRING",           LIT_STRING},
      {"UNDEF_IDENTIFIER",     UNDEF_IDENTIFIER},
      {"VAR_IDENTIFIER",       VAR_IDENTIFIER},
      {"UNIT_IDENTIFIER",      UNIT_IDENTIFIER},
      {".LE.",                 LE},
      {".GE.",                 GE},
      {".NE.",                 NE},
      {"BECOMES",              BECOMES},
      {"ASSOC",                ASSOC},
      {"DOTDOT",               DOTDOT},
      {"END OF FILE",          0},
      {0,                      0} } ;



/* lexical analyzer called by yacc parser */
yylex()
{
   int tok = a3lex();
   if (yydebug) printf("<token=%d text='%s'>\n",tok,toktext);
   return tok;
}

a3lex()
{
   tokptr = toktext;
   *tokptr = 0;                   /* initially token text is null */

   yylval.integer = 0;            /* default no lexval */
   yylval.text = toktext;         /* default text value is token text */


   /* skip over whitespace */
   while (isspace(scanc))
      scanc = nextchar();


   /* check for and skip over comments */
   if (scanc == '-') {
      recognize(scanc);

      if (scanc == '-') {         /* comment seen - skip to end of line */
         while (scanc != '\n')
            scanc = nextchar();

         return a3lex();          /* use tail recursion to scan next token */
      }
      else return tokcode;        /* otherwise it's just a dash */
   }


   /* recognize literal numbers */
   if (isdigit(scanc)) {
      while (isdigit(scanc) || (scanc == '.'))
         recognize(LIT_NUMBER);

      yylval.integer = atoi(toktext);
      return LIT_NUMBER;
   }


   /* recognize literal strings */
   if (scanc == '"') {
      recognize(LIT_STRING);

      while (scanc != '"')
         recognize(LIT_STRING);

      recognize(LIT_STRING);
      yylval.text = strdup(toktext);
      return LIT_STRING;
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

      switch (yylval.sym->type) {
         case undefined_sym:  return tokcode = UNDEF_IDENTIFIER;
         case var_sym:        return tokcode = VAR_IDENTIFIER;
         case unit_sym:       return tokcode = UNIT_IDENTIFIER;

         default:             yyerror("bad symbol type %d",yylval.sym->type);
                              return tokcode = 0;
      }
   }


   /* macro to recognize a twin character keyword */
   #define twin(c1,c2,code) \
      if (scanc == c1) { \
         recognize(scanc); \
         if (scanc == c2) return recognize(code); \
         else return tokcode; \
      }


   /* recognize any special twin character sequences */
   twin('<','=',LE);
   twin('>','=',GE);
   twin('/','=',NE);
   twin(':','=',BECOMES);
   twin('=','>',ASSOC);
   twin('.','.',DOTDOT);


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
 * yacc parse error handler
 */
yyerror(msg,p1,p2)
char *msg;
{
   /* print an error message banner */
   ++error_count;
   printf("\n** ");
   printf(msg,p1,p2);
   printf(", line %d, text '%s', ",lineno,toktext);

   /* consult token description table */
   for (tok = tokens; tok->text; tok++)
      if (tok->code == tokcode)
         return printf("%s\n",tok->text);

   /* consult keyword table */
   for (tok = keywords; tok->text; tok++)
      if (tok->code == tokcode)
         return printf("keyword %s\n",tok->text);

   /* not in table; just print the code number */
   printf("token %d\n",tokcode);
}



/*
 * top-level main program
 *
 */
main(argc,argv)
int argc;
char *argv[];
{
   if (argc == 2) {
      if (freopen(argv[1],"r",stdin) == 0) {
         printf("can't open input: %s\n",argv[1]);
         exit(1);
      }
   }
   else {
      printf("usage: a3 SOURCEFILE [>LISTFILE]\n");
      exit(1);
   }

   if (yyparse()) {
      printf("Parse failed.\n");
      exit(1);
   }
   else {
      printf("Parse completed.  %d errors detected.\n",error_count);
      exit(error_count);
   }
}


