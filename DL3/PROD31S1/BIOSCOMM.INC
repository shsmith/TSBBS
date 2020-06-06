
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
 * PCB ProDOOR -  bios-based communication library (3-1-89)
 *
 *)

{$S-}
{$R-}

procedure BIOS_poll_receive;
   (* see if any receive data is ready on the active com port *)
begin
   
   reg.ax := $0300;   (* get port status *)
   reg.dx := com_current_chan;
   intr($14,reg);

   (* check data ready *)
   if (reg.ax and $0100) <> 0 then
   begin
      reg.ax := $0200;                  (* receive one character *)
      reg.dx := com_current_chan;
      intr($14,reg);

      if rxque.count < queue_size then
      begin
         inc(rxque.count);

         rxque.data[rxque.next_in] := chr(lo(reg.ax));
         if rxque.next_in < queue_size then
            inc(rxque.next_in)
         else
            rxque.next_in := 1;
      end;
   end;
end;


function BIOS_carrier_present:  boolean;
   (* check for carrier loss on the active com channel *)
begin
   BIOS_poll_receive;

   reg.ax := $0300;   (* get port status *)
   reg.dx := com_current_chan;
   intr($14,reg);
   (* check received-line-signal-detector *)
   BIOS_carrier_present := (reg.ax and $0080) <> 0;
end;


function BIOS_receive_ready: boolean;
   (* see if any receive data is ready on the active com port *)
begin
   BIOS_poll_receive;
   BIOS_receive_ready := rxque.count <> 0;
end;


function BIOS_receive_data:  char;
   (* wait for and return 1 character from the active com port.
      returns carrier_lost if carrier is not present *)
var
   c: char;
begin
   repeat 
      ;
   until (BIOS_receive_ready) or (not BIOS_carrier_present);

   if (rxque.count <> 0) then
   begin
      c := rxque.data[rxque.next_out];
      if rxque.next_out < queue_size then
         inc(rxque.next_out)
      else
         rxque.next_out := 1;
      dec(rxque.count);
   end
   else
      c := carrier_lost;

   BIOS_receive_data := c;
end;


procedure BIOS_transmit_data(s:    longstring);
   (* transmits a string of characters to the specified com port *)
var
   i,j:  integer;
   esc:  integer;

begin
   esc := 0;

   for i := 1 to length(s) do
   begin
      reg.ax := $0100 + ord(s[i]);   (* send one character *)
      reg.dx := com_current_chan;
      intr($14,reg);

      if not bios_echo then   {detect ansi codes and cleanup the mess}
      begin                   {left behind by pcbtrap}
         if s[i] = #27 then
            esc := 1
         else

         if esc > 0 then
         begin
            inc(esc);

            case s[i] of
            'a'..'z','A'..'Z':
               begin
                  for j := 1 to esc do
                     {$I-} write(^H' '^H); {$I+}
                  esc := 0;
               end;
            end; {case}

         end; {if esc}

      end; {if not bios echo}

   end; {for each char}
end;


procedure BIOS_init_com(chan: integer);
   (* initialize communication handlers for operation with the specified
      com port number *)
begin

(* initialize port numbers, receive and transmit queues *)
   INTR_select_port(chan);

end;


procedure BIOS_uninit_com;
   (* remove interrupt handlers for the com port
      and prepare for exit to system *)
begin
end;


procedure BIOS_flush_com;
   (* wait for all pending output to be sent - not needed on bios version *)
begin
end;

{ $R+}
