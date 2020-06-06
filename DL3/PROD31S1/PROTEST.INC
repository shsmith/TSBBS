
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
 * PCB ProDOOR module for the test-archive function (3-1-89)
 *
 *)

procedure test_archive;
begin
   if not verify_level(fun_test) then exit;

   (* select the archive (checks stacking, adds .arc and default) *)
   select_archive('test');
   if length(par) = 0 then
      exit;

   (* file is valid; list member files *)
   make_log_entry('TEST executed on file ('+remove_path(par)+')',true);

(***
   execute(cnf.test_command+' '+par);
   display_file(test_archive_file);
***)

   protocol := outside_batch;
   par1 := cnf.test_command+' '+par;
end;
