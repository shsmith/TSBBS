
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

type
   videoram =          array [0..1999] of word;
   videoptr =          ^videoram;

   window_save_rec = record
      WindMin:    word;
      WindMax:    word;
      TextAttr:   integer;
      CuX:        integer;
      CuY:        integer;
      Image:      videoram;
   end;

var
  { saved_window: window_save_rec; }
   disp_mem:     videoptr;
   

procedure setcolor(fg,bg: integer);
begin
   bg := bg and 7;
   crt.textcolor(fg);
   crt.textbackground(bg);
end;

function make_string(c: char; len: integer): string;
   {make a string by repeating a character n times}
var
   i:  integer;
   s:  string;
begin
   for i := 1 to len do
      s[i] := c;
   s[0] := chr(len);
   make_string := s;
end;


procedure disp (s:                  string);
begin
   write(s);
end;

procedure displn(s: string);       {fast display and linefeed}
begin
   writeln(s);
end;


procedure window(x1,y1,x2,y2: integer);
var
   wx,wy: integer;
begin
   wx := wherex + lo(crt.WindMin);    {get absolute cursor location}
   wy := wherey + hi(crt.WindMin);  
   crt.window(x1,y1,x2,y2);
   if (x1=1) and (y1=1) then
      crt.gotoxy(wx,wy);
end;

procedure save_window(var saved: window_save_rec);
   (* save the current window so it can be restored later *)
begin
   saved.Image := disp_mem^;
   saved.WindMin := crt.WindMin;
   saved.WindMax := crt.WindMax;
   saved.CuX := crt.WhereX;
   saved.CuY := crt.WhereY; 
   saved.TextAttr := crt.TextAttr;
end;

procedure restore_window(saved: window_save_rec);
   (* restore the windowing settings *)
begin                   
   disp_mem^ := saved.Image;
   window(lo(saved.WindMin)+1, hi(saved.WindMin)+1,
          lo(saved.WindMax)+1, hi(saved.WindMax)+1);
   crt.GotoXY(saved.CuX,saved.CuY);
   crt.TextColor(lo(saved.TextAttr));
   crt.TextBackground(hi(saved.TextAttr));
end;


procedure init_pop_up;
   {call once before anything else in this library}
begin
   if crt.LastMode = crt.Mono then
      disp_mem := ptr($B000,0)
   else       
      disp_mem := ptr($B800,0);

   window(1,1,80,25);
end;


