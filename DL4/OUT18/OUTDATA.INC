
(*
 * outline - a simple "outline" oriented document generator
 *
 * outdata.inc - this module contains the data declarations
 *               of the outline processor.
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *)


const
   anystring_length = 68;         {the length of lines.  this has to fit on
                                   the screen.}


   print_width = 150;             {the length of print lines}


   max_text = 10;                 {the number of text lines in a section}

   max_subsects = 10;             {max number of subsections in a section.
                                   note that max_text+max_subsects should
                                   be less than 21.  otherwise the screen
                                   formatting won't work}


   start_underline = #27#45#1;

   stop_underline = #27#45#0;     {printer codes to control underlined print}



type

   textfile = text[512];

   anystring = string[anystring_length];

   linestring = string[print_width];

   textarray = array[1..max_text]      {text description of a section}
                 of anystring;

   textptr = ^textarray;


   section_ptr = ^section;
   section = record

      title:          anystring;              {title of a section}

      estimate:       real;                   {estimate (time, value, etc) for
                                               this section and all subs}

      onpage:         integer;                {the page number on which this
                                               section was last printed}

      text:           textptr;                {text description of a section}

      subsect:        array[1..max_subsects]  {list of subsections}
                      of section_ptr;

      refcount:       integer;                {count of references to
                                               this section record.  this
                                               is used when there are multiple
                                               copies or pointers to a single
                                               section record}
   end;


   print_formats = (detail_format,
                    outline_format,
                    contents_format,
                    tree_format,
                    index_format,
                    no_format);



var
   emptytext: textptr;       {common text array when all text is blank}

   document:  section_ptr;   {pointer into main section of document}

   marksec:   section_ptr;   {pointer into section with a marker}
   marksub:   integer;       {subsection number of marker}

   delsec:    section_ptr;   {holding the most recently deleted section}

   docfile:   anystring;     {filename of current document}

   prnfile:   anystring;     {filename of current print output}
   prnline:   integer;       {the current print file line number}

   lineout:   linestring;    {print output line buffer used in reformatting}

   nullfd:    textfile;      {a null output file for linecounting}

   olf_format: integer;      {OLF file format number; used in loading}

   page_number:        integer;   {the current output page number}

   saved:              boolean;   {has the outline been saved since the
                                   last change was made?}


   pagelen:        integer;       {max number of lines to print on a page}

   minlines:       integer;       {minimum number of lines on a page before
                                   a new page can be started}

   indentation:    integer;       {amount of indentation for each level
                                   of subsection nesting in printouts}

   indent_mult:    integer;       {indentation multiplier; used when
                                   printing compressed print}

   right_margin:   integer;       {right margin for reformatted print
                                   file outputs}

   underline_titles:   boolean;   {should section titles be underlined?}

   paragraph_reformat: boolean;   {should paragraphs of text be reformatted?}

   break_into_pages:   boolean;   {should output be divided into pages?}

   section_numbering:  boolean;   {should a dewey-decimal section number
                                   be added to each section on printouts?}


   justify:            boolean;   {right justify text?}

