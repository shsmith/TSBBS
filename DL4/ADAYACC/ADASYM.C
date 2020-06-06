
/*
 * Symbol table maintenance for the A3 language
 *
 * S.H.Smith, 16-Sep-86
 *
 */

#define ADASYM
#include "adasym.h"
#include "ada.h"

extern void *malloc();
extern char *strdup();


/*
 * lookup a symbol and return a pointer to the entry.
 * make a new entry when needed, default code is IDENTIFIER.
 */
symbol *lookup_symbol(name)
char *name;
{
   symbol *sym;

   /* look for symbol in the table */
   for (sym=symbol_table; sym != 0; sym=sym->next) {
      if (!strcmpl(sym->id,name))
         return sym;
   }

   /* symbol not in table - make a new entry */
   sym = (symbol *)malloc(sizeof(symbol));
   sym->id = strdup(name);
   sym->code = IDENTIFIER;

   /* link the new entry into the head of the table */
   sym->next = symbol_table;
   symbol_table = sym;

   /* return pointer to the new entry */
   return sym;
}


/*
 * set the code of a symbol to the specified value.
 * makes new entries when needed.
 */
symbol *set_symbol(name,code)
char *name;
int code;
{
   symbol *sym = lookup_symbol(name);
   sym->code = code;
   return sym;
}


/*
 * dump contents of symbol table
 */

dump_symbol_table()
{
   symbol *sym;

   printf("\nSymbol table:\n");
   for (sym=symbol_table; sym != 0; sym=sym->next)
      printf("   %-20s %s\n",sym->id,describe(sym->code));
}


/*
 * initialize the symbol table and install default symbols
 *
 */

initialize_symbol_table()
{
   set_symbol("integer",TYPE_name);
   set_symbol("boolean",TYPE_name);
   set_symbol("float",TYPE_name);
}

