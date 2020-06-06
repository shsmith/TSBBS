
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
 * ProSM2 - ProDoor System Manager - Extended Conference edit module (3-1-89)
 *
 *)

var
   screen_entry:  integer;

(* -------------------------------------------------- *)
function file_ok(name: string): boolean;
var
   c: char;
begin
   file_ok := true;
   stoupper(name);
   fname := name;
   if dos_exists(name) then
      exit;

   clear_screen;
   needcls := true;

   gotoxy(4,10);
   write('Warning:  (',fname,') file does not exist.');

   gotoxy(4,12);
   write('Create it (Y/N)? ');

   repeat
      c := upcase(readkey);
   until (c = 'Y') or (c = 'N');
   write(c);

   gotoxy(4,15);
   if c = 'N' then
      exit;

   name := path_only(name);
   {$i-} mkdir(name); {$i+}
   if ioresult = 0 then
      write(name,' directory created.');

   gotoxy(4,17);
   file_ok := false;
end;


(* -------------------------------------------------- *)
procedure verify_mail;
var
   hdr:  msgs_header;
   fd:   file of msgs_header;

begin
   if file_ok(conf.conf_msgfile) then
      exit;

   writeln('Message file created ...');

   fillchar(hdr,sizeof(hdr),' ');
   zeros(hdr.himsg);
   zeros(hdr.lowmsg);
   zeros(hdr.msgcnt);
   zeros(hdr.callers);

   assign(fd,fname);
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then exit;

   write(fd,hdr);
   close(fd);
end;


(* -------------------------------------------------- *)
procedure check_index_size(name: string);
var
   c:    char;
   buf:  ^char;
   size: word;
   fsz:  word;
   mbk:  word;
   fd:   dos_handle;
   n:    word;
   i:    integer;

begin
   mbk := $10000 div sizeof(index_block);
   if conf.conf_msgblocks >= mbk then
      conf.conf_msgblocks := mbk-1;

   size := conf.conf_msgblocks*sizeof(index_block);
   fsz := file_size(name);
   if (fsz = size) or (fsz = 0) then
      exit;

   clear_screen;
   needcls := true;

   gotoxy(4,6);
   write('   Current index size = ',fsz div sizeof(index_block),' blocks.');
   gotoxy(4,7);
   write('Configured index size = ',size div sizeof(index_block),' blocks.');

   gotoxy(4,16);
   write('INSURE THAT YOU UPDATE YOUR CNAMES FILE AFTER ADJUSTING INDEX FILE');
   gotoxy(4,17);
   write('SIZES! OTHERWISE PCBOARD MAY RE-ADJUST THE FILES, INVALIDATING THEM.');

   gotoxy(4,10);
   write('Warning:  (',fname,') size is incorrect.');

   gotoxy(4,12);
   write('Adjust it (Y/N)? ');

   repeat
      c := upcase(readkey);
   until (c = 'Y') or (c = 'N');
   write(c);

   gotoxy(4,15);
   if c = 'N' then
      exit;

   dos_getmem(buf,size);
   fillchar(buf^,size,0);

   fd := dos_open(name,open_read);
   n := dos_read(fd,buf^,size);
   dos_close(fd);

   fd := dos_create(name);
   if fd <> dos_error then
   begin
      dos_write(fd,buf^,size);
      dos_close(fd);
   end;

   dos_freemem(buf);
   gotoxy(4,17);
end;


(* -------------------------------------------------- *)
procedure verify_index;
var
   fn:   filenames;
   blk:  index_block;
   fd:   file of index_block;
   i:    integer;

begin
   fn := conf.conf_msgfile+'.NDX';
   if file_ok(fn) then
   begin
      check_index_size(fn);
      exit;
   end;

   writeln('Index file created ...');
   fillchar(blk,sizeof(blk),0);

   assign(fd,fname);
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then exit;

   for i := 1 to conf.conf_msgblocks do
      write(fd,blk);
   close(fd);
end;



(* -------------------------------------------------- *)
procedure load_conf(cn: integer);
begin
   seek(confd,cn);
   {$i-} read(confd,conf); {$i+}
   if ioresult <> 0 then
      fillchar(conf,sizeof(conf),0);
