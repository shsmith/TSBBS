
(*
 * textinc - turbo extract include statements
 *
 *  usage:
 *     place source line into line_txt
 *     extract_include
 *     if there was an include, it will be placed into 'incfile'
 *     otherwise incfile will be ''
 *
 *)

(* scan the current line and extract the include filename, if any *)

procedure extract_include;
var
   i:     integer;

begin
   TRUNC(incfile);

   if LEN(line_txt) < 5 then
      exit;

   i := 1;
   while (i < LEN(line_txt)) and (line_txt[i] = ' ') do
      INCR(i);

   if line_txt[i] = '{' then
   begin
      if (line_txt[i+1] = '$') and
         (line_txt[i+2] in ['i','I']) and
         (line_txt[i+3] in [' ','a'..'z','A'..'Z']) then
      begin
         i := i + 3;
         while line_txt[i] = ' ' do
            INCR(i);

         while line_txt[i] in ['\','/',':','a'..'z','A'..'Z',
                               '0'..'9','_','-','.'] do
         begin
            CONCAT_CHAR(incfile, line_txt[i]);
            INCR(i);
         end;
      end;
   end
   else

   if line_txt[i] = '#' then
   begin
      if (copy(line_txt,i,9) = '#include ') then
      begin
         CONCAT_CHAR(line_txt, EOS);  {insure that there is a delimiter}

         i := i + 9;
         if line_txt[i] in ['<','"',''''] then
            INCR(i);

         while line_txt[i] in ['\','/',':','a'..'z','A'..'Z',
                               '0'..'9','_','-','.'] do
         begin
            CONCAT_CHAR(incfile, line_txt[i]);
            INCR(i);
         end;

         if line_txt[i] = '>' then   {search TPATH paths if <name>}
            incfile := locate_file_env(incfile,'TPATH=');
      end;
   end;
end;


