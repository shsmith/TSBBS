
(*
 * outline - a simple "outline" oriented document generator
 *
 * outtree.inc -  this module contains all of the procedures
 *                for generating and formatting "trees".
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)

type
   long_string = string[255];       {maximum length of an output line}

type
   connector_codes =
     (horizontal, tee, top, cross, middle, bottom, vertical, spaces, empty);

const
   connector_strings: array [connector_codes] of string[3] =
     ('ÄÄÄ', 'ÄÂÄ', ' ÚÄ', 'ÄÅÄ', ' ÃÄ', ' ÀÄ', ' ³ ', '   ', '');




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
   connector := connector_strings [code];
end;



function subsec_count(sec: section_ptr): integer;
var
   i,j:  integer;
   n:    integer;
   t:    section_ptr;

begin
   n := 0;

   with sec^ do
      for i := 1 to max_subsects do
      begin
         if subsect[i] = nil then
            for j := i to max_subsects-1 do
               subsect[j] := subsect[j+1]
         else

         if subsect[i]^.title = '' then
            for j := i to max_subsects-1 do
               subsect[j] := subsect[j+1];

         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               n := n + 1;
      end;

   subsec_count := n;
end;



procedure print_section_tree
                   (var fd:     textfile;          {output file}
                    sec:        section_ptr;       {sec to output}
                    beforetab:  long_string;       {tabs if before header}
                    titletab:   long_string;       {tabs for header}
                    aftertab:   long_string;       {tabs if after header}
                    before:     connector_codes;   {next tab before header}
                    header:     connector_codes;   {next tab for header}
                    after:      connector_codes);  {next tab after header}

var
   i:             integer;
   titlesub:      integer;
   count:         integer;

begin
   if keypressed then
      exit;

   with sec^ do
   begin
      beforetab := beforetab + connector (before) + blanks (length (title));
      titletab  := titletab  + connector (header ) + title;
      aftertab  := aftertab  + connector (after ) + blanks (length (title));

      count := subsec_count(sec);

      case count of
         0:     {terminal sec with header only}
            writeln (fd, titletab);

         1:     {sec with 1 subnode}
            print_section_tree (fd, subsect[1], beforetab, titletab, aftertab,
                                    spaces, horizontal, spaces);

         2:     {sec with 2 subnodes}
            begin
               print_section_tree (fd, subsect[1], beforetab, titletab, aftertab,
                                       spaces, tee, vertical);

               print_section_tree (fd, subsect[2], aftertab, aftertab, aftertab,
                                       vertical, bottom, spaces);
            end;

         else   {sec with n subnodes}
            begin
               titlesub := (count+1) div 2;

               writeln (fd, beforetab);    {blank line before
                                            new large section}

               print_section_tree (fd, subsect[1], beforetab, beforetab, beforetab,
                                       spaces, top, vertical);

               for i := 2 to titlesub-1 do
                  print_section_tree (fd, subsect[i], beforetab, beforetab, beforetab,
                                          vertical, middle, vertical);

               print_section_tree (fd, subsect[titlesub], beforetab, titletab, aftertab,
                                              vertical, cross, vertical);

               for i := titlesub+1 to count-1 do
                  print_section_tree (fd, subsect[i], aftertab, aftertab, aftertab,
                                          vertical, middle, vertical);

               print_section_tree (fd, subsect[count], aftertab, aftertab, aftertab,
                                           vertical, bottom, spaces);
            end;

       end;

   end;

end;


