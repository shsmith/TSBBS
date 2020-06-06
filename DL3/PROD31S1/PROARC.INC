
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
 * PCB ProDOOR module to re-archive the scratch archive (3-1-89)
 *
 *)

procedure rearc_scratchfile;
var
   src:  filenames;

begin
   if not verify_level(fun_rearc) then exit;

   (* select the archive (checks stacking, adds .arc and default) *)
   select_archive('REPACK');
   if length(par) = 0 then
      exit;
   src := par;

   if cmdline = '' then
   begin
      get_def('Pack in what format:',enter_eq+''''+dotpak+'''? ');
      if cmdline = '' then
         cmdline := dotpak;
   end;

   get_nextpar;
   if par[1] <> '.' then
      par := '.' + par;
   stoupper(par);

   (* prepare to chain to the re-arc script *)
   make_log_entry('REPACK file ('+remove_path(src)+') in '+par+' format',true);

   (* make destination a new mailfile if we are repacking a zipm packet *)
   if src = mailarc then
      scratcharc := mailarc;
   set_scratch_type;

(***
   execute(cnf.rearc_command+' '+src+' '+scratcharc+' '+cnf.playpen_dir);
***)

   protocol := outside_batch;
   par1 := cnf.rearc_command+' '+src+' '+scratcharc+' '+cnf.playpen_dir;
end;

