
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
 * PCB ProDOOR sysop control panel handlers (3-1-89)
 *
 *)

procedure adjust_timing;
   (* adjust time-left based on current function crediting *)
var
   now:        longint;
   duration:   longint;
   adj:        longint;

begin

{$IFNDEF IN_PROEDIT}
{$IFNDEF IN_PROKIT}

   now := lget_time;
   if curctl.timefact <> 1 then
   begin
      if now < curstart then
         dec(curstart,86400);

      duration := now - curstart;
      adj := trunc(int(duration) * (1.0-curctl.timefact));

   (**
   if setdebug then
   writeln(dbfd,'[adjust: fun=',curfun,' dur=',duration,' adj=',adj,' now=',now,' start=',curstart,']');
   **)

      adjust_time_allowed(adj);
   end;
   curstart := now;
{$ENDIF}
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure set_function(func: char);
   (* select this function for current time and bytecount crediting *)
begin

   if func <> curfun then 
   begin
      {a function change has been detected; charge for time spent in
       previous function}
      
      adjust_timing;
      curfun := func;
      curctl := control[curfun];
      update_status_display(normal_format);
   end;

end;


(* ------------------------------------------------------------ *)
function check_level(func:     char): boolean;       {function letter}
   (* check access level for a function, select this function for
      current time and bytecount crediting, no warning if not allowed *)
begin
   {set_function(func);}
   check_level := userlevel >= control[func].minlevel {curctl.minlevel};
end;


(* ------------------------------------------------------------ *)
function verify_level(func:     char): boolean;       {function letter}
   (* verify access level for a function, select this function for
      current time and bytecount crediting *)
begin
   if check_level(func) then
   begin
      {set_function(func);}
      set_function(func);
      verify_level := true;
   end
   else

   begin

{$IFNDEF IN_PROEDIT}
      newline;
      make_log_entry('Sorry, ('+par+') is not available at your security level.',true);
      verify_level := false;
      par := '';
      cmdline := '';
{$ENDIF}

   end;
end;


(* ------------------------------------------------------------ *)

{-------------
procedure control_dump;
   (* dump the contents of the sysop control table *)
var
   c: char;

begin      
   newline;
   displn('   Level Time* Byte*');
   for c := min_control to max_control do
   if nomore = false then
      displn(c + ftoa(control[c].minlevel,6,0) +
                 ftoa(control[c].timefact,6,1) +
                 ftoa(control[c].bytefact,6,1));
end;
--------------}
