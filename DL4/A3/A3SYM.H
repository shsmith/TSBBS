
/*---------------------------------------------------
 * A3sym - Symbol table definitions for A3 language
 *
 * S.H.Smith, 15-Sep-86
 *
 */


/* legal symbol table entry types */
typedef enum { undefined_sym,
               unit_sym,
               var_sym
} symbol_type;


/* a symbol table entry */
typedef struct symbol {
   char *id;                /* symbol id string */
   symbol_type type;        /* symbol table entry type */
   struct symbol *next;     /* link to next symbol table entry */
} symbol;


#ifdef a3sym
   symbol *symbol_table = 0;
#else
   extern symbol *symbol_table;
#endif

symbol *lookup_symbol();
