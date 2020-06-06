
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

(* ------------------------------------------------------ *)
procedure setcolor(fg,bg: integer);
begin
   bg := bg and 7;
   crt.textcolor(fg);
   crt.textbackground(bg);
end;

(* ------------------------------------------------------ *)
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

(* ------------------------------------------------------ *)
procedure disp (s:                  string);
begin
   write(s);
end;

(* ------------------------------------------------------ *)
procedure displn(s: string);       {fast display and linefeed}
begin
   writeln(s);
end;

(* ------------------------------------------------------ *)
procedure shadow_display;
var
   i: integer;
begin

(****
   for i := 1 to 2000 do
      disp_mem^[i] := disp_mem^[i] and $F7FF;
****)

Inline(
  $C4/$36/>disp_mem/     {   les si,[>disp_mem]}
  $89/$F7/               {   mov di,si}
  $B9/$D0/$07/           {   mov cx,2000}
                         {next:}
  $26/                   {   es:}
  $AD/                   {   lodsw}
  $25/$FF/$F7/           {   and ax,$F7FF}
  $26/                   {   es:}
  $AB/                   {   stosw}
  $E2/$F7);              {   loop next}

end;

(* ------------------------------------------------------ *)
procedure enable_cursor;
var
   reg: registers;
begin
   reg.ax := $100;            {set cursor size function code}
   reg.cx := $000F;           {large block cursor}
   intr( $10,reg);            {bios video service interrupt}
end;

(* ------------------------------------------------------ *)
procedure disable_cursor;
var
   reg: registers;
begin
   reg.ax := $100;            {set cursor size function code}
   reg.cx := $0F00;           {no cursor}
   intr( $10,reg);          {bios video service interrupt}
end;

(* ------------------------------------------------------ *)
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

(* ------------------------------------------------------ *)
procedure save_window(var saved: window_save_rec);
   (* save the current window so it can be restored later *)
begin
   saved.Image := disp_mem^;
   push_window(saved.Push);
end;

(* ------------------------------------------------------ *)
procedure restore_window(saved: window_save_rec);
   (* restore the windowing settings *)
begin                   
   disp_mem^ := saved.Image;
   pop_window(saved.Push);
end;

(* ------------------------------------------------------ *)
procedure push_window(var push: window_push_rec);
begin
   push.WindMin := crt.WindMin;
   push.WindMax := crt.WindMax;
   push.CuX := crt.WhereX;
   push.CuY := crt.WhereY;
   push.TextAttr := crt.TextAttr;
end;

(* ------------------------------------------------------ *)
procedure pop_window(var push: window_push_rec);
begin
   window(lo(push.WindMin)+1, hi(push.WindMin)+1,
          lo(push.WindMax)+1, hi(push.WindMax)+1);
   crt.GotoXY(push.CuX,push.CuY);
   crt.TextColor(lo(push.TextAttr));
   crt.TextBackground(hi(push.TextAttr));
end;

(* ------------------------------------------------------ *)
procedure init_pop_up;
   {call once before anything else in this library}
begin
   if crt.LastMode = crt.Mono then
      disp_mem := ptr($B000,0)
   else       
      disp_mem := ptr($B800,0);

   window(1,1,80,25);
end;