end;

procedure save_conf(cn: integer);
begin
   if conf.conf_name <> '' then
   begin
      verify_mail;
      verify_index;
   end;

   if (conf.conf_name <> '') or (cn < maxcn) then
   begin
      seek(confd,cn);
      write(confd,conf);
   end;

   if cn >= maxcn then
      maxcn := filesize(confd);
end;


(* -------------------------------------------------- *)
   procedure init_defaults;
   var
      cdir:    string[30];
      cname:   string[8];
      i:       integer;

   begin
      cdir := conf.conf_name;
      load_conf(0);
      conf.conf_name := cdir;
      conf.conf_public := true;
      conf.conf_private_mail := false;
      conf.conf_echo_mail := true;
      conf.conf_addsec := 0;
      conf.conf_addtime := 0;
      conf.conf_minsec := 110;

      cdir := path_only(conf.conf_msgfile);
      cname := name_only(conf.conf_name);
      for i := 1 to length(cname) do
         case cname[i] of
            '0'..'9','a'..'z','A'..'Z','_','-':
               ;
            else
               cname[i] := '-';
         end;

      cdir := path_only(cdir) + '\' + cname + '\';

      conf.conf_msgfile  := cdir + cname;
      conf.conf_newsfile := cdir + cname[1] + 'NEWS';
   end;


(* -------------------------------------------------- *)
procedure edit_conf(cn: integer; var ex: char);
const
   maxent = 26;  {entries on screen}
var
   entry:   integer;
   isnew:   boolean;

   procedure proc_entry(func:  edit_functions);
   begin

      case entry of
         1: begin
               isnew := (conf.conf_name = '');
               edit_string(func,03,04, 'Area Name. . . . . . . . . . ',
                  conf.conf_name,sizeof(conf.conf_name),ex);  {name}
            end;

         2: edit_yesno(func,03,05,  'Public Conference. . . . . . ',
               conf.conf_public,ex);

         3: edit_integer(func,03,06,'Min. Security to Auto-Reg. . ',
               conf.conf_minsec,3,0,199,ex);

         4: edit_yesno(func,03,07,  'Make all Uploads Private . . ',
               conf.conf_private_ul,ex);

         5: edit_yesno(func,03,08,  'Make all Messages Private. . ',
               conf.conf_private_mail,ex);

         6: edit_yesno(func,45,04,  'Auto ReJoin on logon . . . . ',
               conf.conf_autojoin,ex);

         7: edit_yesno(func,45,05,  'Echo Mail in Conference. . . ',
               conf.conf_echo_mail,ex);

         8: edit_integer(func,45,06,'Added Security . . . . . . . ',
               conf.conf_addsec,3,-99,99,ex);

         9: edit_integer(func,45,07,'Added Time (minutes) . . . . ',
               conf.conf_addtime,3,0,999,ex);

        10: edit_integer(func,45,08,'Number of Message Blocks . . ',
               conf.conf_msgblocks,3,1,14,ex);


        11: edit_string(func,03,10, 'ProPack Command Options. . . ',
                  conf.conf_packopt,sizeof(conf.conf_packopt)-1,ex);

        12: edit_fname(func,03,11,  'Message File Path Name . . . ',
               conf.conf_msgfile,sizeof(conf.conf_msgfile)-1,false,ex);

        13: edit_fname(func,03,12,  'Conference News Path Name. . ',
               conf.conf_newsfile,sizeof(conf.conf_newsfile)-1,false,ex);

        14: edit_fname(func,03,13,  'Public Upload DIR File . . . ',
               conf.conf_public_uplist,sizeof(conf.conf_public_uplist)-1,false,ex);

        15: edit_fname(func,03,14,  'Public Upload Directory. . . ',
               conf.conf_updir,sizeof(conf.conf_updir)-1,true,ex);

        16: edit_fname(func,03,15,  'Private Upload DIR File. . . ',
               conf.conf_private_uplist,sizeof(conf.conf_private_uplist)-1,false,ex);

        17: edit_fname(func,03,16,  'Private Upload Directory . . ',
               conf.conf_private_updir,sizeof(conf.conf_private_updir)-1,true,ex);


        18: edit_fname(func,03,19, 'Doors . . . . . ',
               conf.conf_doormenu,28,false,ex);

        19: edit_fname(func,48,19, ' ',
               conf.conf_doorinfo,28,false,ex);

        21: edit_fname(func,03,20, 'Bulletins . . . ',
               conf.conf_bltmenu,28,false,ex);

        22: edit_fname(func,48,20, ' ',
               conf.conf_bltinfo,28,false,ex);

        24: edit_fname(func,03,21, 'File Areas. . . ',
               conf.conf_dirmenu,28,false,ex);

        25: edit_fname(func,48,21, ' ',
               conf.conf_dirinfo,28,false,ex);

        26: edit_fname(func,03,22, 'Download Paths. . . (Listing Only). . . . . . ',
               conf.conf_dlinfo,28,false,ex);
      end;

      select_next_entry(func,entry,maxent,ex);
   end;
   
