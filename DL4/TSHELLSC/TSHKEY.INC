
const tshkey_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Keyword table manipulation 1.1'#0;
#log Keyword table manipulation 1.1



(*------------------------------------------
 *
 * dispose_list
 *    dispose all entries in a linked replacement list
 *
 *)

procedure dispose_list(var last: replace_ptr);
var
   trash:  replace_ptr;

begin
   while last <> nil do
   begin
      trash := last;
      last := last^.prior;
      freemem(trash^.line,LEN(trash^.line^)+1);
      dispose(trash);
   end;
end;


(*------------------------------------------
 *
 * lookup_keyword
 *    check to see if a keyword has been defined.
 *    return 0 if not defined
 *
 *)

function lookup_keyword(var keys: anystring): integer;
var
   entry:      integer;

begin

   entry := key_hash(keys);         {calculate the 'calc key' for this
                                     keyword.  scan forward to find an
                                     empty slot.  if we find one, then the
                                     key was not defined.}
   while true do
      with define_table[entry] do

      if key = '' then               {ran off the end?  not in table}
      begin
         lookup_keyword := 0;        {not found}
         exit;
      end
      else

      if key = keys then
      begin
         lookup_keyword := entry;    {found at entry}
         exit;
      end
      else

      if entry = max_define then    {wrap around checking overflows}
         entry := 1
      else
         INCR(entry);

end;


(*------------------------------------------
 *
 * new_keyword
 *    enter a new keyword into the define table.
 *    return the index into the table for the new keyword.
 *
 *)

function new_keyword(var key: anystring): integer;
var
   entry:  integer;

begin

   if define_count >= (max_define-1) then
   begin
      error('Too many defines: '+key);
      exit;
   end;

   entry := key_hash(key);              {calculate the 'calc key' for this
                                         keyword.  scan forward to find an
                                         empty slot.  this makes all overflows
                                         live next to each other.}
   while define_table[entry].key > ' ' do
      if entry = max_define then
         entry := 1
      else
         INCR(entry);

   INCR(define_count);              {make a new entry in the define table}

   new_keyword := entry;           {return index to new entry}

end;


(*------------------------------------------
 *
 * link_line
 *    link a line into a replacement list
 *
 *)

procedure link_line(var last:  replace_ptr;
                    var pline: repstring);
var
   tail:    replace_ptr;

begin
   new(tail);
   tail^.prior := last;     {insert new link into head of the list}

   last := tail;
   with last^ do
   begin
      getmem(line,LEN(pline)+1);
      COPY_STR(line^, pline);       {store the replacement}
   end;

end;



(*------------------------------------------
 *
 * link_replacement
 *    link a replacement line into a replacement list
 *
 *)

procedure link_replacement(entry:     integer;
                           var pline: repstring);
var
   tail:    replace_ptr;

begin

   {indicate that there is no current entry if the line ends without
    a continuation character.  if there is a trailing "\", then the
    current entry will remain active and remaining lines will be
    linked into the current replacement table entry}

   if pline[LEN(pline)] = '\' then
   begin
      current_entry := entry;    {keep current entry number}
      DECR(pline[0]);            {and remove the trailing "\"}
   end
   else
      current_entry := 0;        {otherwise no current entry}


   {insert new link into head of the list}

   link_line(define_table[entry].last, pline);
end;


(*------------------------------------------
 *
 * preproc_define
 *    enter a new macro definition into the define table
 *    returns the define table entry used
 *
 *)

procedure preproc_define(word: anystring);
var
   posit:   integer;
   keys:    anystring;
   entry:   integer;

begin
   line_txt := '';
   if not ifstack[if_level].compiling then
      exit;

   strip_leading_spaces(word); {remove spaces before the keyword}

   posit := pos(' ',word);     {look for the end of the keyword}

   if posit > 0 then           {if there is a value then isolate it}
   begin
      keys := copy(word,1,posit-1);
      word := copy(word,posit+1,255);
      strip_leading_spaces(word);
   end
   else

   begin                       {otherwise this keyword has an empty
                                replacement string}
      keys := word;
      word := '';
   end;

   strip_leading_spaces(keys);     {remove leading spaces from the keyword}
   strip_trailing_spaces(keys);    {remove trailing spaces and comments}

   entry := lookup_keyword(keys);
   if entry = 0 then
      entry := new_keyword(keys); {locate the proper location for
                                   this keyword and make the new
                                   table entry}

   {create the define table entry and enter the first line into
    the linked replacement line list}
   with define_table[entry] do
   begin
      COPY_STR(key, keys);                {store the keyword string}

      if last <> nil then                 {free previous replacement list}
         dispose_list(last);

      link_replacement(entry,word);        {and the first replacement line}
   end;

#ifdef DEBUGGING
   writeln('define, key=',keys,' rep="',word,'" entry=',entry);
#endif

end;


(*------------------------------------------
 *
 * preproc_undef
 *    delete the definition of a macro
 *
 *)

procedure preproc_undef(keys: anystring);
var
   entry:   integer;

begin
   TRUNC(line_txt);
   if not ifstack[if_level].compiling then
      exit;

   strip_leading_spaces(keys);     {remove leading spaces from the keyword}
   strip_trailing_spaces(keys);    {remove trailing spaces and comments}
   entry := lookup_keyword(keys);

   if entry <> 0 then
   with define_table[entry] do
   begin
      key := ' ';              {make key invalid to prevent maches}
      dispose_list(last);      {and dispose the replacement list}
      DECR(define_count);
   end;
end;



(*------------------------------------------
 *
 * initialize_table
 *    clear all previous definitions from define table
 *    special case initialize on first run
 *
 *)

procedure initialize_table;
var
   entry:  integer;

const
   first_time: boolean = true;

begin


   {initialize the define table}
   for entry := 1 to max_define do
   with define_table[entry] do
   begin
      TRUNC(key);
      if first_time then
         last := nil;
      dispose_list(last);
   end;

   {clean up the pending replaced text stack}
   if first_time then
      repstack := nil;
   dispose_list(repstack);
   current_entry := 0;
   replevel := 0;

   first_time := false;
   define_count := 0;
end;

