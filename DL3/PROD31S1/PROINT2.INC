
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
 * PCB ProDOOR file interfaces for PCBoard files (3-1-89)
 *
 *)

procedure fill_chars( var dest; 
                      source:    anystring;
                      size:      integer);
var
   into:  array[1..1000] of char absolute dest;
   ilen:  integer;

begin
   fillchar(into,size,' ');
   ilen := length(source);
   if ilen > size then
      ilen := size;
   move(source[1], into[1], ilen);
end;


(* ----------------------------------------------------------- *)
procedure lfill_chars( var dest;
                       source:    anystring;
                       size:      integer);
   {fill_chars with leading space on source}
begin
   fill_chars(dest,' '+source,size);
end;


(* ----------------------------------------------------------- *)
procedure prepare_word_wrap(var par: string; var pos: integer; len: integer);
begin
   {need to wordwrap?  delete partial word and start it on the next line}
   if (length(par) > len) and (par[length(par)] <> ' ') then
   begin
      pos := length(par);
      while (pos > 2) and (par[pos] <> ' ') do
      begin
         dec(pos);
         disp(^H' '^H);   {delete partial word from screen}
      end;
   end
   else
      pos := length(par)+1;
   newline;
end;


(* ----------------------------------------------------------- *)
procedure save_name_list;
   (* save the filename list in the namefile *)
var
   fd:    text;
   i:     integer;

begin
   assign(fd,namefile_path);
   {$i-} rewrite(fd); {$i+}
   if ioresult <> 0 then exit;

   for i := 1 to transfer.count do
   begin
      writeln(fd,transfer.entry[i]^);
      if pro_mode = RX then
         writeln(fd,descr.entry[i]^);
   end;

   close(fd);
end;


(* ----------------------------------------------------------- *)
procedure load_name_list;
   (* load the filename list from the namefile *)
begin
   transfer.count := 0;
   openfile(namefile_path);
   if not ok then
      exit;

   while not endfile do
   begin
      inc(transfer.count);
      vgetline(transfer.entry[transfer.count]);
      if pro_mode = RX then
         vgetline(descr.entry[transfer.count]);
   end;

   closefile;
   dos_unlink(namefile_path);
end;


(* ----------------------------------------------------------- *)
procedure save_pointers(name: filenames);
   (* save current message pointers *)
var
   fd:    dos_handle;
begin
   cons_path(dos_name,sys_dir,name);
   fd := dos_create(dos_name);
   if fd <> dos_error then
   begin
      dos_write(fd,extuser,sizeof(extuser));
      dos_close(fd);
   end;
end;


(* ----------------------------------------------------------- *)
procedure load_pointers(name: filenames);
   (* load message pointers *)
var
   fd:   dos_handle;
   n:    integer;
begin
   cons_path(dos_name,sys_dir,name);
   fd := dos_open(dos_name,open_read);
   if fd <> dos_error then
   begin
      n := dos_read(fd,extuser,sizeof(extuser));
      dos_close(fd);
      dos_unlink(dos_name);
   end;
end;


(* ------------------------------------------------------------ *)
procedure print_text(s: anystring);
   {send text to the proper printer}
var
   i:       integer;
   reg:     registers;

begin
   if pcbsetup.printer_num = 0 then
      exit;

   i := 1;
   while i <= length(s) do
   begin

(******************
      {filter out all escape sequences to printer}
      if s[i] = #27 then
      begin
         inc(i);
         if s[i] = '[' then
            repeat inc(i);
            until s[i] >= 'A';
         inc(i);
      end;
*******************)

      reg.ax := ord(s[i]);
      reg.dx := pcbsetup.printer_num-1;   {0 1 or 2}
      intr($17, reg);

      {disable printing if printer errors out}
      if (reg.ah and 1) <> 0 then
      begin
         i := length(s);
         pcbsys.printer := ' 0';
         alt_p := false;
      end;

      inc(i);
   end;

end;


(* ------------------------------------------------------------ *)
procedure make_raw_log_entry(entry: anystring);
   (* make an entry in the caller log file; also log to printer *)
var
   fd:    text;
   
begin

