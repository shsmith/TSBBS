
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

(******************************************************
 *
 * Procedure:  itoh
 *
 * Purpose:    converts an integer into a string of hex digits
 *
 * Example:    s := itoh(i);
 *
 *)

function itoh(i: longint): string8;   {integer to hex conversion}
var
   h:   string8;
   w:   word;

   procedure digit(ix: integer; ii: word);
   begin
      ii := ii and 15;
      if ii > 9 then 
         ii := ii + 7;
      h[ix] := chr(ii + ord('0'));
   end;

begin
   w := i and $FFFF;
   h[0] := chr(4);
   digit(1,w shr 12);
   digit(2,w shr 8);
   digit(3,w shr 4);
   digit(4,w);
   itoh := h;   
end;

(******************************************************
 *
 * Procedure:  htoi
 *
 * Purpose:    converts a string of hex digits into an integer
 *
 * Example:    i := htoi(h);
 *
 *)

function htoi(h: string8): longint;   {hex to integer conversion}
var
   r:    longint;
   i:    integer;

begin
   r := 0;
   for i := 1 to length(h) do
   begin
      r := r*16 + ord(upcase(h[i])) - ord('0');
      if h[i] > '9' then
         dec(r,7);
   end;
   htoi := r;
end;