label
   restart;

begin
   load_conf(cn);

   title_screen(3,23,'['+conf.conf_name+'] Message Area');

   gotoxy(2,24);
   disp('F2 [edit]    F3 [edit G]     F4 [find]     F9 [init]     F10 [update CNAMES]');
   gotoxy(2,25);
   disp('PgUp PgDn [select area]      Ctrl-PgUp Ctrl-PgDn [jump 10]');

   gotoxy(15,18);
   displn('          Menu File                     Listing File');

   gotoxy(70,1);
   write('Area:',cn:3);

   lowvideo;
   vscroll_bar(cn, 0, maxcn, 78,4,22);

restart:
   for entry := 1 to maxent do
      proc_entry(display);

   entry := screen_entry;
   ex := DOWN;
   repeat
      screen_entry := entry;
      proc_entry(edit);

     {if ex = F1 then
         help(8,8,'Conferences');}

      if (screen_entry = 1) and isnew and (conf.conf_name <> '') then
      begin
         init_defaults;
         goto restart;
      end;

   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);

   screen_entry := entry;
   save_conf(cn);
end;


(* -------------------------------------------------- *)
procedure find_conference(var cn: integer);
var
   ex:      char;
   n:       integer;
   newname: string[10];

begin
   edit_string(edit,03,04, 'Conference to locate . . . . ',
      conf.conf_name,sizeof(conf.conf_name),ex);  {name}

   newname := conf.conf_name;
   for n := 0 to maxcn do
   begin
      load_conf(n);
      if conf.conf_name = newname then
      begin
         cn := n;
         exit;
      end;
   end;
end;


(* -------------------------------------------------- *)
procedure edit_list(fname: anystring);
const
   entries = 15;
   rec_size = 30;
   max_rec = 2000;
type
   list_rec = array[1..rec_size] of char;
   list_array = array[1..max_rec] of list_rec;

var
   fd:   dos_handle;
   rec:  ^list_array;
   recs: integer;
   recn: integer;
   brec: integer;
   en:   filenames;
   ex:   char;

   procedure display_screen;
   var
      n:    word;
      r:    word;
   begin
      for n := 1 to entries do
      begin
         r := brec+n-1;
         lowvideo;
         gotoxy(10,n+4);
         if r > recs then
            write('':rec_size+8)
         else
         begin
            write(r:4,':');
            en := rec^[r];
            delete_trailing_spaces(en);
            edit_fname(display,18,n+4, '',en,rec_size,false,ex);
         end;
      end;
   end;


   procedure edit_rec;
   var
      n:    word;
   begin
      n := recn-brec+1;
      if (n < 1) or (n > entries-1) then
      begin
         brec := recn - (entries div 2);
         if brec > recs-(entries div 2) then
            brec := recs-(entries div 2);
         if brec < 1 then
            brec := 1;

         display_screen;
         n := recn-brec+1;
      end;

      lowvideo;
      gotoxy(10,n+4);
      write(recn:4,':');

      en := rec^[recn];
      delete_trailing_spaces(en);
      edit_fname(edit,18,n+4, '',en,rec_size,false,ex);

      for n := 1 to length(en) do
         rec^[recn][n] := en[n];
      for n := length(en)+1 to rec_size do
         rec^[recn][n] := ' ';
      select_next_entry(edit,recn,recs,ex);
   end;


   procedure delete_rec;
   var
      n: integer;
   begin
      if (recn > recs) or (recs < 2) then exit;
      dec(recs);
      for n := recn to recs do
         rec^[n] := rec^[n+1];
      display_screen;
   end;

   procedure insert_rec;
   var
      n: integer;
   begin
      if recs >= max_rec then
         exit;
      inc(recn);
      if recn <= recs then
         for n := recs downto recn do
            rec^[n+1] := rec^[n];
      inc(recs);
      fillchar(rec^[recn],rec_size,' ');
      display_screen;
   end;

