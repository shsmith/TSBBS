
(*
 * makebody - generate a unit body from files in the current directory
 *
 * samuel h. smith, 4-18-91
 *
 *)

uses dos;

const
   maxfiles = 200;

type
   fileinfo = record
      fname:   namestr;
      ext:     extstr;
   end;

var
   filetab: array[1..maxfiles] of fileinfo;
   files:   integer;
   search:  searchrec;
   dir:     dirstr;
   i:       integer;

begin
   files := 0;

   findfirst('*.*',$21,search);
   while doserror = 0 do
   begin
      if files < maxfiles then
         inc(files);

      with filetab[files] do
         fsplit(search.name,dir,fname,ext);

      findnext(search);
   end;

   writeln;
   writeln('unit ',paramstr(1),';');
   writeln;
   writeln('interface');
   writeln('   uses ;');
   writeln;
   for i := 1 to files do
      with filetab[i] do
         if (ext = '.DCL') or (ext = '.INT') then
            writeln('   {$i ',fname,ext,'}');

   writeln;
   writeln('implementation');
   writeln('   uses ;');
   writeln;
   for i := 1 to files do
      with filetab[i] do
         if (ext = '.INC') then
            writeln('   {$i ',fname,ext,'}');

   writeln;
   writeln('{initialization}');
   writeln;
   for i := 1 to files do
      with filetab[i] do
         if (ext = '.INI') then
            writeln('   {$i ',fname,ext,'}');

   writeln;
   writeln('begin');
   for i := 1 to files do
      with filetab[i] do
         if (ext = '.INI') then
            writeln('   ',fname,'_initialize;');
   writeln('end.');
   writeln;

end.

