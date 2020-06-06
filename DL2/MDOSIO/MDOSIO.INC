
(*
 * mdosio - Mini library for interface to DOS v2 file access functions
 *          Samuel H. Smith,  rev. 19-Jul-87
 *
 * Usage:
 *  fd := dos_open('name',open_(read write update))
 *  fd := dos_create('name')
 *  bytesread := dos_read(fd,buffer,sizeof(buffer))
 *  dos_write(fd,buffer,bytes)
 *  dos_lseek(fd,offset,seek_(start cur end))
 *  dos_find_eof(fd)
 *  dos_close(fd)
 *  dos_unlink(name)
 *
 *)

procedure dos_call;
begin
   msdos(dos_regs);

   if (dos_regs.flags and 1) = 1 then
   begin
      writeln('DOS Error #',dos_regs.ax,' on ',dos_name);
      dos_regs.ax := dos_error;
   end;
end;


(* dos_open(name,mode) -> handle or dos_error *)

function dos_open(name:    dos_filename;
                  mode:    integer):  dos_handle;
var
   try: integer;
const
   retry_count = 3;

begin
   dos_name := name + #0;

   for try := 1 to retry_count do
   begin
      dos_regs.ax := $3d00 + mode;
      dos_regs.ds := seg(dos_name);
      dos_regs.dx := ofs(dos_name)+1;
      msdos(dos_regs);
      dos_open := dos_regs.ax;
      if (dos_regs.flags and 1) = 0 then
         exit;
   end;

   dos_open := dos_error;
end;


(* dos_create(name) -> handle *)

function dos_create(name:    dos_filename): dos_handle;
begin
   dos_regs.ax := $3c00;
   dos_regs.ds := seg(dos_name);
   dos_regs.dx := ofs(dos_name)+1;
   dos_regs.cx := 0;   {attrib}
   dos_name := name + #0;
   dos_call;
   dos_create := dos_regs.ax;
end;


(* read(fd,buffer,bytecount) *)

function dos_read( handle:  dos_handle;
                   var      buffer;
                   bytes:   word): word;
begin
   dos_regs.ax := $3f00;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call;
   dos_read := dos_regs.ax;
end;


(* write(fd,buffer,bytecount) *)

procedure dos_write(handle:  dos_handle;
                    var buffer;
                    bytes:   word);
begin
   dos_regs.ax := $4000;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call;
   if dos_regs.ax <> bytes then
      writeln('ERROR: write failed (disk full?)');
end;


(* dos_lseek(fd,offset,method) *)

procedure dos_lseek(handle:  dos_handle;
                    offset:  longint;
                    method:  integer);
var
   pos:  long_int absolute offset;

begin
   dos_regs.ax := $4200 + method;
   dos_regs.bx := handle;
   dos_regs.cx := pos.msw;
   dos_regs.dx := pos.lsw;
   dos_call;
end;


(* tell long result of last dos call (used after lseek to get position) *)

function dos_tell: longint;
var
   pos:  long_int;
   li:   longint absolute pos;
begin
   pos.lsw := dos_regs.ax;
   pos.msw := dos_regs.dx;
   dos_tell := li;
end;


(* find end of file, skip backward over ^Z eof markers *)

procedure dos_find_eof(fd: dos_handle);
var
   b: char;
   n: word;

begin
   dos_lseek(fd,0,seek_end);
   if dos_tell = 0 then
      exit;

   dos_lseek(fd,-1,seek_end);
   n := dos_read(fd,b,1);
   while (b = ^Z) and (n = 1) do
   begin
      b := ' ';
      dos_lseek(fd,-2,seek_end);
      n := dos_read(fd,b,1);
   end;
end;


procedure dos_close(handle:  dos_handle);
begin
   dos_regs.ax := $3e00;
   dos_regs.bx := handle;
   dos_call;
end;


(* delete a file *)

procedure dos_unlink(name:    dos_filename);
begin
   dos_regs.ax := $4100;
   dos_regs.ds := seg(dos_name);
   dos_regs.dx := ofs(dos_name)+1;
   dos_name := name + #0;
   msdos(dos_regs);
end;

