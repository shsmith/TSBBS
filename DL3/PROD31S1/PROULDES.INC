
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


(* ------------------------------------------------------------ *)
procedure get_upload_description(prompt: string80; var desc: string);
var
   i:       integer;
   empty:   integer;

begin
   if length(prompt) = 1 then
      disp_margin(1,45);
   desc := '';
   par := '';
   empty := 0;

   {input the required part of the description.  re-prompt
    if user leaves this too short}

   repeat
      dYELLOW(prompt);
      space;
      no_hotkeys;
      line_input(par,46,true,true);

      if length(par) = 0 then
      begin
         inc(empty);
         if (empty > 1) and (length(prompt) = 1) then
         begin
            newline;
            exit;
         end;
      end;

      if length(par) < min_desc then
      begin
         newline;
         displn('Enter a longer description of the file please!');
      end;
   until (length(par) >= min_desc) or dump_user;


   {input the rest of the description; use word-wrap
    between lines}

   repeat
      {need to wordwrap?  delete partial word and start it on the next line}
      prepare_word_wrap(par,i,45);

      {move the partial word to the start of the next line}
      if length(desc) > 0 then
         desc := desc + #255;
      desc := desc + copy(par,1,i-1);
      par := copy(par,i+1,45);

      if length(desc) < 213 then
      begin
         for i := 1 to length(prompt)-1 do
            space;
         dYELLOW('? ');
         line_input(par,46,true,true);
      end;

   until (length(par) = 0) or dump_user;

   newline;
   if dump_user  then
      desc := '<no description given>';
end;