{$IFNDEF IN_PROEDIT}
   prepare_line(entry);
   if pcbsys.printer[1] = '-' then
      print_text(entry+^M^J);

   if pcbsetup.caller_path^= '' then exit;
   assignText(fd,pcbsetup.caller_path^);
   {$i-} append(fd); {$i+}
   if ioresult <> 0 then exit;

   writeln(fd,ljust(entry,62));
   close(fd);
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure make_log_entry (entry: anystring; echo: boolean);
   (* make an entry in the caller log file; also log to printer *)
begin
   if echo {and (nomore=false)} then
   begin
      dWHITE(entry);
      newline;
   end;

{$IFNDEF IN_PROEDIT}
   make_raw_log_entry('      '+entry);
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
function download_k_allowed: word;
   (* determine number of K bytes allowed for downloading *)
var
   allowed:  longint;
   limit:    longint;
   used:     longint;

begin
{$IFDEF IN_PROEDIT}
   download_k_allowed := 0;
{$ELSE}

   used  := dtol(user.downbytes);  {bytes downloaded}

   limit := longint(pcbsys.down_limit + user.earned_k) * 1024;
            
   allowed := (limit - used) div 1024;          {remaining allowed in kbytes}

   if allowed < 0 then
      allowed := 0;
   if allowed >= $FFFF then
      allowed := $FFFF;

   download_k_allowed := allowed;
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure get_infocount(path:        filenames;
                        reclen:      longint;
                        var count:   integer);
   (* open specified infofile and return the number of entries *)
var
   fd:   dos_handle;

begin
   count := 0;

   if length(path) = 0 then
      exit;
   fd := dos_open(path,open_read);
   if fd = dos_error then
      exit;

   dos_lseek(fd,0,seek_end);
   count := dos_tell div reclen;
   dos_close(fd);
end;


(* ------------------------------------------------------------ *)
procedure get_dirn(n:         integer;
                   var name:  filenames;
                   var descr: anystring);
   (* construct and return the directory file name based on
      current conference *)
var
   fd:   dos_handle;

   rec:  record               {layout of dir.lst files}
            name:    char30;
            dir:     char30;
            descr:   char35;
            order:   byte;
         end;

begin
   name := '@@@';
   descr := '';

   if n > conf_dirs then
   begin
      descr := 'Recent uploads';
      if conf_info.conf_private_ul then
         displn('Uploads are Private ...')
      else
         name := upload_list;
   end
   else

   begin
      fd := dos_open(conf_info.conf_dirinfo,open_read);
      if fd = dos_error then
         exit;

      dos_rseek(fd,n-1,sizeof(rec),seek_start);
      n := dos_read(fd,rec,sizeof(rec));
      dos_close(fd);

      name := rec.name;    delete_trailing_spaces(name);
      descr := rec.descr;  delete_trailing_spaces(descr);
   end;
end;


(* ------------------------------------------------------------ *)
function dir_count: integer;
   (* construct and return the highest file directory number, based
      on current conference *)
var
   n: integer;
begin
   n := conf_dirs;
   if not conf_info.conf_private_ul then
      inc(n);
   dir_count := n;
end;


(* ---------------------------------------------------------------- *)
function minutes_before_event: integer;
   {determine number of minutes before the scheduled event}
var
   ontime:  integer;
   evtime:  integer;
   now:     integer;
   h,m,e:   integer;

begin

{$IFDEF IN_PROEDIT}
   minutes_before_event := 9999;
{$ELSE}

   if not pcbsetup.event_active then
   begin
      minutes_before_event := 9999;
      exit;
   end;

   val(copy(pcbsetup.event_time,1,2),h,e);
   val(copy(pcbsetup.event_time,4,2),m,e);
   evtime := h*60 + m;

   {take midnight rolover into account}
   ontime := pcbsys.time_on {minutes};
   if evtime < ontime then
      inc(evtime,1440);

   now := get_mins;
   if now < ontime then
      inc(now,1440);
   now := now + pcbsetup.event_buffer;

(***
if setdebug then
writeln('[evtime=',evtime,' now+buffer=',now,' before=',evtime-now,']');
***)

   minutes_before_event := evtime - now;
{$ENDIF}

end;


(* ----------------------------------------------------------- *)
function event_run_needed(possible: boolean): boolean;
   (* return true if there will be an event when the caller logs off 
      (or at the latest time he can logoff)
      also adjusts time to prevent passing over a non-sliding event *)
