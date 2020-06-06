
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
 * popup - utility library for simple "pop-up" windows (3-1-89)
 *
 *)

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

const
   low_attr:  integer = 7;
   norm_attr: integer = 15;
   back_attr: integer = 0;

type
   popup_string = string[255];

   screenloc =         record
         character:          char;
         attribute:          byte;
   end;

   videoram =          array [0..1999] of screenloc;
   videoptr =          ^videoram;

   window_rec = record
      x1,y1,x2,y2: integer;
      attr:        byte;
   end;

   window_save_rec = record
      win:      window_rec;
      scr:      videoram;
      cux,cuy:  integer;
   end;


var
   cur_window:   window_rec;
   saved_window: window_save_rec;
   disp_mem:     videoptr;


procedure setcolor(fg,bg: integer);
begin
   bg := bg and 7;
   textcolor(fg);
   textbackground(bg);
   cur_window.attr := fg + bg shl 4;
end;

procedure normvideo;
begin
   setcolor(norm_attr,back_attr);
end;

procedure lowvideo;
begin
   setcolor(low_attr,back_attr);
end;

procedure old_window(win: window_rec);   {redefine the old window
                                          command so it can still be
                                          used by other procs}
begin
   with win do
      window(x1,y1,x2,y2);
end;

procedure window(a1,b1,a2,b2: integer);    {make a new version of window
                                            that saves the current state}
begin
   with cur_window do
   begin
      x1 := a1;
      y1 := b1;
      x2 := a2;
      y2 := b2;
   end;

   old_window(cur_window);
end;



function make_string(c: char; len: integer): popup_string;
   {make a string by repeating a character n times}
var
   i:  integer;
   s:  popup_string;
begin
   for i := 1 to len do
      s[i] := c;

   s[0] := chr(len);
   make_string := s;
end;


procedure disp (s:                  popup_string);
   {very fast dma string display}
var
   index:              integer;
   i:                  integer;
   c:                  char;
   len:                integer;
   max_index:          integer;

begin

   with cur_window do
   begin
      len := ord(s[0]);
      index :=(wherey + y1 - 2)* 80 +(wherex + x1 - 2);
      max_index := y2*80;

      for i := 1 to len do
      begin
         c := s [i];

         case c of
            ^H:   dec(index);

            ^J:   begin
                     index := index + 80;
                     if index >= max_index then
                     begin
                        write(^J);
                        index := index - 80;
                     end;
                  end;

            ^M:   index :=(index div 80)* 80 + x1 - 1;

            ^G:   write(^G);

            else  begin
                     with disp_mem^[index] do
                     begin
                        character := c;
                        attribute := attr;
                     end;

                     inc(index);

                     if index >= max_index then
                     begin
                        index := index - 80;
                        writeln;
                     end;
                  end;
         end;
      end;

(* place cursor at end of displayed string *)
      gotoxy((index mod 80)- x1 + 2,(index div 80)- y1 + 2);
   end;
end;



procedure displn(s: popup_string);       {fast display and linefeed}
begin
   disp(s);
   writeln;
end;


procedure save_window(var saved: window_save_rec);
   (* save the current window so it can be restored later *)
begin
   saved.scr := disp_mem^;
   saved.win := cur_window;
   saved.cux := wherex;
   saved.cuy := wherey;
end;


procedure restore_window(saved: window_save_rec);
   (* restore the windowing settings *)
begin
   cur_window := saved.win;
   old_window(cur_window);

(* restore the cursor position *)
   gotoxy(saved.cux,saved.cuy);

(* restore the display contents *)
   disp_mem^ := saved.scr;

(* restore current video mode *)
   if cur_window.attr = low_attr then
      lowvideo
   else
      normvideo;
end;


procedure init_pop_up;
   {call once before anything else in this library}
begin
   case Vmode of
      MdaMono, VgaMono:
         disp_mem := ptr($B000,0);
      else
         disp_mem := ptr($B800,0);
   end;

   window(1,1,80,25);
   normvideo;
end;

