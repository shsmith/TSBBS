

(*****************************************************************************
 *
 *  Subsystem:   symtable - Symbol Table Management subsystem
 *
 * S.H.Smith
 *
 *)


(*       The three routines Find, Declare and Blot manage the symbol
 *       table.  The table is organized as a linked list in which
 *       FirstSym always points to the most recently added entry.  The
 *       Next field points to the next-youngest entry, so that
 *       following the chain of Nexts ultimately leads to the first
 *       entry, which is always the declaration of the program
 *       header.  Because all variables are global, the
 *       symbol table has a fixed, predictable structure: the program
 *       declaration is followed by variable declarations and then by
 *       procedure declarations.  *)


(*       Find is passed an identifier string and returns either a
 *       pointer to the corresponding symbol-table entry or nil if
 *       the identifier does not exist.  It traverses the chain of
 *       entries beginning with FirstSym, and so the first matching
 *       entry will be found.  *)

 function find (id:           identstr): symptr;
 var
   thissym:      symptr;

 begin
   thissym := firstsym;       { start with the latest entry }

   while ((id <> thissym^.ident) and
                              { loop if no match and...  }
    (thissym <> nil)) do      { we're not at the end of list }

      thissym := thissym^.next;
                              { get next record }

   find := thissym;           { a match if there is one, or nil }
 end;



(*      Declare installs both variable names and procedure names in
 *       the symbol table.  ID is the name of the Identifier, as given
 *       in TK.Name; CL is either "Proc" or "Variable"; Kind is "IntSym"
 *       or "BoolSym" for variables, "Null" for procedures.  *)

 function declare (id:           identstr;
                   cl:           symclass;
                   kind:         tokcode): symptr;
 var
   thissym:      symptr;
   numstr:       string [4];

 begin
   thissym := find (id);      { See if it already exists }

   if thissym <> nil then
      error(dupdec);          { Call error & halt if it does }

   new(thissym);              { Create a new record }
   thissym^.next := firstsym; { Swap pointers to put the...  }
   firstsym := thissym;       { ...new record first in list }

   with firstsym^ do
   begin                         { make a new symbol number and create
                                   a formal name for this symbol that
                                   is composed of part of the identifier
                                   with a unique number on the end.  this
                                   allows local symbols to be defined as
                                   statics in the object code. }
      symbolnum := symbolnum + 1;
      str(symbolnum:0,numstr);
      name := copy(id,1,6-length(numstr)) + numstr;

      ident := id;               { Plug in the other values passed...  }
      class := cl;               { ...as arguments...  }
      vartype := kind;
      scope := currentscope;     { ...and a value from a global }
   end;

   declare := firstsym;
 end;


(*      Blot is called when the "end" of a block is reached and removes
 *       from the symbol table all names whose scope is confined to that
 *       block.  The global variable CurrentScope is initialized to zero
 *       and incremented each time ParseBlock is called.  Blot decrements
 *       CurrentScope and unlinks from the symbol table any entry whose
 *       Scope field is numerically greater than CurrentScope.  *)

 procedure blot;
 var
   trashsym:     symptr;

 begin
   currentscope := currentscope - 1;
                              { back to scope of next outer block}


   while firstsym^.scope > currentscope do
                              { erase entries for closed block }
   begin
      trashsym := firstsym;      { Give the pointer an alias }
      firstsym := firstsym^.next;
                                 { Unlink the record }
      dispose(trashsym);         { Free the allocated memory }
   end;

 end;