var
   needed:  boolean;
const
   news:    boolean = true;

begin

{$IFDEF IN_PROEDIT}
   needed := false;
{$ELSE}

   if not pcbsetup.event_active then
   begin
      event_run_needed := false;
      exit;
   end;

(***
writeln('[before=',minutes_before_event,' minutes_left=',minutes_left,']');
***)
   if (pcbsetup.slide_event = false) and
      ({pcbsys.sminsleft}minutes_left > minutes_before_event) then
   begin

      (* don't say this over and over when an event is pending *)
      if news then
      begin
         newline;
         par5 := minutes_before_event;
         pdispln('Time limit reduced because an event is scheduled in $5W$ minutes.');
         news := false;
      end;

      pcbsys.time_limit := pcbsys.time_limit +
                           (minutes_before_event -
                            {minutes_left}pcbsys.sminsleft);
(***
writeln('[...new minutes_left=',minutes_left,']');
***)
   end;

   if possible=event_possible then
      needed := {pcbsys.sminsleft}minutes_left >= minutes_before_event
   else  {event_now}
      needed := minutes_before_event+pcbsetup.event_buffer < 1;

(***
writeln('[event possible=',possible,' needed=',needed,']');
***)

{$ENDIF}

   event_run_needed := needed;
end;


(* ------------------------------------------------------------ *)
function time_used: integer;
   (* determine number of minutes used for this caller *)
var
   time_now:  integer;
   ontime:    integer;
   mins:      integer;

begin

{$IFDEF IN_PROEDIT}
   mins := 1;
{$ELSE}

   ontime := pcbsys.time_on;
   time_now := get_mins;

   if time_now < ontime then
      inc(time_now,1440);     {midnight rolover}

   mins := time_now - ontime;        (* calc number of minutes used *)

{$ENDIF}

   time_used := mins;
end;


(* ------------------------------------------------------------ *)
function minutes_left: integer;
   (* determine number of minutes left for this caller *)
begin

{$IFDEF IN_PROEDIT}
   minutes_left := 999;
{$ELSE}

   if (lget_time - curstart) > 60 then
      adjust_timing;

   pcbsys.sminsleft := pcbsys.time_limit
                          - time_used
                          + pcbsys.time_added    {???}
                          + pcbsys.time_credit
                       {-}+ pcbsys.prev_used;

   minutes_left := pcbsys.sminsleft;

{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure check_time_left;
   (* check to see if there is any time left *)
const
   recur: boolean=false;
begin

{$IFNDEF IN_PROEDIT}
   if recur then 
      exit; 
   recur:=true;

   if ((option = o_none) or (option = o_nosignon)) and
      (not chat_active) and (minutes_left <= 0) and (not dump_user) then
   begin
      dump_user := true;
      newline;
      make_log_entry('Time Limit Exceeded!',true);
   end;
   recur := false;
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure display_time(used: boolean);
begin

{$IFNDEF IN_PROEDIT}
(***
   displn('[Left='+itoa(minutes_left)+
           ', Used='+itoa(time_used)+
           ', Last='+itoa(user.lastused)+
           ', Cred='+itoa(pcbsys.time_credit)+
           ', Lim='+itoa(pcbsys.time_limit)+
           ', Add='+itoa(pcbsys.time_added)+']');
***)

   dYELLOW('(');
   par5 := time_used;
   if used then
      dGREEN('$5W$ used, ');
   par3 := itoa(minutes_left);
   dRED('$3$ left');
   dYELLOW(') ');

{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure display_time_left;
begin

{$IFNDEF IN_PROEDIT}
   display_time(true);
{$ENDIF}

end;


(* ------------------------------------------------------------ *)
procedure adjust_time_allowed(addseconds: longint);
var
   minutes: integer;
const
   recur: boolean=false;

begin

{$IFNDEF IN_PROEDIT}
   if recur then exit;
   recur := true;

   minutes := addseconds div 60;
   last_adjustment := minutes;
   pcbsys.time_credit := pcbsys.time_credit + minutes;

   {checking for an event adjusts for pending events}
   if (minutes > 0) and event_run_needed(event_possible) then ;

   recur := false;
{$ENDIF}

end;


