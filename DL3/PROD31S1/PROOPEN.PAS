
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
 * PCB ProDOOR module to open other doors (3-1-89)
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProOpen;

interface

   Uses
     Tools,
     MdosIO,
     ProData,
     ProRoot,
     ProTran;

   procedure do_open;


implementation

procedure do_open;
var
   n:                byte;
   entry:            integer;
   door_name:        string30;
   door_password:    string30;
   door_level:       integer;

begin

   if not verify_level(fun_door) then exit;

   (* prompt for a door number if needed *)
   if length(cmdline) = 0 then
   begin
      par := conf_info.conf_doormenu + '.' + itoa(userlevel);
      if dos_exists(par) then
         display_file(par)
      else
         display_file(conf_info.conf_doormenu);
      newline;
   end;

   n := 0;
   get_int('Enter the DOOR # to Open:',n);
   if (n < 1) or dump_user then
      exit;

   (* scan the door file for the specified entry *)
   openfile(conf_info.conf_doorinfo);
   if not ok then
      exit;

   entry := 0;
   repeat
      inc(entry);
      getstr(door_name,sizeof(door_name));
      getstr(door_password,sizeof(door_password));
      stoupper(door_password);
      getint(door_level);
   until (entry = n) or endfile;

   closefile;

   (* see if the selected door is available *)
   if (n <> entry) then
   begin
      not_available;
      exit;
   end;

   par := door_name;
   cons_path(dos_name,sys_dir,par);
   if (not dos_exists(dos_name)) then
      not_available
   else

   (* prepare to chain to the door if it is allowed to this user *)
   if verify_access(door_name, door_level, door_password,
                    'Insufficient security for DOOR') then
   begin
      make_log_entry('Opened DOOR ('+door_name+') at '+system_time,false);
      protocol := opening_door;
      par1 := door_name;
   end;
end;

end.

