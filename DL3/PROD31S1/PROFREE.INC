
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
 * PCB ProDOOR - check for "free" files (download)    (3-1-89)
 *
 *)

function is_free_file(name: string65): boolean;
var
   entry: string65;

begin
   if not dos_exists(freefile_list) then
   begin
      is_free_file := false;
      exit;
   end;

   openfile(freefile_list);
   if not ok then
      file_missing;

   name := remove_path(name);
   while not endfile do
   begin
      getstrd(entry);
{writeln('free: ',entry,' ? ',name);}

      if wildcard_match(entry, name) then
      begin
         is_free_file := true;
         closefile;
         exit;
      end;
   end;

   is_free_file := false;
   closefile;
end;

