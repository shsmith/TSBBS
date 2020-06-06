
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
 * procomm.inc - high-level communications handlers (3-1-89)
 *
 *)


(* ------------------------------------------------------------ *)
procedure disp (msg:  string240);
   (* display a string on both local and com port *)
   (* note: ^J must not be combined with other text! *)
var
   c:    char;
   i:    integer;
   x,y:  integer;

label recur;

begin

   if linenum > 8000 then
   begin
      linenum := 2000;
      displn('^K');
   end;

(* process sysop keys at all times *)
   if keypressed then
   begin
      c := readkey;

      if (c = #0) and process_fkeys then
         process_function_keys
      else

      if (c = ^K) then
      begin
         disable_int;
         control_k;
         enable_int;
      end
      else

      if c <> carrier_lost then
      begin
         inc(pending_keys[0]);
         pending_keys[length(pending_keys)] := c;
      end;
   end;


(* if output is being captured for download, direct output to file
   with no display at all *)
   
   if message_capture then
   begin
      {$i-} write(mailfd,msg); {$i+}
      if ioresult <> 0 then
         usage('Disk Full! Writing ZIPM capture...');
      exit;
   end;

recur:
   if length(msg) = 0 then
      exit;

(* get current x,y position *)
   Inline(
     $B4/$03/               {mov ah,3}
     $30/$FF/               {xor bh,bh}
     $55/                   {push bp}
     $CD/$10/               {int $10}
     $5D/                   {pop bp}
     $30/$E4/               {xor ah,ah}
     $FE/$C2/               {inc dl}
     $88/$D0/               {mov al,dl}
     $89/$86/>X/            {mov [bp+>X],ax}
     $FE/$C6/               {inc dh}
     $88/$F0/               {mov al,dh}
     $89/$86/>Y);           {mov [bp+>Y],ax}

(* prevent text from spilling into the status area *)
   if (y > scroll_line-3) and ((length(msg)+x) > 80) and (length(msg) > 1) then
   begin
      {output the portion of the line that is sure to fit}
      i := 80 - x;
      disp(copy(msg,1,i));

      {display critical character at line boundry}
      dispc(msg[i+1]);

      {tail recursion; output the rest of the line}
      delete(msg,1,i+1);
      goto recur;
   end;


(* transmit to user *)
   if not LOCAL then
      transmit_data(msg);

(* process ALT-F and ALT-P flags *)
   if setdebug then
   begin
      if (GetEnv('CAP')='ON') and (length(msg) > 2) then
         writeln(dbfd,'@@',msg)
      else
         write(dbfd,msg);
   end;

   if alt_p then
      print_text(msg);

   
(* provide local echo *)
   if (pcbsys.display[1] = '-') and bios_echo then
   begin
      (* recover cursor if it slipped into the status line *)
      if (y > scroll_line) and status_active then
      begin
         gotoxy(x,scroll_line);
         {$i-} write(^J); {$i+}
      end;

      (* preserve non-scrolling status area by scrolling with CON (minicrt) *)
      if msg[1] = ^J then
         {$i-} write(^J) {$i+}
      else

      begin
         (* beep only when alarm toggle is active *)
         if (msg[1] = ^G) and (pcbsys.alarm[1] = ' ') then
            delete(msg,1,1);

         (* record prompt strings *)
         if (msg <> '') then
         begin
            if msg[1] = ^M then
               current_line := ''
            else
               current_line := current_line + msg;
(***
            if length(current_line)+length(msg) < sizeof(current_line) then
            begin
               move(msg[1],current_line[length(current_line)+1],length(msg));
               current_line[0] := chr(length(current_line)+length(msg));
            end;
***)
         end;

         (* display everything else *)
         if x+length(msg) > 79 then
            {$i-} write(stdout,msg) {$i+}
         else
            StdWrite(msg[1],length(msg));

         {dos_write(TextRec(stdout).Handle,msg[1],length(msg));}
      end;
   end;
end;


procedure dispc( c: char );
   {optimal way to display a single charater}
begin
   disp(c);
end;


(* ------------------------------------------------------------ *)
procedure newline;
   (* display a CR/LF on both local and com port *)
begin
   verify_txque_space;
   check_carrier_loss;

   disp{c}(^M);
   disp{c}(^J);

   if not message_capture then
      inc(linenum);
end;


(* ------------------------------------------------------------ *)
procedure displn(msg:  string240);
   (* display a string with CR/LF on both local and com port *)
begin
   disp(msg);
   newline;
end;


(* ------------------------------------------------------------ *)
procedure pdisp (msg:  string240);
begin
   prepare_line(msg);
   disp(msg);
end;

procedure pdispln(msg:  string240);
begin
   pdisp(msg);
   newline;
end;


(* ------------------------------------------------------------ *)
procedure beep;
begin
   dispc(^G);
end;


(* ------------------------------------------------------------ *)
procedure spaces(n: byte);
var
   buf:  string;
begin
   fillchar(buf[1],n,' ');
   buf[0] := chr(n);
   disp(buf);
end;

procedure space;
   (* display a space *)
begin
   spaces(1);
end;


(* ------------------------------------------------------------------- *)
procedure erase_prompt (len: integer);
   {remove a prompt from display}
var
   plen:  integer;
begin
   if alt_p then
      print_text(^J);

   plen := length(current_line);

   if GRAPHICS then
      disp(^M#27'[K')    {ansi clear-to-end-of-line}
   else

   begin
      dispc(^M);
      spaces(len+plen);
      dispc(^M);
   end;

   default_color;
end;


(* ------------------------------------------------------------------- *)
procedure repeat_prompt;
begin
   pending_keys := '';
   dispc(^M);
   disp(prev_prompt);
   linenum := 1;
end;


(* ------------------------------------------------------------ *)
procedure get_cmdline_raw(prelength: integer);
   (* read next command line, erase afterwards if prelength > 0 *)
var
   i: integer;

begin
   fillchar(cmdline,sizeof(cmdline),0);
   input(cmdline,sizeof(cmdline)-1);
   stoupper(cmdline);

   if prelength > 0 then
      erase_prompt(length(cmdline))
   else
      newline;

   {process stacked 'ns' at end of command line}
   i := pos(' NS',cmdline);
   if i = 0 then
      i := pos(';NS',cmdline);

   if (i > 0) and (i = length(cmdline)-2) then
   begin
      cmdline[0] := chr(i-1);
      linenum := -30000;    {go 30000 lines before stopping again}
   end;
end;


(* ------------------------------------------------------------ *)
procedure no_hotkeys;
begin
   hotkeys_active := false; {nohot_list := allkeys;}
end;


(* ------------------------------------------------------------ *)
procedure get_cmdline;
begin
   hotkeys_active := false;
   get_cmdline_raw(0);
end;


(* ------------------------------------------------------------ *)
procedure get_hcmdline;
begin
   hotkeys_active := true;
   get_cmdline_raw(0);
end;


(* ------------------------------------------------------------ *)
procedure prompt_def(prompt: string80; default: string80);
   (* display a prompt with a default message *)
begin
   dYELLOW(prompt);
   space;
   dGREEN(default);
end;


(* ------------------------------------------------------------ *)
procedure get_def(prompt: string80; default: string80);
   (* display a prompt with a default message, get command line *)
var
   tries: integer;

begin

(*******************
{writeln('[get_def cmdline=',cmdline,' pr=',prompt,' def=',default,']');}
   tries := 0;

   repeat
      prompt_def(prompt,default);
      get_cmdline_raw(0);
      {get_cmdline;}

      inc(tries);
      if tries > 10 then
         dump_user := true;

   until (linenum < 2000) or dump_user;
***************)

   prompt_def(prompt,default);
   get_cmdline_raw(0);

{writeln('[get_def exit cmdline=',cmdline,']');}

end;


(* ------------------------------------------------------------ *)
procedure get_defn(prompt: string80; default: string80);
   (* get input with default prompt, "enter=none" automatically appended *)
begin
   no_hotkeys;
   get_def(prompt,default+enter_eq_none);
end;


(* ------------------------------------------------------------ *)
procedure get_defen(prompt: string80);
   (* get input with default prompt, "enter=none" default *)
begin
   no_hotkeys;
   get_def(prompt,enter_eq_none);
end;


(* ------------------------------------------------------------ *)
procedure get_defnh(prompt: string80; default: string80);
   (* get hotkey input with default prompt, "enter=none" automatically appended *)
begin
   hotkeys_active := true;
   get_def(prompt,default+enter_eq_none);
end;


(* ------------------------------------------------------------ *)
procedure get_defbl(prompt: string80);
begin
   no_hotkeys;
   delete_trailing_spaces(cmdline);
   prompt_def(prompt,'(Blank)=abort? ');
   line_input(cmdline,sizeof(cmdline),true,false);
   stoupper(cmdline);
   newline;
end;


(* ------------------------------------------------------------ *)
procedure get_int(prompt: string80; var n: byte);
var
   defalt:  string80;

begin

{writeln('[get_int cmdline=',cmdline,' pr=',prompt,' n=',n,']');}

   if length(cmdline) = 0 then
   begin
      if n = 0 then
         defalt := enter_eq_none
      else
      begin
         str(n,defalt);
         defalt := '(0)=none, (Enter)='''+defalt+'''? ';
      end;

      hotkeys_active := true;
      {nohot_list := '';}
      {no_hotkeys;}
      get_def(prompt,defalt);
   end;

   get_nextpar;
   if (par <> '') and (par[1] >= '0') and (par[1] <= '9') then
      n := parn;

{writeln('[get_int exit par=',par,' n=',n,']');}

end;


(* ------------------------------------------------------------ *)
procedure get_defyn(prompt: string80; default: boolean);
begin
   repeat
      par := enter_eq_yesno[default];
      hotkeys_active := true;
      {nohot_list := '';}
      get_def(prompt,par);
      if length(cmdline) = 0 then
         cmdline := par[9];
      stoupper(cmdline);
   until (dump_user) or (cmdline[1] = 'Y') or (cmdline[1] = 'N') or (cmdline[1] = 'Q');
   get_nextpar;
end;


(* ------------------------------------------------------------ *)
function key_ready: boolean;
   (* check to see if a key is ready (local or remote) *)
var
   ready:   boolean;
begin
   ready := keypressed or (length(pending_keys) > 0);
   if not local then
      ready := ready or receive_ready or not carrier_present; {ss}
   key_ready := ready;
end;


(* ------------------------------------------------------------ *)
procedure keyboard_time_expired;
begin
   newline;
   make_log_entry('Keyboard Time Expired!',true);
   dump_user := true;
end;


(* ------------------------------------------------------------ *)
function get_key: char;
   (* get key from local or remote; waits if no key ready *)
   (* return carrier_lost if carrier lost.  returns #255 sometimes
    * (after processing function keys) *)
var
   c:      char;
   start:  longint;
   rwait:  longint;
   wait:   integer;
   pwait:  integer;
   maxwait:integer;
   pfun:   char;

label
   gotkey;

begin
   pfun := curfun;

   {grab pending keys, if any}
   if length(pending_keys) > 0 then
   begin
      c := pending_keys[1];
      delete(pending_keys,1,1);
      goto gotkey;
   end;

   {read input from a file if alt-i in effect}
   if alt_i then
   begin

      if eof(alti_fd) then
      begin
         close(alti_fd);    {close alt-i file at eof}
         alt_i := false;
      end
      else

      begin
         read(alti_fd,c);   {get next char from alt-i file}
         key_source := sysop_key;
         goto gotkey;
      end;
   end;

   flush_com;
   XOFF_char := #255;     {allow xoff character as valid input}


   (* wait for a key to show up *)
   start := lget_time;
   pwait := 0;
   maxwait := pcbsetup.timeout_minutes * 60;

   repeat

      (* dump the user if no time left *)
      check_time_left;
      if dump_user then
      begin
         c := carrier_lost;
         goto gotkey;
      end;

      (* check local keys *)
      if keypressed then
      begin
         key_source := sysop_key;
         c := readkey;
         if (c = #0) and process_fkeys then
         begin
            process_function_keys;
            c := #255;
         end;

         if c = carrier_lost then
            c := #255;
         goto gotkey;
      end;

      if linenum >= 2000 then
      begin
         c := ^K;
         goto gotkey;
      end;

      if not local then
      begin
         key_source := user_key;
         if not carrier_present then
         begin
            check_carrier_loss;
            if not carrier_present then
            begin
               c := carrier_lost;
               goto gotkey;
            end;
         end;

         (* check remote keys *)
         if receive_ready then
         begin
            c := receive_data;
            if c <> carrier_lost then
            begin
               if not bios_echo then
               begin
                  if c >= ' ' then
                     {$i-} write(stdout,^H' '^H) {$i+}  {erase pcbtrap's echo}
                  else
                  if c = ^H then
                     {$i-} write(stdout,' '); {$i+}
               end;

               goto gotkey;
            end;
         end;
      end;


      (* check timeout *)
      (* how long have we been waiting?, reset on midnight rollover *)
      rwait := lget_time - start;
      if (rwait < 0) or (rwait > 9999) then
      begin
         wait := 0;
         start := lget_time;
      end
      else
         wait := rwait;


      (* give up extra time (doubledos awareness) *)
      if wait = pwait then
         give_up_time
      else


      (* dump the user if keyboard time is expired *)
      if (maxwait > 0) and (wait >= maxwait) then
      begin
         keyboard_time_expired;
         c := carrier_lost;
         goto gotkey;
      end
      else

      (* decide what to do based on how low we have been waiting *)
      case wait mod 60 of
         2,30,55,58:
         begin
            update_status_display(normal_format);

            (* prevent all but status display update while in sysop-chat mode *)
            if wait >= 55 then
               if chat_active then
                  start := lget_time
               else
                  set_function(fun_idle);

            (* beep a reminder 3 times a minute after the first minute *)
            if (maxwait > 0) and ((maxwait-wait) < 90) then
               beep;
         end;
      end;

      pwait := wait;

   until true=false;


(* a key has been decoded - return to previous function code and exit *)
gotkey:
   set_function(pfun);
   get_key := c;
end;


(* ------------------------------------------------------------ *)
function time_key(ms: integer): char;
   (* get an input key; return #255 if wait time expires first *)
var
   finish:  longint;
   start:   longint;
   now:     longint;

begin
   start := lget_ms;
   finish := start + longint(ms);

   repeat
      if key_ready then
      begin
         time_key := get_key;
         exit;
      end;

      give_up_time;  {?}
      now := lget_ms;
   until (now > finish) or    {time elapsed}
         (now < start);       {midnight rolover!}

   (* no key available *)
   time_key := #255;
end;


(* ------------------------------------------------------------ *)
procedure drop_carrier;
begin
   flush_com;
   if (not local) and (pcbsys.connectbps <> pcbsys.openbps) then
      delay(5000)
   else
      delay(2000);
   lower_dtr;
end;


(* ------------------------------------------------------------ *)
procedure force_offhook;
   (* forces modem off-hook; used when carrier is lost
      to prevent more callers before PCBoard gets around
      to resetting the modem *)
var
   try:     integer;
   c:       char;
   time:    longint;
const
   maxsecs = 1;

   procedure recv;
   begin
      flush_com;
      time := lget_time;
      par := '';
      cmdline := '';

      while (cmdline = '') and                     {no input yet}
            (lget_time < time+maxsecs) and         {timeout}
            (lget_time >= time) do                 {midnight}
      begin
         if receive_ready then
         begin
            c := receive_data;
            case c of
            ' '..'~':
                   par := par + c;
            ^J:
                   if length(par) > 1 then
                   begin
                      cmdline := par;
                      par := '';
                   end;
            end;
         end;
      end;
   end;

begin
   if (com_chan < 0) or local then
      exit;

   write('Going Off-Hook ...');
   try := 0;
   raise_dtr;

   repeat
      inc(try);

      if receive_ready then
         recv;

      if carrier_present then
      begin
         lower_dtr;
         delay(500);
         raise_dtr;
         delay(200);
      end;

      transmit_data(^M);
      repeat
         recv;
      until cmdline = '';

      transmit_data(pcbsetup.modem_offhook^+^M);

      repeat
         recv;
      until copy(cmdline,1,1) <> 'A';
      write(cmdline,' ');

   until (cmdline = 'OK') or (try > 5);

   writeln;
end;



(* ------------------------------------------------------------ *)
procedure check_carrier_loss;
   (* check for carrier loss and place modem off-hook if needed *)
const
   recur: boolean=false;
begin

{$IFNDEF IN_PROEDIT}
   if recur then
      exit;
   recur:=true;

   (* dump the user if carrier lost *)
   if (not LOCAL) and (not carrier_present) then
   begin

      if (not dump_user) and (protocol <> logging_off) then
      begin

{if setdebug then 
writeln('[possible carrier loss]');}

         delay(2000);                 {allow possible recovery after spurious}

         if not carrier_present then  {carrier loss; allow modem to stabilize}
         begin

{if setdebug then
writeln('[carrier loss verified]');}

            if (option = o_none) or
               (option = o_nosignon) then  {if not logging a transfer}
            begin
               newline;
               make_log_entry('Carrier Lost ...',true);
               {force_offhook;}
            end;

            dump_user := true;
         end;
      end;
   end;

   recur := false;
{$ENDIF}

end;

(* ------------------------------------------------------------ *)
procedure line_input(var line:  string;
                     maxlen:    integer;
                     echo:      boolean;
                     autocr:    boolean);
   (* provide a string input with editing.  enforces specified input length.
      leaves cursor at end of input when ENTER is keyed.  returns without c/r
      with full buffer if autocr is true. Echos dots if 'echo' param is false *)
var
   c:     char;
   hot:   boolean;
   secs:  integer;


   procedure add_key;
   begin
      high_ascii_filter(c);
      if c = #0 then exit;

      if length(line) < maxlen then
      begin
         if (wherex > 79) then
            newline;

         inc(line[0]);
         line[length(line)] := c;

         if not echo then 
            c := '.';
         dispc(c);

         if autocr then
         begin
            if (length(line) = maxlen) then
               c := ^M;    {automatic CR}
         end
(***********
         else

         if hot and (pos(upcase(c),'0123456789;'+nohot_list) = 0) then
            c := ^M;
************)
      end
      else
         disp(^G^X^H' '^H);
   end;

begin
   default_color;

{$IFDEF IN_PROKIT}
   hot := false;
{$ELSE}
   hot := echo and getflag(user.flags,flag_hotkeys) and hotkeys_active;
{$ENDIF}

   prev_prompt := current_line;

   if linenum > 1000 then
      repeat_prompt;

   linenum := 1;
   disp(line);
   secs := pcbsetup.timeout_minutes*60;
   if secs = 0 then secs := maxint;

   check_chat_request;

   repeat
      check_disconnect_warning;

      if linenum >= 2000 then
      begin
         repeat_prompt;
         disp(line);
      end;

      if hot then
      begin
         disp('°'^H);
         if line = '' then
            c := get_key
         else
            c := time_key(1000);
         disp(' '^H);

         if (line <> '') and (c = #255) then
            c := ^M;

         dec(secs,2);
         if secs <= 0 then
         begin
            keyboard_time_expired;
            c := carrier_lost;
         end
         else
         if secs < 30 then
            beep;
      end
      else
         c := get_key;

      case c of
         ^M,^J,
         #255:   ;   {ignore after sysop function keys}
   
         #27:  if pcbsetup.allow_esc_codes and autocr then
                  add_key
               else
               while length(line) > 0 do
               begin
                  dec(line[0]);
                  disp(^H' '^H);
               end;
   
         ^I:   repeat
                  c := ' ';
                  add_key;
               until (length(line) = maxlen) or ((length(line) mod 4) = 0);
               
         ^H,
         #127: if length(line) > 0 then
               begin
                  dec(line[0]);
                  disp(^H' '^H);
               end;
   
         ^K:   control_k;
   
{$IFNDEF IN_PROKIT}
         ^E:   begin
                  newline;
                  _DREG_(disp);
                  linenum := 2000;
               end;
{$ENDIF}

         carrier_lost:
               begin
                  check_carrier_loss;
                  line := carrier_lost;
                  exit;
               end;
   
         ' '..#254:
               begin
                  if c = ';' then
                     hot := false;
                  add_key;
               end;
   
         else            {echo ^X with invalid inputs; might stop
                         an external protocol driver that is stuck}
               disp(^X^X^X^H^H^H'   '^H^H^H);
      end;

   until (c = ^M) or dump_user;

   current_line := prev_prompt + line;
   {?} prev_prompt := '';
end;


(* ------------------------------------------------------------ *)
procedure input(var line:  string;
                maxlen:    integer);
   (* provide a string input with editing.  always echos *)
begin
   line := '';
   line_input(line,maxlen,true,false);
end;


(* ------------------------------------------------------------ *)
procedure force_new_prompt;
begin
   pending_keys[0] := #0;
   linenum := 2000;
end;


(* ------------------------------------------------------------ *)
procedure get_chars(prompt: string;
                    var dest;
                    size: integer;
                    echo: boolean);
var
   i:    integer;
   src:  array[1..200] of char absolute dest;

begin
   cmdline[0] := chr(size);
   for i := 1 to size do
      cmdline[i] := src[i];
   delete_trailing_spaces(cmdline);

   i := 0;
   repeat
      inc(i);
      if i >= 10 then
         dump_user := true;
      if dump_user then exit;

      disp_margin(length(prompt)+1,size);
      dYELLOW(prompt);
      disp('? ');
      line_input(cmdline,size,echo,false);
      newline;
   until (cmdline <> '') or (not echo);

   stoupper(cmdline);
   for i := 1 to length(cmdline) do
      if cmdline[i] = ';' then
         cmdline[i] := ' ';

   remove_variables(cmdline);

   if (@dest = @user.passwd) then {hack to force password to 1 word}
   begin
      get_nextpar;
      cmdline := par;
   end;

   fill_chars(dest,cmdline,size);
end;

