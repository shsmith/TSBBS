
(*
 * outline - a simple "outline" oriented document generator
 *
 * outfiles.inc - this module contains all of the file access
 *                procedures.  Saves and Loads are
 *                handled by the procedures in this module.
 *
 * Author:  Samuel H. Smith, 11-Jan-86
 *
 *)


procedure select_file(pattern:    anystring;
                      prompt:     linestring;
                      var name:   anystring;
                      var key:    char);     {select a filename for reading
                                              or writing; this may give a
                                              directory of files in a future
                                              version}
var
   i:    integer;
   x, y: integer;
   n:    integer;
   sel:  anystring;
   dir:  anystring;

begin
   clrscr;
   getdir(0,dir);
   getfiles(pattern, filetable, filecount);    {get the files matching
                                                the pattern}
   clrscr;
   lowvideo;
   gotoxy(1, 1);
   displn('List of files matching '+ pattern+ ' in directory '+dir);

   normvideo;
   x := 4;
   y := 2;
   for i := 1 to filecount do                  {display the filenames in
                                                up to 5 columns on screen}
   begin
      gotoxy(x, y);
      disp(filetable[i]);

      y := y + 1;
      if y > 15 then
      begin
         y := 2;
         x := x + 16;
      end;
   end;


   gotoxy(1, 18);
   normvideo;
   displn(prompt+' 컴컴컴컴컴컴컴');  {display the prompt and give a little
                                       help with keys in this function}
   gotoxy(1, 25);
   lowvideo;
   disp('Enter a filename,  UP or DOWN to select from the directory,  ESC to cancel');
   gotoxy(1, 20);
   disp('File name: ');
   n := 0;

   normvideo;
   repeat
      if n = 0 then
         sel := name
      else
         sel := filetable[n];

      gotoxy(12, 20);
      disp(sel);
      i := length(sel) + 1;
      edit_string(12, 20, i, sel, key, 64);   {allow user to edit a filename
                                               or to press a function key}

      case key of

         UP:   begin
                  n := n - 1;
                  if n < 0 then
                     n := filecount;
               end;


         DOWN: begin
                  n := n + 1;
                  if n > filecount then
                     n := 0;
               end;


         NEWLINE, 
         ESC:  ;


         else  write(^G);
     end;

   until (key in [NEWLINE, ESC]);


   name := sel;
   for i := 1 to length(name) do
      name[i] := upcase(name[i]);      {map the filename to all upper case}

   gotoxy(1, 25);
   clreol;
   gotoxy(1, 21);                      {remove extra prompts from screen so
                                        that the caller can print some
                                        more, if needed}
end;



function file_exists(name:  anystring): boolean;      {check to see if a file
                                                       already exists.  knows
                                                       about special devices
                                                       and won't complain
                                                       about them}
var
   fd:  textfile;
   i:   integer;
   dev: anystring;

begin

   dev := copy(name, 1, 4);
   if dev[4] in [':', '.'] then
      dev := copy(dev, 1, 3);                {get the 3 letter device name
                                              from the filename, if any was
                                              present}

   file_exists := false;
   if dev = 'LST' then exit;
   if dev = 'AUX' then exit;
   if dev = 'NUL' then exit;
   if dev = 'CON' then exit;
   if dev = 'PRN' then exit;                 {don't bother checking on these
                                              files; they are special}


   assign(fd, name);                {it looks like an ordinary disk file;
                                     try to open it to see if it is there}
{$I-}
   reset(fd);
{$I+}
   if ioresult = 0 then
   begin
      file_exists := true;
      close(fd);
   end
   else
      file_exists := false;
end;


procedure save_section(var sec: section_ptr;
                       var fd:  textfile);       {save a section in special
                                                  .OLF format; recursively
                                                  calls itself for sub-
                                                  sections}
var
   i:           integer;
   textcount:   integer;
   subscount:   integer;
   ifd:         text;
   name:        anystring;
   c:           char;

begin
   with sec^ do
   begin
      writeln(fd, title);                   {save the title}

      if (text^[1][1] = '@') and
         (text^[2][1] = '@') and
         (text^[3][1] = '@') then
      begin
         name := text^[2];
         i := pos('.',name);
         if i > 0 then
         if copy(name,i,4) = '.scr' then
         begin
           name := copy(name,2,i-1) + 'inc';
           writeln;
           writeln('about to split into file ',name);
           for i := 4 to max_text do
              if text^[i] <> '' then
                 writeln(text^[i]);

           write('ok? (Y/N) ');
           read(kbd,c);
           if c = 'Y' then
           begin

            assign(ifd,name);
            rewrite(ifd);

            writeln('include file created: ',name);
            for i := 4 to max_text do
               if text^[i] <> '' then
               begin
                  writeln(ifd,text^[i]);
                  text^[i] := '';
               end;
            close(ifd);
            text^[4] := '@' + name;

           end;
         end;
      end;

      textcount := 0;
      for i := 1 to max_text do
         if text^[i] <> '' then
            textcount := textcount + 1;     {count the lines of text}

      writeln(fd, textcount, ' ',estimate:7:2, ' ', onpage);
      for i := 1 to max_text do
         if text^[i] <> '' then
            writeln(fd, text^[i]);           {save the text lines}


      subscount := 0;
      for i := 1 to max_subsects do
         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               subscount := subscount + 1;     {count the subsections}

      writeln(fd, subscount);
      for i := 1 to max_subsects do
         if subsect[i] <> nil then
            if subsect[i]^.title <> '' then
               save_section(subsect[i], fd);   {save all the subsections}
   end;
