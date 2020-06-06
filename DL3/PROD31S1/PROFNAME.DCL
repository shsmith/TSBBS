
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



const
   sysfile              = 'PCBOARD.SYS'; {system file}
   pcboard_dat_file     = 'PCBOARD.DAT'; {setup file}

   doorfile             = '$DOOR.BAT';   {door created for each transfer}
   namefile             = '$DOOR.NAM';   {list of names, used in logging}
   doorlogfile          = '$DOOR.LOG';   {logfile for DSZ or outside batch}
   resultfile           = '$DOOR.RES';   {result message filename}
   newptrfile           = '$PTRS.NEW';   {new message pointers}
   oldptrfile           = '$PTRS.OLD';   {old message pointers}

   signon_file          = 'PROSTRT';      {filenames of message files}
   protocol_help_file   = 'PROHELP';
   main_menu_file       = 'PROMENU';
   mail_menu_file       = 'PROREAD';
   mail_help_file       = 'PROMAIL';
   enter_help_file      = 'PROENTR';
   closing_door_file    = 'PROCLOS';

   extract_help_file    = 'PROEXT';
   rearc_file           = 'PROARC';   {REARC explanation to user}
   test_archive_file    = 'PROTEST';  {TEST explanation to user}
   arcm_help_file       = 'PROARCM';  {ARCM explanation to user}
   visual_help_file     = 'PROVIS';   {visual edit help file}
   freefile_list        = 'PROFREE';  {list of free d/l files}
   usermail_file        = 'PROUSER';  {user has mail/other flags}

   enter_chat_file      = 'PROCHAT';
   chat_request_file    = 'PROREQ';
   dump_user_message    = 'PRODUMP';  {after F8 key is pressed}

   newuser_file         = 'PRONEW';   {display first time}

   library_menu         = 'PROLIB';
   library_table        = 'LIBDEF';
   library_help_file    = 'LIBHELP';

