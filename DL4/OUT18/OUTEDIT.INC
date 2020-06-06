
(*
 * outline - a simple "outline" oriented document generator
 *
 * outedit.inc - this file contains the section display
 *               and editor procedures.  this is the main
 *               part of the user interface.
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *)


procedure display_section(sec:     section_ptr;
                          parent:  anystring);   {display the current
                                                  section on the screen
                                                  for editing}
var
   i:  integer;

begin
   gotoxy(1,1);

   with sec^ do
   begin
      lowvideo;
      disp('Parent: '+parent);
      clreol;
      writeln;      lowvideo;
      disp('Title:  ');

      normvideo;
      disp(title);
      clreol;
      writeln;

      lowvideo;
      clreol;
      writeln;
      disp('Text:');

      normvideo;
      for i := 1 to max_text do
      begin
         gotoxy(9,wherey);
         disp(text^[i]);
         clreol;
         writeln;
      end;


      lowvideo;
      clreol;
      disp('Sub-sections:');

      writeln;

      normvideo;
      for i := 1 to max_subsects do
         if subsect[i] <> nil then
         begin
            if (marksec = sec) and (marksub = i) then
               disp('<mark>  ')
            else
               if subsect[i]^.estimate = 0 then
                  disp('        ')
               else
                  write(subsect[i]^.estimate:5:1,'   ');

            disp(subsect[i]^.title);
            clreol;
            writeln;
         end;
   end;

   for i := wherey to 24 do
   begin
      clreol;
      writeln;
   end;

   lowvideo;
   disp('Keys:  UP,  DOWN,  PGUP (parent),  PGDN (sub-section),  F1 (help)');
   clreol;
   gotoxy(74,wherey);
   write(maxavail shr 6,'k');
   if not saved then
      disp(' *');

   normvideo;
end;


procedure edit_help;     {display a help message for the section editor}
var
   key:  char;

begin
   clrscr;
   lowvideo;
   displn(version);
   writeln; normvideo;
   displn('               H E L P  -  O N  -  T A P');
   writeln;
   displn('    Key                  Action');  lowvideo;
   displn('   อออออ    อออออออออออออออออออออออออออออ');
   writeln;
   displn('   F1       Display this help screen');
   displn('   F2       UnDelete deleted section in front of the current sub-section');
   displn('   F3       Save the outline on disk');
   displn('   F4       Print this section');
   displn('   F6       Mark/unmark the current sub-section');
   displn('   F7       Move the marked sub-section in front of the current sub-section');
   displn('   F8       Copy the marked sub-section in front of the current sub-section');
   displn('   F9       Delete the current sub-section');
   displn('   F10      Change estimate for the current sub-section');
   displn('   UP       Move the cursor up to the previous item');
   displn('   DOWN     Move the cursor down to the next item');
   displn('   PGUP     Go up an outline level (to the Parent-Section)');
   displn('   PGDN     Go down a level to the Sub-Section under the cursor');
   writeln;

   gotoxy(74,25);
   write(maxavail shr 6,'k');
   if not saved then
      disp(' *');

   gotoxy(1,24);
   normvideo;
   disp('Press ENTER to leave help-on-tap: ');

   repeat
   until getkey in [NEWLINE,F1];

   clrscr;
end;


procedure edit_section(sec:        section_ptr;
                       parent:     anystring;
                       dewey:      anystring);   {user interface to
                                                  edit a section of an
                                                  outline.  recursively
                                                  calls itself when the
                                                  user goes "down" a
                                                  section.  this is the
                                                  most elaborate procedure
                                                  since it does all of the
                                                  actual section manipulation}
var
   fld:  integer;
   sub:  integer;
   key:  char;
   temp: section_ptr;
   i:    integer;
   col:  integer;
   est:  real;
   buf:  string[6];
   pag:  integer;
   ssec: string[2];
   mark: integer;

