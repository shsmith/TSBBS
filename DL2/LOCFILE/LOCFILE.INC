
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
 * get the value of an environment variable
 *
 *)
type
   gestring = string[255];


function get_environment_var(id: gestring): gestring;
var
   envseg:  integer;
   i:       integer;
   env:     gestring;

begin
   envseg := memw[PrefixSeg:$2c];

   i := 0;
   repeat
      env := '';
      while mem[envseg:i] <> 0 do
      begin
         env := env + chr(mem[envseg:i]);
         i := i + 1;
      end;

      if copy(env,1,length(id)) = id then
      begin
         get_environment_var := copy(env,length(id)+1,255);
         exit;
      end;

      i := i + 1;
   until mem[envseg:i] = 0;

(* not found *)
   get_environment_var := '';
end;


(*
 * locate a file with search rules from specified environment variable.
 * returns the full pathname of the located file.
 * returns only the original name if not found.
 *
 *)

function locate_file_env(name:    gestring;
                         environ: gestring): gestring;
var
   paths:  gestring;
   dir:    gestring;
   i:      integer;
   fd:     file;

begin

(* get the paths and start searching them.  arrange for current directory
   to be scanned first.  add trailing ; to handle special case for last path *)

   paths := environ + ';';
   dir := '';

   for i := 1 to length(paths) do
   begin

(* if a full directory has been collected, then try this path *)
      if (paths[i] = ';') or (i = length(paths)) then
      begin
         if (length(dir) > 1) and (dir[length(dir)] <> '\') then
            dir := dir + '\';

{$I-}
         assign(fd,dir + name);
         reset(fd);
{$I+}
         if ioresult = 0 then
{! 7. IOResu^lt now returns different values corresponding to DOS error codes.}
         begin
           close(fd);
           locate_file_env := dir + name;
           exit;
         end;

         dir := '';
      end
      else
         dir := dir + paths[i];
   end;

(* couldn't find it.  return the original name *)
   locate_file_env := name;
end;


(*
 * locate a file.  search PATH= paths if needed.  returns
 * the full pathname of the located file.
 * returns only the original name if not found.
 *
 *)

function locate_file(name: gestring): gestring;
begin

   locate_file := locate_file_env(name,';' + get_environment_var('PATH='));

end;

