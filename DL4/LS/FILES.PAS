

(*
 * files - list filenames matching a wildcard
 *
 * version 2, shs 5/14/86
 *
 *)

{$p2048}

const
   version = 'FILES - Unix like file lister  (26-sep-86, S.H.Smith)';

type
   anystring = string[80];


{$I\SHS\TOOLS\regpack.inc    DOS register package}
{$I\SHS\TOOLS\getfiles.inc   Get file list from wildcard}


var
   cur_dir:  anystring;


procedure translate(var str: anystring; old: char; new: char);
var
   i: integer;
begin
   for i := 1 to length(str) do
      if str[i] = old then
         str[i] := new
      else
         str[i] := upcase(str[i]);
end;


procedure makepath(var name: anystring; dir: anystring);
var
   i:    integer;
   rest: anystring;

begin

(* make sure device is specified in pathname *)
   if name[1] = '/' then
      name := copy(dir,1,2) + name
   else

(* make sure pathname is absolute *)
   if name[2] <> ':' then
      name := dir + name;

(* remove references to current directory *)
   i := pos('/./',name);
   while i > 0 do
   begin
      name := copy(name,1,i) + copy(name,i+3,length(name));
      i := pos('/./',name);
   end;

(* remove references to parent directory *)
   i := pos('/../',name);
   while i > 0 do
   begin
      rest := copy(name,i+4,length(name));
      i := i - 1;

      while (name[i] <> '/') and (i > 2) do
         i := i - 1;

      name := copy(name,1,i) + rest;

      i := pos('/../',name);
   end;

(* change absolute into relative if possible *)
   if copy(name,1,length(cur_dir)) = cur_dir then
      name := copy(name,length(cur_dir)+1,length(name));
end;


procedure procparam(pattern: anystring);
var
   i:   integer;

begin
   translate(pattern,'\','/');
   makepath(pattern,cur_dir);
   translate(pattern,'/','\');

   getfiles(pattern,filetable,filecount);

   for i := 1 to filecount do
      writeln(filetable[i]);
end;


var
   i: integer;

begin
   if paramcount < 1 then
   begin
      writeln(version);
      writeln;
      writeln('usage:   files FILE-LIST >DESTINATION');
      writeln('example: files a:/work/*.doc a:/*.dat >file.lst');
      writeln;
      halt(1);
   end;

   getdir(0,cur_dir);
   translate(cur_dir,'\','/');
   if cur_dir[length(cur_dir)] <> '/' then
      cur_dir := cur_dir + '/';

   for i := 1 to paramcount do
      procparam(paramstr(i));
end.

