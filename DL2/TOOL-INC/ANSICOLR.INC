

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
   _disp(#27'[' + itoa(y) + ';' + itoa(x) + 'f');
end;

procedure clear_screen;
   {easee screen in current color}
begin
   _disp(#27'[2J');
end;

procedure clear_eol;
   {clear to end of line}
begin
   _disp(#27'[K');
end;


(* ------------------------------------------------------------ *)
function code_colors(code:  string30): string30;
   {form an ansi color command}
begin
   if graphics and (not message_capture) then
      ansi_ccolor := #27'[' + code + 'm'
   else
      ansi_ccolor := '';
   code_colors := ansi_ccolor;
end;



(* ------------------------------------------------------------ *)
function code_color(control: integer): string20;
   {form an ansi color command}
begin
   code_color := code_colors(ansi_colors[control]);
end;



(* ------------------------------------------------------------ *)
{color selection macros}
function aRED:     string20; begin aRED     := code_color(ansi_RED);     end;
function aGREEN:   string20; begin aGREEN   := code_color(ansi_GREEN);   end;
function aYELLOW:  string20; begin aYELLOW  := code_color(ansi_YELLOW);  end;
function aBLUE:    string20; begin aBLUE    := code_color(ansi_BLUE);    end;
function aMAGENTA: string20; begin aMAGENTA := code_color(ansi_MAGENTA); end;
function aCYAN:    string20; begin aCYAN    := code_color(ansi_CYAN);    end;
function aWHITE:   string20; begin aWHITE   := code_color(ansi_WHITE);   end;
function aGRAY:    string20; begin aGRAY    := code_color(ansi_GRAY);    end;

procedure adRED(m: string);    begin _disp(aRED);     pdisp(m); end;
procedure adGREEN(m: string);  begin _disp(aGREEN);   pdisp(m); end;
procedure adYELLOW(m: string); begin _disp(aYELLOW);  pdisp(m); end;
procedure adBLUE(m: string);   begin _disp(aBLUE);    pdisp(m); end;
procedure adMAGENTA(m: string);begin _disp(aMAGENTA); pdisp(m); end;
procedure adCYAN(m: string);   begin _disp(aCYAN);    pdisp(m); end;
procedure adWHITE(m: string);  begin _disp(aWHITE);   pdisp(m); end;
procedure adGRAY(m: string);   begin _disp(aGRAY);    pdisp(m); end;

procedure default_color;      begin _disp(code_color(ansi_default)); end;


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


(* ------------------------------------------------------------ *)
function expand_xansi(xansi: string20): string30;

const
   fgtab:   array[0..15] of string[5] =
      (';30',   ';34',   ';32',   ';36',   ';31',   ';35',   ';33',   '',
       ';1;30', ';1;34', ';1;32', ';1;36', ';1;31', ';1;35', ';1;33', ';1');

   bgtab:   array[0..15] of string[5] =
      ('',  ';44',   ';42',   ';46',   ';41',   ';45',   ';43',   ';47',
      ';5', ';5;44', ';5;42', ';5;46', ';5;41', ';5;45', ';5;43', ';5;47');

var
   fg:   integer;
   bg:   integer;

begin
   expand_xansi := '';

   bg := ord(xansi[3])-ord('0');
   if bg > 9 then dec(bg,7);

   fg := ord(xansi[4])-ord('0');
   if fg > 9 then dec(fg,7);

   if (fg = 0) and (bg = 0) then
   begin
      SaveColor;
      exit;
   end;

   if (fg = 15) and (bg = 15) then
   begin
      fg := ansi_pcolor and 15;
      bg := ansi_pcolor shr 4;
   end;


   if (fg >= 0) and (fg <= 15) and (bg >= 0) and (bg <= 15) then
      expand_xansi := code_colors('0'+fgtab[fg]+bgtab[bg]);
end;

