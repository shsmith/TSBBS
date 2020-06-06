
(*
 * PCB ProDOOR mail access module (3-1-89)
 *
 *  NOTICE: ALL MODIFIED VERSIONS OF THIS PROGRAM _MUST_ BE DISTRIBUTED
 *          WITH SOURCE CODE.  I STRICTLY FORBID THE USE OF ANY NON-
 *          PUBLIC INFORMATION IN MODIFICATIONS.  FOR EXAMPLE, YOU
 *          CANNOT USE CDC PROVIDED INFORMATION FOR PCBOARD 14.5
 *          COMPATIBILITY, SINCE SUCH A VERSION CANNOT BE RELEASED IN
 *          SOURCE CODE.
 *)

const
   msgmaxlen = 80;      {maximum line length in new message entry}
   msgwraplen = 72;     {word wrap length}
   maxlines = 255+2;    {maximum lines per message}

   maxtext = (maxlines+1)*(msgmaxlen+8);
                        {maximum text size per message maxlen*maxlines}

   blksiz = 128;        {size of each message block}
   maxblocks = (maxtext div blksiz)+1;
                        {maximum number of blocks per message}

   no_msg = $FFFF;      {message position indicating no valid message}

   cap_bufsize = 10240; {mail capture buffer size}
   maxinbuf = 128;      {input buffer records *128}
   maxixbuf = 128;      {index buffer records *4}
   
   maxthread = 1000;    {maximum range of thread memory}


(* layout of the message control file records for PCBoard *)

type
   message_rec = record
      case integer of

      {file header record}
         0: (himsg:    single;    {highest message on file}
             lowmsg:   single;    {low msg number in message base}
             msgcnt:   single;    {number of active messages}
             callers:  single;    {number of callers on system}
             lockflag: char6;     {LOCKED if file being updated}
             fill1:    array[1..105] of char);
                                  {reserved for future use}

      {message header record}
         1: (StatusCode:  char;     {protect, unprotect flag '*' or blank}
             Number:      single;   {message number}
             ReferTo:     single;   {reference message number}
             blocks:      byte;     {number of 128 byte text blocks}
             Date:        char8;    {mm-dd-yy}
             Time:        char5;    {hh:mm}
             WhoTo:       char25;
             ReadDate:    single;   {yymmdd numeric date of reply message}
             ReadTime:    char5;    {hh:mm of reply}
             HasReplys:   char;     {'R' is ALL message has replys}
             WhoFrom:     char25;
             Subject:     char25;
             Password:    char12;   {blank=none}
             status:      char;     {dead_msg(226) or live_msg(225)}
             echoflag:    char;     {'E' if msg to be echoed}
             filler:      char6);   {reserved}

      {message text record}
         2: (body:      array[1..128] of char); {body of the message, space fill}
   end;


   blockarray = array[1..maxblocks] of message_rec;
   rawarray   = array[1..maxtext] of char;
   textarray  = array[1..maxlines] of string[msgmaxlen];
   threadarray= array[1..maxthread] of boolean;
   cap_bufrec = array[1..cap_bufsize] of byte;
   
const
   dead_msg    = #226;           {message status codes}
   live_msg    = #225;
   endline     = #227;           {end of line character in message files}

var
   cap_buffer:   ^cap_bufrec;
   cap_count:    integer;
   
   mainfn:            filenames;
   selectedfile:      filenames;
   messagebase_file:  filenames;

   mbfd:         buffered_file;
   ixfd:         buffered_file;
   header:       message_rec;
   mheader:      message_rec;

   curmsg:       longint;
   basemsg:      longint;
   memorymsg:    longint;
   priormsg:     longint;
   newmsgs:      longint;
   yourmsgs:     longint;

   msgpos:       word;

   txtblocks:    integer;
   maxpos:       integer;
   block:        ^blockarray;
   raw:          ^rawarray absolute block;

   lines:        ^textarray;
   linecnt:      integer;

   threadseen:   ^threadarray;  {message thread memory}
   threadbase:   longint;

   privatep:     boolean;       {message private?}
   groupp:       boolean;       {message has a group password?}
   readp:        boolean;       {message has been read?}
   tomep:        boolean;       {message is to me?}
   frommep:      boolean;       {message is from me?}
   toallp:       boolean;       {message is to ALL?}
   kill_allowed: boolean;       {user allowed to kill this message}

   protokp:      boolean;       {is it okay to toggle message protection?}

   WhoTo:        char25;        {to: address after prepare_line}
   Subject:      char25;        {subject after prepare_line}

   search_key:   anystring;

   nextjoin:     string20;      {set to J nn at end of message base}
   direction:    char;          {+ or -}
   
   lastread:     ^single;       {pointer to current lastread counter}

   fromUser:     pcb_user_rec;  {user record of message sender}
   have_city:    boolean;

   non_stop:     boolean;       {currently in non-stop mode?}

   ctagline:     string72;      {currently defined tagline}


const
   lastmsg:      longint = 0;
   search_count: word = $FFFF;
   match_count:  word = 0;

   pprevcmd:     string2 = 'R';
   prevcmd:      string2 = 'R';         {previous command letter}
   substitute:   boolean = true;        {allow @...@ substitutes?}