begin

   fld := 1;
   col := 1;
   mark := 0;
   display_section(sec,parent);

   with sec^ do
   repeat

      if fld > max_text+1 then
      begin
         sub := fld - (max_text+1);      {calculate the subsection index}
         ssec := itoa(sub) + '.';
         if subsect[sub] <> nil then
            pag := subsect[sub]^.onpage
         else
            pag := 0;
      end
      else
      begin
         pag := onpage;
         ssec := '';
      end;


      gotoxy(30,(max_text+4));
      clreol;
      lowvideo;

      disp('Sec: '+dewey+ssec);

      gotoxy(55,(max_text+4));
      if pag <> 0 then
         write('Page:',pag:3);

      est := 0;                           {calculate this section's estimate}
      for i := 1 to max_subsects do
         if subsect[i] <> nil then
            est := est + subsect[i]^.estimate;
      if (est <> 0) or (sec = document) then
         estimate := est;

      gotoxy(69,(max_text+4));
      if estimate <> 0 then
         write('Est: ',estimate:0:1);

      normvideo;


      if (fld = 1) then                   {edit the section title}
         edit_string(9,2,col,title,key,anystring_length)
      else

      if (fld > 1) and (fld <= max_text+1) then
      begin
                                          {edit the section text lines}
         if text = emptytext then
            allocate_text(sec);

         edit_string(9,fld+2,col,text^[fld-1],key,anystring_length);

      end

      else                                {edit the subsect list}
      begin
          sub := fld - (max_text+1);      {calculate the subsection index}
          if subsect[sub] = nil then
             subsect[sub] := new_section;

          edit_string(9,sub+(max_text+4),col,
                       subsect[sub]^.title,key,anystring_length);
      end;


      case key of     {process special function keys from edit-string}

         F1:    {get help-on-tap}
                begin
                   edit_help;
                   display_section(sec,parent);
                end;


         F2:    {undelete most recently deleted in front of current subsection}
                if fld <= (max_text+1) then
                   warning('The cursor must be on a sub-section')
                else

                if (delsec = nil) then
                   warning('There is nothing to undelete')
                else

                begin
                   for i := max_subsects-1 downto sub do
                      subsect[i+1] := subsect[i];
                                          {open up a space for the undel'd
                                           subsection to go into}

                   subsect[sub] := delsec;
                   display_section(sec,parent);
                                          {put it into the list and
                                           update the screen}

                   delsec := nil;         {now there's nothing deleted}
                   saved := false;
                end;

         F3:    {save current outline}
                begin
                   save_document;
                   clrscr;
                   display_section(sec,parent);
                end;


         F4:    {print section}
                begin
                   print_document(sec,sec^.onpage,dewey);
                   clrscr;
                   display_section(sec,parent);
                end;


         F6:    {mark current subsection}
                if fld <= (max_text+1) then
                   warning('This can''t be marked')
                else

                begin
                   if (marksub <> 0) and (marksec = sec) then
                                         {if there is already a mark on this
                                          screen, then remove it }
                   begin
                      gotoxy(1,marksub+(max_text+4));
                      disp('      ');
                   end;

                   if (marksec = sec) and (marksub = sub) then
                                         {toggle mark off/on}
                      marksec := nil
                   else
                   begin
                      marksub := sub;
                      marksec := sec;
                      gotoxy(1,marksub+(max_text+4));
                      disp('<mark>');
                   end;
                end;


         F7:    {move marked subsect in front of current subsection}
                if fld <= (max_text+1) then
                   warning('The cursor must be on a sub-section')
                else

                if (marksec = nil) then
                   warning('First mark the section to move')
                else

                begin
                   temp := marksec^.subsect[marksub];
                                          {grab the subsection to be moved}

                   for i := marksub to max_subsects-1 do
                      marksec^.subsect[i] := marksec^.subsect[i+1];
                   marksec^.subsect[max_subsects] := nil;
                                          {delete position of marked
                                           subsect from subsection list}

                   if (marksec = sec) and (sub > marksub) then
                      sub := sub - 1;     {adjust if current fld got moved}

                   for i := max_subsects-1 downto sub do
                      subsect[i+1] := subsect[i];
                                          {open up a space for the moved
                                           subsection to go into}

                   subsect[sub] := temp;
                   fld := sub + (max_text+1);
                                          {put it into the list}

                   marksec := nil;
                   marksub := 0;
                   display_section(sec,parent);
                                           {clear the marker and update the
                                            screen to show changes}
                   saved := false;
                end;


         F8:    {copy marked subsection in front of current subsection}
                if fld <= (max_text+1) then
                   warning('The cursor must be on a sub-section')
                else

                if (marksec = nil) then
                   warning('First mark the section to copy')
                else

                begin
                   temp := marksec^.subsect[marksub];
                                          {grab the subsection to be moved}

                   for i := max_subsects-1 downto sub do
                      subsect[i+1] := subsect[i];
                                          {open up a space for the moved
                                           subsection to go into}

                   subsect[sub] := temp;
                   temp^.refcount := temp^.refcount + 1;
                                          {put it into the list and update
                                           the screen}
                   display_section(sec,parent);
                   saved := false;
                end;


         F9:    {delete the current subsection (and all subordinate sections)}
                if fld <= (max_text+1) then
                   warning('The cursor must be on a sub-section')
                else

                begin
                   if delsec <> nil then
                      delete_section(delsec);        {if there was a previous
                                                      delete, throw it away}

                   delsec := subsect[sub];           {hold in to this delete in
                                                      case of undelete}

                   for i := sub to max_subsects-1 do
                      subsect[i] := subsect[i+1];
                   subsect[max_subsects] := nil;     {get rid of the entry}

                   display_section(sec,parent);
                   saved := false;
                end;



         F10:   {change estimate}
                if fld <= (max_text+1) then
                   warning('This can''t be estimated')
                else

                begin
                   normvideo;
                   gotoxy(1,sub+(max_text+4));
                   write('     ',#13);
                   i := 1;
                   buf := '';
                   edit_string(1,sub+(max_text+4),i,buf,key,5);
                   val(buf,subsect[sub]^.estimate,i);

                   lowvideo;
                   gotoxy(1,sub+(max_text+4));
                   write(subsect[sub]^.estimate:5:1,'   ');
                   disp(subsect[sub]^.title);

                   saved := false;
                end;

      end;


      case key of     {select next field/screen based on exit key from edit}

         ESC,
         PGUP:  {go up to parent section}
                ;


         PGDN:  {go down into current subsection}
                if fld <= (max_text+1) then
                   fld := max_text+2
                else

                if (sec = marksec) and (sub = marksub) then
                   warning('First unmark with F4')
                else

                if subsect[sub]^.title = '' then
                   warning('First enter the title; blank titles are forbidden')
                else

                begin
                   edit_section(subsect[sub],title,dewey+ssec);
                   display_section(sec,parent);
                end;


         UP:    {go up to previous field on screen, skipping blanks}
                if fld > 1 then
                begin
                   fld := fld - 1;
                   if (fld > 1) and (fld <= (max_text+1)) then
                      while (fld > 1) and (text^[fld-1] = '') do
                         fld := fld - 1;
                end
                else
                   warning('Top of screen');


         NEWLINE,
         DOWN:  {move down to next field on screen, skipping blanks}
                if (fld > 1) and (fld <= max_text) then
                begin
                   if text^[fld-1] = '' then
                      fld := max_text+2
                   else
                      fld := fld + 1;
                end
                else

                if (fld - (max_text+1)) < max_subsects then
                   fld := fld + 1
                else
                   warning('Bottom of screen');


         F1..F10:  ;

         else   warning('Invalid function key');
      end;


   until (key = PGUP) or (key = ESC);
end;

