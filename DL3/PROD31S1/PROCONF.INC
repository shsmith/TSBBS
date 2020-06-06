
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
 * PCB ProDOOR configuration file processing (3-1-89)
 *
 *)


procedure load_config_file;
   (* load the prod.cnf configuration file *)

{$IFDEF IN_PROEDIT}
begin
{$ELSE}

var
   i:     integer;
   temp:  anystring;
   c:     char;
   

   procedure config_error(why: anystring);
   begin
{$i-} writeln('Error: ',why);
      writeln('   entry = [',temp,']');
{$i+}
{$IFNDEF IN_PROCONF}
      usage('Bad config file');
{$ENDIF}
   end;

   procedure configline(var line: string; max: integer);
   begin
      repeat
         getline(line,max);
      until length(line) > 0;  {line:=^Z at endfile}
   end;
   
   procedure getfile(var line: filenames);
      (* get a system filename specification *)
   begin
      configline(line,sizeof(line)-1);
      stoupper(line);
      delete_spaces(line);
   end;

   procedure getdirect(var line: filenames);
      (* get a directory specification *)
   begin
      getfile(line);

{$IFNDEF IN_PROCONF}
      if line[2] <> ':' then
         config_error('Missing "Drive:\"');
{$ENDIF}

      (* remove trailing "\" if found (except ROOT directories) *)
      if (line[length(line)] = '\') and (length(line) > 3) then
         dec(line[0]);
   end;

   procedure verify_directory(line: filenames);
   begin
{$IFNDEF IN_PROCONF}
      (* create the directory if needed *)
      {$i-} mkdir(line); {$i+}
      if ioresult = 0 then
{$i-}    writeln(line,' directory created.'); {$i+}
{$ENDIF}
   end;

   function getf: real;
   begin
      configline(temp,20);
      getf := atof(temp);
   end;

   procedure getndir(var line: filenames);
   begin
      getdirect(line);
      if pcbsetup.under_network then
         line := line + pcbsetup.node_number^;
      verify_directory(line);
   end;

   procedure gettemp;
   begin
      configline(temp,sizeof(temp)-1);
   end;

begin
   (* load and interpret the configuration file *)
   getdir(0,home_dir);

   readbas_comment := ';';
   openfile(config_file);
   if not ok then
      file_missing;

(* load general configuration *)
   gettemp;
   stoupper(temp);
   bios_echo := true;

   if not local then
   begin
      if (temp[1] = 'I'{NTERRUPT'}) or (temp[1] = 'H'{ANDSHAKE'}) then
         bios_comm := false
      else
      if temp[1] = 'P'{CBTRAP'} then
         bios_echo := false;
   end;
   
   gettemp;

   cnf.overhead := getf;

   getndir(cnf.playpen_dir);

   getdirect(cnf.trashcan_dir);
   verify_directory(cnf.trashcan_dir);

   getfile(cnf.trashcan_list);


   max_capcount := trunc(getf);

   configline(cnf.mail_prefix,7);
   getndir(cnf.scratch_dir);
   configline(cnf.scratch_prefix,7);

   if cnf.scratch_dir = cnf.playpen_dir then
   begin
      inc(cnf.scratch_dir[5]);
{$IFDEF IN_PROCONF}
      displn('CONFIG ERROR: SCRATCH directory has been changed to: '+cnf.scratch_dir);
{$ELSE}
      par3 := cnf.scratch_dir;
      pdispln('CONFIG ERROR: SCRATCH directory has been changed to: $3$');
{$ENDIF}
   end;

   if cnf.scratch_prefix = cnf.mail_prefix then
   begin
      inc(cnf.scratch_prefix[4]);
{$IFDEF IN_PROCONF}
      displn('CONFIG ERROR: SCRATCH prefix has been changed to: '+cnf.scratch_prefix);
{$ELSE}
      par3 := cnf.scratch_prefix;
      pdispln('CONFIG ERROR: SCRATCH prefix has been changed to: $3$');
{$ENDIF}
   end;

   (* get archive command lines *)
   configline(cnf.listing_command,sizeof(cnf.listing_command));
   configline(cnf.typetext_command,sizeof(cnf.typetext_command));
   configline(cnf.xtract_command,sizeof(cnf.xtract_command));
   configline(cnf.test_command,sizeof(cnf.test_command));
   configline(cnf.rearc_command,sizeof(cnf.rearc_command));
   configline(cnf.badarc_keymsg,sizeof(cnf.badarc_keymsg));

   (* spare configuration fields *)
   for i := 1 to 5 do
      gettemp;


(* load color codes *)
   for i := 1 to 8 do
      configline(ansi_colors[i],sizeof(color_string));


(* load extended security control codes *)
   for c := min_control to max_control do
   with control[c] do
   begin
      repeat
         {$i-} read(curfd,minlevel, timefact, bytefact); {$i+}
      until (ioresult = 0) or endfile;
      readln(curfd);
   end;
   
{$IFNDEF IN_PROCONF}
   curfun := '0';
   curctl := control[curfun];
   curstart := lget_time;
{$ENDIF}

(* load protocol table *)
   cnf.protocol_count := 0;
   gettemp;

   while temp[1] <> ^Z do
   begin
      if cnf.protocol_count < max_proto then
         inc(cnf.protocol_count);
(***
      else
         displn('Too many protocol entries in '+dos_name);
***)

      with cnf.protocol_table[cnf.protocol_count] do
      begin
         peffic := int(atoi(copy(temp,1,2))) / 100.0;
         code := temp[4];

         if temp[6] < 'R' then
         begin
            efree := temp[6] = '1';
            delete(temp,6,2);
         end
         else
            efree := false;

         if temp[6] = 'R' then
            mode := RX
         else
            mode := TX;

         files := atoi(copy(temp,8,2));
         if temp[10] = ' ' then
            delete(temp,1,1);
         savestr(title,copy(temp,10,99));

         configline(temp,sizeof(temp));
         savestr(command,temp);

         gettemp;
      end;
   end;

   closefile;
   readbas_comment := '#';
{$ENDIF}

end;