begin
   if not dos_exists(fname) then
      fd := dos_create(fname)
   else
      fd := dos_open(fname,open_update);
   if fd = dos_error then exit;

   dos_getmem(rec,sizeof(rec^));
   fillchar(rec^,sizeof(rec^),' ');
   recs := dos_read(fd,rec^,sizeof(rec^)) div rec_size;
   dos_close(fd);

   brec := 1;
   recn := 1;
   if recs = 0 then
      inc(recs);

   repeat
      needcls := true;
      title_screen(3,23,'Editing '+fname);

      gotoxy(2,25);
      disp('ALT-D [delete]   ALT-I [insert]');
      disp('   F2 [edit]   F3 [edit G]');

      display_screen;

      repeat
         edit_rec;

         case ex of
            ALT_D:   delete_rec;
            ALT_I:   insert_rec;
         end;
      until (ex = ESC) or (ex = F2) or (ex = F3);

      if (ex = F2) or (ex = F3) then
         edit_text(en,ex);
   until ex = ESC;

   fd := dos_create(fname);
   dos_write(fd,rec^,recs*rec_size);
   dos_close(fd);
   dos_freemem(rec);

   clrscr;
   needcls := true;
end;


(* -------------------------------------------------- *)
procedure edit_dirs(fname: anystring);
const
   entries = 12;
   rec_size = 96;
   max_rec = 500;
type
   list_rec = record          {layout of dir.lst files}
      name:    char30;
      dir:     char30;
      descr:   char35;
      order:   byte;
   end;

   list_array = array[1..max_rec] of list_rec;

var
   fd:   dos_handle;
   rec:  ^list_array;
   recs: integer;
   recn: integer;
   brec: integer;
   ex:   char;
   entry:integer;

   procedure proc_entry(func:  edit_functions);
   var
      n:    integer;
      fld:  integer;
      y:    integer;

   begin
      n := ((entry-1) div 4);
      fld := ((entry-1) mod 4)+1;
      y := n*6+5;
      recn := n+brec;

      if recn > recs then
      begin
         gotoxy(3,y);   write('':60);
         gotoxy(3,y+1); write('':60);
         gotoxy(3,y+2); write('':60);
         gotoxy(3,y+3); write('':60);
         gotoxy(3,y+4); write('':60);
         ex := UP;
      end
      else

      case fld of
         1: begin
               gotoxy(3,y);
               highvideo;
               write('Directory ',recn:3);
               edit_byte(func,3,y+1,'   Sort Order. . . . . ',
                  rec^[recn].order,1,0,4,ex);
            end;

         2: edit_chars(func,3,y+2,  '   Description . . . . ',
               rec^[recn].descr,sizeof(char35),ex);

         3: edit_chars(func,3,y+3,  '   Listing file  . . . ',
               rec^[recn].name,sizeof(char30),ex);

         4: edit_chars(func,3,y+4,  '   File directory. . . ',
               rec^[recn].dir,sizeof(char30),ex);
      end;

   end;

   procedure display_screen;
   var
      n: integer;
      p: integer;
   begin
      p := entry;
      for n := 1 to entries do
      begin
         entry := n;
         proc_entry(display);
      end;
      entry := p;
   end;

   procedure delete_rec;
   var
      n: integer;
   begin
      if (recn > recs) or (recs < 2) then exit;
      dec(recs);
      for n := recn to recs do
         rec^[n] := rec^[n+1];
      display_screen;
   end;

   procedure insert_rec;
   var
      n: integer;
   begin
      if recs >= max_rec then
         exit;
      inc(recn);
      if recn <= recs then
         for n := recs downto recn do
            rec^[n+1] := rec^[n];
      inc(recs);
      fillchar(rec^[recn],rec_size,' ');
      display_screen;
   end;

