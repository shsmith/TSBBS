
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * PCB ProDoor visual message entry/edit module for ProMail unit (3-1-89)
 *
 *)


procedure append_space;
   {append a space to current line}
begin
   lines^[cline] := lines^[cline] + ' ';
end;


(* ----------------------------------------------------------- *)
function curlength: integer;
   {return the length of the current line}
begin
   curlength := length(lines^[cline]);
end;


(* ----------------------------------------------------------- *)
function line_boundry: boolean;
   {is the cursor at either the start of the end of a line?}
begin
   line_boundry := (ccol=1) or (ccol > curlength);
end;


(* ----------------------------------------------------------- *)
function curchar: char;
   {return the character under the cursor}
begin
   if ccol <= curlength then
      curchar := lines^[cline][ccol]
   else
      curchar := ' ';
end;


(* ----------------------------------------------------------- *)
function lastchar: char;
   {return the last character on the current line}
begin
   if curlength = 0 then
      lastchar := ' '
   else
      lastchar := lines^[cline][curlength];
end;


(* ----------------------------------------------------------- *)
procedure remove_trailing;
begin
   delete_trailing_spaces(lines^[cline]);
end;


(* ----------------------------------------------------------- *)
function delimiter: boolean;
   {return true if the current character is a delimiter for words}
begin
   case curchar of
      '0'..'9','a'..'z','A'..'Z','_':
         delimiter := false;
      else
         delimiter := true;
   end;
end;


(* ----------------------------------------------------------- *)
procedure reposition;
   {update physical cursor position}
var
   eol:  integer;

begin
   eol := curlength+1;
   if ccol > eol then
      ccol := eol;

   count_lines;
   position(ccol+4,cline-topline+topscreen);
end;


(* ----------------------------------------------------------- *)
procedure set_phyline;
   {set physical line to match logical line (indicates display update)}
begin
   phyline[cline-topline+1] := lines^[cline];
end;


(* ----------------------------------------------------------- *)
procedure truncate_line;
   {update screen after changing end-of-line}
begin
   lines^[cline][0] := chr(ccol-1);
   reposition;                            
   clear_eol;        {remove end of line on screen}
   set_phyline;
end;
   

(* ----------------------------------------------------------- *)
procedure refresh_screen;
var
   pline:   integer;
   pcol:    integer;
   phline:  integer;

begin
   if (cline >= pcbsetup.msg_lines) then
      cline := pcbsetup.msg_lines;

   pline := cline;
   cline := topline;
   pcol := ccol;
   ccol := 1{-3};       {backspace to before the line number}

   for cline := topline to topline+scrlines-1 do
   begin
      phline := cline-topline+1;

      if cline > pcbsetup.msg_lines then
      begin
         reposition;
         dGREEN('--');
         phyline[phline] := '--';
         clear_eol;
      end
      else

      begin
         if lines^[cline] <> phyline[phline] then
         begin
            reposition;
            {show_line_number(cline);}
            default_color;
            if (not substitute) then
               remove_variables(lines^[cline]);
            if curlength > 0 then
               disp(lines^[cline]);
            if curlength < length(phyline[phline]) then
               clear_eol;
            set_phyline;
         end;
      end;
   end;

{$IFNDEF IN_PROEDIT}
   if pleft <> minutes_left then
   begin
      pleft := minutes_left;
      position(1,statline);
      display_time_left;
      space;
   end;
{$ENDIF}

   ccol := pcol;
   cline := pline;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure scroll_screen(lines: integer);
begin
   inc(topline,lines);

   if (cline < topline) or (cline >= topline+scrlines) then
      topline := cline - scrlines div 2;

   if topline < 1 then
      topline := 1
   else
   if topline >= pcbsetup.msg_lines then
      dec(topline,scrollsiz div 2);

   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure cursor_up;
begin
   if cline > 1 then
      dec(cline);

   if cline < topline then
      scroll_screen(-scrollsiz)
   else
      reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_down;
begin
   inc(cline);
   if (cline >= pcbsetup.msg_lines) then
      cline := pcbsetup.msg_lines;

   if (cline-topline >= scrlines) then
      scroll_screen(scrollsiz)
   else
      reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_endline;
begin
   ccol := 73;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_startline;
begin
   ccol := 1;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure cursor_left;
