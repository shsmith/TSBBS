
/*
 * Created by Unix/CSD YACC for MSDOS (SS-9/86) from "a3.Y"
 */


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

typedef union  {
   int integer;   /* literal integers */

   char *text;    /* pointer to literal strings */

   symbol *sym;   /* pointer to symbol table entry */

   int none;      /* no value */
} YYSTYPE;

#define AND 257
#define ASSOC 258
#define BECOMES 259
#define BEGIN 260
#define BOOLEAN 261
#define BYTE 262
#define CALL 263
#define CASE 264
#define CHARACTER 265
#define DEBUG 266
#define DOTDOT 267
#define ELSE 268
#define ELSIF 269
#define END 270
#define EXIT 271
#define FALSE 272
#define FLOAT 273
#define FOR 274
#define FUNCTION 275
#define GE 276
#define IF 277
#define IN 278
#define INTEGER 279
#define IS 280
#define LE 281
#define LIST 282
#define LIT_NUMBER 283
#define LIT_STRING 284
#define LOOP 285
#define NE 286
#define NOT 287
#define NULL 288
#define OF 289
#define OFF 290
#define ON 291
#define OR 292
#define OTHERS 293
#define OUT 294
#define PACKAGE 295
#define PRAGMA 296
#define PROCEDURE 297
#define RETURN 298
#define REVERSE 299
#define STRING 300
#define SUBTYPE 301
#define THEN 302
#define TO 303
#define TRACE 304
#define TRUE 305
#define TYPE 306
#define UNDEF_IDENTIFIER 307
#define UNIT_IDENTIFIER 308
#define USE 309
#define VAR_IDENTIFIER 310
#define WHEN 311
#define WHILE 312
#define WITH 313
#define UMINUS 314
#define yyclearin yychar = -1
#define yyerrok   yyerrflag = 0

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
extern YYSTYPE yylval;
YYSTYPE yyval;
#define YYERRCODE 256


/* lexical analysis is in a3lex.c */

short yyexca[] = {    /* exception table */
   -1,    1,
    0,   -1,
   -2,    0,
};

#define YYNPROD 126

/* optimized parser tables */

#define YYLAST 593

short yyact[] = {     /* action table */
  112,   89,  149,  222,  100,  111,  112,   27,   28,   97,
  178,  111,  177,   72,   14,   60,   98,   59,   31,   95,
  112,   39,   90,   30,   16,  111,  251,  179,   73,  207,
   96,  225,  266,   99,    8,   10,   13,  112,   63,   62,
   14,   10,  111,   93,   19,  208,  261,  245,   12,  243,
  123,  231,   11,   92,  112,  100,  143,   94,  219,  111,
   20,   10,   13,  122,  184,   32,   42,  185,   17,  263,
  250,   41,   40,  239,   12,  240,  262,  258,  253,  234,
  230,  186,   21,  134,  132,   23,   25,  166,   24,  227,
  246,  164,  162,  215,  163,  166,  165,   75,  226,  164,
  162,   55,  163,  139,  165,  248,  247,  214,  137,  160,
  156,  158,  220,  108,  129,  140,  213,  160,  156,  158,
  166,  268,  101,  203,  164,  162,  267,  163,  166,  165,
   71,  265,  164,  162,  259,  163,  255,  165,  252,  233,
  223,  175,  160,  156,  158,  211,  210,  205,   48,   70,
  160,  156,  158,  166,  204,  181,  152,  164,  162,  150,
  163,  166,  165,  136,  128,  164,  162,   69,  163,   67,
  165,   66,   65,   64,  183,  160,  156,  158,   50,   61,
   57,   26,   58,  160,  156,  158,  166,  164,  130,  141,
  164,  162,  165,  163,   29,  165,  131,  166,   49,  121,
   52,  164,  162,  144,  163,  228,  165,  173,  160,  156,
  158,  125,  124,   44,  115,    1,  151,  126,   15,   51,
  114,  104,  107,   88,    5,  103,    5,   37,    7,  113,
    7,   68,  119,  106,   76,  236,  170,  221,  119,  102,
   87,   86,   38,  116,  117,  171,  172,  110,   85,  116,
  117,   53,  119,  110,  148,   91,   38,  188,   38,  237,
  105,  176,   84,  116,  117,  118,   83,  110,  120,  119,
  100,  118,   82,   81,  120,   91,  100,   91,  174,  218,
  116,  117,   33,   80,  110,  118,  119,   79,  120,   18,
  100,  209,   78,   77,  206,  145,   91,  116,  117,  217,
  127,  110,  118,   36,   34,  120,  154,  100,   35,    4,
  133,    4,  135,   74,  154,   54,    6,   56,    3,  118,
    2,    9,  120,   43,  100,  159,   22,    0,    0,  224,
  161,  146,  232,  159,  235,  157,  241,  242,  161,  154,
    0,  155,    0,  157,   45,   46,   47,  154,    0,  155,
    0,    0,    0,    0,    0,    0,    0,    0,  159,  264,
    0,    0,    0,  161,  109,    0,  159,    0,  157,    0,
  187,  161,  154,    0,  155,    0,  157,    0,    0,   91,
  154,    0,  155,    0,   91,    0,    0,    0,    0,    0,
  153,  159,    0,    0,    0,    0,  161,    0,    0,  159,
    0,  157,    0,    0,  161,  154,    0,  155,    0,  157,
    0,    0,    0,    0,  212,  155,    0,    0,    0,  216,
    0,    0,    0,    0,  159,    0,    0,    0,    0,  161,
    0,   91,    0,    0,  157,    0,    0,    0,    0,   91,
  155,    0,    0,    0,    0,   91,    0,   91,   91,    0,
    0,   91,    0,    0,    0,  138,    0,    0,  142,  138,
    0,    0,  147,    0,    0,    0,  244,    0,    0,    0,
    0,    0,    0,    0,  249,  167,  168,  169,    0,    0,
  254,    0,  256,  257,    0,    0,  260,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,  180,    0,  182,    0,    0,    0,
    0,    0,    0,  138,    0,    0,    0,    0,  189,  190,
  191,  192,  193,  194,  195,  196,  197,  198,  199,  200,
  201,  202,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
  229,    0,    0,    0,    0,    0,    0,  238,    0,    0,
    0,    0,  138 };