begin
   if not dos_exists(fname) then
      fd := dos_create(fname)
   else
      fd := dos_open(fname,open_update);
   if fd = dos_error then exit;

   dos_getmem(rec,sizeof(rec^));
   fillchar(rec^,sizeof(rec^),' ');
   recs := dos_read(fd,rec^,sizeof(rec^)) div rec_size;
   dos_close(fd);

   brec := 1;
   entry := 1;
   recn := 1;
   if recs = 0 then
      inc(recs);

   repeat
      needcls := true;
      title_screen(3,23,'Editing '+fname);

      gotoxy(2,25);
      disp('ALT-D [delete]   ALT-I [insert]');
      disp('   F2 [edit]   F3 [edit G]');

      display_screen;

      repeat
         proc_entry(edit);

         case ex of
            ALT_D:   delete_rec;
            ALT_I:   insert_rec;

            F2,F3:
               case entry of
                  3: edit_text(rec^[recn].name,ex);
                  4: list_dir(rec^[recn].dir);
               end;

            UP:
               if (brec > 1) and (entry = 1) then
               begin
                  dec(brec);
                  inc(entry,3);
                  display_screen;
               end
               else if entry > 1 then
                  dec(entry);

            TAB, NEWLINE, DOWN:
               if (brec < recs) and (entry = entries) then
               begin
                  inc(brec);
                  dec(entry,3);
                  display_screen;
               end
               else if entry < entries then
                  inc(entry);
         end;
      until (ex = ESC) or (ex = F2) or (ex = F3);
   until ex = ESC;

   fd := dos_create(fname);
   dos_write(fd,rec^,recs*rec_size);
   dos_close(fd);
   dos_freemem(rec);
   needcls := true;
end;


(* -------------------------------------------------- *)
procedure edit_file(ex: char);
begin
   case screen_entry of
      13: edit_text(conf.conf_newsfile,ex);
      15: list_dir(conf.conf_updir);
      14: edit_text(conf.conf_public_uplist,ex);
      16: edit_text(conf.conf_private_uplist,ex);
      17: list_dir(conf.conf_private_updir);
      18: edit_text(conf.conf_doormenu,ex);
      19: edit_text(conf.conf_doorinfo,F2);
      21: edit_text(conf.conf_bltmenu,ex);
      22: edit_list(conf.conf_bltinfo);
      24: edit_text(conf.conf_dirmenu,ex);
      25: edit_dirs(conf.conf_dirinfo);
      26: edit_text(conf.conf_dlinfo,F2);
   end;
end;


(* -------------------------------------------------- *)
procedure open_extconf_file;
begin
   assign(confd,confinfo_file);
   fileMode := $42;
   {$i-} reset(confd); {$i+}
   if ioresult <> 0 then
      usage('Sorry, can''t open '+confinfo_file+'.  RUN PRODOOR TO CREATE THIS FILE.');
   maxcn := filesize(confd);
end;


(* -------------------------------------------------- *)
procedure set_defaults(cn: integer);
var
   ex:   char;
begin
   needcls := true;
   title_screen(3,23,'Initialize ['+conf.conf_name+'] Conference Definition');

   gotoxy(2,25);
   disp('PgDn [begin]');

   gotoxy(10,12);
   disp('Press PgDn to reset all defaults to match the Main Board.');
   gotoxy(10,14);
   disp('Press any other key to cancel this operation.');

   ex := get_key;
   needcls := true;
   if ex <> PGDN then
      exit;

   init_defaults;
   save_conf(cn);
end;


(* -------------------------------------------------- *)
procedure perform_cnames_update;
const
   flag: array[false..true] of integer = (0,-1);
