
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
 * PCB ProDOOR expert toggle handler (3-1-89)
 *
 *)

procedure log_onoff(what: string30; state: boolean);
const
   onoff: array[boolean] of string[4] = (' OFF', ' ON');
begin
   newline;
   make_log_entry(what + onoff[state],true);
   wait_for_enter;
end;
      

(* ----------------------------------------------------- *)
procedure expert_toggle;
begin
   if not verify_level('X') then exit;
   if user.expert = 'Y' then
      user.expert := 'N'
   else
      user.expert := 'Y';
   log_onoff('Expert Mode',user.expert = 'Y'{toggleflag(user.flags,flag_expert)});
end;


(* ----------------------------------------------------- *)
procedure mode_toggle;
begin
   if not verify_level('M') then exit;
   if pcbsys.graphics = 'Y' then
      pcbsys.graphics := 'N'
   else
      pcbsys.graphics := 'Y';
   graphics := pcbsys.graphics = 'Y';

   if not graphics then
      disp(ansi_reset);
   log_onoff('Graphics Mode',graphics);
end;


(* ----------------------------------------------------- *)
procedure snoop_toggle;
begin
   update_user := not update_user;
   update_read := update_user;
   log_onoff('Snoop Mode',not update_user);
end;


(* ----------------------------------------------------- *)
procedure hotkey_toggle;
begin
   if not verify_level('H') then exit;
   log_onoff('Hotkey Mode',toggleflag(user.flags,flag_hotkeys));
end;


(* ----------------------------------------------------- *)
procedure scan_toggle;
begin
   if not verify_level(fun_confreg) then exit;
   log_onoff('AutoScan [@INCONF@] is',
         toggleflag(extuser.conf[user.curconf].flags,ext_scan));
end;

