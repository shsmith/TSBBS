

(*****************************************************************************
 *
 *  Subsystem:   symtable - Symbol Table Management subsystem
 *
 *
 *)


(*       The routines Find and Declare manage the symbol
 *       table.  The table is organized as a linked list in which
 *       FirstSym always points to the most recently added entry.  The
 *       Next field points to the next-youngest entry, so that
 *       following the chain of Nexts ultimately leads to the first
 *       entry.  *)


(*       Find is passed an identifier string and returns either a
 *       pointer to the corresponding symbol-table entry or nil if
 *       the identifier does not exist.  It traverses the chain of
 *       entries beginning with Table, and so the first matching
 *       entry will be found.  *)

 function find (id:        identstr;
                var table: symptr): symptr;
 var
   thissym:      symptr;

 begin
   thissym := table;          { start with the latest entry }

   while ((id <> thissym^.name) and
                              { loop if no match and...  }
    (thissym <> nil)) do      { we're not at the end of list }

      thissym := thissym^.next;
                              { get next record }

   find := thissym;           { a match if there is one, or nil }
 end;



(*      Declare installs entries in a symbol table.
 *      ID is the name of the Identifier, as given
 *       in TK.Name.  *)

 function declare (id:         identstr;
                   symtype:    symtypes;
                   var table:  symptr): symptr;
 var
   thissym:      symptr;

 begin
   thissym := find (id,table);  { See if it already exists }

   if thissym <> nil then
      error('duplicate declaration: '+id);
                              { Call error & halt if it does }

   new(thissym);              { Create a new record }
   thissym^.next := table;    { Swap pointers to put the...  }
   table := thissym;          { ...new record first in list }

   thissym^.name := id;
   thissym^.symtype := symtype;
   thissym^.class := nil;

   declare := thissym;
 end;


