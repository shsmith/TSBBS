
(*
 * outline - a simple "outline" oriented document generator
 *
 * outmisc.inc - this module contains various support procedures
 *               used by the rest of the outline processor.
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *)


const                      {single character codes for each of
                            the special keys on the keyboard}
   BACKSPC  = #8;
   TAB      = #9;
   NEWLINE  = #13;
   ESC      = #27;

   F1       = #128;
   F2       = #129;
   F3       = #130;
   F4       = #131;
   F5       = #132;
   F6       = #133;
   F7       = #134;
   F8       = #135;
   F9       = #136;
   F10      = #137;

   HOME     = #140;
   UP       = #141;
   PGUP     = #142;
   LEFT     = #144;
   RIGHT    = #146;
   ENDLINE  = #148;
   DOWN     = #149;
   PGDN     = #150;
   INS      = #151;
   DEL      = #152;



function getkey: char;      {get a key; map special keys into the
                             matching symbolic constant}
var
   c:  char;

begin
   read(kbd,c);                           {read a key}

   if (c = ESC) and keypressed then       {if this is a funtion key, then
                                           read the second byte and convert
                                           it into a special key code}
   begin
      read(kbd,c);
      c := chr(ord(c) + 69);   {this makes F1=#128}
   end;

   getkey := c;
end;



function new_section: section_ptr;      {allocate a new section and
                                         return a pointer to it}
var
   i:   integer;
   sec: section_ptr;

begin
   new(sec);                         {make a new section record}

   with sec^ do
   begin
      title := '';                    {initialize all of the fields}
      estimate := 0;
      onpage := 0;

      text := emptytext;

      for i := 1 to max_subsects do
         subsect[i] := nil;

      refcount := 1;
   end;

   new_section := sec;
end;


procedure allocate_text(var sec: section_ptr);     {allocate memory for the
                                                    text array of this section}
var
   i:  integer;

begin
   with sec^ do
   begin
      if text = emptytext then
      begin
         new(text);
         for i := 1 to max_text do
            text^[i] := '';
      end;
   end;
end;


procedure delete_section(var sec: section_ptr);    {delete a section and
                                                    all sub-sections unless
                                                    the section is still
                                                    referenced by someone
                                                    else}
var
   i:  integer;

begin
   with sec^ do
   begin

      refcount := refcount - 1;      {decrement the reference count for
                                      this section}

      if refcount = 0 then           {if nobody references this any more,
                                      then release all subordinates and
                                      dispose of myself!}
      begin
         for i := 1 to max_subsects do
            if subsect[i] <> nil then
               delete_section(subsect[i]);

         if text <> emptytext then
            dispose(text);

         dispose(sec);
      end;

      sec := nil;                    {set this reference pointer to
                                      nil even if it is not the last ref}
   end;
end;



procedure warning(msg:  anystring);   {display a warning message for a
                                       couple of seconds}
var
   i:  integer;
   c:  char;

begin
   msg := '<<< '+msg+' >>>';
   sound(430);

   for i := 1 to 5 do
   begin
      lowvideo;
      gotoxy(79-length(msg), 3);
      disp(msg);
      delay(125);                     {flash a dim message}

      normvideo;
      gotoxy(79-length(msg), 3);
      disp(msg);
      delay(125);                     {flash a bright message}

      gotoxy(79-length(msg),3);
      clreol;
      nosound;                        {remove the message and stop beeping}
   end;


   while keypressed do
      read(kbd,c);             {throw away all key-aheads after a warning}

end;



procedure edit_string(x,y:      integer;
                      var col:  integer;
                      var str:  anystring;
                      var c:    char;
                      maxlen:   integer);   {provide full text editing
                                             on the contents of a string
                                             variable; processes most
                                             editing keys.  this is where
                                             all the time is spent while
                                             waiting on the user}
var
   i:   integer;

begin

   gotoxy(x+length(str),y);

   lowvideo;
   disp(make_string('_',maxlen-length(str)));
                                          {display underscores out to the
                                           end of the field.  this lets
                                           the user know when he is near
                                           the end of line}
   normvideo;

   repeat
      if col > length(str) then
         col := length(str)+1;            {if i am beyond end of string,
                                           move cursor back to first legal
                                           position}

      gotoxy(x+col-1,y);
      c := getkey;                        {position the cursor and wait for an
                                           input from the user}


      case c of                           {switch on the key and do what
                                           ever is needed}

         HOME:      col := 1;


         ENDLINE:   col := length(str) + 1;


         TAB:       repeat
                       col := col + 1;
                    until (col mod 4) = 0;


         ^S,LEFT:   if col > 1 then
                       col := col - 1
                    else
                       write(^G);


         ^A:        begin
                       while (col > 1) and (str[col] <> ' ') do
                          col := col -1;
                       while (col > 1) and (str[col] = ' ') do
                          col := col -1;
                       while (col > 1) and (str[col] <> ' ') do
                          col := col -1;
                       if str[col] = ' ' then
                          col := col + 1;
                    end;


         ^D,RIGHT:  col := col + 1;


         ^F:        begin
                       while (col < length(str)) and (str[col] <> ' ') do
                          col := col +1;
                       while (col < length(str)) and (str[col] = ' ') do
                          col := col +1;
                    end;


         INS:       if col <= length(str) then
                    begin
                       insert(' ',str,col);
                       disp(copy(str,col,99));
                       saved := false;
                    end;


         ^G,DEL:    if col <= length(str) then
                    begin
                       delete(str,col,1);
                       disp(copy(str,col,99));
                       lowvideo;
                       disp('_');
                       normvideo;
                       saved := false;
                    end
                    else
                       write(^G);


         BACKSPC:   if col > 1 then
                    begin
                       col := col - 1;
                       delete(str,col,1);
                       disp(^H+copy(str,col,99));
                       lowvideo;
                       disp('_');
                       normvideo;
                       saved := false;
                    end
                    else
                       write(^G);


         NEWLINE:   col := 1;


         ^Y:        begin
                       str := '';
                       gotoxy(x,y);
                       lowvideo;
                       disp(make_string('_',maxlen));
                       normvideo;
                       saved := false;
                    end;

         ^E:        c := UP;
         ^X:        c := DOWN;
         ^R:        c := PGUP;
         ^C:        c := PGDN;

         UP,
         DOWN,
         PGUP,
         PGDN,
         ESC,
         F1..F10:   ;


         else       begin
                       if col = (maxlen-7) then
                       begin
                          sound(1200);         {make a quick beep when
                                                getting close to the end
                                                of a line}
                          delay(100);
                          nosound;
                       end;

                       if col > length(str) then
                          if length(str) < maxlen then
                          begin
                             str := str + c;
                             col := col + 1;
                             write(c);           {add to end of string
                                                  if there is room}
                          end
                          else
                             warning('Line full')     {beep if no more room}
                       else
                       begin
                          str[col] := c;
                          col := col + 1;       {replace in middle of string}
                          write(c);
                          saved := false;
                       end;

                    end;
      end;

   until c in [UP,DOWN,PGUP,PGDN,NEWLINE,ESC,F1..F10];


   gotoxy(x+length(str),y);
   clreol;                             {input is finished, remove the extra
                                        underscores from the screen}
end;



procedure change_dir;      {user interface to change working subdirectory }
var
   cd:  anystring;

begin

   getdir(0,cd);
   gotoxy(1,23);
   normvideo;
   disp('Current directory = '+cd);
   clreol;

   gotoxy(1,24);
   clreol;
   disp('Enter new current directory: ');
   cd := '';
   readln(cd);
   if cd = '' then
      exit;

{$I-}
   chdir(cd);
{$I+}
   if ioresult <> 0 then
      write(^G);
end;



procedure check_page_header(var fd: textfile;
                            format: print_formats;
                            sec:    section_ptr);    {check to see if a page
                                                      header is needed. print
                                                      one if it is needed.}
var
   dir: anystring;

begin
   if break_into_pages and (prnline = 1) then
   begin
      page_number := page_number + 1;
      if page_number = 1 then
      begin
         getdir(0,dir);
         if dir[length(dir)] <> '\' then
            dir := dir + '\';

         write(fd,dir,docfile,'':right_margin-10-length(dir+docfile));
      end
      else
         write(fd,document^.title,'':right_margin-10-length(document^.title));

      if format = contents_format then
         writeln(fd,'Contents ',page_number)
      else
      if format = index_format then
         writeln(fd,'   Index ',page_number)
      else
         writeln(fd,'    Page ',page_number);

      writeln(fd);
      prnline := 2;

      if (prnfile <> 'CON') then
      begin
         gotoxy(1,wherey);
         write('Page: ',page_number);
         gotoxy(10,wherey);
         disp('Section: '+sec^.title);
         clreol;
      end;
   end;
end;



procedure pflush(var fd: textfile);
var
   start,stop: real;
   time:       real;
   c:          char;
begin
   start := get_time;
   flush(fd);
   stop := get_time;

   if prnfile <> 'PRN' then exit;

   if (stop-start) > 0.5 then
   begin
      stop := get_time + 10.0;
      write(' DELAY');

      while (get_time < stop) and (not keypressed) do
         give_up_time;

      write(^H^H^H^H^H^H'      '^H^H^H^H^H^H);

      if keypressed then
         read(kbd,c);
   end;
end;


function itoa(i: integer): anystring;
begin
   if i < 10 then
      itoa := chr(i + ord('0'))
   else
      itoa := '1' + chr(i + ord('0') - 10);
end;

