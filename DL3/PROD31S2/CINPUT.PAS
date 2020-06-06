
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

{$i prodef.inc}
{$D+}    {Global debug information}
{$L+}    {Local debug information}

unit CInput;

interface

   Uses
      Dos, MiniCrt, Mdosio, Tools;

   var
      linenum:       integer;
      pending_keys:  string;
      cmdline:       string;
      par:           string;
      ontime:        integer;
      tleft:         integer;

   const
      tlimit:  integer = 10;  {default time limit}
      com_chan: integer = 0;   {default to local, monitor carrier if 1 or 2}

      allow_flagging = false;
      graphics = false;
      red = '';
      green = '';
      yellow = '';
      blue = '';
      magenta = '';
      cyan = '';
      white = '';
      gray = '';
      fun_arcview = 'V';
      fun_textview = 'T';
      fun_xtract = 'X';
      enter_eq = '(Enter)=';
      option = '';
      expert = true;
      dump_user: boolean = false;

   type
      user_rec = record
           pagelen: integer;
      end;

   const
      user: user_rec = (pagelen:22);
      o_logoff = 'x';
      o_offok = 'x';
      o_offerr = 'x';

   const
      queue_size       =  300;   {fixed size of all queues}
      queue_high_water =  255;   {maximum queue.count before blocking}
      queue_low_water  =  100;   {unblock queue at this point}

   type
      queue_rec = record
         next_in:  integer;
         next_out: integer;
         count:    integer;
         data:     array[1..queue_size] of char;
      end;

   {$i intrcomm.int}

   procedure opencom(port: integer);
   procedure closecom;
   function local: boolean;

   procedure disp(msg:  string);
   procedure newline;
   procedure displn(msg:  string);
   procedure space;
   procedure spaces(n: integer);
   procedure input(var line:  string; maxlen:    integer);
   procedure prompt_def(what,options: string);
   procedure get_def(what,options: string);
   procedure get_cmdline_raw(len: integer);

   procedure dRED(m: string);
   procedure dGREEN(m: string);
   procedure dYELLOW(m: string);
   procedure dBLUE(m: string);
   procedure dMAGENTA(m: string);
   procedure dCYAN(m: string);
   procedure dWHITE(m: string);
   procedure dGRAY(m: string);
   procedure default_color;

   procedure get_cmdline;
   function scan_nextpar(var cmdline: string): string;
   procedure get_nextpar;

   function verify_level(fun: char): boolean;
   procedure set_function(fun: char);
   procedure erase_prompt(len: integer);
   procedure check_time_left;
   procedure display_time(left: boolean);
   procedure flag_files;
   procedure make_log_entry(s:string; f:boolean);
   function nomore: boolean;


