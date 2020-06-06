
(*
 * form - reformat a textfile
 * shs 3-oct-86
 *
 *)

{$p2048,g512}

type
   linestring = string[128];
   anystring = linestring;

var
   lineout: linestring;

const
   right_margin = 72;
   justify = true;

procedure pflush(var fd: text); begin flush(fd); end;


type
   word_info_rec = record
      word: string[40];
      spaces: integer;
   end;

var
   words:       array[1..40] of word_info_rec;
   word_count:  integer;


procedure justify_line(indent:  integer);
var
   i,j:   integer;
   need:  integer;

begin
   need := (right_margin - indent) - length(lineout);
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


procedure reformat_line(var fd:     text;
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


   if (linein = '') or (linein[1] = ' ') then   {if this is a blank line or
                                                 the start of a new paragraph}
   begin
      if lineout <> '' then                 {write any partial line}
      begin
         writeln(fd, '':indent, lineout);
         pflush(fd);
         lines := lines + 1;
         lineout := '';
         word_count := 0;
      end;

      writeln(fd);                          {write a blank line}
      pflush(fd);
      lines := lines + 1;
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
         case c of
            '.',',',';',':':
               word := word + ' ';
         end;
      end;
   end;

end;



procedure format_file(name:  anystring);
var
   lines:      integer;
   line:       linestring;
   i:          integer;
   fd:         text;

const
   indent = 6;

begin
   assign(fd,name);
   reset(fd);

   lineout := '';
   lines := 0;

   while not eof(fd) do
   begin
      readln(fd,line);
      reformat_line(output, line, indent, lines)
   end;

   if lineout <> '' then      {output last reformatted line}
   begin
      writeln(output, '':indent, lineout);
      lines := lines + 1;
      lineout := '';
   end;

   close(fd);
end;


begin
   format_file('tandem.doc');

end.
