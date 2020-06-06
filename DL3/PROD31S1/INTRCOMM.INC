
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
 * intrcomm.inc - interrupt-based communication library for PCB ProDOOR
 *
 *)

{$R-,S-}


(* ------------------------------------------------------------ *)
procedure control_k;
   (* process cancel-output command *)
begin
   txque.next_in := 1;
   txque.next_out := 1;          (* throw away pending output *)
   txque.count := 0;             

   rxque.next_in := 1;
   rxque.next_out := 1;          (* throw away pending input *)
   rxque.count := 0;

   linenum := 9000;              (* cancel current function *)
   pending_keys[0] := #0;
end;


(* ------------------------------------------------------------ *)
procedure INTR_service_MSR;
  (* modem status change interrupt *)
var
   c: byte;
begin
   c := port[ port_base+MSR ];
   io_delay;
end;


(* ------------------------------------------------------------ *)
procedure INTR_service_LSR;
   (* line status change interrupt *)
var
   c: byte;
begin
   c := port[ port_base+LSR ];
   io_delay;
end;


(* ------------------------------------------------------------ *)
procedure INTR_service_transmit;
   (* low-level interrupt service for transmit, call only when transmit
      holding register is empty *)
var
   c:       char;
const
   recur:  boolean = false;

begin

(* prevent recursion fb/bg *)
   if recur then exit;
   recur := true;

(* drop out if transmitter is busy *)
   if (port[ port_base+LSR ] and LSR_THRE) = 0 then
   begin
      io_delay;
      recur := false;
      exit;
   end;

   io_delay;

   (* stop transmitting when queue is empty, or XOFF is active
      or it is not CLEAR-to-send to modem *)

   xmit_active := (txque.count <> 0) and (not xoff_active) and
                  (disable_CTS_check or ((port[port_base+MSR] and MSR_CTS)>0));

   io_delay;

   (* start next byte transmitting *)
   if xmit_active then
   begin
      c := txque.data[txque.next_out];
      if txque.next_out < sizeof(txque.data) then
         inc(txque.next_out)
      else
         txque.next_out := 1;
      dec(txque.count);

      port[ port_base+THR ] := ord(c); io_delay;
   end;

   recur := false;
end;


(* ------------------------------------------------------------ *)
procedure INTR_service_receive;
   (* low-level interrupt service for receive data,
      call only when receive data is ready *)
var
   c: char;
   o: byte;
   err: boolean;

begin
   o := port[ port_base+LSR ];
   io_delay;

   err := false;
   if (o and LSR_OERR) <> 0 then begin inc(LOERR_count);  err := true; end;
   if (o and LSR_PERR) <> 0 then begin inc(LPERR_count);  err := true; end;
   if (o and LSR_FERR) <> 0 then begin inc(LFERR_count);  err := true; end;
   if (o and LSR_BREAK)<> 0 then begin inc(LBREAK_count); err := true; end;

   if err then
   begin
      o := port[ port_base+RBR ];
      exit;
   end;

   if ((o and LSR_DAV) = 0) then
      exit;

   c := chr( port[ port_base+RBR ] ); io_delay;

   if XOFF_active then           (* XOFF cancelled by any character *)
      cancel_xoff
   else

   if c = XOFF_char then         (* process XOFF/XON flow control *)
      XOFF_active := true
   else

   if (c = ^K) then              (* process cancel-output command *)
      control_k
   else

   if c = carrier_lost then      (* ignore this special character! *)
   begin
      {do nothing}
   end
   else

   if rxque.count < sizeof(rxque.data) then
   begin
      inc(rxque.count);
      rxque.data[rxque.next_in] := c;
      if rxque.next_in < sizeof(rxque.data) then
         inc(rxque.next_in)
      else
         rxque.next_in := 1;
   end;
end;


(* ------------------------------------------------------------ *)
procedure INTR_poll_transmit;
   (* recover from CTS or XOF handshake when needed *)
begin
   {no action if nothing to transmit}
   if (txque.count = 0) or (com_chan < 0){local} then
      exit;

   {check for XON if output suspended by XOFF}
   disable_int;
   INTR_service_receive;
   INTR_service_transmit;
   enable_int;
end;


(* ------------------------------------------------------------ *)
procedure cancel_xoff;
begin
   XOFF_active := false;
   INTR_poll_transmit;
end;


(* ------------------------------------------------------------ *)
procedure INTR_check_interrupts;
   (* check for and process any pending 8250 interrupts.
      can be called from TPAS *)
var
   status:  integer;

begin

(* get the interrupt identification register *)
   status := port[ port_base+IIR ]; io_delay;