end;


procedure save_document;       {user interface for saving the current
                                outline to a file so that it can be
                                loaded at a later time}
var
   fd:      textfile;
   key:     char;

begin

   select_file('*.OLF', 'Save outline to a file', docfile, key);

   if (key <> NEWLINE) or (docfile = '') then
      exit;

   if pos('.', docfile) = 0 then
      docfile := docfile + '.OLF';

   if file_exists(docfile) then
   begin
      writeln;
      displn('WARNING:  The file '+ docfile+ ' already exists!  ');
      disp('Overwrite it? (Y/N) ');

      if upcase(getkey) <> 'Y' then
         exit;

      displn('Yes');
   end;

   assign(fd, docfile);
   rewrite(fd);

   writeln(fd,'OUTLINE OLF 3');
   save_section(document, fd);
   close(fd);

   saved := true;
end;




function load_section(var fd:  textfile):  section_ptr;
                                              {loads a single section
                                               of an outline from
                                               an .OLF format file.
                                               returns section
                                               pointer for the loaded
                                               section.  recursively
                                               calls itself for
                                               loading subsections}
var
   i:       integer;
   count:   integer;
   sec:     section_ptr;
   tfd:     text;
   tname:   anystring;

begin
   if eof(fd) then
   begin
      load_section := nil;
      displn('ERROR:  Unexpected end of file!!!'^G^G^G);
      exit;
   end;

   sec := new_section;             {create the section to load}

   with sec^ do
   begin
      readln(fd, title);           {get the section title}

      case olf_format of
         2: readln(fd, count, estimate);
         3: readln(fd, count, estimate, onpage);
         else
            readln(fd, count);
      end;

      if count <> 0 then
      begin
         allocate_text(sec);
         for i := 1 to count do
            readln(fd, text^[i]);      {get all text lines for this section}

         if text^[count][1] = '@' then
         begin
            tname := copy(text^[count],2,99);
            if copy(tname,length(tname)-3,4) = '.inc' then
            begin
               count := count-1;
               assign(tfd,tname);
               reset(tfd);
               while not eof(tfd) do
               begin
                  count := count + 1;
                  readln(tfd,text^[count]);
               end;
               close(tfd);
            end;
         end;
      end;

      readln(fd, count);
      for i := 1 to count do
         subsect[i] := load_section(fd);
                                   {recursively load all subsections for
                                    this section}
   end;

   load_section := sec;            {return pointer to the loaded section}
end;


procedure save_if_needed;
var
   key: char;

begin
   if not saved then
   begin
      clrscr;
      gotoxy(1,15);
      displn('WARNING:  There are unsaved changes in the current outline.'^G);
      writeln;
      disp  ('          Do you want to save? (Y/N) ');

      repeat
         key := upcase(getkey);
      until key in ['Y','N'];

      if key = 'Y' then
         save_document;
   end;

   clrscr;
end;


procedure load_document;      {user interface to load an outline from
                               a .OLF format file}
var
   fd:      textfile;
   key:     char;

begin

   save_if_needed;
   select_file('*.OLF', 'Load outline from a file', docfile, key);

   if (key <> NEWLINE) or (docfile = '') then
      exit;

   if pos('.', docfile) = 0 then
      docfile := docfile + '.OLF';


   docfile := locate_file(docfile);
   if not file_exists(docfile) then
   begin
      displn('I can''t find '+ docfile+ ';  try another filename.'^G);
      delay(3000);
      exit;
   end;


   assign(fd, docfile);
   reset(fd);

   readln(fd,lineout);            {determine outline file format.  some
                                   old formats need different handling}

   if lineout = 'OUTLINE OLF 2' then
      olf_format := 2
   else
   if lineout = 'OUTLINE OLF 3' then
      olf_format := 3
   else
   begin
      olf_format := 1;
      close(fd);
      reset(fd);
   end;

   marksec := nil;
   marksub := 0;                   {remove any markers that are
                                    set when we go to a new section

   delete_section(document);       {delete the current document from memory}

   document := load_section(fd);   {load in a new document.  note that this
                                    could be used to load in a subsection
                                    if there was a user interface for it.
                                    that would then allow you to "merge"
                                    outlines}

   close(fd);
   saved := true;
end;



procedure load_options;           {load in the options file and set the
                                   various program paremeters accordingly}
var
   fd:     text;
   par:    integer;
   name:   anystring;
begin

   name := locate_file('outline.opt');
   if not file_exists(name) then
   begin
      displn('Can''t open option file: '+name);
      halt;
   end;

   assign(fd,name);
   reset(fd);

   readln(fd);                  {skip initial comment line}

   readln(fd,pagelen);          {max number of lines to print on a page}

   readln(fd,minlines);         {minimum number of lines on a page before
                                 a new page can be started}

   readln(fd,indentation);      {amount of indentation for each level of
                                 subsection nesting in printouts}

   readln(fd,right_margin);     {right margin for reformatted print file
                                 outputs}

   read(fd,underline_character);
   readln(fd);                  {characters printed to underline section
                                 titles in detail format printouts}

   readln(fd,par);
   if par = 1 then
      paragraph_reformat := true
   else
      paragraph_reformat := false;
                                {should paragraphs of text be reformatted?}

   readln(fd,par);
   if par = 1 then
      break_into_pages := true
   else
      break_into_pages := false;
                                {should output be divided into pages?}

   readln(fd,par);
   textmode(par);               {set text modes}

{$I-}
   close(fd);
writeln('ioresult=',ioresult); delay(100);
{$I+}
end;



