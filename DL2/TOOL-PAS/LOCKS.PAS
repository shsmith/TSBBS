
uses mdosio,dos;

const
   fname = 'LOCK.$$$';
   entries = 1000;

var
   fd1:  dos_handle;
   fd2:  dos_handle;
   rec:  array[1..entries] of integer;
   rec2: array[1..entries] of integer;
   i:    integer;
   n:    word;

begin
   if not dos_exists(fname) then
   begin
      fd1 := dos_create(fname);
      for i := 1 to entries do
         rec[i] := i;
      dos_write(fd1,rec,sizeof(rec));
      dos_close(fd1);
   end;

   fd1 := dos_open(fname,open_update);
   for i := 1 to entries do
   begin
      n := dos_read(fd1,rec[i],sizeof(rec[i]));
      if rec[i] <> i then
      begin
         writeln('fd1 error: i=',i,' rec[i]=',rec[i],' n=',n);
      end;
   end;

   if not dos_lock(fd1,20{offset},4{length}) then
      writeln('fd1 lock failed');

   fillchar(rec2,sizeof(rec2),99);
   fd2 := dos_open(fname,open_read);
   for i := 1 to entries do
   begin
      writeln(' i=',i);
      n := dos_read(fd2,rec2[i],sizeof(rec2[i]));
      if rec2[i] <> rec[i] then
         writeln('fd2 error: i=',i,' rec2[i]=',rec2[i],' n=',n);
      if n = dos_error then
      begin
         writeln('skipping bad record');
         dos_lseek(fd2,sizeof(rec2[i]),seek_cur);
      end;
   end;
   dos_close(fd2);

   dos_close(fd1);
end.
