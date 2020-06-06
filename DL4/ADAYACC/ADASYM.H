
/*
 * adasym - Symbol table definitions for ADA language
 *
 * S.H.Smith, 15-Sep-86
 *
 */


/* legal symbol table entry types */

/* a symbol table entry */
typedef struct symbol {
   char *id;                /* symbol id string */
   int code;                /* symbol table entry type/token code */
   struct symbol *next;     /* link to next symbol table entry */
} symbol;


#ifdef ADASYM
   symbol *symbol_table = 0;
#else
   extern symbol *symbol_table;
#endif

symbol *lookup_symbol();
