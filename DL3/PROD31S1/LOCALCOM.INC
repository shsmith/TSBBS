
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
 * PCB ProDOOR - local version of dualcomm.inc (3-1-89)
 *
 *)

function carrier_present:  boolean;
begin
   carrier_present := false;
end;

function receive_ready: boolean;
begin
   receive_ready := false;
end;

function receive_data:  char;
begin
   receive_data := '?';
end;

procedure transmit_data(s:    longstring);
begin
end;

procedure verify_txque_space;
begin
end;

procedure init_com;
begin
end;

procedure flush_com;
begin
end;

procedure lower_dtr;
begin
end;

procedure raise_dtr;
begin
end;

procedure uninit_com;
begin
end;

procedure disable_int;
begin
end;

procedure enable_int;
begin
end;

procedure cancel_xoff;
begin
end;

procedure control_k;
begin
   linenum := 2000;              (* cancel current function *)
   pending_keys[0] := chr(1);
   pending_keys[1] := ^M;        (* fake <return> to break loose from prompts *)
end;