short yypact[] = {     /* next state table */
 -261,-1000, -261,-1000,-1000,-1000,-1000,-1000, -283,    9,
 -222, -300, -300, -284, -289,-1000, -215,-1000, -235,  173,
  173,  173,  173,-1000,-1000,-1000,  154,-1000,-1000,  154,
  160,  160, -235, -159, -235,-1000,-1000,-1000,-1000,  121,
  124, -290, -292,  120, -252,  114,  113,  112,  110, -300,
  108,-1000, -294, -270, -163, -255,-1000,-1000,  -40, -217,
 -230,-1000,  171,  170,-1000,-1000,-1000,-1000,  154,-1000,
  105,  144,-1000,  -40, -186, -255, -187, -255,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,  104,
   14, -156,  149,   -3,   14, -306, -255,   14,  -57,  100,
  149,   97,-1000,-1000,-1000,-1000,-1000,-1000,-1000,  123,
   14,   14,   14,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
  149,-1000,  -40,  -40,-1000,-1000,-1000,  166, -294,   83,
 -294,-1000, -295,-1000, -297,-1000,-1000, -275,  148,   14,
   96,   14,  115,-1000, -221, -211, -189,   90,   14,-1000,
-1000,-1000,-1000,   14,   14,   14,   14,   14,   14,   14,
   14,   14,   14,   14,   14,   14,   14,  159,-1000,   82,
-1000,   95,   88,-1000,-1000, -249,  144,   87,   86, -255,
   57,-1000,   49,-1000, -255,  -20, -227, -308,   81,  148,
  159,  159,  159,  159,  159,  159,  159,  159,  145,  145,
-1000,-1000,  145,-1000,-1000,-1000,  -40, -263,-1000,-1000,
-1000,-1000, -180,-1000,  164,   14, -190, -234,   14,   80,
 -191, -308,  -34,-1000,-1000,-1000, -195,   14,-1000,   49,
 -236, -255, -238,-1000, -174,-1000, -152, -153,  148, -255,
 -207, -276,-1000,   79, -192, -255,   77, -255, -255, -193,
   75, -255,-1000, -239, -194,-1000,-1000,-1000, -208,-1000,
 -180,   72, -253,   67,-1000,-1000,   62,-1000,-1000 };

short yypgo[] = {     /* goto table */
    0,  323,  326,  321,  215,  223,  320,  318,  308,  316,
  227,  282,  313,  234,  181,  148,  304,  303,  122,  113,
  219,  149,  300,  130,  114,  294,  293,  292,  287,  283,
  273,  272,  266,  262,  248,  241,  240,  108,   98,  199,
  364,  115,  112,  237,  235,  107,  229,  220,  214 };

