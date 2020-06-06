
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
 * Generation of ANSI codes for color
 *
 *)

procedure position(x,y: byte);
   {position cursor}
begin
   disp(#27'[' + itoa(y) + ';' + itoa(x) + 'f');
end;

procedure clear_screen;
   {easee screen in current color}
begin
   disp(#27'[2J');
end;

procedure clear_eol;
   {clear to end of line}
begin
   disp(#27'[K');
end;


(* ------------------------------------------------------------ *)
function color(control: integer): string20;
   {form an ansi color command}
var
   newcolor: string20;

begin
   if graphics and not message_capture then
      newcolor := #27'[' + ansi_colors[control] + 'm'
   else
      newcolor := '';

   if newcolor = ansi_ccolor then
      color := ''
   else
   begin
      ansi_ccolor := newcolor;
      color := newcolor;
   end;
end;



(* ------------------------------------------------------------ *)
{color selection macros}
function RED:     string20; begin RED     := color(ansi_RED); end;
function GREEN:   string20; begin GREEN   := color(ansi_GREEN); end;
function YELLOW:  string20; begin YELLOW  := color(ansi_YELLOW); end;
function BLUE:    string20; begin BLUE    := color(ansi_BLUE); end;
function MAGENTA: string20; begin MAGENTA := color(ansi_MAGENTA); end;
function CYAN:    string20; begin CYAN    := color(ansi_CYAN); end;
function WHITE:   string20; begin WHITE   := color(ansi_WHITE); end;
function GRAY:    string20; begin GRAY    := color(ansi_GRAY); end;

procedure dRED(m: string);    begin disp(RED);     pdisp(m); end;
procedure dGREEN(m: string);  begin disp(GREEN);   pdisp(m); end;
procedure dYELLOW(m: string); begin disp(YELLOW);  pdisp(m); end;
procedure dBLUE(m: string);   begin disp(BLUE);    pdisp(m); end;
procedure dMAGENTA(m: string);begin disp(MAGENTA); pdisp(m); end;
procedure dCYAN(m: string);   begin disp(CYAN);    pdisp(m); end;
procedure dWHITE(m: string);  begin disp(WHITE);   pdisp(m); end;
procedure dGRAY(m: string);   begin disp(GRAY);    pdisp(m); end;

procedure default_color;      begin disp(color(ansi_default)); end;


(* ------------------------------------------------------------ *)
procedure load_color_constants(name: string65);
   {load a new set of color constants}
var
   fd:   text;
   i:    integer;

begin
   if not dos_exists(name) then
      exit;
   assignText(fd,name);
   reset(fd);
   readln(fd);
   for i := 1 to 8 do
      readln(fd,ansi_colors[i]);
   close(fd);
end;