(* ------------------------------------------------------------ *)
implementation

   procedure flush_com;
   begin
      INTR_flush_com;
   end;

   {$i intrcomm.inc}

   function local: boolean;
   begin
      local := (com_chan = 0);
   end;

   procedure opencom(port: integer);
   begin
      com_chan := port;
      if (com_chan = 1) or (com_chan = 2) then
         INTR_init_com(com_chan-1);
   end;

   procedure closecom;
   begin
      if not local then
         INTR_uninit_com;
   end;

   procedure dRED(m: string);    begin disp(RED+m); end;
   procedure dGREEN(m: string);  begin disp(GREEN+m); end;
   procedure dYELLOW(m: string); begin disp(YELLOW+m); end;
   procedure dBLUE(m: string);   begin disp(BLUE+m); end;
   procedure dMAGENTA(m: string);begin disp(MAGENTA+m); end;
   procedure dCYAN(m: string);   begin disp(CYAN+m); end;
   procedure dWHITE(m: string);  begin disp(WHITE+m); end;
   procedure dGRAY(m: string);   begin disp(GRAY+m); end;
   procedure default_color;      begin disp(GRAY); end;


   (* ------------------------------------------------------------ *)
   procedure get_cmdline;
      (* read next command line *)
   var
      i: integer;

   begin
      fillchar(cmdline,sizeof(cmdline),0);
      input(cmdline,sizeof(cmdline)-1);
      stoupper(cmdline);
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
   function scan_nextpar(var cmdline: string): string;
      (* get the next space or ';' delimited part of a command line
         and return it (removing the string from the command line) *)
   var
      i:      integer;
      par:    string;

   begin
      fillchar(par,sizeof(par),0);
      while copy(cmdline,1,1) = ' ' do   {remove leading spaces}
         delete(cmdline,1,1);

      (* find the end of the next word *)
      i := 1;
      while (i <= length(cmdline)) and (cmdline[i] <> ' ') and
            (cmdline[i] <> ';') and (cmdline[i] <> ',') do
         inc(i);

      (* copy the word to the next param and delete it from the command line *)
      par := copy(cmdline,1,i-1);
      delete(cmdline,1,i);

      scan_nextpar := par;
   end;


   (* ------------------------------------------------------------ *)
   procedure get_nextpar;
      (* get the next space or ';' delimited part of the command line
         and move it to 'par' *)
   begin
      fillchar(par,sizeof(par),0);
      par := scan_nextpar(cmdline);
   end;


   procedure check_carrier;
   begin
      if ((port[port_base+MSR] and MSR_RLSD)=0) and (not dump_user) then
      begin
         dump_user := true;
         displn(^M^J'Carrier lost!'^M^J);
      end;
   end;


   (* ------------------------------------------------------------ *)
   procedure disp(msg:  string);
   begin
      write(msg);
      if not local then
      begin
         INTR_transmit_data(msg);
         check_carrier;
      end;
   end;

   (* ------------------------------------------------------------ *)
   procedure newline;
   var
      c: char;

   begin
{WRITE('`1');}
      verify_txque_space;
{WRITE('`2');}
      disp(^M^J);
      inc(linenum);

      if keypressed then
      begin
         c := readkey;
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
   end;

   procedure displn(msg:  string);
   begin
      disp(msg);
      newline;
   end;

   procedure dispc(c: char);
   begin
      disp(c);
   end;

   procedure space;
   begin
      dispc(' ');
   end;

   (* ------------------------------------------------------------ *)
   procedure spaces(n: integer);
   begin
      while n > 0 do
      begin
         space;
         dec(n);
      end;
   end;


   (* ------------------------------------------------------------ *)
   procedure input(var line:  string;
                   maxlen:    integer);
   var
      c:     char;

   begin
      linenum := 1;
      line := '';

      repeat
         c := #0;

         while (c = #0) and (not dump_user) do
         begin
            check_time_left;

            if length(pending_keys) > 0 then
            begin
               c := pending_keys[1];
               delete(pending_keys,1,1);
            end;

            if keypressed then
               c := readkey;

            if (not local) then
            begin
               check_carrier;
               if INTR_receive_ready then
                  c := INTR_receive_data;
            end;

            if c = #0 then
               give_up_time;
         end;

         if dump_user then
         begin
            line := carrier_lost;
            exit;
         end;

         case c of
            ' '..#126:
               if maxlen = 0 then
               begin
                  line := c;
                  dispc(c);
                  c := ^M;    {automatic CR}
               end
               else

               if length(line) < maxlen then
               begin
                  if (wherex > 78) then
                     newline;

                  line := line + c;
                  dispc(c);
               end;

            ^H,#127:
               if length(line) > 0 then
               begin
                  dec(line[0]);
                  disp(^H' '^H);
               end;

            ^M:   ;

            ^B:   displn(wtoa(ofs(c))+'/'+ltoa(memavail));

            ^C:   dump_user := true;
         end;

      until (c = ^M) or dump_user;

   end;


   (* ------------------------------------------------------------ *)
   procedure erase_prompt(len: integer);
      {remove a prompt from display}
   begin
      dispc(^M);
      spaces(len);
      dispc(^M);
      default_color;
   end;

   (* ------------------------------------------------------------ *)
   procedure get_cmdline_raw(len: integer);
   begin
      input(cmdline,len);
      stoupper(cmdline);
      erase_prompt(len+length(cmdline));
   end;

   procedure prompt_def(what,options: string);
   begin
      disp(what+' '+options);
   end;

   procedure get_def(what,options: string);
   begin
      prompt_def(what,options);
      input(cmdline,sizeof(cmdline)-1);
      stoupper(cmdline);
      newline;
   end;

   (* ------------------------------------------------------------ *)
   procedure check_time_left;
   var
      time: integer;
   begin
      time := get_mins;
      tleft := tlimit+ontime-time;

      if tleft <= 0 then
      begin
         displn(^M^J'Time limit exceeded!'^M^J);
         dump_user := true;
      end;
   end;

   procedure display_time;
   begin
      check_time_left;
      disp('('+itoa(tleft)+' left) ');
   end;


   (* ------------------------------------------------------------------- *)
   function nomore: boolean;
      {check for more output to user; returns true if user doesn't want more}
   begin
      check_time_left;
      if dump_user or (linenum >= 2000) then
      begin
         nomore := true;
         exit;
      end;

      nomore := false;
      if linenum < user.pagelen then
         exit;

      {preserve command-line context since the following code "pops up" over
       what ever is running in the foreground}

      display_time(false);
      prompt_def('More:','(Enter) or (Y)es, (N)o, (NS)non-stop? ');
      get_cmdline_raw(56);
      linenum := 1;

      get_nextpar;
      if (par[1] = 'N') or dump_user then
      begin
         if par[2] = 'S' then
            linenum := -30000     {go 30000 lines before stopping again}
         else
         begin
            nomore := true;
            linenum := 2000;   {flag that nomore is in effect}
         end;
      end;
   end;


   (* ------------------------------------------------------------ *)
   procedure make_log_entry(s:string; f:boolean);
   begin
      if f then displn(s);
   end;

   function verify_level(fun: char): boolean;
   begin
      verify_level := true;
   end;

   procedure set_function(fun: char);
   begin
   end;

   procedure flag_files;
   begin
   end;


begin
   fillchar(rxque,sizeof(rxque),0);
   fillchar(txque,sizeof(txque),0);
   ontime := get_mins;
   pending_keys := '';
end.

