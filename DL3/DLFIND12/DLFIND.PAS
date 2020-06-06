
(*
 * dlfind - find filenames searching DLPATH.LST directories
 *
 * (c) 1992 Samuel H. Smith
 *
 *)

uses openshare,qread,dos;

const
   version = 'DLFIND 1.2 (10/5/92)';

var
   dash_e:     boolean;
   matches:    integer;

procedure check_dir(dir: string; pattern: string);
var
   DirInfo: SearchRec;
   i:       integer;
begin
   if pos('\',pattern) > 0 then
   begin
      i := length(pattern);
      while (i > 1) and (pattern[i] <> '\') do
         dec(i);
      if pattern[i] = '\' then
         pattern := copy(pattern,i+1,255);
   end;

   for i := 1 to length(dir) do
      if dir[i] = '/' then
         dir[i] := '\';
   if dir[length(dir)] <> '\' then
      dir := dir + '\';

   if dash_e then
   begin
      i := pos('.',pattern);
      if i > 0 then
         pattern[0] := chr(i-1);
      pattern := pattern + '.*';
   end;

   FindFirst(dir+pattern,$21,DirInfo);

   while (DosError = 0) do
   begin
      writeln(dir+DirInfo.name);
      inc(matches);
      FindNext(DirInfo);
   end;
end;

(* ------------------------------------------------------------ *)
var
   dlpath:  string;
   dir:     string;
   fd:      text;
   buf:     array[1..10240] of char;
   i:       integer;

begin
   dlpath := getEnv('DLPATH');

   if (paramcount = 0) or (dlpath = '') then
   begin
      writeln(version);
      writeln('Copyright 1992 Samuel H. Smith');
      writeln('Finds filespecs using PCBoard style DLPATH.LST directory list.');
      writeln;
      writeln('Usage: dlfind [-e] FILESPEC ... FILESPEC');
      writeln('Specify one or more wildcard filespecs on the command line.');
      writeln;
      writeln('-E option specifies that FILESPEC.* should be checked, regardless of the');
      writeln('actual .EXT specified.');
      writeln;
      writeln('On exit, ERRORLEVEL is set to the number of matches.');
      writeln;
      writeln('Please execute the command:');
      writeln('   SET DLPATH=[full drive, directory and filename of your DLPATH.LST file]');
      writeln('before using DLFIND.  For example:');
      writeln('   SET DLPATH=C:\PCB\DLPATH.LST');
      writeln('   DLFIND PKZ110.*');
      halt(0);
   end;

   assignText(fd,dlpath);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln(version);
      writeln('Cannot open DLPATH file "'+dlpath+'"!');
      halt(0);
   end;

   dash_e := false;
   matches := 0;

   setTextBuf(fd,buf);
   while not eof(fd) do
   begin
      qReadLn(fd,dir,sizeof(dir)-1);

      for i := 1 to paramcount do
         if (paramstr(i) = '-E') or (paramstr(i) = '-e') then
            dash_e := true
         else
            check_dir(dir,paramstr(i));
   end;

   close(fd);

   halt(matches);
end.


