
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
 * PCB ProDOOR new-mail-capture (3-1-89)
 *
 *)

procedure open_mail_capture;
begin
   assign(mailfd,mailfile);
   {$i-} rewrite(mailfd); {$i+}
   if ioresult <> 0 then file_missing;

   cap_buffer := nil;
end;


(* ---------------------------------------------------------- *)
procedure buffer_mail_capture;
begin
   dos_getmem(cap_buffer,sizeof(cap_buffer^));
   setTextBuf(mailfd,cap_buffer^);
   cap_count := 0;
end;


(* ---------------------------------------------------------- *)
procedure close_mail_capture;
begin
   close(mailfd);
   dos_freemem(cap_buffer);
   if cap_count = 0 then
      dos_unlink(mailfile);
end;


(* ---------------------------------------------------------- *)
procedure capture_current_message;
begin
   {find position in file and read the message}
   load_message(false);

   if msgpos = no_msg then
      set_lastread
   else
   begin
      {caputure message text}
      message_capture := true;
      display_loaded_message;
      message_capture := false;
      inc(cap_count);
   end;
end;

