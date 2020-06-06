
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
 * ProSM1 - ProDoor System Manager - Config file edit module (3-1-89)
 *
 *)

procedure save_config_file;
var
   fd:   text;
   i:    integer;
   c:    char;

   procedure outln(s: string);
   begin
      writeln(fd,s);
   end;

   procedure outs(s: string);
   begin
      write(fd,s);
   end;

begin
   dispnl;
 { displn('Saving configuration file ... '); }

   assign(fd,config_file);
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then exit;

 { outln(';'); }
   outln('; ProDoor 3.1 configuration file');
   outln('; Use PROSM.EXE to edit this file.');
 { outln(';'); }
 { outln('; Driver, spare, Overhead, Playpen, Hold dir, Hold list'); }

   if bios_comm then
      if bios_echo then
         outln('BIOS')
      else
         outln('PCBTRAP')
   else
      outln('INTERRUPT');

   outln('spare');
   writeln(fd,cnf.overhead:0:0);
   outln(cnf.playpen_dir);
   outln(cnf.trashcan_dir);
   outln(cnf.trashcan_list);
 { outln(';'); }

 { outln('; ZIPM limit, ZIPM filename prefix'); }
   writeln(fd,max_capcount);
   outln(cnf.mail_prefix);

   if cnf.scratch_dir = cnf.playpen_dir then
   begin
      inc(cnf.scratch_dir[5]);
      displn('The SCRATCH directory has been changed to: '+cnf.scratch_dir);
   end;

 { outln('; SCRATCH directory, SCRATCH filename prefix'); }
   outln(cnf.scratch_dir);

   if cnf.scratch_prefix = cnf.mail_prefix then
   begin
      inc(cnf.scratch_prefix[4]);
      displn('The SCRATCH prefix has been changed to: '+cnf.scratch_prefix);
   end;

   outln(cnf.scratch_prefix);

 { outln(';');
   outln('; Archive manipulation commands');
   outln(';  list members, text to stdout, xtract file to file, test, rearc, fail msg'); }
   outln(cnf.listing_command);
   outln(cnf.typetext_command);
   outln(cnf.xtract_command);
   outln(cnf.test_command);
   outln(cnf.rearc_command);
   outln(cnf.badarc_keymsg);

 { outln(';');
   outln('; Spares'); }
   for i := 1 to 5 do
      outln('spare');

 { outln(';');
   outln('; Ansi color codes; red green yellow blue magenta cyan whyte gray'); }
   for i := 1 to 8 do
      outln(ansi_colors[i]);

   outln(';');
 { outln('; Extended security table');
   outln('; Min-level, Time factor, Byte factor'); }
   for c := min_control to max_control do
      with control[c] do
         writeln(fd,minlevel,' ',timefact:0:1,' ',bytefact:0:1);

   outln(';');
 { outln('; Protocol table'); }
   outln('; %efficiency, Code, ErrorFree, Direction, Maxfiles, Title ; Command line');
   for i := 1 to cnf.protocol_count do
      with cnf.protocol_table[i] do

      if length(title^) > 0 then
      begin
         if peffic < 0.1 then
            outs('0');
         write(fd,peffic*100:0:0,' ',code);

         if efree then
            outs(' 1')
         else
            outs(' 0');

         if mode = RX then
            outs(' R ')
         else
            outs(' T ');

         writeln(fd,files,' ',title^);
         outln(command^);
         outln(';');
      end;

   close(fd);
end;


(* -------------------------------------------------- *)
procedure general_config(var ex: char);
const
   maxent = 11;  {entries on screen}
var
   entry:  integer;
   pentry: integer;

   procedure proc_entry(func:  edit_functions);
   begin
      case entry of
         1: edit_yesno  (func,   4, 5,
               'Use slow BIOS com driver (Y/N). . . . . ',bios_comm,ex);
         2: if bios_comm then
            edit_yesno  (func,   4, 6,
               'Filter PCBTRAP echo (Y/N) . . . . . . . ',bios_echo,ex);

         3: edit_real   (func,   4, 8,
               'Transfer overhead time (seconds). . . . ',cnf.overhead,4,0,ex);

         4: edit_string (func,   4,10,
               'Held (duplicate) upload listing . . . . ',cnf.trashcan_list,30,ex);

         5: edit_string (func,   4,12,
               'Held (duplicate) upload directory . . . ',cnf.trashcan_dir,30,ex);
         6: edit_string (func,   4,13,
               'Transfer "PLAYPEN" directory. . . . . . ',cnf.playpen_dir,30,ex);
         7: edit_string (func,   4,14,
               'Directory for SCRATCH files . . . . . . ',cnf.scratch_dir,30,ex);

         8: edit_string (func,   4,16,
               'Prefix for SCRATCH file names . . . . . ',cnf.scratch_prefix,5,ex);
         9: edit_string (func,   4,17,
               'Prefix for ZIPM file names. . . . . . . ',cnf.mail_prefix,5,ex);

        10: edit_integer(func,   4,19,
               'Max number of messages per ZIPM run . . ',max_capcount,5,0,maxint,ex);
      end;

      select_next_entry(func,entry,maxent,ex);
   end;
   
