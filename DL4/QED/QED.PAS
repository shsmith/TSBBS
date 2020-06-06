
(*
 * quick editor
 *
 * This is a simple and fast editor to use
 * when you want to quickly change a file.  It is not
 * meant to be used as a programming editor
 *
 *)

 program QuickEditor;

{$c-,v-,i-}

 type
   linestring =        string [128];
   lineptr    =        ^linestring;


 const
   maxlines =          5000;


 var
   keynum,
   currentline,
   column,
   i,
   highestline,
   screenline:         integer;
   inkey,
   secinkey,
   choice,
   ch:                 char;
   linebuffer:         array [1.. maxlines] of lineptr;
   emptyline:          lineptr;
   tabset:             array [1..80] of boolean;
   textfile:           text[20480];
   tempword,
   filename,
   typeset:            linestring;
   searchstring,
   replacement:        linestring;
   secnum,
   insertmode:         boolean; 

type
   screenloc = record
      character: char;
      attribute: byte;
   end;

   videoram = array[1..2000] of screenloc;
   videoptr = ^videoram;



 procedure quick_display(x,y: integer;  s: linestring);
 var
    i:        integer;
    display:  videoram absolute $b800:0;
    index:    integer;
    len:      integer;

 begin

    index := y*80 + x;

    len := length(s);
    if len > 80 then
       len := 80;

    for i := 1 to len do
    begin
       display[index].character := s[i];
       index := index + 1;
    end;
 end;

procedure drawscreen;
var
   i:  integer;
begin
   clrscr;

   for i := 1 to 22 do
      quick_display(1,i,linebuffer [currentline-screenline+i]^);
