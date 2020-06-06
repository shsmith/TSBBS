
(*
 * P4UP - Print "4 UP" format with HP PCL and compatible printers
 *
 * Simple utility formats normal text files to print four pages to
 * a sheet of paper.
 *
 * S.H.Smith, 12-12-88 (11/2/89)
 *
 *)

const
   title = 'HP4UP - Print "4 UP" format with HP PCL and compatible printers.';
   copyright = '(C) 1989 Samuel H. Smith; All Rights Reserved.';

   maxlines  = 66;      {maximum number of lines per page; source}
   maxlen    = 79;      {maximum line length}

   deltay    = 23;      {pixels motion per line}
   topy      = 60;      {top of page y value}

   startpage = #27'&l0L' +             {perf skip off}
               #27'&l0O' +             {portrait mode}
               #27'(sp20H' +           {fixed 20cpi}
               #27'(s6vS' +            {6point, upright}
               #27'(sb3T' +            {normal, courier face}
               #27'&l2a0L';            {letter paper size}

   endpage   = #12 +                   {formfeed}
               #27'&l1L' +             {perf skip on}
               #27'E';                 {reset}

   splitcol  = #27'*p1199X';           {position to split column}

   hdivider  = 'º ';                   {horizontal tearline}
   vdivider  = 'Í';                    {vertical tearline}


type
   page_rec = record
      body:    array[1..maxlines] of string[maxlen];
      count:   integer;
   end;

var
   TopLeft:    page_rec;
   TopRight:   page_rec;      {page buffers}
   BotLeft:    page_rec;
   BotRight:   page_rec;

   ifd:        text;          {source file}
   ofd:        text;          {destination file}
   pnum:       integer;
   prny:       integer;


(* ------------------------------------------------------------------ *)
procedure newline;
begin
   write(ofd,#27'*p',prny,'Y');
   write(ofd,^M);
   inc(prny,deltay);
end;


(* ------------------------------------------------------------------ *)
procedure read_page(var page: page_rec);
var
   line:    string[maxlen];
   ffpos:   integer;

const
   partial: string[maxlen] = '';

begin
   write(^M'Reading Page ',pnum:3,'...');
   inc(pnum);

   page.count := 1;
   page.body[page.count] := partial;
   partial := '';

   while (page.count < maxlines) and (not eof(ifd)) do
   begin
      inc(page.count);
      readln(ifd,line);

      ffpos := pos(^L,line);
      if ffpos > 0 then
      begin
         partial := copy(line,ffpos+1,maxlen);
         line[0] := chr(ffpos-1);
      end;

      page.body[page.count] := line;
      if ffpos > 0 then
         exit;
   end;
end;


(* ------------------------------------------------------------------ *)
procedure print_two(var left,right: page_rec);
var
   i: integer;

begin
   write('  Printing...');

   for i := 1 to maxlines do
   begin
(*******
      if i <= left.count then
         write(ofd,left.body[i],'':maxlen-length(left.body[i]))
      else
         write(ofd,'':maxlen);
*******)
      if i <= left.count then
         write(ofd,left.body[i]);

      write(ofd,splitcol,hdivider);

      if i <= right.count then
         write(ofd,right.body[i]);

      newline;
   end;
end;


(* ------------------------------------------------------------------ *)
var
   i: integer;

begin
   if paramcount <> 1 then
   begin
      writeln;
      writeln(title);
      writeln(copyright);
      writeln;
      writeln('Usage:   p4up FILE');
      writeln('Example: p4up program.doc');
      halt(99);
   end;

   assign(ifd,paramstr(1));
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open input file: ',paramstr(1));
      halt(99);
   end;

   assign(ofd,'PRN');
   rewrite(ofd);
   pnum := 1;

   repeat
      read_page(TopLeft);
      read_page(BotLeft);
      read_page(TopRight);
      read_page(BotRight);

      write(ofd,startpage);
      prny := topy;
      newline;
      print_two(TopLeft,TopRight);

      newline;

      for i := 1 to maxlen-1 do
         write(ofd,vdivider);

      write(ofd,splitcol);
      write(ofd,'  ');
      for i := 1 to maxlen-1 do
         write(ofd,vdivider);
      newline;

      newline;

      print_two(BotLeft,BotRight);
      write(ofd,endpage);
   until eof(ifd);

   close(ifd);
   close(ofd);
   writeln;
end.


