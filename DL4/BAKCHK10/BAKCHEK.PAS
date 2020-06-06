
(*
 * BakChek - Check disk to see if backup is needed
 *
 * Written by S.H.Smith, 24-jul-89
 * Copyright 1989 Samuel H. Smith
 *
 *)

{$m 12000,10000,500000}

uses Dos;

const
   version:    string[40] = 'BakChek Version 1.0 07-29-89';

var
   tfiles:     integer;
   tsizes:     longint;
   afiles:     integer;
   asizes:     longint;
   gtfiles:    integer;
   gtsizes:    longint;
   gafiles:    integer;
   gasizes:    longint;
   gdrives:    integer;


procedure scan_directory(dir: PathStr);
var
   DirInfo: SearchRec;
   name:    PathStr;

begin
   {write(dir);}

   {first process all files in this directory}
   name := dir+'\*.*';
   FindFirst(name,AnyFile,DirInfo);

   while (DosError = 0) do
   begin
      name := dir+'\'+DirInfo.name;

      if (DirInfo.attr and Directory) = 0 then
      begin
         inc(tfiles);
         inc(tsizes,DirInfo.Size);

         if (DirInfo.Attr and Archive) <> 0 then
         begin
            inc(afiles);
            inc(asizes,DirInfo.Size);
         end;
      end;

      FindNext(DirInfo);
   end;

   {write(^M,'':length(dir),^M);}

   {next check all subdirectories}
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

function fmt(n: longint; w: integer): string;
var
   sv:   string;
   i,j:  integer;
begin
   str(n,sv);
   i := 0;
   for j := length(sv) downto 2 do
   begin
      inc(i);
      if (i mod 3) = 0 then
         insert(',',sv,j);
   end;

   while length(sv) < w do
      sv := ' ' + sv;
   fmt := sv;
end;

procedure check_device(drive: DirStr);
begin
   tfiles := 0;
   tsizes := 0;
   afiles := 0;
   asizes := 0;
   drive := copy(drive,1,1);
   write('  ',drive,':');

   scan_directory(drive+':');
   {riteln(' l:     1,478        416     28.1 %      26,263,056    13,878,559    52.8 %');}
   {           1234567890           123456789  1234567890123456              12345678     }
   {                     12345678901                           12345678901234             }

   if (tfiles=0) or (tsizes=0) then
      writeln('   (empty)')
   else
      writeln(fmt(tfiles,11), fmt(afiles,11), afiles*100.0/tfiles:8:1,' %',
              fmt(tsizes,16), fmt(asizes,14), asizes*100.0/tsizes:8:1,' %');

   inc(gtfiles,tfiles);
   inc(gtsizes,tsizes);
   inc(gafiles,afiles);
   inc(gasizes,asizes);
   inc(gdrives);
end;

var
   home: DirStr;
   i:    integer;
begin
   gtfiles := 0;
   gtsizes := 0;
   gafiles := 0;
   gasizes := 0;
   gdrives := 0;

   writeln(version);
   writeln('Copyright 1989 Samuel H. Smith');
   writeln;
   writeln('                File Storage                           Byte Storage');
   writeln('Drive    Total    Modified   Percent        Total        Modified    Percent');
   writeln('-----  --------- ---------- ---------   ------------- ------------- ---------');

   if paramcount = 0 then
   begin
      GetDir(0,home);
      check_device(home);
   end
   else

   for i := 1 to paramcount do
      check_device(paramstr(i));

   if gdrives > 1 then
   begin
      writeln('=====  ========= ========== =========   ============= ============= =========');
      write(gdrives:3,' ');
      if (gtfiles=0) or (gtsizes=0) then
         writeln('   (empty)')
      else
         writeln(fmt(gtfiles,11), fmt(gafiles,11), gafiles*100.0/gtfiles:8:1,' %',
                 fmt(gtsizes,16), fmt(gasizes,14), gasizes*100.0/gtsizes:8:1,' %');
   end;
end.

