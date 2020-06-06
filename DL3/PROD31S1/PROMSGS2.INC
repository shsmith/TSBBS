
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
 * PCB ProDOOR message files library (3-1-89)
 *
 *)


procedure abort_program(reason: string);
var
   fd: text;
   identity: string;

begin
   {unlink the interrupt handlers - crucial to prevent system crash!}
   newline;
   uninit_com;
   
   identity := system_date+' '+system_time+' '+progname+' '+version;

   {write the error message to the error log file}
   assignText(fd,'$door.err');
   {$i-} append(fd); {$i+}
   if ioresult = 0 then
   begin
      writeln(fd,identity);
      writeln(fd,' ',reason);
      close(fd);
   end;

   {display the message; also put it in the caller log (if possible)}
   writeln(identity);
   make_log_entry(reason,true);
   writeln;

(********************
   {make sure $door.bat leads back to pcboard}
   if option = o_none then
   begin
      assignText(fd,doorfile_path);
      {$i-} rewrite(fd); {$i+}
      if ioresult = 0 then
      begin
         writeln(fd,copy(sys_dir,1,2));
         writeln(fd,'cd ',copy(sys_dir,3,99));
         writeln(fd,'%1');
         close(fd);
      end;
   end;
********************)

   if not local then
      displn('Fatal Error!  Returning to system...');

   {close down the session log if active}
   close_capture;

   {give operator a chance to read the message}
   keypause;

   writeln;
   halt(99);
end;


procedure usage (error: anystring);
begin
   writeln(^G^G);
   abort_program('Error: '+error);
end;

