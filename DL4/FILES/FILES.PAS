

(*
 * files - file list program
 *
 * this is a general file-list processing program
 * it can process a comma seperated list of wildcards
 * into a sorted pathname list
 *
 * shs 8/3/85
 * shs 10/29/85 changed to list one file per line
 *
 *)

{$p512,d-}

program files(output);

type anystring = string[128];

#include <regpack.inc>
#include <getfiles.inc>   {expand file lists}

procedure list_files(pattern: anystring);
var
   i: integer;

begin
   getfiles(pattern, filetable, filecount);

   for i := 1 to filecount do
      writeln(filetable[i])
end;


var
   p: integer;

begin
   if paramcount = 0 then
      list_files('*.*')
   else

   for p := 1 to paramcount do
      list_files(paramstr(p));
end.
