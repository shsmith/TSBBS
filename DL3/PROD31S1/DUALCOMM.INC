
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
 * PCB ProDOOR  - bios or interrupt-based communication library (3-1-89)
 *
 *)

function carrier_present:  boolean;
   (* check for carrier loss on the active com channel *)
begin
   if bios_comm then  carrier_present := BIOS_carrier_present
   else               carrier_present := (port[port_base+MSR] and MSR_RLSD)<>0;
end;


function receive_ready: boolean;
   (* see if any receive data is ready on the active com port *)
begin
   if com_chan < 0 then
      receive_ready := false
   else
   if bios_comm then
      receive_ready := BIOS_receive_ready
   else
      receive_ready := INTR_receive_ready;
end;


function receive_data:  char;
   (* wait for and return 1 character from the active com port.
      returns carrier_lost if carrier is not present *)
begin
   if bios_comm then receive_data := BIOS_receive_data
   else              receive_data := INTR_receive_data;
end;


procedure transmit_data(s:    longstring);
   (* transmits a string of characters to the specified com port *)
begin
   XOFF_char := ^S;
   if bios_comm then  BIOS_transmit_data(s)
   else               INTR_transmit_data(s);
end;


procedure init_com;
   (* initialize communication handlers for operation with the specified
      com port number *)
begin
   if local then
      com_chan := -1;
   if bios_comm then BIOS_init_com(com_chan)
   else              INTR_init_com(com_chan);
end;


procedure flush_com;
   (* wait for all pending output to be sent - not needed on bios version *)
begin
   if bios_comm then BIOS_flush_com
   else              INTR_flush_com;
end;


procedure lower_dtr;
   (* lower DTR to inhibit modem from answering *)
begin
   INTR_lower_dtr;
end;


procedure raise_dtr;
   (* raise DTR to allow modem answering *)
begin
   INTR_raise_dtr;
end;


procedure uninit_com;
   (* remove interrupt handlers for the com port
      and prepare for exit to system *)
begin
   if bios_comm then BIOS_uninit_com
   else              INTR_uninit_com;
   bios_comm := true;
end;


