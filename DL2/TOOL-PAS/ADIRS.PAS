
(*
 * adirs - find all directories in a subdirectory tree
 *
 * Author: S.H.Smith, 5-Apr-86 (16-sep-87)
 *
 *)

uses DOS;

procedure getfiles(dir: dirstr);
var
   DirInfo:       SearchRec;

begin
   writeln(dir);

   FindFirst(dir+'\*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) <> 0) and (DirInfo.name[1] <> '.') then
         getfiles(dir+'\'+DirInfo.Name);
      FindNext(DirInfo);
   end;
end;

begin
   getfiles('');
end.

