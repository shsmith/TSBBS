
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
 * qWrite - quick write to screen
 *
 *)

procedure qWrite(x,y: integer; s: string);
   {very fast dma string display}
var
  Vmode:       byte    absolute $0040:$0049;   {Current video mode}

{video modes}
const
  NoDisplay = $00;   VgaMono   = $07;
  MdaMono   = $01;   VgaColor  = $08;
  CgaColor  = $02;   DCC9      = $09;
  DCC3      = $03;   DCC10     = $0A;
  EgaColor  = $04;   McgaMono  = $0B;
  EgaMono   = $05;   McgaColor = $0C;
  PgcColor  = $06;   Unknown   = $FF;

type
   screenloc = record
      character: char;
      attribute: byte;
   end;

   videoram = array [1..2000] of screenloc;
   videoptr = ^videoram;

var
   disp_mem:   videoptr;
   i:          integer;
   bx:         integer;

begin
   case Vmode of
      MdaMono, VgaMono:
         disp_mem := ptr($B000,0);
      else
         disp_mem := ptr($B800,0);
   end;

   bx := 80*y+x-81;
   for i := 1 to length(s) do
      disp_mem^[bx+i].character := s[i];
end;
