

(*
 * outline - a simple "outline" oriented document generator
 *
 * outform.inc - this module contains the procedures
 *               for formatting and outputting blocks of text
 *               and include files.
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)

type
   word_info_rec = record
      word: string[40];
      spaces: integer;
   end;

var
   words:       array[1..40] of word_info_rec;
   word_count:  integer;


procedure print_options(var fd: textfile; opt: anystring);
var
   id: anystring;
   code: integer;
   i:    integer;

begin
   i := pos(' ',opt);
   if i > 1 then
   begin
      id := copy(opt,1,i-1);
      opt := copy(opt,i,99);
      while (copy(opt,1,1) = ' ') do
         delete(opt,1,1);
      val(opt,i,code);
   end
   else
   begin
      id := opt;
      i := 0;
   end;

   for i := 1 to length(id) do
      id[i] := upcase(id[i]);

   if id = '.PAGE' then       {.PAGE nnn}
      page_number := i
   else

   if id = '.EJECT' then
      prnline := 100
   else

   if id = '.SMALL' then
   begin
      writeln(fd,^O);
      indent_mult := 3;
   end
   else

   if id = '.ELITE' then
   begin
      writeln(fd,#27':');
      indent_mult := 2;
   end
   else

   if id = '.NORMAL' then
   begin
      writeln(fd,^R);
      indent_mult := 1;
   end
   else

   if id = '.ENHANCE' then       {enhanced print}
      writeln(fd,#27'I'#3#27'G')
   else

   if id = '.NOENHANCE' then
      writeln(fd,#27'I'#1)
   else

   if id = '.JUST'  then
      justify := true
   else

   if id = '.NOJUST'  then
      justify := false
   else
      write(fd,'** Unknown option: ',id,' ',opt,' (',i,')');

end;


procedure justify_line(indent:  integer);
var
   i,j:   integer;
   need:  integer;

begin

   need := right_margin - indent - length(lineout) + words[word_count].spaces;

   while (need>0) and (word_count>2) do
   begin
      i := random(word_count-1);
      with words[i] do
         if random(spaces*spaces+1) = 1 then    {don't allot big spaces}
         begin
            words[i].spaces := words[i].spaces + 1;
            need := need - 1;
         end;

   end;

   lineout := '';
   for i := 1 to word_count do
   with words[i] do
      lineout := lineout + word + copy('          ',1,spaces);
end;


procedure reformat_line(var fd:     textfile;
                        linein:     linestring;
                        indent:     integer;
                        var lines:  integer);    {reformat one or more
                                                  lines of text to fit
                                                  the margins between
                                                  'indent' and right_margin;
                                                  also counts output lines}

var
   i:           integer;
   word:        anystring;
   c:           char;

begin                 {this procedure is by far the slowest part
                       of printing to a file.   there are several
                       "tricky" things done here for the sake
                       of greater speed.  mostly this involves taking
                       advantage of the fact that str[0] is the length
                       of str, and that whole string assignment generates
                       code to move the whole string to/from the stack}

   if lineout='' then
      word_count := 0;

   if (linein = '') or (linein[1] = ' ') then   {if this is a blank line or
                                                 the start of a new paragraph}
   begin
      if lineout <> '' then                 {write any partial line}
      begin
         writeln(fd, '':indent, lineout);
         pflush(fd);
         lines := lines + 1;
         lineout := '';
      end;

      writeln(fd);                          {write a blank line}
      pflush(fd);
      lines := lines + 1;
      word_count := 0;
   end;


   linein := linein + ' ';            {the line will now be reformatted;
                                       make sure last word on the
                                       line is terminated}
   word := '';

   for i := 1 to length(linein) do
   begin
      c := linein[i];

      if c = ' ' then                   {if at the end of a word}
      begin

         if (ord(word[0]) + ord(lineout[0]) + indent) >= right_margin then
                                            {and the word won't fit
                                             on this output line}
         begin
            if justify then
               justify_line(indent);     {justify the line if needed}

            writeln(fd, '':indent, lineout);
            pflush(fd);
            lines := lines + 1;

            if word = '' then
            begin
               lineout := '';
               word_count := 0;
            end
            else
            begin
               lineout := word + c;          {then start a new line}
               word_count := 1;
               words[1].word := word;
               words[1].spaces := 1;
            end;
         end
         else

         if word <> '' then
         begin
            word_count := word_count + 1;
            words[word_count].word := word;
            words[word_count].spaces := 1;

            case word[length(word)] of    {put an extra space after these}
               '.',',',';',':':
                  begin
                     word := word + ' ';
                     words[word_count].spaces := 2;
                  end;
            end;

            lineout := lineout + word + ' ';
         end;                              {else add a word to this line.
                                            a lot of time is spent on this
                                            line.  how to make it faster?}

         word := '';                         {consume the word}

      end
      else
      begin

         word[0] := succ(word[0]);
         word[ord(word[0])] := c;   {not a space, build up a word.
                                     this is a faster version of
                                       word := word + c;}
      end;
   end;

end;




procedure print_include_file(var fd:    textfile;
                             line:      anystring;
                             indent:    integer;
                             var lines: integer);   {print the contents of
                                                     an include file at a
                                                     given indentation.
                                                     also counts output lines}
var
   incfile:  anystring;
   incfd:    text[3000];
   incline:  string[255];
   txtfile:  boolean;
   c:        char;
   pc:       char;

begin

   incfile := locate_file(copy(line, 2, 255));
   txtfile := copy(incfile,length(incfile)-3,4) = '.inc';

   if (prnfile <> 'CON.PRN') then
   begin
      gotoxy(10,wherey);
      disp('Text: '+incfile);
      clreol;
   end;

   if file_exists(incfile) then
   begin

      if lineout <> '' then      {flush last reformatted line}
      begin
         writeln(fd, '':indent, lineout);
         pflush(fd);
         lines := lines + 1;
         lineout := '';
      end;


      assign(incfd, incfile);
      reset(incfd);

      while not eof(incfd) do    {copy each line from the include
                                  file; do not reformat}
      begin
         incline := '';
         c := #0;
         repeat
            if not eof(incfd) then
            begin
               pc := c;
               read(incfd,c);
               if (c = #10) or (c = #13) then
                  incline := incline + #0
               else
                  incline := incline + c;
            end;
         until (c = #10) or (eof(incfd));

         if paragraph_reformat and txtfile then       {reformat the text}
            reformat_line(fd, incline, indent, lines)
         else

         begin                            {do not reformat the text}
            writeln(fd, '':indent*indent_mult, incline);
            pflush(fd);
            lines := lines + 1;
         end;
      end;

      close(incfd);
   end

   else
      writeln(fd, '*** Include file not found: ', line);

end;



procedure print_text_lines(var sec:    section_ptr;
                           var fd:     textfile;
                           indent:     integer;
                           format:     print_formats;
                           var lines:  integer);
                                 {output the text line portion
                                  of a section of the outline}
var
   i:       integer;
   num:     integer;

begin

   num := lines;
   lineout := '';

   for i := 1 to max_text do
   with sec^ do
   begin                                {output the lines of text;
                                         with word wrap includes}
      if text^[i] <> '' then

         if text^[i][1] = '@' then
            print_include_file(fd, text^[i], indent, lines)
                                             {descriptions with @filename
                                              will insert the contents of
                                              a file into the output}

         else

         if text^[i][1] = '&' then
            print_graph_file(fd, text^[i], indent, lines)
                                             {descriptions with &filename
                                              will insert the contents of
                                              a graphics file into the output}

         else

         if text^[i][1] = '.' then
            print_options(fd, text^[i])   {process options with .xxx}

         else

         if paragraph_reformat then       {reformat the text}
            reformat_line(fd, text^[i], indent, lines)
         else

         begin                            {do not reformat the text}
            writeln(fd, '':indent, text^[i]);
            pflush(fd);
            lines := lines + 1;
         end;
                                             {else reformat it}

   end;


   if lineout <> '' then      {output last reformatted line}
   begin
      if break_into_pages then
      begin
         if (prnline > pagelen) then
         begin
            write(fd,^L);
            flush(fd);
            prnline := 1;
         end;

         check_page_header(fd,format,sec);
      end;

      writeln(fd, '':indent, lineout);
      pflush(fd);

      lines := lines + 1;
      lineout := '';
   end;

   if num<>lines then
   begin
      writeln(fd);
      pflush(fd);
      lines := lines + 1;
   end;

end;


