
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
 * ProSM3 - ProDoor System Manager - Extended User File edit module (3-1-89)
 *
 *)

procedure init_extuser;
var
   r: integer;
begin
   bopen(usrfd, user_file, 25, sizeof(user));
   if berr then
      usage('Can''t open '+user_file);
   
   bseekeof(usrfd);
   maxuser := btell(usrfd);

   extfd := dos_open(extuser_file, open_update);
   if extfd = dos_error then
   begin
      bclose(usrfd);
      usage('Can''t open '+extuser_file);
   end;
   
   determine_extsize(extfd);
end;


(* -------------------------------------------------- *)
procedure prepare_screen;
begin
   needcls := true;
   title_screen(3,23,'Extended User File Editor');
   gotoxy(2,24);
   disp('F2   [next 40]       F3   [prior 40]        F4  [find user]');
   gotoxy(2,25);
   disp('PgDn [next user]     PgUp [prior user] ');

   lowvideo;
   gotoxy( 4,4); disp('User Name:');
   gotoxy(58,4); disp('User Rec:');

   gotoxy( 4,5); disp('Times in ProDoor:');
   gotoxy(55,5); disp('ExtUser Rec:');

   gotoxy(54,6); disp('Last in Door:');

   gotoxy( 3,9);
   disp('Cnf Mem- Last İCnf Mem- Last İCnf Mem- Last İCnf Mem- Last İCnf Mem- Last');
   gotoxy(3,10);
   disp('No. ber  Read İNo. ber  Read İNo. ber  Read İNo. ber  Read İNo. ber  Read');
   gotoxy(3,11);
   disp('ÄÄÄÄÄÄÄÄÄÄÄÄÄ İÄÄÄÄÄÄÄÄÄÄÄÄÄ İÄÄÄÄÄÄÄÄÄÄÄÄÄ İÄÄÄÄÄÄÄÄÄÄÄÄÄ İÄÄÄÄÄÄÄÄÄÄÄÄÄ ');
end;


(* -------------------------------------------------- *)
procedure find_name;
var
   i:       integer;
   r:       integer;
   line:    string[25];
   uname:   char25;
   ex:      char;

begin
   line := '';
   edit_string(edit,23,4,'',line,25,ex);
   if length(line) = 0 then
      exit;

   lowvideo;
   fillchar(uname,sizeof(uname),' ');
   for i := 1 to length(line) do
      uname[i] := upcase(line[i]);

   bseek(usrfd,0);
   i := 0;
   while i < maxuser do
   begin
      vscroll_bar(i, 0, maxuser-1, 78,4,21);
      bread(usrfd,user);

      if uname = user.name then
      begin
         usern := i;
         highvideo;
         disp_int(68,4,usern);
         disp_int(68,5,user.extrarec);

         (* ask for inputs ONLY on prodoor users *)
         if user.flags = 32 then
         begin
            gotoxy(68,6);
            disp('[FLAGS] ');
            delay(1000);
         end
         else
         begin
            read_extrec(extfd);

            if user.name <> extuser.fixed.name then
            begin
               gotoxy(68,6);
               disp('[NAME]  ');
               delay(1000);
            end;
         end;

         exit;
      end
      else
         inc(i);
   end;
end;
   

(* -------------------------------------------------- *)
procedure update_basecn(offset: integer);
var
   cn:   integer;
   x,y:  integer;

begin
   for y := 12 to 21 do
   begin
      gotoxy(3,y);
      disp('              İ              İ              İ              İ               ');
   end;

   basecn := basecn + offset;

   for cn := 0 to 49 do
      if cn+basecn <= (max_conf+extcount) then
      begin
         x := (cn div 10) * 15 + 3;
         y := (cn mod 10) + 12;
         gotoxy(x,y);
         write(cn+basecn:2,': ');
      end;
end;


(* -------------------------------------------------- *)
const
   maxent = 103;

procedure proc_entry(func:        edit_functions;
                     var entry:   integer;
                     var ex:      char);
var
   x,y:  integer;
   cn:   integer;
   fld:  integer;
   ptr:  word;
   lev:  word;

begin

   case entry of
      1: edit_word (func, 4, 6, 'Earned K Bytes:    ',
            user.earned_k,5,0,$FFF0,ex);

      2: begin
            lev := user.level;
            edit_word (func, 4, 7, 'Security Level:    ',
               lev,3,0,255,ex);
            user.level := lev;
         end;

      3: begin
            if ord(extuser.fixed.lockreg) > 1 then
               extuser.fixed.lockreg := false;
            edit_yesno (func, 50,7, 'Lock Conferences: ',
               extuser.fixed.lockreg,ex);
         end;

   else
      cn := ((entry-4) div 2);
      fld := (entry-4) mod 2;
      x := (cn div 10) * 15 + 3;
      y := (cn mod 10) + 12;
      cn := cn + basecn;

      if (cn >= 0) and (cn <= (max_conf+extcount)) then
      with extuser.conf[cn] do
      begin

         case fld of
            0:    edit_bit(func,x+5,y,'',ext_member,extuser.conf[cn].flags,ex);

            1:    begin
                     ptr := stol(lastread);
                     edit_word(func,x+8,y,'',ptr,5,0,$FFFF,ex);
                     if func=edit then
                        ltos(ptr,lastread);
                  end;
         end;

(******
         if ex = F4 then
         begin
            edit_flags(cn);
            ex := '?';
         end;
*****)
      end;
   end;

   select_next_entry(func,entry,maxent,ex);
end;


(* -------------------------------------------------- *)
procedure edit_extuser_file;
var
   cen:  integer;
   i:    integer;
   c:    char;

begin
   usern := 0;
   cen := 1;
   basecn := 0;
   init_extuser;

   prepare_screen;
   update_basecn(0);

   c := PGDN;
   repeat
      if usern < 0 then
         usern := maxuser-1
      else 
      if usern >= maxuser then
         usern := 0;

      bseek(usrfd,usern);
      bread(usrfd,user);
      data_changed := false;

      lowvideo;
      vscroll_bar(usern, 0, maxuser, 78,4,21);

      highvideo;
      gotoxy(23,4); disp(user.name);
      disp_int(68,4,usern);
      disp_int(68,5,user.extrarec);

      (* ask for inputs ONLY on prodoor users *)
      if user.flags = 32 then
      begin
         gotoxy(68,6);
         disp('[FLAGS] ');
      end
      else

      begin
         read_extrec(extfd);

         if user.name <> extuser.fixed.name then
         begin
            gotoxy(68,6);
            disp('[NAME]  ');
         end
         else

         begin
            load_extrec;

            disp_int(23,5,user.dooruse);
            gotoxy(68,6); disp(extuser.fixed.lastdate);
            extn := user.extrarec;

            for i := 1 to maxent do
               proc_entry(display,i,c);

            repeat
               c := DOWN;
               proc_entry(edit,cen,c);
            until (c <> UP) and (c <> DOWN);

            if data_changed then
            begin
               write_extrec(extfd);
               save_extrec;
               bseek(usrfd,usern);
               bwrite(usrfd,user);
            end;
         end;
      end;

      case c of
         PGDN: inc(usern);

         PGUP: dec(usern);

        {F1:   help(8,8,'User Data');}

         F2:   if basecn <= ((max_conf+extcount)-50) then
                  update_basecn(40);

         F3:   if basecn >= 40 then
                  update_basecn(-40);

         F4:   begin
                  find_name;
                  c := PGDN;
               end;
      end;

   until c = ESC;  {exit on these}
   
   bclose(usrfd);
   dos_close(extfd);
end;


