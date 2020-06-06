
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

var
   msgfd:         dos_handle;    {currently locked msgs file handle}

   panelfn:       dos_filename;  {propanel.com pathname}

   user_logged:   boolean;      {valid login?}
   new_user:      boolean;      {first call?}
   door_return:   boolean;      {returning from a door?}
   quick_logon:   boolean;      {quick logon(bypass welcome?}
   bypass_sec:    boolean;      {bypass security message?}
   bypass_news:   boolean;      {bypass news display?}
   dispoff:       boolean;      {is display off now?}
   dos_exit:      boolean;      {are we exiting to dos?}

   cts_check:     boolean;
   speed_known:   boolean;
   dte_known:     boolean;
   protocol_msg:  string40;


{Mailer interface}
const
   mailer_speed:  word = 0;             {/c parameter connect speed}
   mailer_err:    boolean = false;      {/err parameter}


{ProLogon config file variables}
var
   prol_door_menu:      dos_filename;
   prol_menu_always:    boolean;
   prol_door_file:      dos_filename;
   prol_default_option: string8;
   prol_force_default:  boolean;
   prol_allow_override: boolean;

const
   prol_expire_days:    integer = 365;
   prol_expire_level:   integer = 0;
   prol_common_dir:     dos_filename = '';
   prol_disp_news:      (internal, extern, both) = both;
   prol_force_monitor:  boolean = FALSE;
   prol_ring_count:     integer = 1;
   prol_limit_level:    integer = 100;
   prol_count_local:    boolean = TRUE;
   prol_min_baud:       string5 = '1200';
   prol_reset_ticks:    integer = 20;   {automatic modem reset minutes*2}
   prol_auto_register:  boolean = false;
   prol_chat_level:     integer = 0;
   prol_ignore_com_err: boolean = false;
   prol_system_level:   integer = 0;
   prol_monitor_com:    integer = 0;
