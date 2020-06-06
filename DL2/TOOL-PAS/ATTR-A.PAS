
(*
 * attr-a - clear Archive attribute in selected files, quickest method
 *
 * Author: S.H.Smith, 26-aug-90
 *
 *)

uses DOS, Tools, MdosIO;

const
   subdirs: boolean = false;


procedure usage;
begin
   writeln('usage: attr-a [-s] filespec ...');
   writeln('example: attr-a -s *.zip');
   halt;
end;


procedure clear_archive(fname:   PathStr);
var
   fd:      file;
begin
   writeln('   ',fname);
   assign(fd,fname);
   SetFAttr(fd, 0);
   if DosError <> 0 then
      writeln(^G'Can''t clear attributes on [',fname,'].');
end;


procedure dofiles (pattern:   PathStr);
var
   DirInfo:       SearchRec;
   first:         boolean;

const
   dir:           DirStr = '';
   name:          NameStr = '';
   ext:           ExtStr = '';

begin
   FSplit(pattern,dir,name,ext);

   if (name[1] = '/') or (name[1] = '-') then
   begin
      case upcase(name[2]) of
         'S':  subdirs := true;
         else  usage;
      end;
      exit;
   end;

   first := true;
   FindFirst(pattern,dos.Archive,DirInfo);
   while (DosError = 0) do
   begin
      if (DirInfo.attr and dos.Archive) <> 0 then
      begin
         if first then
            writeln(pattern);
         first := false;
         clear_archive(dir+DirInfo.name);
      end;
      FindNext(DirInfo);
   end;

   if subdirs then
   begin
      FindFirst(dir+'*.*',dos.Directory,DirInfo);
      while (DosError = 0) do
      begin
         if (DirInfo.attr and dos.Directory) <> 0 then
            if DirInfo.name[1] <> '.' then
            begin
               FSplit(pattern,dir,name,ext);
               dofiles(dir+DirInfo.name+'\'+name+ext);
            end;
         FindNext(DirInfo);
      end;
   end;
end;


var
   i: integer;
begin
   if paramcount < 1 then
      usage;

   for i := 1 to paramcount do
      dofiles(paramstr(i));
end.

