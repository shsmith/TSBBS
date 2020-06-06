
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
 * extuser - access library for extended user record
 *           (requires a valid pcboard user record)
 *)

procedure determine_extsize(fd: dos_handle);
var
   r: integer;
begin
   (* determine size of conference data *)
   dos_lseek(fd,0,seek_start);
   r := dos_read(fd,extcount,1);
   extsize := extcount * sizeof(extuser_conf_rec) + sizeof(extuser_fixed_rec);

{writeln('extcount=',extcount,' extsize=',extsize);}
end;


(* -------------------------------------------------- *)
procedure read_extrec(fd:  dos_handle);
var
   r:    integer;

begin
{writeln('EXTUSER READ FROM DISK, extcount=',extcount,' extsize=',extsize);}
   fillchar(extuser,sizeof(extuser),0);

   (* load fixed extuser data *)
   dos_rseek(fd,user.extrarec,extsize,seek_start);
   r := dos_read(fd,extuser.fixed,sizeof(extuser.fixed));

   (* load extuser conference data for ONLY extended conferences *)
   r := dos_read(fd,extuser.conf[40],extsize-sizeof(extuser_fixed_rec));
end;


(* -------------------------------------------------- *)
procedure load_extrec;
var
   i:    integer;

begin
   (* update conference table from user record *)
   for i := 0 to max_conf do
   with extuser.conf[i] do
   begin
      setflag(flags,ext_member, getbit(user.conferences,i));
      setflag(flags,ext_scan,   getbit(user.scanconf,i));
      setflag(flags,ext_joined, getbit(pcbsys.joined,i));
      lastread := user.lastread[i];
   end;
{WRITELN('LOAD EXTREC- EXTUSER UPDATED; CONF0.FLAGS=',EXTUSER.CONF[0].FLAGS);}
end;


(* -------------------------------------------------- *)
procedure save_extrec;
var
   i: integer;
begin
{WRITELN('SAVE EXTREC- USER UPDATED; CONF0.FLAGS=',EXTUSER.CONF[0].FLAGS);}
   (* update pcboard user record from extuser data *)
   for i := 0 to max_conf do
   with extuser.conf[i] do
   begin
      setbit(user.conferences,i,getflag(flags,ext_member));
      setbit(user.scanconf,i,getflag(flags,ext_scan));
      setbit(pcbsys.joined,i,getflag(flags,ext_joined));
      user.lastread[i] := lastread;
   end;
end;


(* -------------------------------------------------- *)
procedure write_extrec(fd:  dos_handle);
begin
{writeln('EXTUSER WRITTEN TO DISK, extcount=',extcount,' extsize=',extsize);}
   (* save fixed extuser data *)
   dos_rseek(fd,user.extrarec,extsize,seek_start);
   dos_write(fd,extuser.fixed,sizeof(extuser.fixed));

   (* save extuser conference data for ONLY extended conferences *)
   dos_write(fd,extuser.conf[40],extsize-sizeof(extuser_fixed_rec));
end;

