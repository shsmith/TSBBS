
(*
 * adirs - find all directories in a subdirectory tree
 *
 * Author: S.H.Smith, 5-Apr-86 (16-sep-87)
 *
 *)

uses DOS;

procedure listdirs(dir: dirstr);
var
   DirInfo:       SearchRec;
begin
   writeln(dir);

   FindFirst(dir+'\*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) <> 0) and (DirInfo.name[1] <> '.') then
         listdirs(dir+'\'+DirInfo.Name);
      FindNext(DirInfo);
   end;
end;

procedure listfiles(dir: dirstr; pattern: nameStr);
var
   DirInfo:       SearchRec;
begin
   FindFirst(dir+'\'+pattern,Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if (DirInfo.Attr and Directory) = 0 then
         writeln(dir+'\'+DirInfo.Name);
      FindNext(DirInfo);
   end;

   FindFirst(dir+'\*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) <> 0) and (DirInfo.name[1] <> '.') then
         listfiles(dir+'\'+DirInfo.Name,pattern);
      FindNext(DirInfo);
   end;
end;

var
   con:  text;
   buf:  array[1..$8000] of byte;

procedure findfiles(pattern: nameStr);
begin
   writeln(con,'Finding files like ',pattern,' ...');
   listfiles('',pattern);
end;

begin
   assign(con,'con');
   rewrite(con);
   setTextBuf(output,buf);

   writeln(con,'Finding directories ...');
   listdirs('');
   writeln('free');

   findfiles('*.PAS');
   findfiles('*.IN?');
   findfiles('*.DCL');
   findfiles('*.BAT');
   findfiles('*.COM');
   findfiles('*.EXE');

   close(con);
   close(output);
end.

