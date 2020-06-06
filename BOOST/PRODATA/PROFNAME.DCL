
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



const
   sysfile              = 'PCBOARD.SYS'; {system file}
   pcboard_dat_file     = 'PCBOARD.DAT'; {setup file}

   doorfile             = '$DOOR.BAT';   {door created for each transfer}
   namefile             = '$DOOR.NAM';   {list of names, used in logging}
   doorlogfile          = '$DOOR.LOG';   {logfile for DSZ or outside batch}
   resultfile           = '$DOOR.RES';   {result message filename}
   newptrfile           = '$PTRS.NEW';   {new message pointers}
   oldptrfile           = '$PTRS.OLD';   {old message pointers}
   initialfile          = '$DOOR.CMD';   {initial command line}

   signon_file          = 'PROSTRT';     {filenames of message files}
   closing_door_file    = 'PROCLOS';

   protocol_help_file   = 'PROHELP';
   main_menu_file       = 'PROMENU';
   mail_menu_file       = 'PROREAD';
   mail_help_file       = 'PROMAIL';
   enter_help_file      = 'PROENTR';
   more_help_file       = 'PROMORE';
   join_help_file       = 'PROJOIN';
   view_help_file       = 'PROFV';

   rearc_file           = 'PROARC';   {REARC explanation to user}
   test_archive_file    = 'PROTEST';  {TEST explanation to user}
   arcm_help_file       = 'PROARCM';  {ARCM explanation to user}
   visual_help_file     = 'PROVIS';   {visual edit help file}
   upratio_file         = 'PRORATIO';
   outside_menu_file    = 'PROPROGM';

   ulmsg_file           = 'PROULM';
   dlmsg_file           = 'PRODLM';

   enter_chat_file      = 'PROCHAT';
   chat_request_file    = 'PROREQ';
   dump_user_message    = 'PRODUMP';  {after F8 key is pressed}

   newuser_file         = 'PRONEW';   {display first time}

{  extract_help_file    = 'PROEXT'; }

{  usermail_file        = 'PROUSER';} {user has mail/other flags}

   freefile_list        = 'PROFREE';  {list of free d/l files}

   dupdir_list          = 'PRODUP';   {directories to check for u/l duplication}

   library_menu         = 'PROLIB';
   library_table        = 'LIBDEF';
   library_help_file    = 'LIBHELP';

   trans_file           = 'PROTRNS';  {.LNG; output/message translation file}

