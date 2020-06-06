
/*
 * adatree.c - Parse tree manipulation functions
 *
 * S.H.Smith, 23-Sep-86
 *
 */

#include "adasym.h"
#include "adatree.h"

/* construct a new parse tree node and return
   a pointer to it */

tree *make_tree( code,sym,children,trees )
node_types code;
symbol *sym;
int children;
tree *trees[MAXCHILD];
{
   extern tree *malloc();
   int i;
   tree *node;

   /* allocate and setup the node */
   node = malloc( sizeof(tree) );
   node->code = code;
   node->sym = sym;
   node->children = children;

   /* copy all of the specified children trees */
   for (i=0; i<children; i++)
      node->child[i] = trees[i];

   /* give back a pointer to the new tree node */
   return node;
}


