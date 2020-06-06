
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
 * PCB ProDOOR command-line translation
 *
 *)

procedure get_xcmd(xfile: filenames);
var
   lev:     integer;
   cmd:     anystring;
   rep:     anystring;
   break:   boolean;
   p:       integer;

begin
   get_hcmdline;
   get_nextpar;

   if (par <> '') and (xfile <> '') and (dos_exists(xfile)) then
   begin
      openfile(xfile);
      readbas_comment := ';';

      break := false;
      while (not endfile) and (not break) do
      begin
         getline(rep,sizeof(rep));
         lev := atoi(scan_nextpar(rep));
         cmd := scan_nextpar(rep);

         if (userlevel >= lev) and (par = cmd) then
         begin
            if setdebug then
               writeln(dbfd,'[xlat: from=',par,' to=',rep,' ',cmdline,']');
            par := rep;
            break := true;
         end;
      end;

      closefile;
   end;

   unget_par;
end;


