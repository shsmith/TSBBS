
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
 * PCBoard file interface declarations - SPECIFIC TO PCB 14.0
 *
 * (3-1-89)
 *
 *)


type

   {layout of the PCBOARD.SYS file while doors are open}
   pcb_sys_rec = record
    {1  }display:        char2;          {display on console?  -1 or 0}
    {3  }printer:        char2;          {print log?           -1 or 0}
    {5  }page_bell:      char2;          {bother sysop?        -1 or 0}
    {7  }alarm:          char2;          {caller alarm sound?  -1 or 0}
    {9  }sysop_next:     char;           {force sysop on next? 'N', 'X' or ' '}

    case integer of
    1: (
    {10 }errcheck:       char2;          {error check/correcting modem? -1 or 0}
    {12 }graphics:       char;           {ansi graphics mode?   'Y','N','7'}
    {13 }nodechat:       char;           {node chat status 'U' or 'A'}
    {14 }openbps:        char5;          {BPS rate to open modem port at}
    {19 }connectbps:     char5;          {BPS connect rate or 'Local'}
    {24 }usernum:        integer;        {record number in user file}
    {26 }firstname:      char15;         {caller's first name}
    {41 }password:       char12;         {caller's password}
    {53 }time_on:        integer;        {when the user logged on in MINUTES}
    {55 }prev_used:      integer;        {minutes used in prev calls today, <0}
    {57 }time_logged:    char5;          {hh:mm time the user logged on}
    {62 }time_limit:     integer;        {maximum minutes allowed from PWRD}
    {64 }down_limit:     integer;        {daily download limit/1024 from PWRD}
    {66 }curconf:        byte;           {active conference when door opened}
    {67 }joined:         bitmap;         {areas user has been in}
    {72 }ydone:          bitmap;         {areas user has done 'Y' on}
    {77 }time_added:     integer;        {highest conference added time in mins}
    {79 }time_credit:    integer;        {upload/chat time credit in minutes}
    {81 }slanguage:      char4;          {language used, blank, .FRE etc}
    {85 }name:           char25;         {caller's full name}
    {110}sminsleft:      integer;        {minutes left when door opened}
    {112}snodenum:       byte;           {current node number}
    {113}seventtime:     char5;          {hh:mm event time}
    {118}seventactive:   char2;          {event time active? "-1" or "0 "}
    {120}sslide:         char2;          {slide event? "-1" or " 0"}
    {122}smemmsg:        single;         {memorized message number}
    {126}scomport:       char;           {com port number '0','1','2'}
    {127}fill99:         char2           {filler UNDOCUMENTED}
    {record size: 128}
      );

    2: (
      offline_filler:    array[1..119] of char      {filler, spaces}
      );
   end;


   {layout of the USERS file}
   pcb_user_rec = record
    {1  }name:          char25;
    {26 }city:          char24;
    {50 }passwd:        char12;         {no spaces allowed}
    {62 }busphone:      char13;
    {75 }phone:         char13;
    {88 }date:          char6;          {yymmdd of last call}
    {94 }time:          char5;          {hh:mm  of last call}
    {99 }expert:        char;           {pcboard expert status Y or N}
    {100}protocol:      char;           {X, C, Y, N}
    {101}space1:        char;           {space - reserved}
    {102}filedate:      char6;          {yymmdd of last file directory}
    {108}level:         byte;           {security level}
    {109}total_calls:   integer;        {number of times on system}
    {111}pagelen:       byte;           {page length}
    {112}uploads:       integer;        {number of uploads}
    {114}downloads:     integer;        {number of downloads}
    {116}downbytes:     double;         {daily download bytes so far}
    {124}usercomment:   char30;         {user entered comment field}
    {154}sysopcomment:  char30;         {sysop maintained comment field}
    {184}lastused:      integer;        {minutes used so far today}
    {186}expdate:       char6;          {yymmdd expiration date}
    {192}explevel:      byte;           {expired security level}
    {193}curconf:       byte;           {current conference number}
    {194}conferences:   bitmap;         {area registration 1-39 (5 bytes)}
    {199}expconf:       bitmap;         {expired conference registration}
    {204}scanconf:      bitmap;         {user configured scan conferences}
    {209}downtotal:     double;         {total bytes downloaded, all calls}
    {217}uptotal:       double;         {total bytes uploaded, all calls}
    {225}dead:          char;           {positive delete flag, Y or N}

    {226}lastread:      array[0..39] of single;
                                        {last message pointer, main+39 conf's}

    {386}reserved:      char5;          {reserved for future use}

(*
 * THE FOLLOWING USERS FILE BYTES ARE TAKEN OVER BY PRODOOR
 * FOR STORAGE OF PRODOOR-SPECIFIC DATA FOR A USER.  OTHER DOOR
 * PROGRAMS SHOULD TAKE CARE TO NOT CONFLICT WITH THESE BYTE
 * POSITIONS!
 *)
    {391}extrarec:      word;           {record number for extra user record}

    {393}flags:         byte;           {prodoor user flag bits}

    {394}mailconf:      byte;           {conference user has mail in}
    {395}scratchnum:    byte;           {scratch file number - incremented for
                                         each use of a scratch file}
    {396}dooruse:       byte;           {times in prodoor, up to 255}
    {397}earned_k:      word;           {prodoor; earned kbytes}


    {399}reserve3:      word;           {used by qmail??}
    {total size: 400}
   end;


const
   {bit values in conf_flags}
   conf_scan_blts    = 1;     {qmail include blts?}
   conf_scan_files   = 2;     {qmail scan new files?}

type
(* layout of CNAMES/CONFINFO record *)
   pcbconf_rec = record
      conf_name:              string[10];

      conf_private_ul:        boolean;
      conf_private_mail:      boolean;
      conf_echo_mail:         boolean;
      conf_addsec:            integer;
      conf_addtime:           integer;    {minutes}
      conf_msgblocks:         integer;    {1-32 message blocks; 1024 msgs each}

      conf_msgfile:           string[31];  {conference message base pathname}
      conf_public_uplist:     string[31];  {public uploads listing pathname}
      conf_updir:             string[31];  {conference upload dir}
      conf_private_uplist:    string[31];  {private uploads listing pathname}
      conf_private_updir:     string[31];  {private uploads dir}

      conf_newsfile:          string[31];  {conference news pathname}

      conf_doormenu:          string[31];  {door menu pathname}
      conf_doorinfo:          string[31];  {door info data pathname}

      conf_bltmenu:           string[31];  {bulletin menu pathname}
      conf_bltinfo:           string[31];  {bulletin info pathname}

      conf_minsec:            integer;     {minimum security to join
                                            if conference is non-public}

      conf_dirmenu:           string[31];  {file area menu pathname}
      conf_dirinfo:           string[31];  {file area info pathname}

      conf_autojoin:          boolean;     {auto-rejoin on logon?}

      conf_spare2:            byte;
      conf_dlinfo:            string[31];  {download path info pathname}

      conf_public:            boolean;     {is this conference public?}

      conf_packopt:           string[15];  {propack options}

      conf_flags:             byte;        {Qmail flag bits}

      conf_spare3:            byte;        {spare flag bits}

      conf_msgs_read:         single;      {Number of messages downloaded/read
                                            from this conference}

      conf_msgs_entered:      single;      {Number of messages uploaded to this
                                            conference}

      conf_spare4:            char6;       {unallocated}
   end;


(* layout of pcboard.dat *)
   pcbsetup_rec = record
      sysop_name:             varstring;  {sysop display name}
      use_realname:           boolean;    {use real name for sysop?}
      local_graphics:         boolean;    {graphics on in local mode?}
      security_dir:           varstring;  {security messages location}
      chat_dir:               varstring;  {node chat files location}
      pcbtext_dir:            varstring;  {pcbtext file location}
      userix_dir:             varstring;  {user index location}
      users_path:             varstring;  {user file pathname}
      caller_path:            varstring;  {caller log pathname}
      cnames_path:            varstring;  {cnames file pathname}
      pwrd_path:              varstring;  {pwrd file pathname}
      fsec_path:              varstring;  {fsec file pathname}
      upsec_path:             varstring;  {upsec file pathname}
      tcan_path:              varstring;  {tcan file pathname}
      welcome_path:           varstring;  {welcome file pathname}
      newuser_path:           varstring;  {newuser file pathname}
      closed_path:            varstring;  {closed file pathname}
      warning_path:           varstring;  {30 day expiration warning pathname}
      expired_path:           varstring;  {expired user message pathname}
      usernet_path:           varstring;  {usernet.dat file pathname}
      conference_menu:        varstring;  {conference menu pathname}
      tranlog_path:           varstring;  {down/upload transfer log pathname}
      logoff_path:            varstring;  {logoff message pathname}
      language_path:          varstring;  {multi-lingual data file}
      hayesv_modem:           boolean;    {hayes-v modem?}
      initial_speed:          word;       {modem initial/top open speed}
      lock_speed:             boolean;    {lock modem at initial speed}
      modem_initial:          varstring;  {modem initial command}
      modem_offhook:          varstring;  {modem off-hook command}
      reset_modem:            boolean;    {reset modem during recycle?}
      recycle_offhook:        boolean;    {modem offhook during recycle?}
      allow_300:              boolean;    {allow 300 baud connections?}
      start_300:              string5;    {starting hh:mm for 300 baud}
      stop_300:               string5;    {ending hh:mm for 300 baud}
      disable_blanker:        boolean;    {disable 3 minute screen blanker}
      disable_filter:         boolean;    {disable high-bit filter}
      disable_quick:          boolean;    {disable quick logon/join}
      multi_lingual:          boolean;    {run in multi-lingual mode?}
      only_pwchange:          boolean;    {allow only password changes?}
      closed_board:           boolean;    {run in closed-board mode?}
      disable_graphics:       boolean;    {disable graphics mode?}
      dos_recycle:            boolean;    {exit to dos after each caller}
      subscription_mode:      boolean;    {enable expired user checks}
      allow_esc_codes:        boolean;    {allow escape codes in messages}
      validate_to:            boolean;    {validate "TO:" in messages}
      enforce_time_limit:     boolean;    {enforce daily time limits?}
      new_news:               boolean;    {display only NEW news files?}
      timeout_minutes:        integer;    {keyboard timeout in minutes}
      under_network:          boolean;    {running multi-node?}
      node_number:            varstring;  {node number}
      network_timeout:        integer;    {network timeout in seconds}
      chat_delay:             integer;    {node chat delay in seconds}
      system_name:            varstring;  {name of the bbs system}
      macro_string:           array[1..10] of varstring;
                                          {shift-F1 thru F10 macros}
      public_conferences:     string40;   {public conferences}
      msg_lines:              integer;    {maximum message lines (1-99)}
      ansi_intensity:         varstring;  {default intensity}
      ansi_color:             varstring;  {color for inputs/filedisps}
      event_active:           boolean;    {is event active?}
      event_time:             string8;    {event time hh:mm}
      event_buffer:           integer;    {minutes buffer before event}
      event_noul:             boolean;    {disable uploads before event}
      slide_event:            boolean;    {slide event time if needed}
      disable_freecheck:      boolean;    {disable free space check}
      printer_num:            integer;    {printer port number 1..3}
      min_upload_free:        integer;    {stop uploads if free space less (K)}

      newuser_level:          integer;    {level given to new users}
   end;


(* layout of usernet.dat *)

   usernet_rec = record
      status:  char2;      {chatting-with-node-number or status code}
      nodeno:  char2;      {this-node-number or "R " if chat request sent}
      name:    char25;     {name of caller on this node}
      city:    char24;     {location of caller on this node}
   end;


(* flag bits in user.flags byte *)

const
   flag_hasmail = $01;   {user has mail waiting?}
  {flag_expert  = $02;}  {is user an expert?}
   flag_hotkeys = $04;   {does user want hotkeys?}
   flag_init    = $20;   {set before prodoor runs the first time}
   flag_oldfmt  = $40;   {set by old versions of prodoor, must be clear in new}

