
(*
 * AllDirs - return a listing of all directories on disk
 *
 * Written by S.H.Smith, 24-jul-89
 * Copyright 1989 Samuel H. Smith
 *
 *)

{$m 12000,10000,500000}

uses Dos;

const
   version:    string[40] = 'AllDirs Version 1.0 08-14-89';


procedure scan_directory(dir: PathStr);
var
   DirInfo: SearchRec;
   name:    PathStr;

begin
   writeln(dir);

   {check all subdirectories}
   name := dir+'\*.*';
   FindFirst(name,Directory,DirInfo);

   while (DosError = 0) do
   begin
      if ((DirInfo.attr and Directory) <> 0) and
         (DirInfo.name[1] <> '.') then
      begin
         name := dir+'\'+DirInfo.name;
         scan_directory(name);
      end;

      FindNext(DirInfo);
   end;
end;

procedure check_device(drive: DirStr);
begin
   drive := copy(drive,1,1);
   scan_directory(drive+':');
end;

var
   home: DirStr;
   i:    integer;
begin
   if paramcount = 0 then
   begin
      GetDir(0,home);
      check_device(home);
   end
   else

   for i := 1 to paramcount do
      check_device(paramstr(i));
end.

