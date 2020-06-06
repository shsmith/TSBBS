
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * extadj - exjust size of ProDoor Extended Conference data file (3-1-89)
 *
 *)

{$m 8000,1000,1000}

uses dos, mdosio, bufio;
 
{$i \tinc\anystring.inc}
{$i extuser.dcl}

var
   extcount:   integer;
   extsize:    word;
   extuser:    extuser_rec;
   newcount:   integer;
   newsize:    word;
   maxrec:     integer;


(* -------------------------------------------------- *)
procedure determine_extsize(fd: dos_handle);
var
   r:       integer;
   cl,ch:   byte;
begin
   (* determine size of conference data *)
   dos_lseek(fd,0,seek_start);

   r := dos_read(fd,cl,1);
   r := dos_read(fd,ch,1);
   extcount := cl;
   if ch < $20 then
      extcount := extcount + (ch shl 8);

   extsize := extcount * sizeof(extuser_conf_rec) + sizeof(extuser_fixed_rec);

   dos_lseek(fd,0,seek_end);
   maxrec := (dos_tell div extsize)-1;
   dos_lseek(fd,0,seek_start);
end;


(* -------------------------------------------------- *)
var
   extfile: dos_filename;
   extfd:   dos_handle;
   newfile: dos_filename;
   newfd:   buffered_file;
   r:       integer;
   bakfile: dos_filename;
   bakfd:   file;
   count:   word;

begin
   writeln('EXTADJ 1.1:  Adjust Extended Conference Allocation in EXTUSER File');
   writeln('Copyright 1988, 1990 Samuel H. Smith');
   writeln;

   extfile := GetEnv('EXTUSER');
   if extfile = '' then
      extfile := 'EXTUSER';

   extfd := dos_open(extfile,open_update);
   if extfd = dos_error then
   begin
      writeln('Can''t open ',extfile);
      writeln('Use "SET EXTUSER=path" environment to locate extended user file.');
      halt(99);
   end;
   
   fillchar(extuser,sizeof(extuser),0);
   determine_extsize(extfd);

   writeln('Extended user file: ',extfile);
   writeln(extcount:5,' extended conferences in file.');
   writeln(extsize :5,' bytes per user record.');
   writeln(maxrec  :5,' user records in file.');
   writeln;

   writeln('File is currently allocated for ',extcount,' extended conferences.');
   write('Enter new number of extended conferences in file: ');
   readln(newcount);
   if (newcount < 0) or (newcount > (max_econf-conf_limit)) then
   begin
      writeln('ProDoor 3.2 supports 0 through ',max_econf-conf_limit,' extended conferences.');
      writeln('Please rerun with a number of extended conferences in this range.');
      halt(99);
   end;


   newsize := newcount * sizeof(extuser_conf_rec) + sizeof(extuser_fixed_rec);
   newfile := extfile;
   newfile[length(newfile)] := '$';

   bakfile := extfile;
   bakfile[length(newfile)] := '&';

   writeln;
   writeln(newcount:5,' extended conferences in new file.');
   writeln(newsize :5,' bytes per user record.');

   bcreate(newfile);
   bopen(newfd,newfile,100,newsize);
   if berr then
   begin
      writeln('Can''t create tempfile ',newfile);
      halt(99);
   end;

   r := dos_read(extfd,extuser,extsize);
   extuser.fixed.extcount := lo(newcount);
   extuser.fixed.extcounth := hi(newcount);

   writeln;
   writeln('Working ...');

   count := 0;
   while r = extsize do
   begin
      bwrite(newfd,extuser);
      r := dos_read(extfd,extuser,extsize);
      inc(count);
      if ((count mod 100) = 0) or (r <> extsize) then
         write(count:5,' records converted.'^M);
   end;

   writeln;

   dos_close(extfd);
   bclose(newfd);
   if berr then
      writeln('Error closing tempfile, conversion aborted')
   else

   begin
      dos_unlink(bakfile);

      assign(bakfd,extfile);
      {$i+} rename(bakfd,bakfile); {$i-}
      if ioresult <> 0 then writeln('Rename1 failed');

      assign(bakfd,newfile);
      {$i+} rename(bakfd,extfile); {$i-}
      if ioresult <> 0 then writeln('Rename2 failed');

      writeln;
      writeln('Conversion completed.');
   end;
end.