(* repeatedly service interrupts until no more services possible *)
   while (status and IIR_PENDING) = 0 do
   begin
      {disable_int;}

      case (status and IIR_MASK) of
         IIR_MSR:   (* modem status change interrupt *)
            INTR_service_MSR;

         IIR_THRE:  (* transmit holding register empty interrupt *)
            INTR_service_transmit;

         IIR_DAV:   (* data available interrupt *)
            INTR_service_receive;

         IIR_LSR:   (* line status change interrupt *)
            INTR_service_MSR;
      end;

      {enable_int;}

  (* get the interrupt identification register again *)
      status := port[ port_base+IIR ];
      io_delay;
   end;

end;


(* ------------------------------------------------------------ *)
procedure INTR_interrupt_handler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: word);
interrupt;
   (* low-level interrupt service routine.  this procedure processes
      all receive-ready and transmit-ready interrupts from the 8250 chip.
      DO NOT call this proc from TPAS *)

begin

(* service interrupts until no more services possible *)
   INTR_check_interrupts;

(* acknowledge the interrupt and return to foreground operation *)
   port[ $20 ] := $20;   {non-specific EOI} io_delay;

end;


(* ------------------------------------------------------------ *)
function INTR_receive_ready: boolean;
   (* see if any receive data is ready on the active com port *)
begin
   INTR_poll_transmit;
   INTR_receive_ready := rxque.count > 0;
end;


(* ------------------------------------------------------------ *)
procedure INTR_flush_com;
   (* wait for all pending transmit data to be sent *)
begin
   enable_int;
   while txque.count > 0 do
   begin
      INTR_poll_transmit;
      give_up_time;             (* give up extra time *)
   end;
end;


(* ------------------------------------------------------------ *)
procedure verify_txque_space;
   (* wait until there is enough space in the queue for this message *)
   (* or until flow control is released *)
begin
   while txque.count > queue_low_water do
   begin
      INTR_poll_transmit;
      give_up_time;             (* give up extra time *)
   end;
end;


(* ------------------------------------------------------------ *)
procedure INTR_lower_dtr;
   (* lower DTR to inhibit modem answering *)
var
   o: byte;
begin
   if {local or} (com_chan < 0) then exit;

   o := port [ port_base+MCR ];                 io_delay;
   port[ port_base+MCR ] := o and not MCR_DTR;  io_delay;
end;


(* ------------------------------------------------------------ *)
procedure INTR_raise_dtr;
   (* raise DTR to allow modem answering - not supported by BIOS *)
var
   o: byte;
begin
   if {local or} (com_chan < 0) then exit;

   o := port [ port_base+MCR ];                       io_delay;
   port[ port_base+MCR ] := o or (MCR_DTR+MCR_RTS);   io_delay;
end;


(* ------------------------------------------------------------ *)
procedure INTR_select_port(chan: integer);
   (* lookup the port address for the specified com channel *)
begin
   com_current_chan := chan;
   xmit_active := false;
   XOFF_active := false;

   if (chan >= 0) and (chan <= 2) then
   begin
      port_base := atow(GetEnv('COMBASE'));
      if port_base = 0 then
         port_base := COM_BASE_TABLE[chan];
      bios_bastab[chan] := port_base;

      port_irq := atow(GetEnv('COMIRQ'));
      if port_irq = 0 then
         port_irq := COM_IRQ_TABLE[chan];

      port_intr := IRQ_VECT_TABLE[port_irq];
      intr_mask := IRQ_MASK_TABLE[port_irq];
   end;

(**
writeln('[chan=',chan,' port base=',port_base,' intr=',port_intr,' mask=',intr_mask,']');
**)

(* initialize the receive and transmit queues *)
   rxque.next_in := 1;
   rxque.next_out := 1;
   rxque.count := 0;

   txque.next_in := 1;
   txque.next_out := 1;
   txque.count := 0;

   INTR_raise_dtr;
end;


(* ------------------------------------------------------------ *)
procedure INTR_init_com(chan: integer);
   (* initialize communication handlers for operation with the specified
      com port number.  must be called before any other services here *)
var
   o: byte;
begin

(* initialize port numbers, receive and transmit queues *)
   INTR_select_port(chan);

   if chan < 0 then exit;

