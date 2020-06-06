
(*
 * what - list what programs match search PATHS
 *
 * author: s.h.smith, 14-may-86
 *
 *)

uses dos;

const
   version = 'WHAT v2.0   (10-Jul-89, S.H.Smith)';

(*
 * locate a file.  search paths if needed.  returns
 * prints the full pathname of all located files.
 *
 *)

procedure locate_file(name: string);
var
   paths:  string;
   dir:    string;
   i:      integer;
   fd:     file;

   procedure try(ext: string);
   var
      DirInfo:  SearchRec;
   begin
      FindFirst(dir+name+ext,$21,DirInfo);
      if (DosError = 0) then
         writeln(dir + name + ext);
   end;

begin

(* get the paths and start searching them.  arrange for current directory
   to be scanned first.  add trailing ; to handle special case for last path *)

   paths := ';' + GetEnv('PATH') + ';';
   dir := '';

   for i := 1 to length(paths) do
   begin

(* if a full directory has been collected, then try this path *)
      if (paths[i] = ';') or (i = length(paths)) then
      begin
         if (length(dir) > 1) and (dir[length(dir)] <> '\') then
            dir := dir + '\';

         try('');
         try('.EXE');
         try('.COM');
         try('.BAT');
         dir := '';
      end

      else
         dir := dir + paths[i];
   end;

end;


begin
   if paramcount <> 1 then
   begin
      writeln(version);
      writeln;
      writeln('Usage:    what COMMAND');
      writeln;
      writeln('Action:   Locates and lists all commands in search PATH');
      writeln;
      writeln('Example:  what CHKDSK');
   end;

   locate_file(paramstr(1));
end.
