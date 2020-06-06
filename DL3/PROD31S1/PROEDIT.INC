
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
 * PCB ProDOOR edit message module for ProMail unit (3-1-89)
 *
 *)

procedure save_header;
   {rewrite the message header, if it was changed}
begin
   bseek(mbfd,msgpos);
   bwrite(mbfd,header);
   bflush(mbfd);
   {displn('Changes saved ...');}
end;


procedure edit_header;
   {modify fields in the message header}

   procedure entry(title:  anystring;
                   var     bufptr;
                   len:    integer;
                   caps:   boolean);
   var
      buf:  array[1..100] of char   absolute bufptr;
      i:    integer;

   begin
      {convert from a char array into a string}

      if cmdline = '' then
      begin
         {display a prompt that lines up with this variable}
         disp_margin(1+length(title),len);

         {list old, ask for new}
         disp(title);
         disp(': ');

         cmdline := '';
         for i := 1 to len do
            cmdline := cmdline + buf[i];
         delete_trailing_spaces(cmdline);

         line_input(cmdline,len,true,true);
         newline;
      end;

      if caps then
         stoupper(cmdline);
      fill_chars(buf,cmdline,len);
      cmdline := '';
   end;


begin
   repeat
      decode_status;

      if cmdline = '' then
      begin
         newline;
         display_header;
         newline;
         dYELLOW('(D)ate, T(i)me, (E)cho, (T)o, (F)rom, (S)ubject, (P)assword');
         newline;
         get_defen('Header Edit Command:');
      end;

      if dump_user then exit;
      get_nextpar;
      newline;

      if par = '' then
      begin
         save_header;
         exit;
      end;

      with header do
      case par[1] of
         'D':  entry('Date',     header.Date,      sizeof(header.Date),true);
         'I':  entry('Time',     header.Time,      sizeof(header.Time),true);
        {'R':  entry('Refer To', header.ReferTo,   sizeof(header.ReferTo));}
         'T':  entry('Who To',   header.WhoTo,     sizeof(header.WhoTo),true);
         'F':  entry('Who From', header.WhoFrom,   sizeof(header.WhoFrom),true);
         'S':  entry('Subject',  header.Subject,   sizeof(header.Subject),false);
         'P':  entry('Password', header.Password,  sizeof(header.Password),true);

         'E':  if header.echoflag = 'E' then
                  header.echoflag := ' '
               else
                  header.echoflag := 'E';
      end;

      Subject := header.Subject;
      WhoTo := header.WhoTo;

   until true=false;
end;


procedure edit_message;

   procedure save_text;
      {convert the text back into PCBoard's block format and
       write it to the file}
   var
      i,j:       integer;
      c:         char;
      pos:       integer;
      len:       integer;
      pure:      boolean;

      procedure put(c: char);
      begin
         inc(pos);
         raw^[pos] := c;
         if (pos mod 128) = 1 then
            pure := (c <> endline)
         else
         if c = endline then
            pure := false;
      end;

   begin
      {convert the lines back into a block of bytes}
      pos := 0;
      pure := true;
      for i := 1 to linecnt do
      begin
         for j := 1 to length(lines^[i]) do
            put(lines^[i][j]);
       { if pos >= maxpos then
            displn('Error: text truncated on line '+itoa(i)); }
         put(endline);
      end;

      {check for block overflows}
      len := 1;
      if pos > maxpos then
      begin
         displn('Changes NOT saved (I can''t expand an existing message!)');
         exit;
      end
      else

      {pad to the end of the record with blanks.   add endlines once in a while
       so PCBPACK won't screw up the file later on...}
      while pos < maxpos-1 do
      begin
         if len > 70 then
         begin
            put(endline);
            len := 1;
         end
         else
            put(' ');
      end;

      {make sure that no blocks have pure spaced.  PCBPACK will corrupt the
       message file if this happens}
      if pure then
         put(endline)
      else
         put(' ');

      {write the text portion of the message back to the file}
      bseek(mbfd,msgpos+1);
      for i := 1 to txtblocks do
         bwrite(mbfd,block^[i]);
      bflush(mbfd);

      displn('Changes saved ...');
   end;


   procedure edit_list;
      {list all text lines in the current message - edit mode}
   var
      i: integer;
   begin
      newline;
      decode_status;
      display_header;
      newline;
      show_margins;

      for i := 1 to linecnt do
      if nomore = false then
      begin
         show_line_number(i);
         dGRAY(lines^[i]);
         newline;
      end;
   end;


var
   i: integer;

begin
   for i := linecnt+1 to pcbsetup.msg_lines do
      lines^[i] := '';

   visual_edit;
{  if graphics then
      visual_edit
   else
      edit_list; }

   while true do
   begin
      count_lines;
      if msgpos < 1 then
         exit;

      newline;
      dYELLOW('(D)el, (E)dit, (H)eader, (I)ns, (L)ist, (Q)uit, (S)ave, (V)isual? ');
      get_hcmdline; {command('');}
      get_nextpar;
      if dump_user then exit;

      if par <> '' then
      begin
         newline;
         count_lines;

         case par[1] of
            'E':  edit_line;
            'L':  edit_list;
            'I':  insert_text;
            'D':  delete_text;

            'S':  begin
                     save_text;
                     exit;
                  end;
                  
            'H':  edit_header;

            'V':  visual_edit;

            'Q':  exit;

            else  not_understood;
         end;
      end;
   end;

end;