begin
   if ccol = 1 then
   begin
      cursor_up;
      cursor_endline;
   end
   else

   begin
      dec(ccol);
      disp(#27'[D'); {cursor left}
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_right;
begin
   if ccol > curlength then
   begin
      ccol := 1;
      cursor_down;
   end
   else
   begin
      default_color;
      dispc(curchar);
      inc(ccol);
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_wordright;
begin
   if delimiter then
   begin
      {skip blanks right}
      repeat
         cursor_right;
         if line_boundry then exit;
      until not delimiter;
   end
   else

   begin
      {find next blank right}
      repeat
         cursor_right;
         if line_boundry then exit;
      until delimiter;

      {then move to a word start (recursive)}
      cursor_wordright;
   end;
end;


(* ----------------------------------------------------------- *)
procedure cursor_wordleft;
begin
   if delimiter then
   begin
      {skip blanks left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until not delimiter;

      {find next blank left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until delimiter;

      {move to start of the word}
      cursor_right;
   end
   else

   begin
      {find next blank left}
      repeat
         cursor_left;
         if line_boundry then exit;
      until delimiter;

      {and then move a word left (recursive)}
      cursor_wordleft;
   end;
end;


(* ----------------------------------------------------------- *)
procedure join_lines;
   {join the current line with the following line, if possible}
begin
   inc(cline);
   remove_trailing;
   dec(cline);
   remove_trailing;
   if (curlength + length(lines^[cline+1])) >= msgmaxlen then
      exit;

   if (lastchar <> ' ') then
      append_space;
   lines^[cline] := lines^[cline] + lines^[cline+1];

   inc(cline);
   delete_line;
   dec(cline);

   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure split_line;
   {splits the current line at the cursor, leaves cursor in original position}
var
   pcol:    integer;

begin
   pcol := ccol;
  {remove_trailing;}                      {get the portion for the next line}
   par := copy(lines^[cline],ccol,msgmaxlen);

   truncate_line;

   ccol := 1;                             {open a blank line}
   inc(cline);
   insert_line(par);

   if cline-topline > scrlines-2 then
      scroll_screen(scrollsiz)
   else
      refresh_screen;

   dec(cline);
   ccol := pcol;
end;


(* ----------------------------------------------------------- *)
procedure cursor_newline;
begin
   if insert_mode then
      split_line;

   ccol := 1;
   cursor_down;
end;


(* ----------------------------------------------------------- *)
procedure reformat_paragraph;
   {paragraph reformat, starting at current line and ending at any
    empty or indented line; leaves cursor after last line formatted}
begin

   remove_trailing;
   ccol := curlength;

   {for each line of the paragraph}
   while curchar <> ' ' do
   begin

      {for each word of the current line}
      repeat
         {determine length of first word on the following line}
         inc(cline);
         remove_trailing;
         ccol := 1;
         while curchar <> ' ' do
            inc(ccol);
         dec(cline);

         {hoist a word from the following line if it will fit}
         if (ccol > 1) and (ccol + curlength < msgmaxlen) then
         begin
            if curlength > 0 then
            begin
               {add a second space after sentences}
               case lastchar of
                  '.','?','!':
                     append_space;
               end;
               append_space;
            end;
            lines^[cline] := lines^[cline] + copy(lines^[cline+1],1,ccol-1);

            {remove the hoisted word}
            inc(cline);
            while (curchar = ' ') and (ccol <= curlength) do
               inc(ccol);
            delete(lines^[cline],1,ccol-1);
            if curlength = 0 then
               delete_line;
            dec(cline);
         end
         else
            ccol := 0;  {end of line}
      until ccol = 0;

      {no more lines will fit - either time for next line, or end of paragraph}
      inc(cline);
      ccol := 1;
      remove_trailing;
   end;

end;


(* ----------------------------------------------------------- *)
procedure visual_reformat;
   {reformat paragraph, update display}
var
   pline: integer;

begin
   pline := cline;
   reformat_paragraph;

   {find start of next paragraph}
   while (curlength = 0) and (cline <= linecnt) do
      inc(cline);

   {find top of screen for redisplay}
   while cline-topline > scrlines-2 do
   begin
      inc(topline,scrollsiz);
      pline := topline;
   end;

   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure word_wrap;
   {line is full and a character must be inserted.  perform word-wrap,
    updating screen and leave ready for the insertion}
var
   pcol:    integer;
   pline:   integer;

begin
   remove_trailing;
   pline := cline;
   pcol := ccol;

   {find start of word to wrap}
   ccol := curlength;
   while (ccol > 0) and (curchar <> ' ') do
      dec(ccol);

   {cancal wrap if no spaces in whole line}
   if ccol = 0 then
   begin
      ccol := 1;
      cursor_down;
      exit;
   end;

   {get the portion to be moved down}
   inc(ccol);
   par := copy(lines^[cline],ccol,msgmaxlen);

   {remove it from current line and refresh screen}
   truncate_line;

   {place text on open a new line following the cursor}
   inc(cline);
   insert_line(par);

   {join the wrapped text with the following lines of text}
   reformat_paragraph;

   {restore cursor to proper position after the wrap}
   cline := pline;
   if pcol > curlength then
   begin
      ccol := pcol-curlength{-1};   {position cursor after wrapped word}
      inc(cline); {cursor_down;}
   end
   else
      ccol := pcol;               {restore original cursor position}

   if (cline-topline >= scrlines) then
      scroll_screen(scrollsiz)
   else
      refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure insert_char(c: char);
   {insert a character at the cursor position; word-wrap if needed}
begin
   high_ascii_filter(c);
   if c = #0 then exit;

   {remove trailing spaces unless appending current line}
   if ccol < curlength then
   begin
      remove_trailing;
      if ccol > curlength then
         reposition;
   end;

   {word-wrap needed if line is full}
   if (insert_mode and (curlength >= msgmaxlen)) or (ccol > msgmaxlen) then
   begin
      if (ccol <= msgmaxlen) then          {wrap last word if cursor is not at end}
         word_wrap
      else

      {ccol must be > msgmaxlen}
      if c = ' ' then
      begin                         {space at end-line is the same as newline}
         cursor_newline;
         exit;
      end
      else

      if lastchar = ' ' then        {nonspace w/space at end-line is newline}
         cursor_newline
      else
         word_wrap;                 {otherwise wrap word down and continue}
   end;

   {insert character into the middle of a line}
   if insert_mode and (ccol <= curlength) then
   begin
      insert(c,lines^[cline],ccol);

      {update display line following cursor}
      default_color;
      disp(copy(lines^[cline],ccol,msgmaxlen));

      {position cursor for next insertion}
      inc(ccol);
      reposition;
   end
   else

   {append a character to the end of a line}
   begin
      while curlength < ccol do
         append_space;
      lines^[cline][ccol] := c;

      {advance the cursor, updating the display}
      cursor_right;
   end;

   set_phyline;
end;


(* ----------------------------------------------------------- *)
procedure delete_char;
begin

   {delete whole line if it is empty}
   if ccol > curlength then
      join_lines
   else

   {delete in the middle of a line}
   if ccol <= curlength then
   begin
      delete(lines^[cline],ccol,1);
      default_color;
      disp(copy(lines^[cline],ccol,msgmaxlen));
      space;
      reposition;
      set_phyline;
   end;
end;


(* ----------------------------------------------------------- *)
procedure delete_wordright;
begin
   if curchar = ' ' then
      repeat   {skip blanks right}
         delete_char;
      until (curchar <> ' ') or (ccol > curlength)

   else
      repeat   {find next blank right}
         delete_char;
      until delimiter;

end;



(* ----------------------------------------------------------- *)
procedure cursor_tab;
begin
   repeat
      insert_char(' ');
   until (ccol mod 8) = 0;
end;


(* ----------------------------------------------------------- *)
procedure page_down;
begin
   if topline+scrlines < pcbsetup.msg_lines then
   begin
      inc(cline,scrollsiz);
      scroll_screen(scrollsiz);
   end;
end;

procedure page_up;
begin
   if topline > 1 then
   begin
      dec(cline,scrollsiz);
      if cline < 1 then
         cline := 1;
      scroll_screen(-scrollsiz);
   end;
end;


(* ----------------------------------------------------------- *)
procedure visual_insert_line;
   {open a blank line, update display}
begin
   insert_line('');
   if cline-topline > scrlines-2 then
      scroll_screen(scrollsiz)
   else
      refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_delete_line;
   {delete the line at the cursor, update display}
begin
   delete_line;
   refresh_screen;
end;


(* ----------------------------------------------------------- *)
procedure display_insert_status;
begin
   position(61,2);
   if insert_mode then
      dGRAY('³  Insert Mode  ³')
   else
      dGRAY('³ Overtype Mode ³');
end;


(* ----------------------------------------------------------- *)
procedure display_message_header;
begin
   position(1,1);
   decode_status;
   display_header;
   reposition;
end;


(* ----------------------------------------------------------- *)
procedure prepare_screen;
var
   i: integer;
begin
   linenum := 1;
   clear_screen;
   update_status_display(normal_format);

   position(61,1);
   dGRAY('ÚÄVisual EditorÄ¿');
   display_insert_status;
   position(61,3);
   disp('³ (Ctrl-Z)=Help ³');
   position(61,4);
   disp('ÀÄ(Escape)=ExitÄÙ');

   position(1,6);
   show_margins;

   for i := 1 to scrlines do  {physical lines are now invalid}
      phyline[i] := '' {#0};
   pleft := -1;
   scroll_screen(0); {causes redisplay}
   display_message_header;
end;


(* ----------------------------------------------------------- *)
procedure redisplay;
begin
   topline := cline - scrlines div 2;
   prepare_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_help;
begin
   clear_screen;
   linenum := 2;
   display_file(visual_help_file);
   force_enter;
   prepare_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_display_original;
begin
   clear_screen;
   linenum := 2;
   display_original;
   prepare_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_quote_original;
begin
   linenum := 2;
   cmdline := '';
   position(1,statline-1);
   quote_from_original;
   prepare_screen;
end;


(* ----------------------------------------------------------- *)
procedure visual_edit;
var
   key:  char;
   i:    integer;

begin
   {determine screen size}
   statline := user.pagelen;
   if (statline > scroll_line) or (statline < 10) then
      statline := scroll_line;
   scrlines := statline-8;
   scrollsiz := scrlines-3;

   {disable function key polling during display}
   process_fkeys := false;

   {determine initial cursor and screen position}
   cline := linecnt;
   ccol := curlength+1;
   topline := 1;
   while (cline-topline) > (scrollsiz+3) do
      inc(topline,scrollsiz);

   {paint the initial screen}
   prepare_screen;


   {process visual commands}
   repeat
      key := get_key;

      {translate local keyboard/doorway keys into wordstar keys}
      if (key = #0) then
      begin
         key := get_key;

         {don't translate sysop keys if a caller is online}
         if (not local) and (key_source = sysop_key) then
         begin
            dispatch_function_key(key);
            key := #255;
         end
         else

         case key of
            'G':  key := ^W;     {Home}
            'H':  key := ^E;     {UpArrow}
            'I':  key := ^R;     {PgUp}
            'K':  key := ^S;     {LeftArrow}
            'M':  key := ^D;     {RightArrow}
            'O':  key := ^P;     {End}
            'P':  key := ^X;     {DownArrow}
            'Q':  key := ^C;     {PgDn}
            'R':  key := ^V;     {Ins}
            'S':  key := ^G;     {Del}
            's':  key := ^A;     {ctrl-LeftArrow}
            't':  key := ^F;     {ctrl-RightArrow}

            else
               if key_source = sysop_key then
               begin
                  dispatch_function_key(key);
                  reposition;
               end;
               key := #255;
         end;
      end;


      {translate vt102 / ansi-bbs keyboard into wordstar keys}
      if (key = #27) and (not local) then
      begin
         key := time_key(500);
         if key = '[' then key := get_key;
         if key = 'O' then key := get_key;

         case key of
            'A':  key := ^E;     {UpArrow}
            'B':  key := ^X;     {DownArrow}
            'C':  key := ^D;     {RightArrow}
            'D':  key := ^S;     {LeftArrow}
            'H':  key := ^W;     {Home}
            'K',                 {End - PROCOMM+}
            'R':  key := ^P;     {End - GT}
            'r':  key := ^R;     {PgUp}
            'q':  key := ^C;     {PgDn}
            'n':  key := ^V;     {Ins}

            #255: key := #27;    {timeout - escape key}
         end;
      end;


      {process each character typed}
      case key of
         ^A:      cursor_wordleft;
         ^B:      visual_reformat;
         ^C:      page_down;
         ^D:      cursor_right;
         ^E:      cursor_up;
         ^F:      cursor_wordright;
         ^G:      delete_char;
         ^I:      cursor_tab;
         ^J:      join_lines;
        {^K:      cancel and residplay}
         ^L:      redisplay;
         ^M:      cursor_newline;

         ^N:      begin
                     split_line;
                     reposition;
                  end;

         ^O:      visual_display_original;
         ^P:      cursor_endline;
         ^Q:      visual_quote_original;
         ^R:      page_up;
         ^S:      cursor_left;
         ^T:      delete_wordright;

         {^U:     exit visual}

         ^V:      begin
                     insert_mode := not insert_mode;
                     display_insert_status;
                     reposition;
                  end;

         ^W:      cursor_startline;
         ^X:      cursor_down;
         ^Y:      visual_delete_line;
         ^Z:      visual_help;

         #$7f,^H: begin
                     cursor_left;
                     if insert_mode then
                        delete_char;
                  end;

         ^U,
         #27:     ;

         ' '..#254:     {all other characters are self-inserting}
                  insert_char(key);
      end;

      if linenum >= 2000 then
         redisplay
      else
         reposition;

   until (key = #27) or (key = ^U) or dump_user;

   position(1,statline);
   process_fkeys := true;
   count_lines;
end;


