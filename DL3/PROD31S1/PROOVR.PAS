
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
 * ProOvr.pas - prodoor overlay initializer module
 *
 * 'Use' this in the main module to enable prodoor overlays.
 * Using this module first insures that overlays are initialized
 * before any other unit initializers are called.
 *
 *)

{$O+,F+}

unit ProOvr;

interface

implementation
   uses Overlay, Tools;

begin
   OvrFileMode := $0;  {compatibility read/only}

   {$i-}
(****
   OvrInit(remove_ext(paramstr(0)) + '.OVR');
*****)
   OvrInit(paramstr(0));
   if OvrResult <> OvrOK then
   begin
      writeln(^G'Can''t open overlay file: '+paramstr(0));
      halt(1);
   end;
   {$i+}

   {OvrInitEMS;}
   OvrSetBuf(maxavail);
end.

