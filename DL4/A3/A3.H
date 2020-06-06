
/*
 * Created by Unix/CSD YACC for MSDOS (SS-9/86) from "a3.Y"
 */


typedef union  {
   int integer;   /* literal integers */

   char *text;    /* pointer to literal strings */

   symbol *sym;   /* pointer to symbol table entry */

   int none;      /* no value */
} YYSTYPE;
extern YYSTYPE yylval;
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
