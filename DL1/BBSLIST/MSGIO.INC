
(*
 * msgio - message declarations and procedures for interface
 *         with pcboard 14.0
 *
 * (C) 1988 Samuel H. Smith, 10-Sep-88 (rev. 11-Sep-88)
 *
 *)

const
   maxlines = 102;      {maximum lines per message}
   maxtext = 7334;      {maximum text size per message maxlen*maxlines}
   maxblocks = 58;      {maximum number of 128 byte blocks per message}
   blksiz = 128;        {size of each message block}

   maxmbuf  = 64;       {message buffer records}
   maxixbuf = 64;       {index buffer records}
   

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
         2: (body:      array[1..blksiz] of char); {body of the message,
                                                    space fill}
   end;

   blockarray = array[1..maxblocks] of message_rec;
   rawarray   = array[1..maxtext]   of char;
   textarray  = array[1..maxlines]  of string72;
   
const
   dead_msg    = #226;           {message status codes}
   live_msg    = #225;
   endline     = #227;           {end of line character in message files}

var
   mbfile:        string65;
   mbfd:          buffered_file;
   ixfd:          buffered_file;

   mheader:       message_rec;
   basemsg:       word;
   lastmsg:       word;
   msgpos:        word;

   header:        message_rec;
   block:         blockarray;
   raw:           rawarray absolute block;
   txtblocks:     integer;

   lines:         textarray;
   linecnt:       integer;


(* --------------------------------------------------------- *)
procedure remove_trailing(var s: string);
begin
   while s[length(s)] = ' ' do
      dec(s[0]);
end;

procedure remove_leading(var s: string);
begin
   while copy(s,1,1) = ' ' do
      delete(s,1,1);
end;

procedure remove_comment(var s: string; delimiter: char);
var
   i: integer;
begin
   remove_leading(s);
   i := pos(delimiter,s);
   if i > 0 then
      s[0] := chr(i-1);
   remove_trailing(s);
end;

(* --------------------------------------------------------- *)
procedure fill_chars(var dest; source: string; size: integer);
var
   destb:   array[1..1000] of char absolute dest;
   i:       integer;
begin
   for i := 1 to size do
      if i <= length(source) then
         destb[i] := source[i]
      else
         destb[i] := ' ';
end;


(* ---------------------------------------------------------- *)
procedure allocate_number;
   {allocate the next message number}
begin
   inc(lastmsg);
   ftos(lastmsg,header.number);
   ftos(lastmsg,mheader.himsg);
   incs(mheader.msgcnt, 1);

   writeln('Message: ',lastmsg,'  To: ',header.whoto);
end;


(* ---------------------------------------------------------- *)
procedure save_text;
   {convert the text into PCBoard's block format and write it to the file}
var
   i:         integer;
   pos:       integer;

   procedure put(s: string);
   begin
      move(s[1], raw[pos+1], length(s));
      inc(pos,length(s));
   end;

begin
   {convert the lines into a block of bytes}
   pos := 0;
   for i := 1 to linecnt do
   begin
      put(lines[i]);
      put(endline);
   end;

   {pad to end of block}
   while (pos and (blksiz-1)) <> 0 do
      put(' ');

   txtblocks := pos div blksiz;
   header.blocks := txtblocks+1;

   msgpos := btell(mbfd);

   bwrite(mbfd,header);
   for i := 1 to txtblocks do
      bwrite(mbfd,block[i]);
end;


(* ---------------------------------------------------------- *)
procedure save_index;
   {enter current message into index file}
var
   ixrec:       single;
begin
   ftos(msgpos+1,ixrec);
   bseek(ixfd,lastmsg - basemsg);
   bwrite(ixfd,ixrec);
end;


(* ---------------------------------------------------------- *)
procedure write_message;
   {save the current message: header and lines}
begin
   allocate_number;
   save_text;
   save_index;
end;


(* ---------------------------------------------------------- *)
procedure open_conference;
   {open and lock the selected conference file}
var
   i: integer;
begin
   {open the index and message base files}
   bopen(ixfd,mbfile + '.NDX',maxixbuf,sizeof(single));
   if berr then
      error('Can''t open message index');

   bopen(mbfd,mbfile,maxmbuf,sizeof(message_rec));
   if berr then
      error('Can''t open message file');

   {attempt to lock the message file}
   for i := 1 to 20 do
   begin
      bseek(mbfd,0);
      bread(mbfd,mheader);

      if mheader.lockflag[1] = ' ' then
      begin
         mheader.lockflag := 'LOCKED';
         bseek(mbfd,0);
         bwrite(mbfd,mheader);
         bflush(mbfd);

         basemsg := stol(mheader.lowmsg);
         lastmsg := stol(mheader.himsg);

         bseekeof(mbfd);   {position for first append}
         exit;
      end;

      writeln('Network Delay - Message File Busy');
      delay(1000);
   end;

   writeln('Warning: Message file locked!');
end;


(* ---------------------------------------------------------- *)
procedure close_conference;
   {close and unlock the active conference}
begin
   mheader.lockflag := '      ';
   bseek(mbfd,0);
   bwrite(mbfd,mheader);
   bclose(mbfd);
   bclose(ixfd);
end;

