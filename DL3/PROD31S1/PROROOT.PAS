
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

unit ProRoot;

interface

Uses

{$IFDEF OVERLAY}
   Overlay,
{$ENDIF}
   Dos,
   MiniCrt,
   Tools,
   DosMem,
   MdosIO,
   BufIO,
   OpenShare,
   Qread,
{$IFNDEF IN_PROKIT}
   ProRegL,
{$ENDIF}
   ProData;

var
   setdebug:     boolean;     (* true if SET DEBUG=ON before calling *)
   dbfd:         text;        (* debugging output file *)

   {$I \tinc\quelib.dcl}     (* circular queue management library *)
   {$i \tinc\readbas.int}    (* library to read "basic" format data files *)
   {$I \tinc\movefile.int}   (* move a file, either rename or copy/delete *)
   {$I \tinc\ansicolr.int}   (* ansi color generation *)

   {$I extuser.int}     (* extended user file procedures *)
   {$I proerror.int}    (* error trap *)
   {$I proint.int}      (* pcboard interface procedures *)
   {$I proint2.int}     (* more pcboard interface procedures *)
   {$I probuild.int}    (* build download directory list *)
   {$I proconf.int}     (* configuration file processing *)
   {$I proprep.int}     (* prepare protocol table (expand macros) *)

   {$I proctl.int}      (* sysop control handlers *)
   {$I proutil.int}     (* utility functions for command/file interface *)
   {$I promsgs.int}     (* messages, more? processor *)
   {$I promsgs2.int}    (* usage, signon messages *)

{$IFDEF IN_PROEDIT}
   {$I localcom.int}
{$ELSE}
   {$I intrcomm.int}    (* interrupt-based low level communication library *)
   {$I bioscomm.int}    (* bios-based low level communication library *)
   {$I dualcomm.int}    (* dual bios/interrupt com routing library *)
{$ENDIF}

   {$I procomm.int}     (* high level communication handlers *)
   {$I procolr.int}     (* colorize dir files *)
   {$I prodisp.int}     (* display file module *)
   {$I prochat.int}     (* sysop chat mode and operator page *)
   {$I prosysop.int}    (* sysop status display and function keys *)

   {$i proflag.int}
   {$I proxprt.int}     (* expert toggle *)
   {$i pronode.int}


implementation

   {$i \tinc\readbas.inc}    (* library to read "basic" format data files *)
   {$I \tinc\movefile.inc}   (* move a file, either rename or copy/delete *)
   {$I \tinc\ansicolr.inc}   (* ansi color generation *)

   {$I extuser.inc}     (* extended user file procedures *)
   {$I proerror.inc}    (* error trap *)
   {$I proint.inc}      (* pcboard interface procedures *)
   {$I proint2.inc}     (* more pcboard interface procedures *)
   {$I probuild.inc}    (* build download directory list *)
   {$I proconf.inc}     (* configuration file processing *)
   {$I proprep.inc}     (* prepare protocol table (expand macros) *)

   {$I proctl.inc}      (* sysop control handlers *)
   {$I proutil.inc}     (* utility functions for command/file interface *)
   {$I promsgs.inc}     (* messages, more? processor *)
   {$I promsgs2.inc}    (* usage, signon messages *)

{$IFDEF IN_PROEDIT}
   {$I localcom.inc}
{$ELSE}
   {$I intrcomm.inc}    (* interrupt-based low level communication library *)
   {$I bioscomm.inc}    (* bios-based low level communication library *)
   {$I dualcomm.inc}    (* dual bios/interrupt com routing library *)
{$ENDIF}

   {$I procomm.inc}     (* high level communication handlers *)
   {$I procolr.inc}     (* colorize dir files *)
   {$I prodisp.inc}     (* display file module *)
   {$I prochat.inc}     (* sysop chat mode and operator page *)
   {$I prosysop.inc}    (* sysop status display and function keys *)

   {$I proflag.inc}
   {$I proxprt.inc}     (* expert toggle *)
   {$i pronode.inc}     (* node status *)


begin
   {writeln('proroot init');}

{$IFNDEF IN_PROEDIT}
   fillchar(rxque,sizeof(rxque),0);
   fillchar(txque,sizeof(txque),0);
{$ENDIF}

   setdebug := false;
end.