(* save the old interrupt handler's vector *)
   GetIntVec(port_intr, old_vector);
{writeln('got old');}

(* install a vector to the new handler *)
   SetIntVec(port_intr,@INTR_interrupt_handler);
{writeln('new set');}

(* save original 8250 registers *)
   disable_int;
   prev_LCR := port[ port_base+LCR ];              io_delay;
   prev_MCR := port[ port_base+MCR ];              io_delay;
   prev_IER := port[ port_base+IER ];              io_delay;
   prev_ICTL  := port[ ICTL ];                     io_delay;

(* clear divisor latch if needed *)
   port[ port_base+LCR ] := prev_LCR and not LCR_ABDL;
   io_delay;

(* initialize the 8250 for interrupts *)
   o := port[ port_base+MCR ];                     io_delay;
   port[ port_base+MCR ] := o or MCR_OUT2;         io_delay;
   port[ port_base+IER ] := IER_DAV+IER_THRE;      io_delay;

(* enable the interrupt through the interrupt controller *)
   o := port[ ICTL ];                              io_delay;
   port[ ICTL ] := o and (not intr_mask);          io_delay;
   enable_int;

(* initialize the receive queues in case of an initial garbage byte *)
   disable_int;
   rxque.next_in := 1;
   rxque.next_out := 1;
   rxque.count := 0;
   enable_int;

{writeln('init done');}

end;


(* ------------------------------------------------------------ *)
procedure INTR_uninit_com;
   (* remove interrupt handlers for the com port
      must be called before exit to system *)
var
   o: byte;
begin
   if (port_base = -1) or (old_vector = nil) then
      exit;

(* wait for the pending data to flush from the queue *)
   INTR_flush_com;

(* attach the old handler to the interrupt vector *)
   disable_int;

   SetIntVec(port_intr, old_vector);

   port[ port_base+LCR ] := prev_LCR;     io_delay;
   port[ port_base+MCR ] := prev_MCR;     io_delay;
   port[ port_base+IER ] := prev_IER;     io_delay;
   o := port[ ICTL ];                     io_delay;
   port[ ICTL ] := (o and not intr_mask) or (prev_ICTL and intr_mask);
   io_delay;

   enable_int;

(***
writeln('prev: LCR=',itoh(prev_LCR),
             ' MCR=',itoh(prev_MCR),
             ' IER=',itoh(prev_IER),
             ' ICTL=',itoh(prev_ICTL));
****)
(***
writeln(' now: LCR=',itoh(port[ port_base+LCR ]),
             ' MCR=',itoh(port[ port_base+MCR ]),
             ' IER=',itoh(port[ port_base+IER ]),
             ' ICTL=',itoh(port[ ICTL ]));
****)
(***
writeln('intr_mask=',itoh(intr_mask),
             ' vector=',itoh(seg(old_vector)),':',itoh(ofs(old_vector)));
***)

   old_vector := nil;
end;


(* ------------------------------------------------------------ *)
procedure INTR_set_baud_rate(speed: word);
var
   divisor: word;
   o: byte;
begin
   if com_chan < 0 then exit;
   {INTR_}flush_com;

   divisor := 115200 div speed;
   disable_int;

(* enable address divisor latch *)
   o := port[port_base+LCR];              io_delay;
   port [port_base+LCR] := o or LCR_ABDL; io_delay;

(* set the divisor *)
   portw[port_base+THR] := divisor;       io_delay;

(* set 8 bits, 1 stop, no parity, no break, disable divisor latch *)
   prev_LCR := LCR_8BITS   or LCR_1STOP   or
               LCR_NPARITY or LCR_NOBREAK;

   port[ port_base+LCR ] := prev_LCR;     io_delay;

   enable_int;

(****
if setdebug then
writeln(dbfd,'set baud: LCR=',itoh(port[ port_base+LCR ]),
             ' MCR=',itoh(port[ port_base+MCR ]),
             ' IER=',itoh(port[ port_base+IER ]),
             ' ICTL=',itoh(port[ ICTL ]),
             ' div=',divisor,
             ' spd=',speed);
****)
end;


(* ------------------------------------------------------------ *)
function INTR_receive_data:  char;
   (* wait for and return 1 character from the active com port *)
   (* returns carrier_lost if carrier is not present *)
var
   c: char;

begin
   if com_chan < 0 then exit;

   repeat
      io_delay;

      if INTR_receive_ready then
      begin
         disable_int;

         {deque from rxque}
         c := rxque.data[rxque.next_out];
         if rxque.next_out < sizeof(rxque.data) then
            inc(rxque.next_out)
         else
            rxque.next_out := 1;
         dec(rxque.count);

         enable_int;

         {strip parity in 7,E mode}
         if even_parity then
            c := chr( ord(c) and $7f );

         INTR_receive_data := c;
         exit;
      end;

      {give up time while waiting}
      give_up_time;

      io_delay;
   until not ((port[port_base+MSR] and MSR_RLSD)<>0);

   {carrier not present}
   cancel_xoff;
   INTR_receive_data := carrier_lost;
end;


(* ------------------------------------------------------------ *)
procedure INTR_transmit_data(s:    longstring);
   (* transmits a string of characters to the specified com port;
      does not transmit when carrier is not present *)
var
   i:    integer;

begin
   if com_chan < 0 then exit;

(* wait until there is enough space in the queue for this message *)
(* or until flow control is released *)

   if txque.count > queue_high_water then
      verify_txque_space;


(* enque the string to be transmitted *)
   for i := 1 to length(s) do
   begin
      disable_int;

      inc(txque.count);
      txque.data[txque.next_in] := s[i];
      if txque.next_in < sizeof(txque.data) then
         inc(txque.next_in)
      else
         txque.next_in := 1;

      enable_int;
   end;


(* force an initial interrupt to get things rolling (in case there are
   no more pending transmit-ready interrupts *)

   INTR_poll_transmit;
end;

{ $R+,S+}

