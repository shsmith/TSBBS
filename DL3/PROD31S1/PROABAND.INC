
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
 * PCB ProDOOR abandon conference (3-1-89)
 *
 *)

procedure select_main_board;
begin
   if pcbsys.curconf <> 0 then
   begin
      if not verify_level('A') then exit;

      newline;
      make_log_entry('@INCONF@ Conference Abandoned',true);

      userlevel := userlevel - conf_info.conf_addsec;
   end;
   
   if select_conference(0) then ;

{$IFNDEF IN_PROEDIT}
   build_download_list;
{$ENDIF}
end;


procedure abandon_conference;
begin
   par := '0';
   unget_par;
   join_conference;

(***********
   select_main_board;

   {check for quick join option}
   if cmdline[1] = 'Q' then
      get_nextpar;

   newline;
   display_conference_info;   
   wait_for_enter;
***********)

end;