label
   restart;
begin

   pentry := 1;
restart:
   title_screen(3,23,'General Configuration');

   gotoxy(2,24);
   disp('F2   [edit]');
   gotoxy(2,25);
   disp('PgDn [next page]      PgUp [prior page]');

   for entry := 1 to maxent do
      proc_entry(display);

   ex := DOWN;
   entry := pentry;

   repeat
      proc_entry(edit);
     {if ex = F1 then
         help(8,8,'General');}

      if (ex = F2) or (ex = F3) then
      begin
         pentry := entry;
         case entry of
            4: edit_text(cnf.trashcan_list,ex);
            5: list_dir (cnf.trashcan_dir);
            6: list_dir (cnf.playpen_dir);
            7: list_dir (cnf.scratch_dir);
         end;
         goto restart;
      end;

   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);

end;


(* -------------------------------------------------- *)
procedure archive_config(var ex: char);
const
   maxent = 6;  {entries on screen}
var
   entry:  integer;

   procedure proc_entry(func:  edit_functions);
   begin
      case entry of
         1: edit_string (func,   4, 7,
               'Files listing command . . . . . . . . . ',cnf.listing_command,30,ex);
         2: edit_string (func,   4, 9,
               'Type files to console command . . . . . ',cnf.typetext_command,30,ex);
         3: edit_string (func,   4,11,
               'Extract from file to file command . . . ',cnf.xtract_command,30,ex);
         4: edit_string (func,   4,13,
               'Test archive integrity command. . . . . ',cnf.test_command,30,ex);
         5: edit_string (func,   4,15,
               'Repack archive command. . . . . . . . . ',cnf.rearc_command,30,ex);
         6: edit_string (func,   4,17,
               'Test failure message suffix . . . . . . ',cnf.badarc_keymsg,30,ex);
      end;

      select_next_entry(func,entry,maxent,ex);
   end;
   
begin
   title_screen(3,23,'Archive Manupilation Configuration');

   gotoxy(2,25);
   disp('PgDn [next page]      PgUp [prior page]');

   for entry := 1 to maxent do
      proc_entry(display);

   entry := 1;
   ex := DOWN;
   repeat
      proc_entry(edit);
     {if ex = F1 then
         help(8,8,'Archives');}
   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);
end;


(* -------------------------------------------------- *)
procedure security_config(var ex: char; base,limit: char);
const
   names:   array[min_control..max_control] of string[30] = 
      ('(0) Idle time . . . . . . ',
       '(1) Download batch. . . . ',
       '(2) Upload batch. . . . . ',
       '(3) Private message entry ',
       '(4) Reply message . . . . ',
       '(5) Archive view. . . . . ',
       '(6) Archive extract . . . ',
       '(7) Sysop chat. . . . . . ',
       '(8) Zip mail scan . . . . ',
       '(9) Library request . . . ',
       '(:) RePack  . . . . . . . ',
       '(;) Test Archive. . . . . ',
       '(<) Config Conferences. . ',
       '(=) ALL Sysop Mail Cmds . ',
       '(>) Node Status . . . . . ',
       '(?) spare                 ',
       '(@) spare                 ',
       '(A) Abandon conference. . ',
       '(B) Bulletins listings. . ',
       '(C) Comment to sysop. . . ',
       '(D) Download (single) . . ',
       '(E) Enter message (public)',
       '(F) File listings . . . . ',
       '(G) Goodbye . . . . . . . ',
       '(H) Hotkeys . . . . . . . ',
       '(I) spare                 ',
       '(J) Join conference . . . ',
       '(K) Kill message. . . . . ',
       '(L) Locate file . . . . . ',
       '(M) Mode (graphics) . . . ',
       '(N) New files scan. . . . ',
       '(O) Operator page . . . . ',
       '(P) Quit to BBS . . . . . ',
       '(Q) Quick scan. . . . . . ',
       '(R) Read mail . . . . . . ',
       '(S) spare                 ',
       '(T) Table of protocols. . ',
       '(U) Upload (single) . . . ',
       '(V) View user profile . . ',
       '(W) Write user info . . . ',
       '(X) Xpert . . . . . . . . ',
       '(Y) Your mail . . . . . . ',
       '(Z) Zip search. . . . . . ',
       '([) Open door . . . . . . ');

var
   maxent: integer;
   entry:  integer;

   procedure proc_entry(func:  edit_functions);
   var
      ctl: char;
      line: integer;

   begin
      line := (entry-1) div 3;
      ctl := chr(line + ord(base));

      if (ctl >= min_control) and (ctl <= max_control) then
      if length(names[ctl]) > 0 then

      with control[ctl] do
         case (entry-1) mod 3 of
            0: edit_integer (func, 4, line+7,   names[ctl]+'    ', 
                                                minlevel,4,0,999,ex);

            1: edit_real (func, 50, line+7, '', timefact,6,1,ex);

            2: edit_real (func, 65, line+7, '', bytefact,6,1,ex);
         end;

      select_next_entry(func,entry,maxent,ex);
   end;
   
