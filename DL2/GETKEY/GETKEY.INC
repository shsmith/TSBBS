
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
 * function key and other keyboard entry definition
 * shs (rev. 12-nov-87)
 *
 *)

const
   YES         = 'Y';
   NO          = 'N';
   BACKSPACE   = #8;
   TAB         = #9;
   NEWLINE     = #13;
   ESC         = #27;
   F1          = #201;
   F2          = #202;
   F3          = #203;
   F4          = #204;
   F5          = #205;
   F6          = #206;
   F7          = #207;
   F8          = #208;
   F9          = #209;
   F10         = #210;
   HOME        = #213;
   UP          = #214;
   PGUP        = #215;
   LEFT        = #217;
   RIGHT       = #219;
   ENDK        = #221;
   DOWN        = #222;
   PGDN        = #223;
   INS         = #224;
   DEL         = #225;
   CTRL_F1     = #236;
   CTRL_F2     = #237;
   CTRL_F3     = #238;
   CTRL_F9     = #244;
   CTRL_F10    = #245;
   CTRL_PGUP   = #18;
   CTRL_PGDN   = #4;
   CTRL_LEFT   = #1;
   CTRL_RIGHT  = #2;
   CTRL_HOME   = #5;
   CTRL_END    = #3;

function getkey: char;
var
   key: char;

begin
   key := crt.readkey;

   if (key = #0) then
   begin
      key := crt.readkey;
      key := chr( lo( ord( key )+ 142 ));
                              {convert function keys to 201..210}
   end;

   getkey := key;
end;