var
   entry:   anystring;
   i:       integer;
   cn:      integer;
   oldfile: dos_filename;
   newfile: dos_filename;
   newfd:   text;
   fd:      text;

   procedure subs(s: anystring);
   begin
      readln(fd,entry);
      writeln(newfd,s);
   end;

   procedure isubs(i: integer);
   begin
      readln(fd,entry);
      writeln(newfd,i);
   end;

   procedure retain(n: integer);
   begin
      while n > 0 do
      begin
         dec(n);
         readln(fd,entry);
         writeln(newfd,entry);
      end;
   end;

begin
   gotoxy(10,18);
   disp('Working...');

   oldfile := cnames_file;
   assign(fd,oldfile);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
      usage('Can''t open '+oldfile);

   {create new CNAMES file}
   newfile := cnames_file;
   newfile[length(newfile)] := '$';

   assign(newfd,newfile);
   {$i-} rewrite(newfd); {$i-}
   if ioresult <> 0 then
      usage('Can''t create '+newfile);

   cn := 0;
   while not eof(fd) do
   begin
      load_conf(cn);
      subs(conf.conf_name);
      if conf.conf_autojoin then subs('-1') else subs('0');
      retain(1);
      isubs(flag[conf.conf_private_ul]);
      isubs(flag[conf.conf_private_mail]);
      isubs(flag[conf.conf_echo_mail]);
      isubs(conf.conf_addsec);
      isubs(conf.conf_addtime);
      isubs(conf.conf_msgblocks);
      subs(conf.conf_msgfile);
      retain(2);
      subs(conf.conf_newsfile);
      retain(1);
      subs(conf.conf_public_uplist);
      subs(conf.conf_updir);
      retain(1);
      subs(conf.conf_private_uplist);
      subs(conf.conf_private_updir);
      retain(1);
      subs(conf.conf_doormenu);
      subs(conf.conf_doorinfo);
      retain(1);
      subs(conf.conf_bltmenu);
      subs(conf.conf_bltinfo);
      retain(4);
      subs(conf.conf_dirmenu);
      subs(conf.conf_dirinfo);
      retain(1);
      subs(conf.conf_dlinfo);
      inc(cn);
      disp('.');
   end;

   close(fd);
   close(newfd);

   {rename old file}
   dos_unlink(oldfile+'.BAK');

   {$i-} rename(fd,oldfile+'.BAK'); {$i+}
   if ioresult <> 0 then
      usage('Could not rename '+oldfile+' to '+oldfile+'.BAK');

   {$i-} rename(newfd,oldfile); {$i+}
   if ioresult <> 0 then
      usage('Could not rename '+newfile+' to '+oldfile);
end;


(* -------------------------------------------------- *)
procedure update_cnames;
var
   ex:   char;
begin
   needcls := true;
   title_screen(3,23,'Update CNAMES File With CONFINFO Changes');

   edit_fname(edit,3,5, 'Cnames file to update? ',
              cnames_file,sizeof(cnames_file)-1,false,ex);

   gotoxy(2,25);
   disp('PgDn [begin]');

   gotoxy(5,9);
   disp('Press PgDn to update your '+cnames_file+' file with changes made');
   gotoxy(5,10);
   disp('in the CONFINFO file.');
   gotoxy(5,12);
   disp('Press any other key to cancel this operation.');
   gotoxy(5,15);
   disp('Warning: CNAMES changes made *only* in PCBSETUP will be lost!');

   ex := get_key;
   needcls := true;
   if ex <> PGDN then
      exit;

   perform_cnames_update;
end;


(* -------------------------------------------------- *)
procedure edit_extconf_file;
var
   cn:      integer;
   ex:      char;

begin
   open_extconf_file;
   needcls := true;
   cn := 0;

   repeat
      edit_conf(cn,ex);
      
      case ex of
         PGUP:       dec(cn);
         PGDN:       inc(cn);
         CTRL_PGUP:  dec(cn,10);
         CTRL_PGDN:  inc(cn,10);
         F2,F3:      edit_file(ex);
         F4:         find_conference(cn);
         F9:         set_defaults(cn);
         F10:        update_cnames;
      end;

      if maxcn > max_econf then
         maxcn := max_econf;

      if cn < 0 then
         cn := maxcn
      else
      if cn > maxcn then
         cn := 0;
      
   until ex = ESC;

   close(confd);
end;

