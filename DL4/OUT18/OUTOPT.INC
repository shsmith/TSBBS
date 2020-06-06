

(*
 * outline - a simple "outline" oriented document generator
 *
 * outopt.inc - this file contains the handlers for the
 *              option selection screen.
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *)

const

   default_print_width = 80;  {the length of print lines}

   default_max_text =  10;    {the number of text lines in a section}

   default_max_subsects = 10; {max number of subsections in a section.
                               note that max_text+max_subsects should
                               be less than 21. otherwise the screen
                               formatting won't work}

   default_pagelen =   60;    {max number of lines to print on a page}

   default_minlines =  20;    {minimum number of lines on a page before
                               a new page can be started}

   default_indentation = 4;   {amount of indentation for each level of
                               subsection nesting in printouts}

   default_right_margin = 77; {right margin for reformatted print file
                               outputs}

   default_underline_character = 'Ä';
                              {characters printed to underline section
                               titles in detail format printouts}

   default_paragraph_reformat = true;
                              {should paragraphs of text be reformatted?}

   default_break_into_pages = true;
                              {should output be divided into pages?}


begin

   show display

   set initial field

   repeat

      CONVERT TO STRING

      EDIT STRING

      CONVERT TO BIN

      SELECT NEXT FIELD

   until exit key

end;