short yyr1[] = {     /* lev productions */
    0,    5,    5,    5,    5,    1,    1,    4,    4,    6,
    6,    6,    6,    6,    7,   12,   12,    9,   10,   14,
   14,   15,   15,   11,   11,   16,   16,   16,   16,   16,
   17,   17,   17,   18,   18,   18,   18,   18,   18,   18,
    8,    8,    3,    3,   20,   20,   21,   23,   24,   24,
   22,   22,   25,   25,   25,   25,   13,   13,   26,   26,
   26,   26,   26,   26,   26,   26,   26,   26,   26,   26,
   27,   27,   38,   38,   28,   29,   30,   30,   31,   32,
   32,   33,   34,   42,   42,   43,   43,   35,   35,   36,
   39,   19,   41,   41,   45,   45,    2,    2,    2,   44,
   37,   40,   40,   40,   40,   40,   40,   40,   40,   40,
   40,   40,   40,   40,   40,   40,   40,   40,   40,   40,
   46,   46,   46,   46,   48,   47 };

short yyr2[] = {     /* production pointers */
    0,    4,    4,    4,    4,    3,    3,    2,    0,    1,
    1,    1,    1,    1,    8,    2,    0,    4,    4,    1,
    1,    3,    0,    2,    0,    1,    1,    1,    1,    2,
    4,    5,    5,    1,    1,    1,    1,    1,    1,    1,
    2,    8,    3,    5,    4,    0,    5,    1,    3,    0,
    2,    0,    2,    1,    1,    0,    2,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    1,    1,    2,
   10,    8,    5,    0,    4,    3,    3,    2,    7,    9,
   10,    5,    7,    2,    0,    4,    4,    4,    2,    2,
    2,    3,    4,    0,    3,    0,    1,    1,    1,    1,
    1,    2,    3,    3,    3,    3,    3,    3,    3,    3,
    3,    3,    3,    3,    3,    2,    3,    1,    1,    1,
    1,    1,    1,    1,    1,    2 };

short yychk[] = {     /* shift/token table */
-1000,   -4,   -6,   -7,   -8,   -5,   -9,  -10,  295,   -3,
  296,  313,  309,  297,  275,   -4,  307,   59,  280,  266,
  282,  304,   -2,  307,  310,  308,  -14,  307,  308,  -14,
  307,  307,  280,  -11,  -16,   -8,  -17,  -10,   -5,  256,
  307,  306,  301,   -1,   40,   -1,   -1,   -1,  -15,   44,
  -15,  -20,   40,  -20,  -11,  260,  -11,   59,   58,  307,
  307,   59,  291,  290,   59,   59,   59,   59,  -14,   59,
  -21,  -23,  307,  298,  -12,  260,  -13,  -26,  -27,  -28,
  -29,  -30,  -31,  -32,  -33,  -34,  -35,  -36,   -5,  256,
  277,  -39,  308,  298,  312,  274,  285,  264,  271,  288,
  310,  -18,  279,  265,  261,  300,  273,  262,  -19,  -40,
  287,   45,   40,  -46,  -47,  -48,  283,  284,  305,  272,
  308,  -39,  280,  280,   41,   41,  -15,  -22,   59,  -24,
   44,  -18,  270,  -13,  270,  -13,   59,  -37,  -40,  259,
  -41,   40,  -40,   59,  -37,  -39,  -13,  -40,  311,   59,
   59,  -41,   59,  267,  257,  292,   61,  286,   62,  276,
   60,  281,   43,   45,   42,   47,   38,  -40,  -40,  -40,
  -41,  -18,  -18,   41,  -21,   58,  -23,  307,  307,  302,
  -40,   59,  -40,   59,  285,  278,  270,  280,  -37,  -40,
  -40,  -40,  -40,  -40,  -40,  -40,  -40,  -40,  -40,  -40,
  -40,  -40,  -40,   41,   59,   59,  -25,  278,  294,  -24,
   59,   59,  -13,   59,  -45,   44,  -13,  -19,  299,  285,
  -42,  -43,  311,   59,  -18,  294,  -38,  269,   41,  -40,
  270,  285,  -19,   59,  270,  -42,  -44,  293,  -40,  268,
  270,  -37,  -45,  285,  -13,  285,  264,  258,  258,  -13,
  277,  302,   59,  270,  -13,   59,  -13,  -13,  270,   59,
  -13,  285,  270,  277,  -38,   59,  285,   59,   59 };

