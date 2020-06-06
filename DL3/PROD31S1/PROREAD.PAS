
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
 * PCB ProDOOR ProRead unit - message base reader functions
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProRead;

interface

   uses Tools, BufIO, ProData;

   {$I proread.int}

   procedure message_reader;

implementation

   uses Dos, DosMem, MdosIO, ProJoin, ProEnter, ProMail, ProRoot, ProSysF;

   {$i proread.inc}     (* read messages *)

   (* ---------------------------------------------------------- *)
   procedure message_reader;
   begin
      {determine message base filename}
      if select_conference(pcbsys.curconf)= false then
      begin
         par := selectedfile;
         not_available;
         exit;
      end;
         
      {if message base is okay, allocate buffers and enter the reader}
      alloc_mail;
      open_conference;
      read_messages;
      close_conference;
      free_mail;
   end;

end.


