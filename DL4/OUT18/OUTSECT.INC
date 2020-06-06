

(*
 * outline - a simple "outline" oriented document generator
 *
 * outsect.inc - this module contains the procedures
 *               for printing document sections in detail,
 *               contents and outline formats.
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)


function lines_in_section(var sec: section_ptr;
                          indent:  integer;
                          format:  print_formats): integer;
                                       {determine the number of
                                        lines needed to output
                                        a section to the printer.
                                        this is used to decide
                                        when to generate a formfeed}
var
   i:       integer;
   lines:   integer;
   subcnt:  integer;
   txtcnt:  integer;

begin

   with sec^ do
   begin
      subcnt := 0;
      for i := 1 to max_subsects do    {count the defined subsections}
         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               subcnt := subcnt + 1;

      txtcnt := 0;
      for i := 1 to max_text do        {count the lines with text}
         if text^[i] <> '' then
            txtcnt := txtcnt + 1;

      if format = detail_format then
      begin
         if (txtcnt > 0) or (subcnt > 0) then
            lines := 3
         else
            lines := 2;

         print_text_lines(sec, nullfd, indent+indentation, format, lines);
      end

      else
         lines := 2;


      for i := 1 to max_subsects do
         if (lines < pagelen) and (subsect[i] <> nil) then
            if subsect[i]^.title <> '' then
               lines := lines + lines_in_section(subsect[i], indent+5, format);

   end;

   lines_in_section := lines;
end;



procedure print_section(var sec: section_ptr;
                        var fd:  textfile;
                        indent:  integer;
                        format:  print_formats;
                        dewey:   anystring);   {write a section of the
                                                outline to an output file;
                                                recursively calls itself
                                                for subsections.  keeps
                                                track of formfeeds on
                                                printer output}
var
   i:       integer;
   subcnt:  integer;
   txtcnt:  integer;
   len:     integer;

begin

   if keypressed then
      exit;

   if section_numbering = false then
      dewey := '';

   if format <> index_format then
   begin
      if break_into_pages and (prnline > minlines) then
         if (prnline + lines_in_section(sec, indent, format)) > pagelen then
         begin
            write(fd, ^L);      {generate a formfeed if this section will
                                 not fit completely on the current page}
            prnline := 1;
            pflush(fd);
         end;

      check_page_header(fd,format,sec);

      writeln(fd);
      prnline := prnline + 1;
      pflush(fd);
   end;

   with sec^ do
   begin
      subcnt := 0;
      for i := 1 to max_subsects do    {count the defined subsections}
         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               subcnt := subcnt + 1;

      txtcnt := 0;
      for i := 1 to max_text do        {count the lines with text}
         if text^[i] <> '' then
            txtcnt := txtcnt + 1;

      if format = detail_format then
      begin
         if (txtcnt > 0) or (subcnt > 0) then
            write(fd, '':indent,
                   start_underline,
                   dewey,' ',title,
                   stop_underline)        {output the title}
         else
            write(fd,'':indent,dewey,' ',title);

         if estimate <> 0 then
            write(fd,'  (',estimate:0:1,')');
         writeln(fd);

         pflush(fd);
         onpage := page_number;
         prnline := prnline + 1;

         print_text_lines(sec, fd, indent+indentation, format, prnline);
      end
      else

      if format = index_format then
         index_text_lines(sec)

      else         {else not detail mode}

      begin
         write(fd, '':indent, dewey,' ',title);      {output only the title
                                                     if not in detail mode}
         len := length(title)+indent;

         if estimate <> 0 then
         begin
            write(fd,'  (',estimate:4:1,')');
            len := len + 8;
         end;

         if (format = contents_format) and (onpage <> 0) then
         begin
            while len < (right_margin-4-length(dewey)) do
            begin
               if odd(len) then
                  write(fd,' ')
               else
                  write(fd,'.');
               len := len + 1;
            end;
            write(fd,onpage:3);
         end;

         writeln(fd);
         pflush(fd);
         prnline := prnline + 1;
      end;


      for i := 1 to max_subsects do    {recursively output all subsections
                                        with some extra indentation}
         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               print_section(subsect[i], fd,
                             indent+indentation, format,
                             dewey + itoa(i) + '.');

   end;
end;

