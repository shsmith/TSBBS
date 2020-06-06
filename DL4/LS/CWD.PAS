
(*
 * cwd - change working directory.  this version allows / instead of \
 *
 * s.h.smith, 3-may-86
 *
 *)

{$P128,d-}

const
   version = 'Change working directory    (11-May-86, S.H.Smith)';

type
   anystring = string[65];


procedure usage;
begin
   writeln(version);
   writeln;
   writeln('Usage: cwd PATH              ;change working dir to PATH');
   writeln('       cwd -mk NEW_DIR       ;make new subdirectory');
   writeln('       cwd -rm OLD_DIR       ;remove old subdirectory');
   writeln;
end;


procedure change_dir;
var
   dir:  anystring;
   len:  integer;
   i:    integer;

begin
   dir := paramstr(1);
   len := length(dir);

   (* map all / into \ *)
   for i := 1 to len do
      if dir[i] = '\' then
         dir[i] := '/';

   (* remove trailing / when not allowed by DOS *)
   if (dir[len] = '/') and (dir[len-1] <> ':') and (len > 1) then
      dir[0] := pred(dir[0]);

   {$I-} chdir(dir); {$I+}
   if ioresult <> 0 then
      writeln('cwd: chdir to "',dir,'" failed'^G);
end;


procedure create_remove_dir;
var
   param:  anystring;
   fun:    char;
   dir:    anystring;
   i:      integer;
   len:    integer;

begin

   dir := paramstr(2);
   len := length(dir);

   (* map all / into \ *)
   for i := 1 to len do
      if dir[i] = '\' then
         dir[i] := '/';

   (* remove trailing / when not allowed by DOS *)
   if (dir[len] = '/') and (dir[len-1] <> ':') and (len > 1) then
      dir[0] := pred(dir[0]);

   param := paramstr(1);
   if param[1] = '-' then
      fun := upcase(param[2])
   else
      fun := upcase(param[1]);

   case fun of
      'M':
         begin
            {$I-} mkdir(dir); {$I+}
            if ioresult = 0 then
               writeln(dir,': created')
            else
               writeln('cwd: could not create directory: ',dir,^G);
         end;

      'R':
         begin
            {$I-} rmdir(dir); {$I+}
            if ioresult = 0 then
               writeln(dir,': removed')
            else
               writeln('cwd: could not remove directory: ',dir,^G);
         end;

      else  usage;
   end;

end;



procedure show_dir;
var
   i:    integer;
   len:  integer;
   dir:  anystring;

begin
   usage;

   getdir(0,dir);
   len := length(dir);

   (* map all \ into / *)
   for i := 1 to len do
      if dir[i] = '\' then
         dir[i] := '/';

   (* add trailing / where dos leaves it off *)
   if dir[len] <> '/' then
      dir := dir + '/';

   writeln('Working directory = ',dir);
end;



begin
   if paramcount = 1 then
      change_dir
   else

   if paramcount = 2 then
      create_remove_dir

   else
      show_dir;

end.
