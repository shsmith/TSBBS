
{$r+,s+}

uses DOS, TOOLS;

{$i t:\tinc\errmsg.inc}

const
   bytes_per_dir = 2*1024*1024;
   file_size = $8000;
   files_per_dir = bytes_per_dir/file_size;
   remove_after_test: boolean = false;
   max_dirs: integer = 1000;

type
   clust = array[0..file_size-1] of byte;

var
   prefix:  string;
   fn:      string;
   dir:     string;
   fd:      file of clust;
   rec:     clust;
   free:    longint;
   filen:   integer;
   dirn:    integer;

(* -------------------------------------------------------- *)
procedure make_bad(code: char);
var
   newn: string;
   i:    integer;

begin
   {$i-} mkdir('\BAD'); {$i+}
   i := ioresult;
   if i = 0 then
      writeln('\BAD directory created.');

   write('File: ',dir,'\',fn,' ');

   for i := 1 to 50 do
   begin
      newn := '\BAD\'+fn+'.'+code+itoa(i);

      write('>');
      {$i-} rename(fd,newn); {$i+}
      if ioresult = 0 then
      begin
         writeln(' moved to ',newn);
         SetFAttr(fd, ReadOnly+Hidden);
         if DosError <> 0 then
            writeln('  (Could not set ReadOnly+Hidden attributes)');
         exit;
      end;
   end;

   writeln('Could not move!'^G);
end;


(* -------------------------------------------------------- *)
procedure makedir;
var
   j: integer;
begin

   {randomize file data}
   for j := 0 to sizeof(rec)-1 do
      rec[j] := random(255);

   inc(dirn);
   dir := prefix+itoa(dirn);
   writeln;

   free := DiskFree(0);
   write(dir:7,free div 1024:7,'k');

   {$i-} mkdir(dir); {$i+}
   j := ioresult;
   if j <> 0 then
   begin
      writeln;
      write(^G'Error: ',j,' ',errormsg(j));
      writeln(',  MkDir ',dir);
   end;
end;


(* -------------------------------------------------------- *)
procedure makefile;
var
   j: integer;
begin

{$i-}
   assign(fd,dir+'\'+fn);
   rewrite(fd);
   write(fd,rec);
   j := ioresult;
   close(fd);
   if j = 0 then
      j := ioresult;
{$i+}

   if j <> 0 then
   begin
      writeln;
      write(^G'Error: ',j,' ',errormsg(j));
      writeln(',  Writing file: ',fn);
      make_bad('W');
   end
   else
      dec(free,sizeof(rec));
   write('.');
end;


(* -------------------------------------------------------- *)
procedure testfile;
var
   j:       integer;
   start:   real;
   elapse:  real;
const
   max_time = 1.5;

begin

{$i-}
   assign(fd,dir+'\'+fn);
   reset(fd);
   start := get_time;
   read(fd,rec);
   j := ioresult;
   close(fd);
   if j = 0 then
      j := ioresult;
{$i+}
   elapse := get_time-start;

   if j <> 0 then
   begin
      writeln;
      write(^G'Error: ',j,' ',errormsg(j));
      writeln(',  Reading file: ',fn);
      make_bad('B');
   end
   else

   if elapse > max_time then
   begin
      writeln;
      write(^G'Error: SOFT ERRORS (',elapse:0:1,' seconds)');
      writeln(',  Reading file: ',fn);
      make_bad('S');
   end
   else
      dec(free,sizeof(rec));
   write('.');
end;


(* -------------------------------------------------------- *)
procedure testdir;
var
   lfilen:  integer;
begin
   writeln;
   write('     Test files');
   lfilen := filen;
   filen := 1;
   while filen < lfilen do
   begin
      fn := prefix + itoa(dirn)+'F'+itoa(filen);
      inc(filen);
      testfile;
   end;
end;


(* -------------------------------------------------------- *)
procedure removedir;
var
   lfilen:  integer;
   j:       integer;

begin
   writeln;
   write('   Remove files');
   lfilen := filen;
   filen := 1;
   while filen < lfilen do
   begin
      fn := prefix + itoa(dirn)+'F'+itoa(filen);
      inc(filen);
      assign(fd,dir+'\'+fn);
      {$i-} erase(fd); {$i+}
      j := ioresult;
      if (j <> 0) and (j <> 2{file not found}) then
      begin
         writeln;
         write(^G'Error: ',j,' ',errormsg(j));
         writeln(',  Erasing file: ',fn);
      end;
      write('.');
   end;

   writeln;
   {$i-} rmdir(dir); {$i+}
   j := ioresult;
   if j <> 0 then
   begin
      write(^G'Error: ',j,' ',errormsg(j));
      writeln(',  RmDir ',dir);
   end;

end;


(* -------------------------------------------------------- *)
var
   i: integer;
begin
   assign(output,'');
   rewrite(output);

   for i := 1 to paramcount do
   begin
      prefix := paramstr(i);
      case upcase(prefix[1]) of
         'R':  remove_after_test := true;
         'M':  max_dirs := atoi(copy(prefix,2,99));
         else
            writeln('Usage:  mk32tmp [r] [m###]');
            writeln('    r = remove directories and files after testing them');
            writeln(' m### = maximum number of directories to create');
            halt(99);
      end;
   end;

   {randomize filename prefix}
   prefix := '';
   randomize;
   while length(prefix) < 2 do
      prefix := prefix + chr( random(26)+ord('A') );

   filen := 1;
   dirn := 0;
   makedir;

   repeat
      if filen > files_per_dir then
      begin
         testdir;
         if remove_after_test then
            removedir;
         filen := 1;
         makedir;
      end;

      fn := prefix + itoa(dirn)+'F'+itoa(filen);
      inc(filen);
      makefile;
   until (free <= 3*sizeof(rec)) or
         ((dirn = max_dirs) and (filen > files_per_dir));

   testdir;
   if remove_after_test then
      removedir;
   writeln;
end.

