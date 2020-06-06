
/*
 * Symbol table maintenance for the A3 language
 *
 * S.H.Smith, 16-Sep-86
 *
 */

#define a3sym
#include "a3sym.h"

extern void *malloc();
extern char *strdup();


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
   sym->type = undefined_sym;

   /* link the new entry into the head of the table */
   sym->next = symbol_table;
   symbol_table = sym;

   /* return pointer to the new entry */
   return sym;
}

