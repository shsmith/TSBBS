
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
 * locks - set and clear locks
 *
 * used to manage shared resources
 *
 * s.h.smith, 9-mar-87
 *
 *)

function lock_set(lock: anystring): boolean;
   {check to see if a lock is already set by another process}
var
   fd: file;
begin
   assign(fd,lock);
   {$i-}
   reset(fd);
   {$i+}

   if ioresult <> 0 then
      lock_set := false
   else

   begin
      close(fd);
      lock_set := true;
   end;
end;


procedure set_lock(lock: anystring);
   {set a lock; wait if lock is already present}
var
   fd:   file;
   try:  integer;

begin
   try := 0;
   while lock_set(lock) do
   begin
      try := try + 1;
      if try = 5 then
      begin
         writeln(con,'Lock present: ',lock,' - program aborted');
         writeln(con,'This resource could be allocated to another program.');
         writeln(con,'Delete the file ',lock,' to remove the lock.');
         halt(1);
      end
      else
      begin
         write(con,'<WAIT>'^H^H^H^H^H^H);
         delay(500);
         write(con,'      '^H^H^H^H^H^H);
      end;
   end;

   assign(fd,lock);
   rewrite(fd);
   close(fd);
end;


procedure clear_lock(lock: anystring);
var
   fd: file;
begin
   assign(fd,lock);
   {$i-}
   erase(fd);
   {$i+}
   if ioresult <> 0 then
      writeln(con,'Lock missing: ',lock);
end;
