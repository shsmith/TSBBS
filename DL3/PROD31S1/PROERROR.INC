
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
 * PCB ProDOOR runtime error handler (3-1-89)
 *
 *)

procedure error_handler;
   {exit handler, checks for I/O and runtime errors}
var
   reason: anystring;

begin
   {link to the next exitproc when this one's finished}
   ExitProc := ExitSave;

   {all finished unless there is an error}
   if ErrorAddr = nil then
      exit;

   {generate error message text and clear the error condition}
   reason := 'Runtime error: '+ itoa(ExitCode)+
             ' PC='+itoh(seg(ErrorAddr^)) + ':' + itoh(ofs(ErrorAddr^));
   ErrorAddr := nil;

   {abort the program and log the reason}
   abort_program(reason);
end;


procedure ctrl_break_handler(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: word);
interrupt;
   (* ignore control-break *)
begin
end;


procedure install_error_handler;
   (* install new runtime error handler *)
begin
   SetCBreak(false);            {disable control-break}
   SetIntVec($23,@ctrl_break_handler);

   ExitSave := ExitProc;        {save link to next handler in chain}
   ExitProc := @error_handler;  {link in my handler}

   SetIntVec($24,SaveInt24);    {restore normal critical error handler,
                                 allows 'FATAL' to work, if present}
end;