short yydef[] = {     /* default action table */
    8,   -2,    8,    9,   10,   11,   12,   13,    0,    0,
    0,    0,    0,    0,    0,    7,    0,   40,   24,    0,
    0,    0,    0,   96,   97,   98,   22,   19,   20,   22,
   45,   45,   24,    0,   24,   25,   26,   27,   28,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   42,    0,    0,   16,    0,   23,   29,    0,    0,
    0,    1,    0,    0,    2,    3,    4,   17,   22,   18,
   51,   49,   47,    0,    0,    0,    0,   57,   58,   59,
   60,   61,   62,   63,   64,   65,   66,   67,   68,    0,
    0,    0,   93,    0,    0,    0,    0,    0,    0,    0,
   93,    0,   33,   34,   35,   36,   37,   38,   39,    0,
    0,    0,    0,  117,  118,  119,  120,  121,  122,  123,
   93,  124,    0,    0,    5,    6,   21,    0,    0,    0,
    0,   43,    0,   15,    0,   56,   69,    0,  100,    0,
    0,    0,    0,   77,    0,    0,    0,    0,    0,   88,
   89,   90,   30,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  101,  115,    0,
  125,    0,    0,   44,   50,   55,   49,    0,    0,    0,
    0,   75,   95,   76,    0,    0,    0,   84,    0,   91,
  102,  103,  104,  105,  106,  107,  108,  109,  110,  111,
  112,  113,  114,  116,   31,   32,    0,   53,   54,   48,
   14,   41,   73,   74,    0,    0,    0,    0,    0,    0,
    0,   84,    0,   87,   46,   52,    0,    0,   92,   95,
    0,    0,    0,   81,    0,   83,    0,    0,   99,    0,
    0,    0,   94,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   78,    0,    0,   82,   85,   86,    0,   71,
   73,    0,    0,    0,   72,   79,    0,   70,   80 };

/* Parser for Yacc output  */

#define YYFLAG   -1000
#define YYERROR  goto yyerrlab
#define YYACCEPT return(0)
#define YYABORT  return(1)

int yydebug = 0;          /* 1 for debugging */
YYSTYPE yyv[YYMAXDEPTH];  /* where the values are stored */
int yychar = -1;          /* current input token number */
int yynerrs = 0;          /* number of errors */
short yyerrflag = 0;      /* error recovery flag */