begin
   title_screen(3,23,'Extended Security Configuration');

   gotoxy(2,25);
   disp('PgDn [next page]      PgUp [prior page]');

   gotoxy(11,5); 
   disp('Function         Security Level    Time Factor    Byte Factor');

   maxent := 3 * (ord(limit)-ord(base)+1);
   for entry := 1 to maxent do
      proc_entry(display);

   entry := 1;
   ex := DOWN;
   repeat
      proc_entry(edit);
     {if ex = F1 then
         help(8,8,'Security');}
   until (ex <> UP) and (ex <> DOWN) and (ex <> F1);
end;


(* -------------------------------------------------- *)
procedure protocol_config(var ex: char);
const
   maxent = 35; {entries on screen}

var
   base:   integer;
   entry:  integer;
   prot:   integer;
   y:      integer;

   procedure edit_vstring(func:     edit_functions;
                          x,y:      integer;
                          prompt:   string;
                          var data: varstring;
                          width:    integer);
   var
      temp: string;
   begin
      if data = nil then
         savestr(data,'');
      temp := data^;
      edit_string(func,x,y,prompt,temp,width,ex);
      savestr(data,temp);
   end;
                             
   procedure edit_mode(func:     edit_functions;
                       x:        integer;
                       var data: transfer_modes);
   var
      temp: string2;
   begin
      if data = RX then
         temp := 'R'
      else
         temp := 'T';

      edit_string(func,x,y,'',temp,1,ex);

      if upcase(temp[1]) = 'R' then
         data := RX
     else
         data := TX;
   end;
                             
   procedure edit_efree(func:     edit_functions;
                        x:        integer;
                        var data: boolean);
   var
      temp: string2;
   begin
      if data then
         temp := 'Y'
      else
         temp := 'N';

      edit_string(func,x,y,'',temp,1,ex);

      data := upcase(temp[1]) = 'Y';
   end;
                             
                             
   procedure proc_entry(func:  edit_functions);
   var
      line: integer;

   begin
      line := (entry-1) div 7;
      y := line*3 + 8;
      prot := line + base;

      with cnf.protocol_table[prot] do
      begin
         case (entry-1) mod 7 of
            0: edit_vstring(func, 4,y,'',title,35);
            1: edit_chars  (func,42,y,'',code,1,ex);
            2: edit_mode   (func,48,mode);
            3: edit_integer(func,56,y,'',files,2,0,max_files,ex);
            4: edit_real   (func,64,y,'',peffic,4,2,ex);
            5: edit_efree  (func,73,efree);
            6: edit_vstring(func,4,y+1,'Cmd line: ',command,60);
         end;
         
         if (prot > cnf.protocol_count) and (length(title^) > 0) then
            cnf.protocol_count := prot;
      end;

      select_next_entry(func,entry,maxent,ex);
   end;
   
begin
   title_screen(3,23,'Extended Protocol Configuration');

   gotoxy(2,25);
   disp('PgDn [next page]      PgUp [prior page]      F10 [delete]');

   gotoxy(14,5);  
   disp('Protocol                   Menu  Trans/  File  Estimated  Error');

   gotoxy(14,6);  
   disp('  Name                     Code  Recv    Specs   Effic.   Free');

   base := 1;
   repeat
      for entry := 1 to maxent do
         proc_entry(display);
   
      entry := 1;
      ex := DOWN;
      repeat
         proc_entry(edit);
        {if ex = F1 then
            help(8,8,'Protocols');}
      until (ex <> UP) and (ex <> DOWN) and (ex <> F1);
      
      case ex of
         PGDN:  inc(base,5);
         PGUP:  dec(base,5);

         F10:   fillchar(cnf.protocol_table[prot],
                         sizeof(cnf.protocol_table[prot]),0);
      end;

   until (ex = ESC) or (base < 0) or (base > cnf.protocol_count+1);
end;

   
(* -------------------------------------------------- *)
procedure edit_config_file;
const
   maxscr = 7;
var
   scrnum:  integer;
   ex:      char;

begin
   scrnum := 1;
   repeat
      needcls := true;

      case scrnum of
         1: general_config(ex);
         2: archive_config(ex);
         3: security_config(ex,'0','=');
         4: security_config(ex,'>','L');
         5: security_config(ex,'M','[');
         6: protocol_config(ex);
      end;
      
      case ex of
         PGUP:    dec(scrnum);
         PGDN:    inc(scrnum);
      end;

      if scrnum < 1 then
         scrnum := maxscr
      else
      if scrnum > maxscr then
         scrnum := 1;
      
   until ex = ESC;
end;

