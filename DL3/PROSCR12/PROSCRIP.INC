
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *  NOTICE: ALL MODIFIED VERSIONS OF THIS PROGRAM _MUST_ BE DISTRIBUTED
 *          WITH SOURCE CODE.  I STRICTLY FORBID THE USE OF ANY NON-
 *          PUBLIC INFORMATION IN MODIFICATIONS.  FOR EXAMPLE, YOU
 *          CANNOT USE CDC PROVIDED INFORMATION FOR PCBOARD 14.5
 *          COMPATIBILITY, SINCE SUCH A VERSION CANNOT BE RELEASED IN
 *          SOURCE CODE.
 *)


(*
 * script questionnaire processing
 * sets ok=true if a script was answered
 *)


(* ---------------------------------------------- *)
function valid_answer(cmdline,chk: anystring): boolean;
   {insure that cmdline meets chk criteria}
var
   valid:   boolean;
   i:       integer;
   c:       char;
const
   bad:     integer = 0;

begin
   stoupper(cmdline);
   stoupper(chk);
   while length(cmdline) <= length(chk) do
      cmdline := cmdline +'~';

   valid := true;
   c := cmdline[1];

   if chk = '' then
      {no validation required}
   else

   if chk[2] = '?' then
   begin
      valid := (c = 'Y') or (c = 'N');
      if not valid then
         pdispln('  Please begin response with Y or N!');
   end
   else

   for i := 2 to length(chk) do
   if valid then
   begin
      c := cmdline[i-1];
      case chk[i] of
         '#':  begin
                  valid := (c >= '0') and (c <= '9');
                  if not valid then
                     pdispln('  Response must be 0-9 instead of '+c+'!');
               end;

         '$':  begin
                  valid := (c <> '~'{end_of_line});
                  if not valid then
                     pdispln('  Response required at column '+itoa(i-1)+'!');
               end;

         '_':  ;

         else  begin
                  valid := c = chk[i];
(***
                  if not valid then
                     pdispln('  Response must be '+chk[i]+' instead of '+c+'!');
***)
               end;
      end;
   end;

   if not valid then
   begin
      inc(bad);
      if bad >= 10 then
      begin
         pdispln('  Too many invalid responses!  Script aborted ...');
         ok := false;
      end
      else
      begin
         pdispln('  Invalid response - Please re-enter!');
      end;

      newline;
   end;

   valid_answer := valid;
end;


(* ---------------------------------------------- *)
procedure process_script( script_file, answer_file: dos_filename );
const
   prefix = 5;    {prefix lines}
   maxans = 200;  {maximum number of answers}
var
   answer:  array[1..maxans] of varstring;
   answers: integer;


   (* ---------------------------------------------- *)
   procedure ask_script;
   var
      ifd:  text;
      ques: anystring;
      i:    integer;
      chk:  anystring;
      len:  integer;

   begin
      AssignText(ifd,script_file);
      {$i-} reset(ifd); {$i+}
      if ioresult <> 0 then exit;

      default_color;
      for i := 1 to prefix do
      begin
         readln(ifd,ques);
         spaces(2);
         pdispln(ques);
      end;

      answers := 0;
      newline;
      get_defyn('  Complete the script questionnaire:',false);
      if par[1] <> 'Y' then
      begin
         close(ifd);
         ok := false;
         exit;
      end;

      newline;
      chk := '';

      while (not eof(ifd)) and ok and (not dump_user) do
      begin
         readln(ifd,ques);

         if copy(ques,1,1) = ';' then
         begin
            ques[1] := ' ';
            pdispln('$GREEN$ '+ques);
         end
         else

         if copy(ques,1,1) = '\' then
            chk := ques
         else

         if answers < maxans then
         begin
            newline;
            repeat
               pdispln('$YELLOW$  '+ques);

               if chk = '' then
                  len := 65
               else
                  len := length(chk)-1;
               disp_margin(1,len);

               pdisp('? ');
               cmdline := '';
               input(cmdline,len);
               newline;
            until dump_user or valid_answer(cmdline,chk) or (not ok);

            inc(answers);
            savestr(answer[answers],cmdline);
            chk := '';
         end;
      end;

      close(ifd);

      if (answers = 0) or dump_user then
         ok := false;
   end;


   (* ---------------------------------------------- *)
   procedure save_script;
   var
      ifd:  text;
      ofd:  text;
      ques: anystring;
      i:    integer;

   begin
      make_log_entry('Questionnaire Information Saved ...',true);

      AssignText(ifd,script_file);
      {$i-} reset(ifd); {$i+}
      if ioresult <> 0 then exit;
      for i := 1 to prefix do
         readln(ifd,ques);

      AssignText(ofd,answer_file);
      {$i-} append(ofd); {$i+}
      if ioresult <> 0 then exit;

      writeln(ofd,'**************************************************************');
      writeln(ofd,'From: ',username,', ',system_date,' (',system_time,')');

      i := 0;
      while not eof(ifd) do
      begin
         readln(ifd,ques);

         if (copy(ques,1,1) <> ';') and (copy(ques,1,1) <> '\')  then
         begin
            writeln(ofd,'Q: ',ques);

            inc(i);
            if i <= answers then
            begin
               writeln(ofd,'A: ',answer[i]^);
               releasestr(answer[i]);
            end
            else
               writeln(ofd,'A: ');
         end;
      end;

      close(ifd);
      close(ofd);
   end;

begin
   fillchar(answer,sizeof(answer),0);
   ok := true;
   ask_script;

   if ok then
      save_script;
end;


(* ---------------------------------------------- *)
(**********
procedure script_menu;
begin
   {Questionnaire # to Answer (Enter)=none}
   if GetEnv('TEST') = 'SCRIPT' then
      process_script( 'script1','script.out');
   cmdline := '';
end;
**********)
