
(*
 * fmt05 - filter to reformat RASM05 sources into neet columns
 *
 * Author: S. H. Smith, 9-Apr-86
 *
 *)

{$g10240,p1024,d-}

type
   anystring = string[128];


var
   input_line:       anystring;
   output_position:  integer;



procedure output_space;
begin
   write(' ');
   output_position := output_position + 1;
end;


procedure skip_spaces;
begin
   while copy(input_line,1,1) = ' ' do
      input_line := copy(input_line,2,length(input_line));
end;


procedure copy_until_space;
begin
   while (input_line > '') and (input_line[1] <> ' ') do
   begin
      write(input_line[1]);
      input_line := copy(input_line,2,length(input_line));
      output_position := output_position + 1;
   end;

   skip_spaces;
end;


procedure tab_output_to(column: integer);
begin
   repeat
      output_space;
   until output_position >= column;
end;


procedure process_comment_or_opcode;
var
   is_branch: boolean;
   opcode:    anystring;

begin
   tab_output_to(9);
   skip_spaces;

   opcode := copy(input_line,1,3);

   if (opcode = 'RTS') or (opcode = 'RTI') or (opcode = 'JMP') then
      is_branch := true
   else
   if opcode[1] = 'B' then
      if (opcode <> 'BSE') and (opcode <> 'BCL') then
         is_branch := true
      else
         is_branch := false
   else
      is_branch := false;


   copy_until_space;    {OPCODE}

   if input_line = '' then
   begin
      if is_branch then writeln;
      exit;
   end;

   if (opcode <> 'SEI') and (opcode <> 'CLI') and (opcode <> 'TAX') and
      (opcode <> 'TXA') and (opcode <> 'RTS') and (opcode <> 'RTI') then
   begin
      tab_output_to(17);
      copy_until_space;    {OPERAND}
      if input_line = '' then
      begin
         if is_branch then writeln;
         exit;
      end;
   end;

   tab_output_to(35);   {COMMENTS}
   write(';',input_line);
   if is_branch then writeln;
end;


procedure process_label;
begin
   writeln;
   copy_until_space;
   process_comment_or_opcode;
end;


begin
   while not eof do
   begin

      readln(input_line);
      output_position := 1;

      if input_line[1] in ['0'..'9'] then
         input_line := copy(input_line,6,length(input_line));
                                         {delete line numbers, if needed}

      if input_line = '' then
         write('')
      else

      if input_line[1] = ' ' then
         process_comment_or_opcode
      else

      if input_line[1] = '*' then
         write(input_line)
      else

      if input_line[1] in ['A'..'Z'] then
         process_label
      else
         write(input_line);    {shouldn't happen}

      writeln;
   end;

end.
