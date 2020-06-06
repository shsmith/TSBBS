
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


(* ------------------------------------------------------------ *)
function next_extended_descr(var descr: string): anystring;
var
   p:    integer;
begin
   p := posc(#255,descr);
   if p = 0 then
   begin
      next_extended_descr := descr;
      descr := '';
   end
   else
   begin
      next_extended_descr := copy(descr,1,p-1);
      descr := copy(descr,p+1,255);
   end;
end;


(* ------------------------------------------------------------ *)
procedure display_extended_description(descr: string);
begin
   displn(next_extended_descr(descr));
   while length(descr) > 0 do
   begin
      spaces(31);
      displn(next_extended_descr(descr));
   end;
end;



(* ------------------------------------------------------------ *)
procedure log_upload_name(logfile:  anystring;
                          source:   anystring;
                          dest:     anystring;
                          size:     longint;
                          descr:    string);
   (* make an entry in the upload description file *)
   (* prompt for a description if none is provided *)

{$IFDEF IN_PROEDIT}
begin

{$ELSE}
var
   fd:    text;
   sizes: anystring;
   date:  anystring;
   name:  anystring;
   p:     integer;
   len:   integer;
   who:   anystring;

begin
   date := system_date;              (* mm-dd-yy format *)
   sizes := ftoa(size,7,0);
   name := ljust(remove_path(dest),12);

   (* redirect logs to private directory when needed *)
   if (logfile = upload_list) and (descr[1] = '/') then
      logfile := private_list;

   if length(logfile) < 3 then
      exit;

   (* append data to the file *)
   assignText(fd,logfile);
   {$i-} append(fd); {$i+}
   if ioresult <> 0 then exit;

   write(fd,name,'  ',sizes,'  ',date,'  ');
   writeln(fd,next_extended_descr(descr));
   while length(descr) > 0 do
      writeln(fd,'| ':33,next_extended_descr(descr));

   if not environment_on('NOULBY') then
   begin
      who := username;
      capstr(who);
      writeln(fd,'| ':33,'Uploaded by: ',who);
   end;

   close(fd);

{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure log_download(entry: anystring);
   (* make an entry in the download log file *)
var
   fd:    text;
begin

{$IFNDEF IN_PROEDIT}
   if pcbsetup.tranlog_path^= '' then exit;
   assignText(fd,pcbsetup.tranlog_path^);
   {$i-} append(fd); {$i+}
   if ioresult <> 0 then exit;

   writeln(fd,entry);
   close(fd);
{$ENDIF}

end;


