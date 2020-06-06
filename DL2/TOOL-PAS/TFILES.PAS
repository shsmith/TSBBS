
(*
 * adirs - find all directories in a subdirectory tree
 *
 * Author: S.H.Smith, 5-Apr-86 (16-sep-87)
 *
 *)

uses DOS, MDOSIO, MINICRT, TOOLS;

var
   fix:  text;
   buf:  array[1..$8000] of byte;

   nfiles:  longint;
   totalsz: longint;
   itime:   real;

const
   max_time = 1.5;

(* ------------------------------------------------- *)
procedure testfile(dir,fname: pathstr);
var
   fd:         dos_handle;
   filesize:   longint;
   slow:       boolean;
   n:          word;
   started:    real;
   initial:    real;
   elapsed:    real;
   now:        real;
   speed:      real;

begin
   if (dir = '\') and (fname = 'FIX.BAT') then
      exit;

   fd := dos_open(dir+fname,open_read);
   if fd = dos_error then
      exit;

   inc(nfiles);
   elapsed := get_time - itime;
   if elapsed <> 0 then
      write(fname:16,' - ',
         nfiles:5,' files, ',
         totalsz/1048576.0:7:2,' meg, ',
         elapsed:6:1,' sec, ',
         totalsz/elapsed/1024.0:6:1,' k/s - ');

   slow := false;

   initial := get_time;
   now := initial;
   filesize := 0;

   repeat
      started := now;
      n := dos_read(fd,buf,sizeof(buf));
      filesize := filesize + n;
      now := get_time;
      elapsed := now-started;
      slow := elapsed > max_time;
   until slow or (n < sizeof(buf));

   dos_close(fd);

   filesize := (filesize + 511) and $7FFFFE00;
   totalsz := totalsz + filesize;

   if slow then
   begin
      if length(dir) > 1 then
         dec(dir[0]);

      write(fix,'call ');
      if paramstr(2) = '' then
         write(fix,'makebad')
      else
         write(fix,paramstr(2));
      writeln(fix,' ',fname,' ',dir);
      flush(fix);

      writeln('Slow!'^G);
   end
   else
      write('Ok      '^M);
end;

(* ------------------------------------------------- *)
procedure getfiles(dir: dirstr);
var
   DirInfo:       SearchRec;
begin
   clreol;
   writeln(dir);
   if dir = '\BAD\' then exit;

   FindFirst(dir+'*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) = 0) then
         testfile(dir,DirInfo.Name);
      FindNext(DirInfo);
   end;

   FindFirst(dir+'*.*',Anyfile,DirInfo);
   while (DosError = 0) do
   begin
      if ((DirInfo.Attr and Directory) <> 0) then
         if (DirInfo.name[1] <> '.') then
            getfiles(dir+DirInfo.Name+'\');
      FindNext(DirInfo);
   end;
end;

(* ------------------------------------------------- *)
begin
   {clrscr;}
   gotoxy(1,25);
   assign(output,'');
   rewrite(output);
   assign(fix,'\FIX.BAT');
   rewrite(fix);
   nfiles := 0;
   totalsz := 0;
   itime := get_time;
   getfiles(paramstr(1)+'\');
   close(fix);
end.

