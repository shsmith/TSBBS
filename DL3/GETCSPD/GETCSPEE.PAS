
(*
 * get connect speed from pcboard.sys and set errorlevel accordingly.
 *
 * (c) 1991 samuel h. smith
 * written 1-19-91
 *
 *)

uses tools,mdosio;

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
    {127}fill99:         char2;          {filler UNDOCUMENTED}

    {129}useansi:        boolean;        {true if caller is ansi capable}
    {130}lastevdate:     char8;          {last event date mm-dd-yy}
    {138}lastevmin:      word;           {last event minute; 12am=0}
    {140}remotedos:      boolean;        {true if caller has dropped to dos}
    {141}eventupcoming:  boolean;        {true if event is within user time limit}
    {142}conference:     word            {conference the caller was in}
    {144 - bitmap for ConfJoined in high conferences}
    {??? - bitmap for ConfScanned in high conferences}

      );

    2: (
      offline_filler:    array[1..119] of char      {filler, spaces}
      );
   end;

var
   fd:      dos_handle;
   n:       integer;
   sys:     pcb_sys_rec;
   speed:   word;

begin
   fd := dos_open('PCBOARD.SYS',open_read);
   if fd = dos_error then
   begin
      writeln('Can''t open PCBOARD.SYS!');
      halt;
   end;

   n := dos_read(fd,sys,sizeof(sys));
   dos_close(fd);

   speed := atol(sys.connectbps);
   writeln('Connect speed = ',speed);

   halt(speed);
end.

