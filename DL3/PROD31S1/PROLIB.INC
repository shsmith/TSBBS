
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
 * PCB ProDOOR module to access CD-ROM libraries (3-1-89)
 *
 *)

procedure request_library;
var
   i:                integer;
   code:             longint;
   hicode:           longint;
   prefix:           string;
   line:             string;

begin
   if not verify_level(fun_lib) then exit;

   (* verify that there is a library definition file *)
   if not dos_exists(library_menu) then
   begin
      not_available;
      exit;
   end;

   (* prompt for a disk number if needed *)
   if cmdline = '' then
   begin
      display_file(library_menu);
      newline;
      get_defen('Enter the library disk # to request:');
   end;

   newline;
   get_nextpar;
   if (par = '') or dump_user then
      exit;

   val(par,code,i);
   par := itoa(code);

   dYELLOW('Checking ... ');

   (* scan the door file for the specified entry *)
   openfile(library_table);
   if not ok then
      exit;

   prefix := '';
   hicode := 0;
   while (not endfile) and (code > hicode) do
   begin
      getline(line,sizeof(line)-1);
      if line[1] <> ';' then
      begin
         i := posc(' ',line);
         prefix := copy(line,i+1,255);
         line[0] := chr(i-1);
         val(line, hicode, i);
      end;
   end;
   closefile;

   (* see if the selected door is available *)
   if (code < 1) or (code > hicode) then
   begin
      not_available;
      exit;
   end;

   newline;
   make_log_entry('Request Library Disk '+par,true);
   display_file(library_help_file);

   protocol := outside_batch;
   par1 := 'prolib '+result_path+' '+prefix+par+' '+par + ' ' + cnf.scratch_dir;
end;
