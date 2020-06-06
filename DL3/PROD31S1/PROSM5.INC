
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
 * ProSM5 - ProDoor System Manager - Insert/Remove conference module (3-1-89)
 *
 *)

procedure insert_group(insert: boolean);

var
   entry:   integer;
   ex:      char;

const
   cmin:    integer = 1;
   cmax:    integer = 1;
   minlev:  integer = 10;
   maxlev:  integer = 10;
   maxent = 10;


   procedure proc_entry(func:        edit_functions);
   begin

      case entry of
         1: edit_integer(func,5,8 ,'Minimum security level:  ',
               minlev, 3, 0, 120, ex);

         2: edit_integer(func,5,10,'Maximum security level:  ',
               maxlev, 3, 0, 120, ex);

         3: edit_integer(func,5,14,'First conference number: ',
               cmin, 3, 0, (max_conf+extcount), ex);

         4: edit_integer(func,5,16,'Last conference number: ',
               cmax, 3, 0, (max_conf+extcount), ex);

      end;

      select_next_entry(func,entry,maxent,ex);
   end;


   (* -------------------------------------------------- *)
   procedure perform_update;
   var
      usern:      word;
      haveext:    boolean;
      i:          integer;
      changed:    boolean;
      member:     boolean;
      cn:         integer;
      userlevel:  integer;

   begin
      clear_screen;
      lowvideo;
      gotoxy(1,23);
      displn('Scanning USERS file ...');
      writeln;
      init_extuser;

      for usern := 0 to maxuser-1 do
      begin
         vscroll_bar(usern, 0, maxuser-1, 78,1,20);

         bseek(usrfd,usern);
         bread(usrfd,user);
         changed := false;

         if (user.expdate[1] = '0') or (user.expdate >= user.date) then
            userlevel := user.level
         else
            userlevel := user.explevel;

         (* process only users in specified range *)
         if (userlevel >= minlev) and (userlevel <= maxlev) then
         begin

            (* check for prodoor extended conferences *)
            haveext := false;
            if user.flags <> 32 then
            begin
               read_extrec(extfd);
               if user.name = extuser.fixed.name then
                  haveext := true;
            end;

            load_extrec;

            for cn := cmin to cmax do
            begin
               member := getflag(extuser.conf[cn].flags,ext_member);
               if insert and (not member) then
               begin
                  setflag(extuser.conf[cn].flags,ext_member+ext_scan,true);
                  changed := true;
               end
               else

               if (not insert) and member then
               begin
                  setflag(extuser.conf[cn].flags,ext_member+ext_scan,false);
                  changed := true;
               end;
            end;


            if changed then
            begin
               py := -1;   {force scroll bar update}

               if haveext then
                  write_extrec(extfd);

               save_extrec;
               bseek(usrfd,usern);
               bwrite(usrfd,user);

               gotoxy(1,25);
               disp(user.name);
               if insert then
                  displn(' inserted.')
               else
                  displn(' removed.');
            end;
         end;

      end;

      gotoxy(1,25);

      bclose(usrfd);
      dos_close(extfd);
      pause;
   end;


(* -------------------------------------------------- *)
begin
   needcls := true;
   if insert then
      title_screen(3,23,'Insert Group Conference')
   else
      title_screen(3,23,'Remove Group Conference');

   init_extuser;
   dos_close(extfd);

   gotoxy(2,25);
   disp('PgDn [begin]');

   ex := DOWN;
   for entry := 1 to maxent do
      proc_entry(display);

   entry := 1;
   repeat
      proc_entry(edit);
     {if ex = F1 then
         help(45,5,'Insert/Remove Group');}
   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);

   if ex = PGDN then
      perform_update;
end;

