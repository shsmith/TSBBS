
(*
 * indexlib.inc - library for document indexing
 *
 * Author: S.H.Smith, 11-Apr-86
 *
 *)


(*
 * Package specification
 *
 *)

{----------------------------------------------------
 --                                                --
 --            Index package data                  --
 --                                                --
 ----------------------------------------------------}

type phrase_ptr = ^phrase_string;
     phrase_string = string[45];    {longest phrase that can be indexed}

type page_number = 0..255;          {legal page numbers}

const max_pages = 20;               {number of pages on which a phrase
                                     can be used}

type page_list_index = 0..max_pages;
type page_list = array [page_list_index] of page_number;

type index_node = ^index_node_rec;
     index_node_rec = record
        word:    phrase_ptr;        {pointer to the word or phrase}
        count:   page_list_index;   {number of pages where word is used}
        pages:   page_list;         {list of pages where word is used}
        higher:  index_node;        {all higher sort order words}
        lower:   index_node;        {all lower sort order words}
     end;


var index_root: index_node;         {the root of the index}

var longest_word: integer;          {the longest word in the index}



{----------------------------------------------------
 --                                                --
 --        Index creation and disposal             --
 --                                                --
 ----------------------------------------------------}

procedure init_index;
   {-- initialize index for operation}
   forward;

procedure dispose_index;
   {-- dispose of the current index data and release the memory
    -- used by it}
   forward;



{----------------------------------------------------
 --                                                --
 --        Index building and output               --
 --                                                --
 ----------------------------------------------------}

procedure index_word(word: phrase_string; on_page: page_number);
   {-- associate a word or phrase with a page number}
   forward;

procedure output_index(var tofile: textfile);
   {-- prepare and output the index to a text file}
   forward;



(****************************************************
 *
 * End of package specification
 *
 * Start of package body
 *
 *)


{----------------------------------------------------
 --                                                --
 --        Private internal procedures             --
 --                                                --
 ----------------------------------------------------}

function string_save (word: phrase_string): phrase_ptr;
   {-- allocate space for a phrase on the heap and
    -- return a pointer to it.  allocates only enough
    -- space as is needed.}
var
   buf:  phrase_ptr;
begin

   if length(word) > longest_word then
      longest_word := length(word);

   getmem(buf,length(word)+1);
   buf^ := word;
   string_save := buf;
end;



{----------------------------------------------------
 --                                                --
 --        Index creation and disposal             --
 --                                                --
 ----------------------------------------------------}

procedure init_index;
   {-- initialize index for operation}
begin
   new(index_root);

   with index_root^ do
   begin
      word := string_save('Root');
      count := 0;
      pages[0] := 0;
      higher := nil;
      lower := nil;
   end;

   longest_word := 0;
end;


procedure dispose_index;
   {-- dispose of the current index data and release the memory
    -- used by it}

   procedure dispose_node(var node: index_node);
      {-- dispose of an index node and all of the
       -- subordinate nodes; sets the node to nil}
   begin
      if node <> nil then
      begin
         dispose_node(node^.higher);
         dispose_node(node^.lower);
         freemem(node^.word,length(node^.word^)+1);
         dispose(node);
         node := nil;
      end;
   end;

begin
   dispose_node(index_root);
end;



{----------------------------------------------------
 --                                                --
 --        Index building                          --
 --                                                --
 ----------------------------------------------------}

procedure index_word {(word: phrase_string; on_page: page_number)};
   {-- associate a word or phrase with a page number}

   procedure index_node (var node: index_node);
      {-- search for and update the proper node}

   begin
      if node = nil then           {create a new node, if needed}
      begin
         new(node);
         node^.word := string_save(word);
         node^.count := 1;
         node^.pages[1] := on_page;
         node^.higher := nil;
         node^.lower := nil;
      end
      else

      if word = node^.word^ then   {if the phrase has been found, update its
                                    page list with on_page and exit}
      begin
         if (node^.pages[node^.count] <> on_page) then
            if node^.count < max_pages then
               node^.count := node^.count + 1
            else
               on_page := 255;     {too many page references}

         node^.pages[node^.count] := on_page;
      end
      else

      if word > node^.word^ then
         index_node(node^.higher)    {search up the higher branch}
      else
         index_node(node^.lower);    {search down the lower branch}
   end;

begin
   word[1] := upcase(word[1]);    {force first word of all index entries
                                   to be upper case}

   index_node(index_root);        {search for and update a node, starting
                                   at the root of the index}
end;




{----------------------------------------------------
 --                                                --
 --        Index output formatting                 --
 --                                                --
 ----------------------------------------------------}

procedure output_index {(var tofile: textfile)};
   {-- prepare and output the index to a text file}

var
   outpos:  integer;
   pletter: char;


   procedure output_node (node: index_node);
      {-- format and output a node in the index; recursively
       -- outputs all higher and lower branching nodes}

      procedure output_number(n: page_number);
         {-- output a single page number and adjust output position}
      begin
         case n of
            0..9:   outpos := outpos + 1;
            10..99: outpos := outpos + 2;
            else    outpos := outpos + 3;
         end;
         write(tofile, n);
      end;

      procedure output_node_page_list;
         {-- output the page list for a single node}
      var
         i:       page_list_index;
         prev:    page_list_index;

      begin
         prev := 0;
         i := 1;

         with node^ do
         while i <= count do
         begin
            prev := i;         {locate page number ranges}

            while (i < count) and (pages[i]+1 = pages[i+1]) do
               i := i + 1;

            if prev = i then       {output single page number}
               output_number(pages[i])
            else
            begin                  {output a range of page numbers}
               output_number(pages[prev]);
               write(tofile,'-');
               outpos := outpos + 1;
               output_number(pages[i]);
            end;

            if i < node^.count then
            begin                 {insert , delimiter if needed}
               write(tofile,', ');
               outpos := outpos + 2;

               if (outpos > 70) then
               begin              {start a new line if needed}
                  writeln(tofile);
                  write(tofile,'':longest_word+8);
                  outpos := longest_word+8;
               end;
            end;

            i := i + 1;
         end;

         writeln(tofile);
      end;


   begin   {output_node}

      if node <> nil then
      begin
         output_node(node^.lower);      {output all lower words}

         if node^.count > 0 then
         begin
            if pletter <> node^.word^[1] then
            begin                       {start new section for each letter}
               pletter := node^.word^[1];
               writeln(tofile);
               writeln(tofile,pletter);
            end;

            write(tofile,'   ',node^.word^);
            outpos := 3 + length(node^.word^);

            for outpos := outpos+1 to longest_word+8 do
               if odd(outpos) then      {output the word and ...s}
                  write(tofile,'.')
               else
                  write(tofile,' ');

            output_node_page_list;
         end;

         output_node(node^.higher);     {output all higher words}
      end;
   end;

begin
   pletter := #0;
   if odd(longest_word) then
      longest_word := longest_word + 1;

   output_node(index_root);
end;


