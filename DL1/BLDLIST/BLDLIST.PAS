
(*
 * adirs - find all directories in a subdirectory tree
 *
 * Author: S.H.Smith, 5-Apr-86 (16-sep-87)
 *
 *)

{$m 10000,0,500000}

uses DOS;

const
   version = 'BLDLIST 1.1 of 04-07-92   (C) 1992 Samuel H. Smith';

procedure getfiles(dir: dirstr);
var
   DirInfo:       SearchRec;

begin
   if dir[3] = '\' then
      dir[3] := '/';
   writeln(dir);

   FindFirst(dir+'\*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) = 0) then
         writeln(DirInfo.name);
      FindNext(DirInfo);
   end;

   FindFirst(dir+'\*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) <> 0) and (DirInfo.name[1] <> '.') then
         getfiles(dir+'\'+DirInfo.Name);
      FindNext(DirInfo);
   end;
end;

var
   i: integer;

begin
   if paramcount = 0 then
   begin
      writeln(version);
      writeln;
      writeln('Usage:  BLDLIST dir ... dir [>out]');
      writeln;
      writeln('Example:');
      writeln(' BLDLIST C:\DL1 D:\DL2 K:\ >C:\PCB\GEN\DLINFO.DAT');
      writeln(' BLDLIST L:\COMM L:\GIF L:\EDIT L:\GRAPH >>C:\PCB\GEN\DLINFO.DAT');
      writeln(' BLDLIST K: >C:\PCB\GEN\CD-INFO.DAT');
      writeln;
      halt(1);
   end;

   for i := 1 to paramcount do
      getfiles(paramstr(i));
end.

