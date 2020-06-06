
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
 * PCB ProDOOR conference registration update (3-1-89)
 *
 *)

procedure conference_registration;
var
   pconf:   integer;

   procedure select;
   var
      n: integer;
      first: integer;
   begin
      get_nextpar;
      if length(par) = 0 then
         first := 0
      else
         first  := lookup_conference_number(par);
      if first < 0 then
         exit;

      for n := first to conf_count do
      begin
         if select_conference(n) then
         begin
            get_defyn('Scan  '+ljust('['+conf_info.conf_name + ']',13),
                      getflag(extuser.conf[n].flags,ext_scan));
            if par[1] = 'Q' then exit;
            setflag(extuser.conf[n].flags,ext_scan, (par[1] = 'Y'));
         end;
      end;

   end;

begin
   if not verify_level(fun_confreg) then exit;

   newline;
   make_log_entry('Auto-join configuration update',true);
   newline;
   pconf := user.curconf;

   select;

   if select_conference(pconf) then ;
   cmdline := '';
   par := '';   
end;


