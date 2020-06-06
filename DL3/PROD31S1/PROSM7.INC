
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
 * ProSM7 - ProDoor System Manager - Renumber conference module (3-1-89)
 *
 *)

procedure renumber_conference;

var
   entry:   integer;
   ex:      char;

const
   onum:    integer = 1;
   nnum:    integer = 2;
   maxent = 2;

   procedure proc_entry(func:        edit_functions);
   begin

      case entry of
         1: edit_integer(func,5,6, 'Original conference number: ',
               onum, 3, 0, (max_conf+extcount), ex);

         2: edit_integer(func,5,8, 'New conference number:      ',
               nnum, 3, 0, (max_conf+extcount), ex);
      end;

      select_next_entry(func,entry,maxent,ex);
   end;


   (* -------------------------------------------------- *)
   procedure perform_update;
   var
      usern:   word;
      haveext: boolean;
      temp:    extuser_conf_rec;
      tconf:   pcbconf_rec;
      changed: boolean;

   begin
      clear_screen;
      gotoxy(1,10);
      displn('Swapping CONFINFO records ...');
      writeln;
      writeln;

      open_extconf_file; {opens confd}
      load_conf(onum);
      tconf := conf;

      load_conf(nnum);
      save_conf(onum);
      writeln('  [',conf.conf_name,'] is now conference ',onum,'.');

      conf := tconf;
      save_conf(nnum);
      writeln('  [',conf.conf_name,'] is now conference ',nnum,'.');

      close(confd);

      writeln;
      if (onum < 40) or (nnum < 40) then
         writeln('Remember to update your CNAMES file!');

      gotoxy(1,22);
      displn('Updating USERS file ...');
      writeln;
      init_extuser; {opens usrfd AND extfd}

      for usern := 0 to maxuser-1 do
      begin
         vscroll_bar(usern, 0, maxuser-1, 78,1,20);

         bseek(usrfd,usern);
         bread(usrfd,user);

         (* check for prodoor extended conferences *)
         haveext := false;
         if user.flags <> 32 then
         begin
            read_extrec(extfd);
            if user.name = extuser.fixed.name then
               haveext := true;
         end;

         (* swap conference information *)
         load_extrec;

         if getflag(extuser.conf[onum].flags,ext_member) or
            getflag(extuser.conf[nnum].flags,ext_member) then
         begin
            temp := extuser.conf[onum];
            extuser.conf[onum] := extuser.conf[nnum];
            extuser.conf[nnum] := temp;

            (* save user data *)
            if haveext then
               write_extrec(extfd);
            save_extrec;
            bseek(usrfd,usern);
            bwrite(usrfd,user);
         end;

      end;

      gotoxy(1,25);

      bclose(usrfd);
      dos_close(extfd);
      pause;

      if (onum < 40) or (nnum < 40) then
         update_cnames;
   end;


(* -------------------------------------------------- *)
begin
   needcls := true;
   title_screen(3,23,'Renumber Conference');

   {open and close files to verify they are ok, and to get recsize}
   init_extuser;
   bclose(usrfd);
   dos_close(extfd);

   gotoxy(2,25);
   disp('PgDn [begin]');

   gotoxy(8,12);
   disp('All NODES must be offline during this process!');

   gotoxy(8,15);
   disp('All information for OLD CONFERENCE NUMBER and NEW CONFERENCE NUMBER');
   gotoxy(8,16);
   disp('will be EXCHANGED in USERS and EXTUSER files.');

   gotoxy(8,19);
   disp('You MUST update your CNAMES file if you renumber');
   gotoxy(8,20);
   disp('conference numbers less than 40!');

   ex := DOWN;
   for entry := 1 to maxent do
      proc_entry(display);

   entry := 1;
   repeat
      proc_entry(edit);
     {if ex = F1 then
         help(18,12,'Renumber');}
   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);

   if ex = PGDN then
      perform_update;
end;

