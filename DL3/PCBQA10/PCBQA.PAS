
(*
 * QA - Questions and Answers - A simple filter for PCBoard
 *      script answer files.
 *
 * S.H.Smith, 24-May-87
 *
 *)


{$p1024,d-}


#include <anystring.inc>
#include <strutil.inc>
#include <incdec.inc>
#include <linewrap.inc>
#include <ljust.inc>


const
   cols = 20;
   pagewidth = 132;
   pagelines = 62;

type
   colrec = record
      full:   anystring;
      words:  linearray;
      n:      integer;
      width:  integer;
   end;

   blockrec = record
      col:    array[1..cols] of colrec;
      lines:  integer;
   end;

var
   pline:     integer;
   pcol:      integer;



procedure format_block( var block:  blockrec);
   {format all columns in the specified text block; sets number
    of lines needed for output}
var
   c: integer;

begin
   with block do
   begin
      lines := 1;

      for c := 1 to cols do
      with col[c] do
      begin
         line_wrap(full,width,words,n);
         if n > lines then
            lines := n;
      end;
   end;
end;


procedure output_block( var block:  blockrec;
                        underline:  char);
   {send the specified block to the output stream; use underline
    character to separate this block from the next}
var
   i: integer;
   c: integer;

begin
   with block do
   begin
      pline := pline + lines + 1;

      for i := 1 to lines do
         for c := 1 to pcol do
         with col[c] do
         begin
            write(words[i]);
            if c = pcol then
               writeln
            else
               write('':(width-ORD(words[i][0])),'|');
         end;

      for c := 1 to pcol do
         with col[c] do
         begin
            for i := 1 to width do
               write(underline);
            if c = pcol then
               writeln
            else
               write('+');
         end;
   end;

   flush(output);
end;


procedure process;
   {main work-horse routine; read input, process and output}
var
   titles:    blockrec;
   answers:   blockrec;
   line:      string[50];
   fd:        text;
   i:         integer;
   newpage:   boolean;


   procedure init;
   begin
      assign(fd,paramstr(1));
      reset(fd);

      readln(fd,line);
      if line[1] <> '*' then
      begin
         writeln('First line of answer file must be "*******..."');
         halt;
      end;
   end;


   procedure page_check;
   var
      k: integer;
   begin
      pcol := i;

      {allocate widths based on columns used}
      for k := 1 to pcol do
      begin
         titles.col[k].width := (pagewidth-pcol) div pcol;
         answers.col[k].width := (pagewidth-pcol) div pcol;
      end;

      {blank out unused columns}
      INCR(i);
      while i < cols do
      begin
         titles.col[i].full := '';
         answers.col[i].full := '';
         INCR(i);
      end;

      {see if the block will fit on this page}
      format_block(answers);
      if (pline+answers.lines) >= pagelines then
         newpage := true;

      {start a new page when needed}
      if newpage then
      begin
         if pline > 1 then
            writeln(^L);
         pline := 1;
         format_block(titles);
         output_block(titles,'=');
         newpage := false;
      end;

      output_block(answers,'-');
   end;


   procedure output_body;
   begin
      pline := 1;
      i := 1;

      while not eof(fd) do
      begin
         readln(fd,line);

         {start new block when needed}
         if copy(line,1,5) = 'From:' then
         begin
            if i > 1 then
               page_check;

            {grab "From:" field of next block}
            i := 1;
            titles.col[i].full := 'From:';
            answers.col[i].full := copy(line,7,99);
            writeln(con,copy(line,7,99));
         end;

         {see if the question has changed; force new page if it did}
         if copy(line,1,2) = 'Q:' then
         begin
            if i < cols then
               INCR(i);

            line := copy(line,4,99);
            if titles.col[i].full <> line then
               newpage := true;
            titles.col[i].full := line;

            {store answers}
            readln(fd,line);
            answers.col[i].full := copy(line,4,99);
         end;
      end;

      {output the last block}
      page_check;
      close(fd);
   end;


begin
   init;
   output_body;
end;


begin
   if paramcount <> 1 then
   begin
      writeln('usage:  qa ANSWERFILE [>listing]');
      halt;
   end;

   process;
end.


