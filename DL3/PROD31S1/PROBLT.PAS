
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
 * PCB ProDOOR - bulletin listings user interface (3-1-89)
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProBlt;

interface

   Uses
     Tools,
     MdosIO,
     ProData,
     ProRoot;


procedure display_bltmenu;
procedure read_bulletins;


implementation


procedure display_bltmenu;
begin
   display_file(conf_info.conf_bltmenu);
end;


procedure read_bulletins;
var
   count:   integer;
   sel:     integer;

   procedure get_bltfile;
   var
      fd:   dos_handle;
      n:    integer;
      name: char30;

   begin
      fd := dos_open(conf_info.conf_bltinfo,open_read);
      if fd <> dos_error then
      begin
         dos_rseek(fd,sel-1,sizeof(name),seek_start);
         n := dos_read(fd,name,sizeof(name));
         dos_close(fd);
         par := name;
         delete_trailing_spaces(par);
      end;
   end;

begin
   get_infocount(conf_info.conf_bltinfo, 30, count);
   if count = 0 then
   begin
      not_available;
      exit;
   end;

   if length(cmdline) = 0 then
   begin
      dec(linenum);
      display_bltmenu;
   end;

   while not dump_user do
   begin
      if length(cmdline) = 0 then
      begin
         newline;
         par5 := count;
         get_defnh('Bulletin: (1-$5W$),','(R)elist, ');
         if (length(cmdline) = 0) then exit;
      end;

      get_nextpar;
      if length(par) <> 0 then

      case par[1] of
         'R':       display_bltmenu;

         '1'..'9':  begin
                       sel := parn;
                       if (sel < 1) or (sel > count) then
                          not_available
                       else

                       begin
                          dec(linenum);
                          get_bltfile;
                          display_file(par);
                          newline;

                          par5 := sel;
                          make_log_entry('Bulletin Read: @INCONF@ # $5W$',true);
                       end;
                    end;
      end; {case}
   end; {while}
end;

end.

