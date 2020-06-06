
(*
 * HSTRESET - Reset the HST modem so PCBoard won't get in trouble...
 *
 * (C) 1988 Samuel H. Smith, 22-Feb-88 (rev. 22-Feb-88)
 *
 *)

(* ------------------------------------------------------------ *)
{$v-}

uses dos,minicrt,tools,proroot,prodata;

const
   whoami   = 'HST Modem Reset Utility - Places hayes compatible modems Off-Hook';
   version  = 'Version 2.1, 03-23-92 S.H.Smith';

   reset_command = 'ATM0H1'^M;
   initial_timeout = 3;
   timeout = 3;
   max_trys = 100;
   initial_baud = 1200; {should work with all modem types}

var
   linenum:  integer;
   inbuf:    string;
   lastln:   string;
   try:      integer;

   procedure xmit(s: string);
   var
      i: integer;
   begin
      for i := 1 to length(s) do
         INTR_transmit_data(s[i]);

      INTR_flush_com;
   end;


   procedure recv;
   var
      c:   char;
   begin

      repeat
         if INTR_receive_ready then
            c := INTR_receive_data
         else
            c := #255;

         case c of
            #255: exit;

            ' '..'~':
                inbuf := inbuf + c;
            ^J:
                if length(inbuf) > 1 then
                begin
                   lastln := inbuf;
                   inbuf := '';
                end;
         end;
         write(c);
      until true=false;

   end;


(*
 * main program
 *
 *)

var
   c: char;
   port: string;
   time: real;


begin
   clrscr;
   assign(output,'');
   rewrite(output);

   writeln(whoami);
   writeln(version);

   if paramcount <> 1 then
   begin
      writeln('Usage:    hstreset PORT');
      writeln('Example:  hstreset 1    ;reset COM1');
      writeln;
      writeln('Use COMBASE and COMIRQ environment variables with PORT 1 ');
      writeln('for non-standard COM ports.');
      writeln;
      halt;
   end;

(* install interrupt handlers *)
   local := false;
   port := paramstr(1);
   com_chan := ord(port[1])-ord('0');
   INTR_init_com;
   disable_cts_check := true;
   INTR_set_baud_rate(initial_baud);

   c := '?';
   inbuf := '';
   lastln := '<timeout>';
   time := get_time-timeout+initial_timeout;
   try := 1;

   writeln('Press ESCAPE to cancel modem reset and drop to DOS...');

   repeat
      recv;

      if {(lastln = '') and} (get_time > time+timeout) then
      begin
         lastln := '<timeout>';
         writeln(lastln);
      end;

      if (lastln = '<timeout>') or
         (lastln = 'RING') or
         (lastln = 'NO CARRIER') or
         (lastln = 'NO DIAL TONE') then
      begin
         inc(try);
         if try > max_trys then
         begin
            writeln('<modem not responding> errorlevel set to 0');
            INTR_uninit_com;
            halt(0);
         end;

         INTR_lower_dtr;
         delay(200);
         INTR_raise_dtr;
         delay(200);
         xmit(reset_command);
         delay(500);

         lastln := '';
         time := get_time;
      end;

      if keypressed then
      begin
         c := readkey;
         if c = #27 then
         begin
            writeln('<user abort> - errorlevel set to 0');
            INTR_uninit_com;
            halt(0);
         end;
      end;
   until lastln = 'OK';

(* remove interrupt handlers before exit *)
   writeln('<modem reset successful> - errorlevel set to 1');
   INTR_uninit_com;
   halt(1);
end.

