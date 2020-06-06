
(*
 * PCBoard file interface declarations - SPECIFIC TO PCB 12.0
 *
 * S.H.Smith, 20-May-87 (rev. 25-Nov-87)
 *
 *  NOTICE: ALL MODIFIED VERSIONS OF THIS PROGRAM _MUST_ BE DISTRIBUTED
 *          WITH SOURCE CODE.  I STRICTLY FORBID THE USE OF ANY NON-
 *          PUBLIC INFORMATION IN MODIFICATIONS.  FOR EXAMPLE, YOU
 *          CANNOT USE CDC PROVIDED INFORMATION FOR PCBOARD 14.5
 *          COMPATIBILITY, SINCE SUCH A VERSION CANNOT BE RELEASED IN
 *          SOURCE CODE.
 *)

const
   max_stdconf = 9;             {highest "standard" conference number}
   min_extconf = 10;            {lowest "extra" conference number}
   max_conf = 36;               {4*9 = cnames, cnames2..cnames4}
   max_cnames = 4;              {highest cnames file to load}   

type

{$IFNDEF PCB14}
   {layout of the PCBOARD.SYS file while doors are open}
   pcb_sys_rec = record
    {1  }display:        char2;          {display on console?  -1 or 0}
    {3  }printer:        char2;          {print log?           -1 or 0}
    {5  }page_bell:      char2;          {bother sysop?        -1 or 0}
    {7  }alarm:          char2;          {caller alarm sound?  -1 or 0}
    {9  }sysop_next:     char;           {force sysop on next? 'N', 'X' or ' '}

    {10 }fill1:          char;           {filler, always a space}
    {11 }baud:           char4;          {caller's baud rate}
    {15 }name:           char25;         {caller's name}
    {40 }sfiller:        char2;          {spaces}
    {42 }firstname:      char15;         {caller's first name}
    {57 }graphics:       char2;          {ansi graphics mode?   '-1', ' 0' or '7E'}
    {58 }password:       char12;         {caller's password (last 2 chars redef'd}
    {71 }usernum:        integer;        {record number in user file}
    {73 }time_on:        single;         {when the user logged on in secs}
    {77 }time_limit:     single;         {user's allowed time in secs}
    {81 }open_time:      single;         {time door was opened in secs}
    {85 }time_logged:    char5;          {time the user logged on in hh:mm}
    {90 }curconf:        integer;        {active conference when door opened}

    {92 }ojoined:        array[1..max_stdconf] of integer;
                                         {0 or -1 for conferences joined}

    {110}time_added:     integer;        {highest conference added time in mins}
    {112}down_limit:     double;         {daily download limit in kbytes}
    {120}time_credit:    integer;        {upload time credit so far that call}

    {122}slanguage:      char4;          {language version used, blank, .FRE etc}
    {126}errcheck:       char2;          {error check/correcting modem? -1 or 0}
    {128}nodechat:       char;           {node chat flag prior to exit to DOS}
    {record size: 128}
   end;


   {layout of the USERS file}
   pcb_user_rec = record
    {1  }name:          char25;
    {26 }city:          char24;
    {50 }passwd:        char12;         {no spaces allowed}
    {62 }busphone:      char13;
    {75 }phone:         char13;

    {88 }date:          char8;          {mm-dd-yy of last call}
    {96 }time:          char5;          {hh:mm    of last call}
    {101}expert:        char;           {pcboard expert status Y or N}
    {102}protocol:      char;           {X, C, Y, N}
    {103}conferences:   char9;          {10000000}
    {112}curconf:       char;           {current conference}
    {113}rejoin:        char;           {Y or N}
    {114}filedate:      char6;          {yymmdd of last file directory}
    {120}level:         integer;
    {122}total_calls:   integer;
    {124}pagelen:       integer;
    {126}olastread:     array[0..max_stdconf] of word;
                                        {for main board & each std conf.}
    {146}uploads:       integer;
    {148}downloads:     integer;
    {150}lastused:      integer;        {time used on previous call}
    {152}dead:          char;           {positive delete flag}

    {153}expdate:       char6;          {expiration date, yymmdd format}
    {159}explevel:      integer;        {expired security level}
    {161}expconf:       char9;          {expired conference registration}
    {170}downbytes:     double;         {daily download byte information}
    {178}usercomment:   char30;         {user entered comment field}
    {208}sysopcomment:  char30;         {sysop maintained comment field}
    {238}ureserved:     char11;         {reserved for future use}

    {249}xpert:         char;           {pcb/pro's expert flag}
    {250}nulls:         char;           {pcb/pro's nulls flag}
    {251}extrarec:      word;           {record number in extra user file}
    {253}reserve2:      word;           {used by qmail}
    {255}reserve3:      word;           {used by qmail}
    {total size: 256}
   end;


   {layout of the PCBOARD.SYS file when offline}
   pcb_offline_sys_rec = record
      display:        char2;          {display on console?  -1 or 0}
      printer:        char2;          {print log?           -1 or 0}
      page_bell:      char2;          {bother sysop?        -1 or 0}
      alarm:          char2;          {caller alarm sound?  -1 or 0}
      sysop_next:     char;           {force sysop on next? 'N', 'X' or ' '}
      filler:         array[1..119] of char;     {filler, spaces}
   end;


   {layout of the CALLER file}
   pcb_caller_rec = record
      message:        array[1..62] of char;
      crlf:           char2;   
   end;


(* layout of CNAMES record *)
   pcbconf_rec = record
      conf_name:              string8;
      conf_downlist:          string160;
      conf_bulletins:         integer;
      conf_dirs:              integer;
      conf_private_ul:        boolean;
      conf_updir:             string65;  {conference upload dir}
      conf_rejoin:            boolean;
      conf_files_dir:         string65;  {conference files dir}
      conf_addsec:            integer;
      conf_addtime:           integer;
      conf_viewmembers:       boolean;
      conf_minibbs:           boolean;
      conf_maxmsgs:           integer;
      conf_keepin:            boolean;
      conf_private_mail:      boolean;
   end;


(* layout of pcboard.dat *)
   pcbsetup_rec = record

(* graphics active in local logins? *)
      local_graphics:         boolean;

(* user levels *)
    {  sec_level:              array[2..41] of integer; }

(* sysop information *)
      pcbvers:                string65;
      sysop_name:             string20;
      local_password:         string20;

(* file name data *)
      msgs_file:              string8;
      caller_file:            string8;
      caller_location:        string65;
      welcome_file:           string8;
      newuser_file:           string8;
      users_file:             string8;
      cnames_file:            string8;
      fsec_file:              string8;
      pwrd_file:              string8;
      tcan_file:              string8;
      remote_file:            string8;
      answer_file:            string8;
      newreg_file:            string20;
      doors_file:             string8;
      news_file:              string8;
      usernet_path:           string65;
      download_log:           string65;

(* file location data *)
      main_updir:             string65;   {where upload files go}
      gen_dir:                string65;
      main_dir:               string65;
      help_dir:               string65;
      main_uplist_dir:        string65;   {where upload DIR and PRIVATE do}
      node_chatdir:           string65;
      main_downlist:          string255;

(* modem data *)
      carrier_wait:           integer;
      modem_init:             string65;
      modem_offhook:          string20;
      comport:                string8;
      topbaud:                integer;
      allow_300baud:          boolean;
      first_300time:          string8;
      last_300time:           string8;
      newuser_level:          integer;
      unregistered_lev:       integer;

(* Miscellaneous *)
      main_bulletins:         integer;
      main_dirs:              integer;
      daily_time_limit:       boolean;
      main_private_ul:        boolean;
      deny_update:            boolean;
      closed_board:           boolean;
      nongraphics_board:      boolean;
      public_conferences:     string20;
      dos_recycle:            boolean;   {exit to dos after each caller}
      event_active:           boolean;
      event_time:             string8;
      msg_lines:              integer;
      ansi_intensity:         string8;
      ansi_color:             string8;
      under_network:          boolean;
      node_number:            integer;
      chat_pause:             boolean;

(* text data *)
      macro_string:           array[1..10] of string65;
      comment_prompt:         string65;
      system_name:            string65;
      printer_num:            integer;
      last_read_upd:          boolean;
      main_max_msgs:          integer;
      allow_esc_codes:        boolean;
      allow_cc_msgs:          boolean;
      validate_to:            boolean;

(* switches and stuff *)
      disable_cls3:           boolean;
      slow_modem:             boolean;
      reset_modem:            boolean;
      upload_buffers:         integer;
      disable_regedit:        boolean;
      ring_detect:            boolean;
      disable_5m_timeout:     boolean;
      disable_GC:             boolean;
      eliminate_snow:         boolean;
      disable_filter:         boolean;
      disable_CTS_check:      boolean;
      slide_event:            boolean;
      min_upload_free:        integer;
      disable_quick:          boolean;
      disable_pwcheck:        boolean;
      network_delay:          integer;
      main_private_mail:      boolean;
      subscription_bbs:       boolean;
      phone_now:              string65;
      conf_count:             integer;
   end;

{$ENDIF}

(* information about the "extra" conferences *)
   extra_conf_rec = record
        name:           char25;         {user name}
               
        lastdate:       string8;        {last date of access (used to reset
                                         joined flags}
                                         
        dooruse:        integer;        {count of door openings}

        joined:         array[1..max_conf] of integer;
                                        {joined flag for all conferences}
                        
        lastread:       array[0..max_conf] of word;
                                        {last message read for all conferences}

        spare0:         byte;
        allowed:        array[1..max_conf] of char;
                                        {list of allowed conferences}
                                        
        earned_bytes:   real;           {(6) bytes of upload credit earned}
         
        scratchnum:     integer;        {scratch file number - incremented for
                                         each use of a scratch file}

        spare:          array[1..157] of char;
                                        {reserved for future uses}
  end;
   
