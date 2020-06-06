
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
 * dosio - library for interface to dos v2 file access functions
 *
 * usage:
 *
 *  fd := dos_create('name',attributes)
 *  if dos_unlink('name') = dos_error then ...
 *  fd := dos_open('name',open_(read write update))
 *  if dos_close(fd) = dos_error then ...
 *  count := dos_read(fd,buffer,sizeof(buffer))
 *  count := dos_write(fd,buffer,sizeof(buffer))
 *  integer_pos := dos_seek(fd,seek_(start cur end),integer_offset)
 *  real_pos := dos_lseek(fd,seek_*,real_offset)
 *  dos_file_times(fd,time_(set get),time,date);
 *
 *)


type

   dos_filename = string[64];
   dos_handle   = integer;

   dos_seek_methods = (seek_start,
                       seek_cur,
                       seek_end);

   dos_time_functions = (time_get,
                         time_set);


const
   dos_error = -1;
   stdin = 0;
   stdout = 1;
   stderr = 2;

   open_read    = $40;   {deny_nothing, allow_read}
   open_write   = $41;   {deny_nothing, allow_write}
   open_update  = $42;   {deny_nothing, allow_read+write}


var
   dos_regs:     registers;
   dos_name:     dos_filename;
   dos_message:  string[90];


procedure dos_call(var regs:  registers);
begin
   msdos(regs);

   if (regs.flags and 1) = 1 then
   begin
      case regs.ax of
         1:   dos_message := 'invalid subfunction code';
         2:   dos_message := 'file not found';
         3:   dos_message := 'directory not found';
         4:   dos_message := 'too many open files';
         5:   dos_message := 'access denied';
         6:   dos_message := 'invalid file handle';
         else dos_message := 'unknown DOS error';
      end;

      writeln('ERROR: ',dos_message,'  ( ',dos_name,')');
      regs.ax := dos_error;
   end;
end;


function dos_create(name:    dos_filename;
                    attrib:  integer):  dos_handle;
begin
   dos_regs.ax := $3c00;
   dos_regs.ds := seg(dos_name);
   dos_regs.dx := ofs(dos_name)+1;
   dos_regs.cx := attrib;
   dos_name := name + #0;
   dos_call(dos_regs);
   dos_create := dos_regs.ax;
end;


function dos_unlink(name:    dos_filename):  dos_handle;
begin
   dos_regs.ax := $4100;
   dos_regs.ds := seg(dos_name);
   dos_regs.dx := ofs(dos_name)+1;
   dos_name := name + #0;
   dos_call(dos_regs);
   dos_unlink := dos_regs.ax;
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


function dos_close(handle:  dos_handle):  dos_handle;
begin
   dos_regs.ax := $3e00;
   dos_regs.bx := handle;
   dos_call(dos_regs);
   dos_close := dos_regs.ax;
end;


(* read(fd,buffer,bytecount) -> bytesread or dos_error *)

function dos_read(handle:  dos_handle;
                  var buffer;
                  bytes:   integer):   dos_handle;
begin
   dos_regs.ax := $3f00;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call(dos_regs);
   dos_read := dos_regs.ax;
end;


(* write(fd,buffer,bytecount) -> byteswritten or dos_error *)

function dos_write(handle:  dos_handle;
                   var buffer;
                   bytes:   integer):   dos_handle;
begin
   dos_regs.ax := $4000;
   dos_regs.bx := handle;
   dos_regs.cx := bytes;
   dos_regs.ds := seg(buffer);
   dos_regs.dx := ofs(buffer);
   dos_call(dos_regs);
   dos_write := dos_regs.ax;
   if dos_regs.ax <> bytes then
      writeln('ERROR: write failed (disk full?)');
end;


(* seek(fd,method,offset) -> new file position *)

function dos_seek(handle:  dos_handle;
                  method:  dos_seek_methods;
                  offset:  integer):  dos_handle;
begin
   dos_regs.ax := $4200 + ord(method);
   dos_regs.bx := handle;
   dos_regs.dx := offset;
   dos_regs.cx := 0;
   dos_call(dos_regs);
   dos_seek := dos_regs.ax;
end;


(* lseek(fd,method,roffset) -> new file position *)

function dos_lseek(handle:  dos_handle;
                   method:  dos_seek_methods;
                   offset:  real):  real;
var
   dxv:  real;

begin
   dos_regs.ax := $4200 + ord(method);
   dos_regs.bx := handle;
   dos_regs.cx := itrunc(offset / 65536.0);

   dxv := offset - 65536.0*int(dos_regs.cx);
   if dxv > int($7fff) then
      dxv := dxv - 65536.0;

   if dxv = $8000 then
      dos_regs.dx := $8000
   else
      dos_regs.dx := itrunc(dxv);

   dos_call(dos_regs);

   if dos_regs.ax = dos_error then
      dos_lseek := dos_error
   else
      dos_lseek := int(dos_regs.dx) * 65536.0 +
                   int(dos_regs.ax shr 1) * 2.0 +
                   int(dos_regs.ax and 1);
end;


(* dos_file_times(fd,time_(set get),time,date); *)

procedure dos_file_times(fd:       dos_handle;
                         func:     dos_time_functions;
                         var time: integer;
                         var date: integer);
begin
   dos_regs.ax := $5700 + ord(func);
   dos_regs.bx := fd;
   dos_regs.cx := time;
   dos_regs.dx := date;
   dos_call(dos_regs);
   time := dos_regs.cx;
   date := dos_regs.dx;
end;



