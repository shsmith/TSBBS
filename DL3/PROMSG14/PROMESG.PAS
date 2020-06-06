
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
 * ProMesg.PAS - Trivial DOOR to display a specific message and logoff.
 *
 *)

{$M 6000,14000,14000}  {Stack, minheap, maxheap}
{$i prodef.inc}


Program ProMesg;

Uses
   Dos,
   MiniCrt,    {BIOS-only crt functions}
   OpenShare,  {Shared text files}
   MdosIO,     {Dos-level random access files}
   BufIO,      {Buffered record i/o}
   qRead,      {Quick string qReadLn procedure}
   Tools,      {Various utilities}
   ProData,    {ProDoor/pcboard data}
   ProRoot,    {ProKit main support library}
   ProSysf,    {ProKit Status display, function keys, system functions}
   ProScan,    {File display and colorization}
   ProUtil,    {ProKit utility library #1}
   ProUtil2,   {proKit utility library #2}
   ProRead,    {message reader/comment entry}
   KitInit;    {ProKit initialization/deinit}


{$DEFINE PCB14}         {Compile for PCBoard 14.0 (otherwise 12.1)}


var
   driver:     dos_filename;  {driver type; taken care of automatically}
   msgfile:    dos_filename;  {script question file}
   action:     string;        {action after message display}


(* ---------------------------------------------------------------- *)
procedure load_config_file;
   {load the latest configuration file}
var
   fd: text;
begin
   assignText(fd,config_file);
   reset(fd);
   readln(fd,driver);
   readln(fd,msgfile);
   readln(fd,action);
   close(fd);
end;



(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}

   progname := 'ProMesg';   {program name on status line}

   newline;
   displn('ProMessage 1.3 (11-11-92) Copyright 1992 Samuel H. Smith');
   newline;

   load_config_file;

   {display the message file}
   display_file(msgfile);
   force_enter;
   newline;

   {leave comment to sysop if needed}
   if action[1] = 'M' then
   begin
      delete(action,1,1);
      load_cnames_file;
      load_conf(0);
      current_conf := 0;   {main board}
      cmdline := 'C';
      message_reader;
   end;

   {trigger automatic logoff}
   if action = 'G' then
   begin
      dump_user := true;
      option := o_logoff;
   end;

   close_down_door(false);  {closes com port and updates database,
                             no signoff message printed}
end.