yyparse()
{
   short yys[YYMAXDEPTH];
   short yyj, yym;
   register YYSTYPE *yypvt;
   register short yystate, *yyps, yyn;
   register YYSTYPE *yypv;
   register short *yyxi;

   yystate = 0;
   yychar = -1;
   yynerrs = 0;
   yyerrflag = 0;
   yyps= &yys[-1];
   yypv= &yyv[-1];

yystack:    /* put a state and value onto the stack */
   if( yydebug  ) printf( "<state %d, char %d>\n", yystate, yychar );
   if( ++yyps> &yys[YYMAXDEPTH] ) {
      yyerror( "yacc stack overflow" );
      return(1);
   }
   *yyps = yystate;
   ++yypv;
   *yypv = yyval;

yynewstate:
   yyn = yypact[yystate];
   if( yyn<= YYFLAG ) goto yydefault; /* simple state */
   if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
   if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

   if( yychk[ yyn=yyact[ yyn ] ] == yychar ) {  /* valid shift */
      yychar = -1;
      yyval = yylval;
      yystate = yyn;
      if( yyerrflag > 0 ) --yyerrflag;
      goto yystack;
   }

yydefault:  /* default state action */
   if( (yyn=yydef[yystate]) == -2 ) {
      if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;

      /* look through exception table */
      for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 )
         ; /* VOID */

      for(yyxi+=2; *yyxi >= 0; yyxi+=2)
         if( *yyxi == yychar ) break;

      if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
   }

   if( yyn == 0 ) {   /* error ... attempt to resume parsing */
      switch( yyerrflag ) {
      case 0:   /* brand new error */
         yyerror( "syntax error" );

yyerrlab:
         ++yynerrs;

      case 1:
      case 2: /* incompletely recovered error ... try again */

         /* find a state where "error" is a legal shift action */
         yyerrflag = 3;
         while ( yyps >= yys ) {
            yyn = yypact[*yyps] + YYERRCODE;
            if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ) {
               yystate = yyact[yyn];  /* simulate a shift of "error" */
               goto yystack;
            }
            yyn = yypact[*yyps];

            /* the current yyps has no shift onn "error", pop stack */
            if( yydebug )
               printf( "<error recovery pops state %d, uncovers %d>\n",
                              *yyps, yyps[-1] );
            --yyps;
            --yypv;
         }

         /* there is no state on the stack with an error shift ... abort */
yyabort:
         return(1);

      case 3:  /* no shift yet; clobber input char */
         if( yydebug ) printf( "<error recovery discards char %d>\n", yychar );
         if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */

         yychar = -1;
         goto yynewstate;   /* try again in the same state */
      }
   }

   /* reduction by production yyn */
   if( yydebug ) printf("<reduce %d>\n",yyn);
   yyps -= yyr2[yyn];
   yypvt = yypv;
   yypv -= yyr2[yyn];
   yyval = yypv[1];
   yym=yyn;

   /* consult goto table to find next state */
   yyn = yyr1[yyn];
   yyj = yypgo[yyn] + *yyps + 1;
   if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn )
      yystate = yyact[yypgo[yyn]];

   /* actions for recognized productions */
   switch(yym) {
      
   case 1: { yydebug=yypvt[-1].integer; } break;

   case 2: { listsrc=yypvt[-1].integer; } break;

   case 3: { traceact=yypvt[-1].integer; } break;

   case 4: { yyerror("unknown pragma"); } break;

   case 5: { yyval.integer = 1; } break;

   case 6: { yyval.integer = 0; } break;

   case 14: {
              if (yypvt[-6].sym != yypvt[-1].sym)
                 yyerror("identifier mismatch: <%s> <%s>",yypvt[-6].sym->id,yypvt[-1].sym->id);
              else {
                 yypvt[-6].sym->type = unit_sym;
                 action(package_declaration);
              }
            } break;

   case 29: {
              action(declaration_error_recoverey);
              yyerrok;
            } break;

   case 30: {
              ACTION(printf("{define variable %s}\n",yypvt[-3].sym->id));
              yypvt[-3].sym->type = var_sym;
            } break;

   case 31: {
              ACTION(printf("{define type %s}\n",yypvt[-3].sym->id));
              yypvt[-3].sym->type = var_sym;
            } break;

   case 32: {
              ACTION(printf("{define subtype %s}\n",yypvt[-3].sym->id));
              yypvt[-3].sym->type = var_sym;
            } break;

   case 40: { action(forward_procedure_decl); } break;

   case 41: { if (yypvt[-7].sym != yypvt[-1].sym)
                 yyerror("identifier mismatch: <%s> <%s>",yypvt[-7].sym->id,yypvt[-1].sym->id);
              else {
                 yypvt[-7].sym->type = unit_sym;
                 action(procedure_decl);
              }
            } break;

   case 42: { yyval.sym = yypvt[-1].sym; } break;

   case 43: { yyval.sym = yypvt[-3].sym; } break;

   case 44: { action(formal_param_list); } break;

   case 46: { action(formal_param); } break;

   case 48: { action(more_formal_param_idents); } break;

   case 50: { action(more_formal_params); } break;

   case 69: {
             action(statement_error_recoverey);
             yyerrok;
           } break;

   case 70: { action(if_then_else); } break;

   case 71: { action(if_then); } break;

   case 72: { action(elsif); } break;

   case 74: { action(assignment); } break;

   case 75: { action(call); } break;

   case 76: { action(return_expr); } break;

   case 77: { action(return); } break;

   case 78: { action(while_loop); } break;

   case 79: { action(for_loop); } break;

   case 80: { action(for_loop_reverse); } break;

   case 81: { action(loop); } break;

   case 82: { action(case_is); } break;

   case 85: { action(when); } break;

   case 86: { action(when_others); } break;

   case 87: { action(exit_when); } break;

   case 88: { action(exit); } break;

   case 90: { action(lvalue); } break;

   case 91: { action(discrete_range); } break;

   case 92: { action(expr_param_list); } break;

   case 94: { action(expr_param_tail); } break;

   case 101: { action(unot_exp); } break;

   case 102: { action(exp_and_exp); } break;

   case 103: { action(exp_or_exp); } break;

   case 104: { action(exp_eq_exp); } break;

   case 105: { action(exp_ne_exp); } break;

   case 106: { action(exp_gt_exp); } break;

   case 107: { action(exp_ge_exp); } break;

   case 108: { action(exp_lt_exp); } break;

   case 109: { action(exp_le_exp); } break;

   case 110: { action(exp_add_exp); } break;

   case 111: { action(exp_sub_exp); } break;

   case 112: { action(exp_mul_exp); } break;

   case 113: { action(exp_div_exp); } break;

   case 114: { action(exp_cat_exp); } break;

   case 115: { action(uminus_exp); } break;

   case 116: { action(subexpression); } break;

   case 120: { action(lit_number); } break;

   case 121: { action(lit_string); } break;

   case 122: { yyval.integer = 1; } break;

   case 123: { yyval.integer = 0; } break;

   case 124: { action(variable_deref); } break;

   case 125: { action(function_call); } break;

   }
   goto yystack;  /* stack new state and value */
}
