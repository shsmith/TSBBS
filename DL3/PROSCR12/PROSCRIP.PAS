
(*
 * Copyright 1987, 1991 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *  NOTICE: ALL MODIFIED VERSIONS OF THIS PROGRAM _MUST_ BE DISTRIBUTED
 *          WITH SOURCE CODE.  I STRICTLY FORBID THE USE OF ANY NON-
 *          PUBLIC INFORMATION IN MODIFICATIONS.  FOR EXAMPLE, YOU
 *          CANNOT USE CDC PROVIDED INFORMATION FOR PCBOARD 14.5
 *          COMPATIBILITY, SINCE SUCH A VERSION CANNOT BE RELEASED IN
 *          SOURCE CODE.
 *)

(*
 * ProScrip.PAS - Script Door program for PCBoard 14/ProDoor systems
 *
 *)

{$M 9000,20000,20000}  {Stack, minheap, maxheap}
{$i prodef.inc}


Program ProScript;

{$i prokit.inc}      {include standard 'uses' statement}
{$i proscrip.inc}    {script processing}


var
   driver:     dos_filename;  {driver type; taken care of automatically}
   scrfile:    dos_filename;  {script question file}
   ansfile:    dos_filename;  {answer file}
   newlevel:   integer;       {new level after answering script}



(* ---------------------------------------------------------------- *)
procedure load_config_file;
   {load the latest configuration file}
var
   fd: text;
begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd,driver);
   readln(fd,scrfile);
   readln(fd,ansfile);
   readln(fd,newlevel);
   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure load_pwrd_file;
   (* access pwrd file and set time and kbyte limits accordingly *)
var
   password:      string30;
   level:         integer;
   minutes:       integer;
   kbytes:        integer;

begin
   (* scan the pwrd file for the specified entry *)
   openfile(pcbsetup.pwrd_path^);
   if not ok then
      file_missing(20000);

   repeat
      getaline(par2,sizeof(par2));
      password := scan_nextpar(par2);
      level := atoi(scan_nextpar(par2));
      minutes := atoi(scan_nextpar(par2));
      kbytes := atoi(scan_nextpar(par2));
   until (level = userlevel{user.level}) or endfile;

   closefile;

   (* see if the selected security level is available *)
   if (level <> userlevel{user.level}) then
   begin
      {writeln('Error: no entry in PWRD file for security level ',userlevel);}
      minutes := 0;
   end;

   pcbsys.time_limit := minutes;         {maximum minutes allowed from PWRD}
   pcbsys.down_limit := kbytes;          {daily download limit/1000 from PWRD}
end;


(* ---------------------------------------------------------------- *)
procedure do_script;
begin
   process_script( scrfile, ansfile );

   if ok and (userlevel < newlevel) then
   begin
      if userlevel <> user.level then
      begin
         make_log_entry('Expired users cannot be upgraded by ProScrip!',true);
      end
      else
      begin
         user.level := newlevel;
         userlevel := newlevel;
         make_log_entry('Security level upgraded to '+itoa(user.level)+'!',true);
         load_pwrd_file;
      end;
   end;
end;


(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}

   progname := 'ProScript';   {program name on status line}

   newline;
   displn('ProScript 1.1 04-01-91;  Copyright 1991 Samuel H. Smith');
   newline;

   load_config_file;
   do_script;

   uninit;   {must be last - closes com port and updates database}
end.

