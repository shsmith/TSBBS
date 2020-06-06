
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
 * Copy or Move files; changes time stamps (3-1-89)
 *
 *)

(* ------------------------------------------------------------ *)
procedure copy_file(source,dest: string65);
   (* copy a file from one place to another *)

const
   bufmax = $8000;   {maximum buffer size}
   extra = $800;     {extra heap to leave free}
var
   avail:    longint;
   bufsize:  word;   {actual buffer size}
   buf:      ^byte;
   ifd:      dos_handle;
   ofd:      dos_handle;
   n,w:      word;

begin
   ifd := dos_open(source,open_read);
   if ifd = dos_error then
      exit;

   ofd := dos_create(dest);
   if ofd = dos_error then
   begin
      dos_close(ifd);
      exit;
   end;

   bufsize := bufmax;
   avail := dos_maxavail-extra;
   if bufsize > avail then
      bufsize := avail;

   if avail < 1 then
   begin
(**)
      make_log_entry('Can''t allocate COPY_FILE buffer!',true);
(**)
      exit;
   end;

   dos_getmem(buf,bufsize);

   repeat
      n := dos_read(ifd,buf^,bufsize);
      dos_write(ofd,buf^,n);
      w := dos_regs.ax;
   until w <> bufsize;

   dos_freemem(buf);
   dos_close(ifd);
   dos_close(ofd);

   if w <> n then
   begin
      dos_unlink(dest);
(**)
      make_log_entry('Sorry, no disk space for '+dest,true);
(**)
(***
      writeln(debugfd^,^G'DISK FULL!  Copying to ',dest);
***)
   end;
end;


(* ------------------------------------------------------------ *)
procedure move_file(source,dest: string65);
   (* move a file from one place to another;  quickly rename if
      possible, otherwise copy and delete.  touches file to make
      file-date = date moved or copied *)
var
   tfd:  file of byte;
   buf:  byte;

begin

(* try to rename the file (fastest way, only on same device) *)
   assign(tfd,source);

   {$i-} rename(tfd,dest); {$i+}
   if ioresult = 0 then
   begin
      (* move worked, touch the file to set last update date/time
         to today's date.  otherwise file may have strange date as
         set by the transfer protocol.  this makes date = date uploaded *)
      {$i-}
         assign(tfd,dest);
         reset(tfd);
         read(tfd,buf);
         seek(tfd,0);
         write(tfd,buf);
         close(tfd);
      {$i-}

      if ioresult <> 0 then {couldn't "touch" file} ;
      exit;
   end
   else

   (* rename failed, just copy the file and delete original *)
   begin
      copy_file(source,dest);
      dos_unlink(source);
   end;

end;

