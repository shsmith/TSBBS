

(*
 * outline - a simple "outline" oriented document generator
 *
 * outprint.inc - this module contains the procedures
 *                for the printing user interface.
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)



function select_print_format: print_formats;
                              {select the format for the printout
                               and return it as a format code}
var
   format: char;

begin
   clrscr;  normvideo;
   displn(version);
   writeln;
   writeln;
   writeln;
   writeln; lowvideo;
   displn('            Key                 Action');
   displn('           อออออ    อออออออออออออออออออออออออออออ');
   writeln;
   displn('             F1     Print full details of the document');
   writeln;
   displn('             F2     Print an outline of the document');
   writeln;
   displn('             F3     Print a table of contents for the document');
   writeln;
   displn('             F4     Print a section tree for the document');
   writeln;
   displn('             F5     Print a keyword index for the document');
   writeln;
   displn('             ESC    Cancel printout');
   writeln;

   gotoxy(74,25);
   write(maxavail shr 6,'k');

   normvideo;
   gotoxy(1,24);
   write  ('        Select print format: ');

   repeat
      format := getkey;
      if not (format in [F1..F5,ESC]) then
         write(^G);
   until format in [F1..F5,ESC];

   case format of
      F1:   select_print_format := detail_format;
      F2:   select_print_format := outline_format;
      F3:   select_print_format := contents_format;
      F4:   select_print_format := tree_format;
      F5:   select_print_format := index_format;
      ESC:  select_print_format := no_format;
   end;

end;



function select_print_file: char;      {select the print output file name;
                                        and leave it in prnfile.   returns
                                        status character: abort print if ESC,
                                        otherwise ok to print}
var
   fd:      textfile;
   key:     char;
   prompt:  linestring;

begin
   normvideo;
   gotoxy(1,24);
   write  ('     Output to Printer, Console or File (P/C/F): ');

   repeat
      key := upcase(getkey);
      if not (key in ['C','F','P',ESC]) then
         write(^G);
   until key in ['C','F','P',ESC];

   select_print_file := key;

   case key of
      'P':   begin
                prnfile := 'PRN';
                exit;
             end;

      'C':   begin
                prnfile := 'CON';
                exit;
             end;
   end;


   prnfile := '';
   prompt := 'Print document '+docfile+' to a file or device';
   select_file('*.PRN,*.SUM,*.INX', prompt, prnfile, key);

   if (key <> NEWLINE) or (prnfile = '') then
   begin
      select_print_file := ESC;
      exit;
   end;

   if pos('.', prnfile) = 0 then
      prnfile := prnfile + '.PRN';

   if file_exists(prnfile) then
   begin
      writeln;
      writeln('WARNING:  The file ', prnfile, ' already exists!  ');
      disp('Overwrite it? (Y/N) ');

      if upcase(getkey) <> 'Y' then
      begin
         select_print_file := ESC;
         exit;
      end;

      writeln('Yes');
   end;

   select_print_file := 'Y';
end;



procedure print_document(var sec:   section_ptr;
                         firstpage: integer;
                         dewey:     anystring); {user interface to output
                                                 a section report
                                                 to a file or printer}
var
   fd:      textfile;
   prompt:  linestring;
   key:     char;
   format:  print_formats;

begin

   format := select_print_format;
   if format = no_format then
      exit;

   if select_print_file = ESC then
      exit;

   clrscr;  normvideo;
   displn(version);
   writeln;
   writeln;
   writeln;
   writeln;
   writeln; lowvideo;
   displn('               Printing '+docfile+' to '+prnfile+' ...');
   writeln;
   writeln;
   writeln; normvideo;
   displn('               Press any key to abort printing.');
   writeln;
   writeln;
   writeln;
   writeln;
   writeln;
   writeln;
   writeln; lowvideo;

   assign(fd, prnfile);
   rewrite(fd);

   page_number := firstpage-1;
   prnline := 1;
   lineout := '';
   word_count := 0;

   case format of
      detail_format,
      outline_format,
      contents_format:
         print_section (sec, fd, 1, format, dewey);

      index_format:
         begin
            disp('Building index.');
            init_index;
            print_section (sec, fd, 1, format, dewey);

            writeln;
            displn('Printing index...');
            output_index (fd);
            flush(fd);

            writeln;
            displn('Release index memory...');
            dispose_index;
            writeln;
         end;

      tree_format:
         print_section_tree (fd, sec, '', '', '', empty, empty, empty);
   end;

   write(fd, ^L);
   close(fd);
   writeln;

   if keypressed then
   begin
      if getkey = '?' then ;
      writeln('*** Print Aborted **');
   end;

   if prnfile = 'CON' then
   begin
      disp('Press ENTER to continue: ');

      repeat
      until getkey = NEWLINE;
   end;


   clrscr;
end;


