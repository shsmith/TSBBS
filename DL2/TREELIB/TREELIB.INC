
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * treelib.inc - Utility library to build, sort and output trees
 *               in a real visual "tree" format. (3-1-89)
 *
 *)

const
   maxsubs = 150;                  {maximum number of subnodes for
                                    any single node in the tree}

   ascii_tree: boolean = false;    {set to true for ASCII only tree
                                    output; full IBM character set is
                                    used by default}


type
   long_string = string[255];       {maximum length of an output line}

   subnode_index = 0..maxsubs;

   name_string = string[40];        {maximum length of the name of a single
                                    tree node}

   subnode_table = ^subnode_tabletype;
   node_ptr = ^node_rec;
   subnode_tabletype = array[1..maxsubs] of node_ptr;

   node_rec = record
      name:   name_string;          {the name of the node}

      count:  subnode_index;        {the count of subnodes}

      subs:   subnode_table;        {pointer to subnode table, if any}
   end;


type
   connector_codes =
     (horizontal, tee, top, cross, middle, bottom, vertical, spaces, empty);

const
   connector_strings: array [boolean, connector_codes] of string[3] =
     (('ÄÄÄ', 'ÄÂÄ', ' ÚÄ', 'ÄÅÄ', ' ÃÄ', ' ÀÄ', ' ³ ', '   ', ''),

      ('---', '-+-', ' +-', '-|-', ' |-', ' +-', ' | ', '   ', ''));



(*
 * new_node - create and return a new empty node
 *
 * note:  the subnode table node^.subs must be allocated
 *        by the user before any subnodes can be
 *        created.  this was done to eliminate the
 *        space needed by the subnode table on the
 *        terminal nodes in the tree.
 *
 *)

function new_node: node_ptr;
var
   node: node_ptr;
   i:    subnode_index;

begin
   new (node);
   node^.name := '';
   node^.count := 0;
   node^.subs := nil;
   new_node := node;
end;



(*
 * dispose_tree - dispose of a tree
 *
 *)

procedure dispose_tree(var node:  node_ptr);
var
   i:      subnode_index;

begin
   if node <> nil then
   begin
      with node^ do
         for i := 1 to count do
            dispose_tree(subs^[i]);

      if node^.subs <> nil then
         dispose(node^.subs);

      dispose(node);
      node := nil;
   end;
end;



(*
 * sort_node - sort the entries in a node
 *
 *)

procedure sort_node(node: node_ptr);
var
   i:        subnode_index;
   swapped:  boolean;
   temp:     node_ptr;

begin
   with node^ do
      repeat
         swapped := false;

         for i := 1 to count-1 do
            if subs^[i]^.name > subs^[i+1]^.name then
            begin
               temp := subs^[i];
               subs^[i] := subs^[i+1];
               subs^[i+1] := temp;
               swapped := true;
            end;

      until swapped = false;
end;



function blanks (len: integer): long_string;
var
   str: long_string;

begin
   str := '';

   while length (str) < len do
      str := str + ' ';

   blanks := str;
end;



function connector (code: connector_codes): long_string;
begin
   connector := connector_strings [ascii_tree, code];
end;



procedure put_node (var fd:     text;              {output file}
                    node:       node_ptr;          {node to output}
                    beforetab:  long_string;       {tabs if before title}
                    titletab:   long_string;       {tabs for title}
                    aftertab:   long_string;       {tabs if after title}
                    before:     connector_codes;   {next tab before title}
                    title:      connector_codes;   {next tab for title}
                    after:      connector_codes);  {next tab after title}

var
   i:             subnode_index;
   titlesub:      subnode_index;

begin
   with node^ do
   begin
      beforetab := beforetab + connector (before) + blanks (length (name));
      titletab  := titletab  + connector (title ) + name;
      aftertab  := aftertab  + connector (after ) + blanks (length (name));

      case count of
         0:     {terminal node with title only}
            writeln (fd, titletab);

         1:     {node with 1 subnode}
            put_node (fd, subs^[1], beforetab, titletab, aftertab,
                                    spaces, horizontal, spaces);

         2:     {node with 2 subnodes}
            begin
               put_node (fd, subs^[1], beforetab, titletab, aftertab,
                                       spaces, tee, vertical);

               put_node (fd, subs^[2], aftertab, aftertab, aftertab,
                                       vertical, bottom, spaces);
            end;

         else   {node with n subnodes}
            begin
               titlesub := (count+1) div 2;

               writeln (fd, beforetab);

               put_node (fd, subs^[1], beforetab, beforetab, beforetab,
                                       spaces, top, vertical);

               for i := 2 to titlesub-1 do
                  put_node (fd, subs^[i], beforetab, beforetab, beforetab,
                                          vertical, middle, vertical);

               put_node (fd, subs^[titlesub], beforetab, titletab, aftertab,
                                              vertical, cross, vertical);

               for i := titlesub+1 to count-1 do
                  put_node (fd, subs^[i], aftertab, aftertab, aftertab,
                                          vertical, middle, vertical);

               put_node (fd, subs^[count], aftertab, aftertab, aftertab,
                                           vertical, bottom, spaces);
            end;
      end;

   end;

end;



(*
 * put_tree - format a tree for output and write it to a file
 *
 *)

procedure put_tree (var fd:  text;
                    root:    node_ptr);
begin
   put_node (fd, root, '', '', '', empty, empty, empty);
   flush (fd);
end;


