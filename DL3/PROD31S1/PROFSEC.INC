
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
 * PCB ProDOOR security checker (3-1-89)
 *
 *)

function verify_access(fname:      anystring;            {function name}
                       flevel:     integer;              {minimum level}
                       fpassword:  anystring;            {password if any}
                       fmessage:   anystring)            {failure message}
                          : boolean;
   (* verfy access to a named resource; check level and password if needed *)
var
   pw:   anystring;

begin
   verify_access := false;

   (* reject if access level is too low *)
   if userlevel < flevel then
   begin
      {newline;}
      make_log_entry(fmessage+' ('+fname+')',true);
      wait_for_enter;
      exit;
   end;

   (* prompt for the password if needed *)
   if length(fpassword) <> 0 then
   begin

(***
if setdebug then
writeln(dbfd,'[verify: fn=',fname,' flev=',flevel,' fpwd=',fpassword,']');
***)

      dYELLOW('Enter password for ('+fname+') access: ');
      pw := '';
      line_input(pw,20,false,false);
      newline;
      if (length(pw) = 0) or dump_user then
         exit;

      stoupper(pw);
      if pw <> fpassword then
      begin
         make_log_entry('Incorrect password ('+pw+') for ('+fname+')',true);
         wait_for_enter;
         exit;
      end;
   end;

   (* access must be okay, allow it *)
   verify_access := true;
end;


(* ------------------------------------------------------------ *)
function file_allowed(path:       anystring;            {name to verify}
                      secfile:    filenames)            {fsec/upsec name}
                         : boolean;
   (* return true if file access is allowed; uses UPSEC/FSEC data;
      prompts for password if needed; verifies security level *)
var
   i:               integer;
   dir:             anystring;
   name:            anystring;
   item:            anystring;
   fsec_dir:        filenames;
   fsec_wildcard:   anystring;
   fsec_level:      integer;
   fsec_password:   anystring;
   message:         anystring;
   wild:            boolean;

begin
   if pro_mode = RX then
      message := 'Uploads Not Accepted on File Format'
   else
      message := 'Insufficient Download Security for';


   (* split the path into dir and name *)
   file_allowed := false;
   dir := path_only(path);
   name := remove_path(path);


   (* open the file security table *)
   openfile(secfile);
   if not ok then
      file_missing;

(***
if setdebug then
writeln(dbfd,'[allowed: name=',name,' secfile=',secfile,' dir=',dir,' msg=',message,']');
***)

   (* scan each entry in the security table *)

   while not endfile do
   begin
      getstrd(fsec_dir);
      getstrd(fsec_wildcard);
      getint(fsec_level);
      getstrd(fsec_password);

(**
if setdebug then
writeln(dbfd,'[allowed: dir=',fsec_dir,' wild=',fsec_wildcard,
        ' lev=',fsec_level,' pw=',fsec_password,']');
**)

      (* if the directory matches *)
      if (length(fsec_dir) = 0) or (fsec_dir = dir) then
      begin
         wild := (length(fsec_wildcard) = 0) or (fsec_wildcard = '*.*');

         (* use wildcard for resource description (except for some cases) *)
         if wild then
            item := name
         else
            item := fsec_wildcard;

         (* verify the access if the filename matches *)
         if wildcard_match(fsec_wildcard, name) then
         begin
            file_allowed := verify_access(item, fsec_level,
                                          fsec_password, message);
            closefile;
            exit;
         end;

      end;
   end;

   (* file access is allowed if not listed in FSEC *)
   closefile;
   file_allowed := true;
end;

