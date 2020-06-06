
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
 * extlist - list contents of ProDoor Extended Conference data file (3-1-89)
 *
 *)

uses dos, mdosio, tools;
 
{$i extuser.dcl}

var
   extcount:  integer;
   extsize:   word;
   extuser:   extuser_rec;

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

   dos_lseek(fd,0,seek_start);
end;



(* -------------------------------------------------- *)
procedure read_extrec(fd:  dos_handle; extrarec: word);
var
   r:    integer;
begin
   fillchar(extuser,sizeof(extuser),0);

   (* load fixed extuser data *)
   dos_rseek(fd,extrarec,extsize,seek_start);
   r := dos_read(fd,extuser.fixed,sizeof(extuser.fixed));

   (* load extuser conference data for ONLY extended conferences *)
   r := dos_read(fd,extuser.conf[40],extsize-sizeof(extuser_fixed_rec));
end;


(* -------------------------------------------------- *)
var
   i:             integer;
   fd:            dos_handle;
   maxrec:        word;
   extuser_file:  string;

begin
   assign(output,'');
   rewrite(output);

   writeln('EXTLIST 1.1 - Extended User File:  List Contents');
   writeln('Copyright 1990 Samuel H. Smith');
   writeln;

   extuser_file := GetEnv('EXTUSER');
   if extuser_file = '' then
      extuser_file := 'EXTUSER';

   fd := dos_open(extuser_file,open_update);
   if fd = dos_error then
   begin
      writeln('Can''t open ',extuser_file);
      writeln('Use "SET EXTUSER=path" environment to locate extended user file.');
      halt(99);
   end;
   
   determine_extsize(fd);

   dos_lseek(fd,0,seek_end);
   maxrec := (dos_tell div extsize)-1;

   writeln(extcount:5,' extended conferences in file.');
   writeln(extsize :5,' bytes per user record.');
   writeln(maxrec  :5,' user records in file.');

   writeln;
   writeln('  Rec   Date   Lev            Name');
   writeln('  --- -------- --- -------------------------');

   for i := 1 to maxrec do
   begin
      read_extrec(fd,i);
      writeln(i:5,' ',extuser.fixed.lastdate:8,
                  ' ',extuser.fixed.level:3,
                  ' ',extuser.fixed.name);
   end;

   dos_close(fd);
end.

