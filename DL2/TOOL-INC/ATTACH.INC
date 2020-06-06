
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
 * attach.inc - support to attach and de-attach interrupt traps
 *
 * Usage:
 *    {$i attach.inc}
 *
 *    const
 *       old_21: longlink(ofs:0;seg:0);
 *
 *    procedure new_21(...);
 *       interrupt;
 *    begin
 *       ENTER_INTERRUPT;
 *       {do normal stuff}
 *       LINK_CALL(old_21);   {call old handler if needed}
 *       {do more normal stuff, beware segment changes}
 *       LINK_JMP(old_21);    {exit this handler and jump to old one}
 *       EXIT_INTERRUPT;      {exit this handler, ignore old one}
 *   end;
 *
 *   initialize:
 *      attach_handler($21,ofs(new_21),old_21);
 *      ... handler is active
 *      remove_handler($21,old_21);
 *
 *)

(*$R-,S-  range check and stack check off, this file only *)


(* ------------------------------------------------------------ *)
procedure get_handler(vector:      integer;     {vector number}
                      var link:    longlink);   {cseg link to old handler}

   (* get a pointer to the current handler for an interrupt vector *)
var
   reg:  registers;
begin

(* save the old interrupt handler's vector *)
   reg.ax := $3500+vector;
   msdos(reg);
   link.seg := reg.es;
   link.ofs := reg.bx;
end;


(* ------------------------------------------------------------ *)
procedure attach_handler(vector:      integer;     {vector number}
                         handler:     integer;     {cseg ofs of new handler}
                         var link:    longlink);   {cseg link to old handler}

   (* attach an interrupt handler to the specified vector number;
      handler is the cseg offset of the new handler; link will
      contain a long pointer to the previous handler *)
var
   reg:  registers;
begin

writeln('attach handler: stubbed; vector=',vector,' handler=',handler);
halt(99);

(* save the old interrupt handler's vector *)
   get_handler(vector,link);

(* install a vector to the new handler *)
   reg.ax := $2500+vector;
   reg.dx := handler;
   reg.ds := cseg;
   msdos(reg);
end;


(* ------------------------------------------------------------ *)
procedure remove_handler(vector:      integer;     {vector number}
                         var link:    longlink);   {cseg link to old handler}

   (* remove an interrupt handler and replace the old handler *)
var
   reg:  registers;
begin

(* can't install old vector more than once *)
   if (link.ofs = 0) and (link.seg = 0) then
      exit;

(* install the old vector *)
   reg.ax := $2500+vector;
   reg.dx := link.ofs;
   reg.ds := link.seg;
   msdos(reg);

(* flag old vector as invalid *)
   link.ofs := 0;
   link.seg := 0;
end;


