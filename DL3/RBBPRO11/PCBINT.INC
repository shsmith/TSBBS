
(*
 * PCBINT.INT - write PCBoard files
 *
 * S.H.Smith, 20-May-87 (rev. 12-Dec-87)
 *
 *)

type
   char2     = array [1..2] of char;
   char8     = array [1..8] of char;
   char9     = array [1..9] of char;
   char12    = array [1..12] of char;
   char13    = array [1..13] of char;
   char25    = array [1..25] of char;


   {layout of the PCBOARD.SYS file while doors are open}
   pcb_sys_rec = record
      display:        char2;          {display on console?  -1 or 0}
      printer:        char2;          {print log?           -1 or 0}
      page_bell:      char2;          {bother sysop?        -1 or 0}
      alarm:          char2;          {caller alarm sound?  -1 or 0}
      sysop_next:     char2;          {force sysop on next? 'N ', 'X ' or '  '}

      baud:           array [1..4] of char;       {caller's baud rate}
      name:           char25;         {caller's name}
      xpert:          char;           {pcb/pro's own expert flag}
      nulls:          char;           {pcb/pro's own nulls flag}
      firstname:      array [1..15] of char;      {caller's first name}
      graphics:       char2;          {ansi graphics mode?   '-1', ' 0' or '7E'}
      password:       array [1..12] of char;      {caller's password (last 2 chars redef'd}
      usernum:        integer;        {record number in user file}
      time_on:        single;         {when the user logged on in secs}
      time_limit:     single;         {user's allowed time in secs}
      open_time:      single;         {time door was opened in secs}
      time_logged:    array [1..5] of char;       {time the user logged on in hh:mm}
      conference:     integer;        {active conference when door opened}
      joined:         array[1..9] of integer;
                                      {0 or -1 for conferences joined}
      time_added:     integer;        {highest conference added time in mins}
      down_limit:     double;         {daily download limit in kbytes}
      upload_credit:  integer;        {upload time credit so far that call}

      slanguage:      array [1..4] of char;       {language version used, blank, .FRE etc}
      errcheck:       char2;          {error check/correcting modem? -1 or 0}
      nodechat:       char;           {node chat flag prior to exit to DOS}
   end;


   {layout of the USERS file}
   pcb_user_rec = record
      name:          char25;
      city:          array [1..24] of char;
      passwd:        char12;         {no spaces allowed}
      busphone:      char13;
      phone:         char13;
      date:          char8;          {mm-dd-yy of last call}
      time:          array [1..5] of char;       {hh:mm    of last call}
      xpert:         char;           {Y or N}
      protocol:      char;           {X, C, Y, N}
      conferences:   array [1..9] of char;       {10000000}
      inconference:  char;
      rejoin:        char;           {Y or N}
      filedate:      array [1..6] of char;       {yymmdd of last file directory}
      level:         integer;
      total_calls:   integer;
      pagelen:       integer;
      lastread:      array[0..9] of integer;  {for main board & each conf.}
      uploads:       integer;
      downloads:     integer;
      lastused:      integer;        {time used on previous call}
      dead:          char;           {positive delete flag}

      regdate:       array [1..6] of char;       {registration date, yymmdd format}
      explevel:      integer;        {expired security level}
      expconf:       array [1..9] of char;       {expired conference registration}
      downbytes:     double;         {daily download byte information}
      usercomment:   array [1..30] of char;      {user entered comment field}
      sysopcomment:  array [1..30] of char;      {sysop maintained comment field}
      ureserved:     array [1..19] of char;      {reserved for future use}
   end;

var
   user:         pcb_user_rec;
   pcbsys:       pcb_sys_rec;


(* ------------------------------------------------------------ *)
procedure put_pcbsys_file;
   (* save PCBOARD.SYS and tinker with some fields *)
var
   fd:  file of pcb_sys_rec;

begin
   assign(fd,'PCBOARD.SYS');
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then
      usage('Can''t create system file PCBOARD.SYS');

   write(fd,pcbsys);
   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure put_user_rec;
   (* load current user's record from the user file *)
var
   fd:  file of pcb_user_rec;

begin
   assign(fd,'USERS');
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then
      usage('Can''t create pcboard user file USERS');

   write(fd,user);
   close(fd);
end;



