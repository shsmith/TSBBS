
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
 * PCB ProDOOR sysop-chat mode and operator-page (3-1-89)
 *
 *)

procedure chat_mode;
var
   pc:     char;
   c:      char;
   
begin

{$IFNDEF IN_PROEDIT}
   (* prevent recursive chat and suspend function key polling *)
   if chat_active then
      exit;

   chat_active := true;
   pcbsys.display := '-1';

   newline;
   newline;
   write('Press (ESC) to exit chat mode.  ');
   make_log_entry('Sysop CHAT active at '+system_time,true);
   display_file(enter_chat_file);

   c := '?';

   repeat
      linenum := 1;
      set_function(fun_chat);

      pc := c;
      c := get_key;
   
      if key_source = sysop_key then 
         disp(GREEN) 
      else 
         disp(WHITE);
      
      case c of
         ^J,^Z,#255,#27:  ;

         ' ':  if wherex > 78 then
                  newline
               else
                  space;

         #127,
         ^H:   if wherex > 1 then
                  disp(^H' '^H);

         ^M:   newline;

         else  begin
                  if ((pc = ' ') and (wherex > 68)) or (wherex > 78) then
                     newline;
                  dispc(c);
               end;
      end;

   until ((c = #27) and (key_source = sysop_key)) or (c = carrier_lost);

   newline;
   make_log_entry('Sysop CHAT ended at '+system_time,true);
   newline;

   chat_active := false;
{$ENDIF}

end;



(*
 * Page the system operator
 *
 *)

procedure operator_page;
var
   i: integer;
   c: char;

begin

{$IFNDEF IN_PROEDIT}
   if not verify_level('O') then exit;

   make_log_entry('Operator Paged at '+system_time,false);

   if (pcbsys.page_bell[1] <> '-') then
   begin
      displn('Sysop is not available.');
      exit;
   end;   

   newline;
   write('Press (Space) to answer page, anything else to ignore.');
   newline;

   dRED('Page ends in 30 seconds.  (Ctrl-K) Aborts.');

   for i := 1 to 30 do
   if (not keypressed) and (linenum < 1000) then
   begin
      if odd(i) then write(^G);
      disp('.');
      delay(1000);
   end;

   if keypressed then
   begin
      c := readkey;
      if (c = ' ') then
         chat_mode
      else
      if (c = #0) then
         process_function_keys;
   end
   else

   begin
      newline;
      newline;
   end;
{$ENDIF}

end;

