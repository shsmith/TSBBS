(*
 * cndump - dump cnames file
 * s.h.smith, 22-sep-93
 *
 *)

uses mdosio,tools;

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
         2: (body:      array[1..128] of char); {body of the message,
                                                    space fill}
   end;

const
   max_conf_num = 1000;

type
   conf_stat_rec = record
      himsg:   longint;
      postcnt:  longint;
      netcnt:   longint;
   end;
   stat_array = array[0..max_conf_num] of conf_stat_rec;

const
   confid_size = 13;
   lines_per_conf = 33;
   confid_line = 1;
   confpath_line = 10;
   netid_line = 27;
   seclev_line = 23;

var
   fd:      text;
   idfd:    text;
   confid:  string;
   confpath:string;
   netid:   string;
   pnetid:  string;
   cnum:    integer;
   i,j:     integer;
   line:    string;
   seclev:  string;
   hdr:     message_rec;
   stat:    stat_array;

   procedure load_stat;
   var
      fd:   text;
      cn:   integer;
      hi,post,net:   longint;

   begin
      fillchar(stat,sizeof(stat),0);
      assign(fd,'CNINFO.DAT');
      {$i-} reset(fd); {$i+}
      if ioresult <> 0 then
         exit;
      while not eof(fd) do
      begin
         readln(fd,cn,hi,post,net);
         stat[cn].himsg := hi;
         stat[cn].postcnt := post;
         stat[cn].netcnt := net;
      end;
      close(fd);
   end;

   procedure save_stat;
   var
      fd:   text;
      i:    integer;
   begin
      assign(fd,'CNINFO.DAT');
      rewrite(fd);
      for i := 0 to max_conf_num do
         {if stat[i].himsg <> 0 then}
            writeln(fd,i,' ',stat[i].himsg,' ',
                             stat[i].postcnt,' ',
                             stat[i].netcnt);
      close(fd);
   end;

   procedure display_conf_info;
   var
      fd:   dos_handle;
      n:    integer;
      num:  longint;
      t:    longint;
   begin
      for n := 1 to length(confpath) do
         if confpath[n] = ' ' then
            confpath[n] := '\';
      fd := dos_open(confpath,open_read);
      if fd = dos_error then
      begin
         writeln(' ERROR OPENING ',confpath);
         exit;
      end;

      n := dos_read(fd,hdr,sizeof(hdr));
      dos_close(fd);

      t := stol(hdr.himsg);
      if stat[cnum].himsg = 0 then
         stat[cnum].himsg := t;

      num := t-stat[cnum].himsg;
      if paramstr(1) = 'NET' then
         inc(stat[cnum].netcnt,num)
      else
      if paramstr(1) <> 'PACK' then
         inc(stat[cnum].postcnt,num);
      stat[cnum].himsg := t;

      writeln(stat[cnum].himsg:10,
              stoa(hdr.msgcnt):10,
              stat[cnum].postcnt:10,
              stat[cnum].netcnt:10);
   end;

begin
   load_stat;
   assign(fd,'CNAMES');
   reset(fd);
   assign(idfd,'CNAMES.ID');
   reset(idfd);
   pnetid := '';
   cnum := 0;

   while not eof(fd) do
   begin
      for i := 1 to lines_per_conf do
      begin
         readln(fd,line);

         for j := 1 to length(line) do
            if line[j] = '\' then
               line[j] := ' ';

         case i of
            confid_line:   confid := line;
            confpath_line: confpath := line;
            netid_line:    netid := line;
            seclev_line:   seclev := line;
         end;
      end;

      readln(idfd,netid);

      if (confid <> '') and (confid <> 'SPARE') then
      begin
         if netid <> pnetid then
         begin
            if netid <> '' then
            begin
               writeln;
               writeln(netid,':');
            end;
            pnetid := netid;
         end;

         write(cnum:4);
         if seclev = '0' then
            write(' ')
         else
            write('*');
         write(confid,'':confid_size-length(confid));
         display_conf_info;

      end;

      inc(cnum);
   end;
   writeln;
   close(fd);
   close(idfd);

   save_stat;
end.