end;

 function replicate (count,
                     ascii:              integer): linestring;
 var
   temp:               linestring;
   i:                  byte;

 begin
   temp := '';

   for i := 1 to count do
      temp := temp + chr (ascii);

   replicate := temp;
 end;


 procedure newbuffer(var buf: lineptr);
 begin

    new(buf);

    if (memavail > 0) and (memavail < 200) then
    begin
       window(1, 1, 80, 25);
       gotoxy(75,1);
       write(memavail:5);
       window(1, 2, 80, 23);
       gotoxy(1,1);

       sound(700);
       delay(500);
       sound(1300);
       delay(600);
       nosound;
    end;
 end;


 procedure loadfile (name:               linestring);
 begin
   window(1, 2, 80, 23);
   clrscr;
   assign(textfile, name);    {$i-}

   reset(textfile);           {$i+}
   

   if (ioresult <> 0) then
   begin
      clrscr;
      writeln(chr (7));
      writeln('File does not exist: ', name);
      halt;
   end;

   writeln;
   write('      Reading ',name);

   for i := 1 to maxlines do
   begin
      if (linebuffer[i] <> emptyline) then
         linebuffer[i]^ := emptyline^;
   end;

   currentline := 1;

   while not eof (textfile) do
   begin
      if (currentline mod 100) = 0 then
         write(#13,currentline);

      if linebuffer[currentline] = emptyline then
         newbuffer(linebuffer[currentline]);

      readln(textfile, linebuffer [currentline]^);

      currentline := currentline + 1;
      if (currentline > maxlines) then
      begin
         writeln('File is too long to edit with QED');
         writeln('Only compiled for ',maxlines,' lines');
         halt;
      end;
   end;

   close(textfile);

   highestline := currentline + 1;
   currentline := 1;
   column := 1;
   screenline := 1;
   drawscreen;

 end;

 procedure dispkey (s:                  linestring);
 begin
   normvideo;
   write(s [1]);
   lowvideo;
   write(copy (s, 2, 80));
 end;

 procedure displaykeys;
 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   dispkey('1Help  ');
   dispkey('2Locate  ');
   dispkey('3Search  ');
   dispkey('4Replace  ');
   dispkey('5SaveQuit  ');
   dispkey('6InsLine  ');
   dispkey('7DelLine  ');
   dispkey('0QuitNosave  ');
   normvideo;
   window(1, 2, 80, 23);
 end;

 procedure initialize;
 begin

   if (paramcount <> 1) then
   begin
      writeln('Usage:  qed FILENAME');
      halt;
   end;

   clrscr;
   crtinit;
   window(1, 1, 80, 25);
   gotoxy(1,1);
   write(replicate (80, 205));
   gotoxy(1,24);
   write(replicate (80, 196));
   gotoxy(12,1);
   write(' Quick Editor ');
   gotoxy(29,1);
   write(' ',paramstr (1),' ');
   displaykeys;
   currentline := 1;
   column := 1;
   screenline := 1;
   highestline := 1;
   newbuffer(emptyline);
   emptyline^ := '';
   searchstring := '';
   replacement := '';
   insertmode := false;

   for i := 1 to 80 do
      tabset[i]:=(i mod 8)= 1;

   for i := 1 to maxlines do
      linebuffer[i] := emptyline;

   gotoxy(10, 20);
   loadfile(paramstr (1));
 end;

procedure help;
begin
   clrscr;
   quick_display(1, 1,'Quick editor commands:');
   quick_display(5, 3,'<BACKSPACE>, <TAB>, <ENTER>, <HOME>, <END>, ');
   quick_display(5, 4,'<PGUP>, <PGDN>, <DELETE>, <arrow keys>');
   quick_display(5, 5,'  - These keys operate as expected');
   quick_display(5, 7,'<ESC>       Erase current line');
   quick_display(5, 8,'<INSERT>    Toggle insert/replace mode');
   quick_display(5, 9,'CTL/LEFT    Previous word');
   quick_display(5,10,'CTL/RIGHT   Next word');
   quick_display(5,11,'CTL/PGUP    Top of file');
   quick_display(5,12,'CTL/PGDN    End of file');
   quick_display(5,13,'F1          Print these instructions');
   quick_display(5,14,'F2          Locate all lines with a string');
   quick_display(5,15,'F3          Search for a string');
   quick_display(5,16,'F4          Global search and replace');
   quick_display(5,17,'F5          Save file and quit');
   quick_display(5,18,'F6          Insert blank line');
   quick_display(5,19,'F7          Delete current line');
   quick_display(5,20,'F10         Abort edit');


   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('Press any key to return to editing...');

   repeat
   until keypressed;
   read(kbd,ch);

   displaykeys;
   drawscreen;
end;


 procedure printrow;
 begin
   window(1, 1, 80, 25);
   gotoxy(54,1);
   write(' line ', currentline : 4,' ');
   gotoxy(68,1);
   write(' col ', column : 2,' ');
   window(1, 2, 80, 23);
 end;

 function getkey (var secnum:         boolean;
                  var inkey:          char): boolean;
 begin
   
   if keypressed then
   begin
      read(kbd,inkey);
      secnum := (inkey = #27) and keypressed;

      if secnum then
      begin
         read(kbd,ch);
         keynum := ord (ch) + 128;
      end
      else

      if ord (inkey)<= 27 then
      begin
         secnum := true;
         keynum := ord (inkey);
      end
      else
      begin
         keynum := ord (inkey);
         secnum := false;
      end
   end
   else
   begin
      getkey := false;
      secnum := false;
   end;
 end;

 procedure character;
 begin

   if column = 79 then
   begin
      sound(510);
      delay(30);
      nosound;
   end
   else

   begin
      gotoxy(column, screenline);
      write(inkey);

      if linebuffer[currentline] = emptyline then
      begin
         newbuffer(linebuffer[currentline]);
         linebuffer[currentline]^ := '';
      end;

      while length(linebuffer[currentline]^) < column do
         linebuffer[currentline]^ := linebuffer[currentline]^ + ' ';

      insert(inkey, linebuffer [currentline]^, column);
      column := column + 1;

      if not insertmode then
         delete(linebuffer [currentline]^, column, 1);



(* redraw current line if in insert mode *)
      if insertmode then
         quick_display(1,screenline,linebuffer [currentline]^);


(* ding the bell when close to the end of a line *)

      if column = 70 then
      begin
         sound(1010);
         delay(10);
         nosound;
      end;
   end;
 end;

 procedure beginfile;
 begin
   currentline := 1;
   column := 1;
   screenline := 1;
   drawscreen;
 end;

 procedure endfile;
 begin
   currentline := highestline + 1;
   screenline := 12;
   column := 1;
   drawscreen;
 end;

 procedure funcend;
 begin
   column := length (linebuffer [currentline]^) + 1;
   if column > 80 then
      column := 80;
 end;

 procedure cursorup;
 var
   count:              integer;

 begin

   if currentline = 1 then
      exit;

   currentline := currentline - 1;
   if screenline = 1 then
   begin
      gotoxy(1, 1);
      insline;
      quick_display(1,1,linebuffer [currentline]^);
   end
   else
      screenline := screenline - 1;
 end;

 procedure cursordown;
 begin
   currentline := currentline + 1;
   if currentline > highestline then
      highestline := currentline;

   screenline := screenline + 1;
   if screenline > 22 then
   begin
      gotoxy(1, 1);
      delline;
      screenline := 22;
      quick_display(1,screenline,linebuffer [currentline]^);
   end;
 end;


 procedure insertline;
 begin
   insline;

   for i := highestline + 1 downto currentline do
      linebuffer[i + 1] := linebuffer [i];

   linebuffer[currentline] := emptyline;
   highestline := highestline + 1;
 end;


 procedure enter;
 begin
   cursordown;
   column := 1;
   gotoxy(column, screenline);

   if insertmode then
      insertline;
 end;


 procedure deleteline;
 begin
   delline;

   if highestline > currentline +(23 - screenline) then
      quick_display(1,22,linebuffer [currentline +(23 - screenline)]^);

   if linebuffer[currentline] <> emptyline then
      linebuffer[currentline]^ := emptyline^;

   for i := currentline to highestline + 1 do
      linebuffer[i] := linebuffer [i + 1];

   linebuffer [highestline+2] := emptyline;
   highestline := highestline - 1;

   if currentline > highestline then
      highestline := currentline;
 end;


 procedure cursorleft;
 begin
   column := column - 1;

   if column < 1 then
   begin
      cursorup;
      funcend;
   end
 end;

 procedure cursorright;
 begin
   column := column + 1;

   if column > 79 then
   begin
      cursordown;
      column := 1;
   end;
 end;

 procedure ins;
 begin

   if insertmode then
      insertmode := false
   else
      insertmode := true;

   window(1,1,80,25);
   gotoxy(1,1);

   if insertmode then
      write('Insert ')
   else
      write(replicate (7, 205));

   window(1,2,80,23);
 end;

 procedure del;
 begin
   if (column > length(linebuffer[currentline]^)) then
   begin
      if (length(linebuffer[currentline]^) +
          length(linebuffer[currentline+1]^)) < 80 then
      begin
         linebuffer[currentline]^ := linebuffer[currentline]^ +
                                     linebuffer[currentline+1]^;

         quick_display(1,screenline,linebuffer [currentline]^);
         cursordown;
         deleteline;
         cursorup;
      end;
      exit;
   end;


   if linebuffer[currentline] = emptyline then
   begin
      newbuffer(linebuffer[currentline]);
      linebuffer[currentline]^ := '';
   end;

   while length(linebuffer[currentline]^) < column do
      linebuffer[currentline]^ := linebuffer[currentline]^ + ' ';

   ch := copy (linebuffer [currentline]^, column, 1);
   delete(linebuffer [currentline]^, column, 1);

   gotoxy(1,screenline);
   clreol;
   quick_display(1,screenline,linebuffer [currentline]^)
 end;

 procedure backspace;
 begin

   if column > 1 then
      column := column - 1
   else
   begin
      cursorup;
      funcend;
      del;
   end;
 end;


 procedure terminate;
 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   gotoxy(1, 24);
   clreol;
   write('      Writing...');

   rewrite(textfile);
   for i := 1 to highestline + 1 do
   begin
      if (i mod 100) = 0 then
         write(#13,i);

      writeln(textfile, linebuffer [i]^);
   end;

   write(#13,i);
   writeln(textfile,^Z);
   close(textfile);
   write(#13);
   clreol;
   halt;
 end;

 procedure quitnosave;
 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   gotoxy(1, 24);
   clreol;
   halt;
 end;

 procedure funcpgup;
 begin
   currentline := currentline - 20;
   if currentline <= screenline then 
      beginfile
   else
      drawscreen;
 end;

 procedure funcpgdn;
 begin
   currentline := currentline + 20;
   if currentline+12 >= highestline then
      endfile
   else
      drawscreen;
 end;



 procedure prevword;
 begin

(* if i am in a word then skip to the space *)
   while (not ((linebuffer[currentline]^[column] = ' ') or
               (column >= length(linebuffer[currentline]^) ))) and
         ((currentline <> 1) or
          (column <> 1)) do
      cursorleft;

(* find end of previous word *)
   while ((linebuffer[currentline]^[column] = ' ') or
          (column >= length(linebuffer[currentline]^) )) and
         ((currentline <> 1) or
          (column <> 1)) do
      cursorleft;

(* find start of previous word *)
   while (not ((linebuffer[currentline]^[column] = ' ') or
               (column >= length(linebuffer[currentline]^) ))) and
         ((currentline <> 1) or
          (column <> 1)) do
      cursorleft;

   cursorright;
 end;

 procedure nextword;
 begin

(* if i am in a word, then move to the whitespace *)
   while (not ((linebuffer[currentline]^[column] = ' ') or
               (column >= length(linebuffer[currentline]^)))) and
         (currentline < highestline) do
      cursorright;

(* skip over the space to the other word *)
   while ((linebuffer[currentline]^[column] = ' ') or
          (column >= length(linebuffer[currentline]^))) and
         (currentline < highestline) do
      cursorright;

 end;
 
 procedure tab;
 begin
   
   if column < 79 then
   begin
      
      repeat
         column := column + 1;
      until (tabset [column]= true) or (column = 79);
   end;
 end;

 procedure backtab;
 begin
   
   if column > 1 then
   begin

      repeat
         column := column - 1;
      until (tabset [column]= true) or (column = 1);
   end;
 end;
 
 procedure esc;
 begin
   column := 1;
   gotoxy(1, wherey);
   clreol;

   if (linebuffer[currentline] <> emptyline) then
      linebuffer[currentline]^ := emptyline^;

   linebuffer[currentline] := emptyline;
 end;


 procedure locate;
 var
   temp:               linestring;
   pointer,
   position,
   line,
   len:                integer;
   
 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('Locate:     Enter string: <',searchstring,'> ');
   temp := '';
   read(temp);
   if temp <> '' then
      searchstring := temp;
   len := length (searchstring);

   if len = 0 then
   begin
      displaykeys;
      beginfile;
      exit;
   end;

   gotoxy(1, 25);
   clreol;
   write('Searching...  Press <ESC> to exit, <HOLD> to pause');
   window(1, 2, 80, 23);
   clrscr;

   for i := 1 to highestline do
   begin
   (* look for matches on this line *)
      pointer := pos (searchstring, linebuffer [i]^);

    (* if there was a match then get ready to print it *)
      if (pointer > 0) then
      begin
         temp := linebuffer [i]^;
         position := pointer;
         gotoxy(1, wherey);
         lowvideo;
         write(copy(temp,1,79));
         normvideo;

         (* print all of the matches on this line *)
         while pointer > 0 do
         begin
            gotoxy(position, wherey);
            write(copy (temp, pointer, len));
            temp := copy (temp, pointer + len + 1, 128);
            pointer := pos (searchstring, temp);
            position := position + pointer + len;
         end;

         (* go to next line and keep searching *)
         writeln;
      end;
   end;

   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('End of locate.  Press any key to exit...');

   repeat
   until keypressed;
   read(kbd,ch);

   displaykeys;
   beginfile;
 end;


 procedure search;
 var
   temp:               linestring;
   pointer,
   position,
   line,
   len:                integer;

 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('Search:     Enter string: <',searchstring,'> ');
   temp := '';
   read(temp);
   if temp <> '' then
      searchstring := temp;
   len := length (searchstring);

   if len = 0 then
   begin
      displaykeys;
      beginfile;
      exit;
   end;

   gotoxy(1, 25);
   clreol;
   write('Searching...');
   window(1, 2, 80, 23);

   for i := currentline+1 to highestline do
   begin
   (* look for matches on this line *)
      pointer := pos (searchstring, linebuffer [i]^);

    (* if there was a match then get ready to print it *)
      if (pointer > 0) then
      begin
         currentline := i;
         if currentline >= 12 then
            screenline := 12
         else
            screenline := currentline;

         drawscreen;
         column := pointer;
         displaykeys;
         exit;
      end;
   end;

   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('Search string not found.  Press any key to exit...');

   repeat
   until keypressed;
   read(kbd,ch);

   displaykeys;
 end;

 procedure replace;
 var
   temp:               linestring;
   position,
   line,
   len:                integer;

 begin
   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('Replace:     Enter search string: <',searchstring,'> ');
   temp := '';
   read(temp);
   if temp <> '' then
      searchstring := temp;

   len := length (searchstring);
   if len = 0 then
   begin
      displaykeys;
      exit;
   end;

   gotoxy(1, 25);
   clreol;
   write('Replace:     Enter replacement string: <',replacement,'> ');
   temp := '';
   read(temp);
   if temp <> '' then
      replacement := temp;
   len := length (replacement);

   gotoxy(1, 25);
   clreol;
   write('Searching...');
   window(1, 2, 80, 23);
   clrscr;

   for line := 1 to highestline do
   begin
      position := pos (searchstring, linebuffer [line]^);

      while (position > 0) do
      begin
         currentline := line;
         if currentline >= 12 then
            screenline := 12
         else
            screenline := currentline;

         drawscreen;
         column := position;
         lowvideo;
         gotoxy(column,screenline);
         write(column,screenline,searchstring);
         normvideo;

         window(1, 1, 80, 25);
         gotoxy(1, 25);
         clreol;
         write('Replace (Y/N/ESC)? ');
         read(kbd, choice);

         if ord (choice)= 27 then
         begin
            displaykeys;
            beginfile;
            exit;
         end;

         gotoxy(1, 25);
         clreol;
         write('Searching...');
         window(1, 2, 80, 23);
         gotoxy(1,line);


         if choice in ['y','Y'] then
         begin
            linebuffer[line]^ := copy (linebuffer [line]^, 1, position - 1) +
                                   replacement +
                                   copy (linebuffer [line]^, position +
                                           length (searchstring), 128);

            position := pos (searchstring, copy (linebuffer[line]^,
                                position + len + 1,128)) +
                            position + len;
         end
         else
            position := pos (searchstring, copy (linebuffer[line]^,
                               position + length(searchstring) + 1,128)) +
                          position + length(searchstring);

         gotoxy(1,screenline);
         clreol;
         write(copy(linebuffer[currentline]^,1,79));
      end;
   end;

   window(1, 1, 80, 25);
   gotoxy(1, 25);
   clreol;
   write('End of replace.  Press any key to exit...');

   repeat
   until keypressed;
   read(kbd,ch);

   displaykeys;
 end;




 procedure handlefunc;
 begin

   case keynum of
      8:  backspace;
      9:  tab;
     13:  enter;
     27:  esc;
    143:  backtab;
    187:  help;
    188:  locate;
    189:  search;
    190:  replace;
    191:  terminate;
    192:  insertline;
    193:  deleteline;
    196:  quitnosave;
    199:  column := 1;
    200:  cursorup;
    201:  funcpgup;
    203:  cursorleft;
    205:  cursorright;
    207:  funcend;
    208:  cursordown;
    210:  ins;
    211:  del;
    209:  funcpgdn;
    243:  prevword;
    244:  nextword;
    246:  endfile;
    260:  beginfile;

    else  begin
{             write('[',keynum:3,']'^H^H^H^H^H);}
             sound(200);
             delay(300);
             nosound;
          end;
   end;
 end;


(* main *)

 begin
   initialize;
   printrow;


(* main loop - get a key and process it *)

   repeat
      gotoxy(column, screenline);


      secnum := false;
      if getkey (secnum, inkey) then
      begin

         if secnum then
            handlefunc
         else
            character;

         printrow;
      end;

   until true = false;

 end.









