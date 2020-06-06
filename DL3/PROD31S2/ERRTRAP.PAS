
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
 * Runtime error handler - traps and reports runtime errors
 * with full messages. (3-1-89)
 *
 *)

unit ErrTrap;

{$F+,R-,S-}

interface

   var
      ExitSave: pointer;   {pointer to next exitproc in the chain}

   procedure error_handler;
   function itoh(w: word): string;
   function error_message(code: integer): string;


implementation

   function error_message(code: integer): string;
      {return message text for a given runtime error code}
   var
      class:  string;
      msg:    string;
   begin
      case code of
           1.. 99: class := 'DOS';
         100..149: class := 'I/O';
         150..199: class := 'CRITICAL';
         200..249: class := 'FATAL';
         else      class := 'UNKNOWN';
      end;

      case code of
           2: msg := 'File not found';
           3: msg := 'Path not found';
           4: msg := 'Too many open files';
           5: msg := 'File access denied';
           6: msg := 'Bad file handle';
          12: msg := 'Bad file access code';
          15: msg := 'Bad drive number';
          16: msg := 'Can''t remove current dir';
          17: msg := 'Can''t rename across drives';

         100: msg := 'Disk read error';
         101: msg := 'Disk write error';
         102: msg := 'File not assigned';
         103: msg := 'File not open';
         104: msg := 'File not open for input';
         105: msg := 'File not open for output';
         106: msg := 'Bad numeric format';

         150: msg := 'Disk is write-protected';
         151: msg := 'Unknown diskette unit';
         152: msg := 'Drive not ready';
         153: msg := 'Unknown command';
         154: msg := 'CRC error in data';
         155: msg := 'Bad drive request structure length';
         156: msg := 'Disk seek error';
         157: msg := 'Unknown diskette type';
         158: msg := 'Sector not found';
         159: msg := 'Printer out of paper';
         160: msg := 'Device write fault';
         161: msg := 'Device read fault';
         162: msg := 'Hardware failure';

         200: msg := 'Division by zero';
         201: msg := 'Range check';
         202: msg := 'Stack overflow';
         203: msg := 'Heap overflow';
         204: msg := 'Bad pointer operation';
         205: msg := 'Floating point overflow';
         206: msg := 'Floating point underflow';
         207: msg := 'Bad floating point operation';

         else str(code,msg);
      end;

      error_message := class + ' ERROR: ' + msg;
   end;


   function itoh(w: word): string;
      {hex conversion}
   const
      hex: array[0..15] of char = '0123456789ABCDEF';
   var
      h: string[4];
   begin
      h[0] := chr(4);
      h[1] := hex[(w shr 12) and $0F];
      h[2] := hex[(w shr  8) and $0F];
      h[3] := hex[(w shr  4) and $0F];
      h[4] := hex[w          and $0F];
      itoh := h;
   end;


   procedure error_handler;
      {exit handler, checks for I/O and runtime errors}
   begin
      {link to the next exitproc when this one's finished}
      ExitProc := ExitSave;

      {all finished unless there is an error}
      if ErrorAddr = nil then
         exit;

      {generate error message text and clear the error condition}
      writeln(^G);
      writeln('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
      writeln('±±±±±      Runtime error ',ExitCode:3,' at location ',
              itoh(seg(ErrorAddr^)),':',itoh(ofs(ErrorAddr^)),  '     ±±±±±');
      writeln('±±±±±':60,^M'±±±±±      ',error_message(ExitCode));
      writeln('±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±');
      ErrorAddr := nil;
   end;


(* install new runtime error handler *)
begin
   ExitSave := ExitProc;        {save link to next handler in chain}
   ExitProc := @error_handler;  {link in my handler}
end.

