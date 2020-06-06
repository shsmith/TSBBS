
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
 * ProSM6 - ProDoor System Manager - Pack extuser file module (3-1-89)
 *
 *)

procedure pack_extuser_file;
var
   usern:   word;
   r:       integer;
   newfd:   buffered_file;
   newfile: dos_filename;
   space:   word;
   needed:  word;
   drive:   char;
   fd:      file;
   ex:      char;

begin
   needcls := true;
   title_screen(3,23,'Pack Extended User File');

   gotoxy(2,25);
   disp('PgDn [begin]');

   gotoxy(10,13);
   disp('All NODES must be offline during this process!');

   ex := get_key;
  {if ex = F1 then
      help(18,5,'Pack');}
   if ex <> PGDN then
      exit;

   clear_screen;
   gotoxy(1,23);
   displn('Packing EXTUSER file ...');
   writeln;

   if extuser_file[2] = ':' then
      drive := extuser_file[1]
   else
   begin
      getdir(0,newfile);
      drive := newfile[1];
   end;

   space := disk_space(drive);
   needed := (file_size(extuser_file) div 1024) + 100;

   if space < needed then
   begin
      writeln('Not enough free disk space!');
      writeln('Drive ',drive,': has ',space,'k free, but you need ',needed,'k!');
      pause;
      exit;
   end;

   init_extuser;

   {create new extuser}
   newfile := extuser_file;
   newfile[length(newfile)] := '$';
   bcreate(newfile);
   
   bopen(newfd,newfile,50,extsize);
   if berr then
   begin
      bclose(usrfd);
      usage('Can''t create '+newfile);
   end;

   {copy header record}
   dos_rseek(extfd,0,extsize,seek_start);
   r := dos_read(extfd,extuser,extsize);
   bwrite(newfd,extuser);

   {process all user records}
   for usern := 0 to maxuser-1 do
   begin
      vscroll_bar(usern, 0, maxuser-1, 78,1,20);

      bseek(usrfd,usern);
      bread(usrfd,user);

      (* check for prodoor extended conferences *)
      if user.flags <> 32 then
      begin
         dos_rseek(extfd,user.extrarec,extsize,seek_start);
         r := dos_read(extfd,extuser,extsize);

         if user.name = extuser.fixed.name then
         begin
            user.extrarec := btell(newfd);
            bseek(usrfd,usern);
            bwrite(usrfd,user);
            bwrite(newfd,extuser);
        end;
      end;

   end;

   gotoxy(1,25);
   bclose(newfd);
   bclose(usrfd);
   dos_close(extfd);

   {rename old extuser file}
   dos_unlink(extuser_file);
   assign(fd,newfile);
   {$i-} rename(fd,extuser_file); {$i+}
   if ioresult <> 0 then
      usage('Could not rename '+newfile+' to '+extuser_file);

   pause;
end;
