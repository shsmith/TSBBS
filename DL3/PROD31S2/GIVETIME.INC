
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
 * this procedure should be called often inside the "nothing to do" loop when
 * the system has nothing to do (eg. waiting for a host mode call; no rx/tx
 * activity when online; sitting at a dialing directory prompt; etc.)
 *
 *)


procedure determine_tasker;
   {determine what multi-tasker is active, if any}
var
   reg:  registers;

begin
   reg.bx := 0;
   reg.ax := $1022;     {get topview/taskview version}
   intr($15,reg);
   tasker := taskview;
   if reg.bx <> 0 then
   begin
      directVideo := false;
      exit;
   end;

   reg.ax := $e400;     {return current program status, doubledos}
   msdos(reg);
   tasker := doubledos;
   if (reg.al = 1) or (reg.al = 2) then
      exit;

   {cannot detect a multi-tasker, disable give-up-time calls}
   tasker := notasker;
end;


(* ------------------------------------------------------------ *)
procedure give_up_time;
   {give up unused time under doubledos}
var
   reg:  registers;

begin

{WRITE('`3');}
   {determine what multi-tasker is active, if any}
   if tasker = unknown then
      determine_tasker;
   
   {give up time with taskview/omniview/topview}
   if tasker = taskview then
   begin
      reg.ax := $1000;          {give up remainder of timeslice}
      intr($15,reg);
   end
   else

   {give up time with doubledos}
   if tasker = doubledos then
   begin
      reg.ax := $0001;           {give up 1 clock tick/slice}
      intr($fe,reg);
   end;

{WRITE('`4');}
end;


