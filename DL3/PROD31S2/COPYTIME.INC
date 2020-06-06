

(*
 * COPYTIME.INC - This utility library will copy the timestamp
 *                of one file to another file.
 *
 * The statement
 *   {$I \shs\tools\dosio.inc}
 * is required in the main program
 *
 * Author: S.H.Smith, 4/4/86
 *
 *)

procedure copytime(fromname: anystring; toname: anystring);
var
   fd:     integer;
   time:   integer;
   date:   integer;

begin
   fd := dos_open(fromname, open_read);
   dos_file_times(fd,time_get,time,date);
   if dos_close(fd) = dos_error then
      writeln(con,'copytime: close error');

   fd := dos_open(toname, open_update);
   dos_file_times(fd,time_set,time,date);
   if dos_close(fd) = dos_error then
      writeln(con,'copytime: to close error');
end;

