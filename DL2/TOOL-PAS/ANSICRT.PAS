
(*
 * ansiCrt - unit to replace some functions of Borland's CRT using
 *           ansi codes instead of bios calls
 *
 * (C) 1989 Samuel H. Smith
 *
 *)

unit ansiCrt;

interface

   const
      Black         = 18;        DarkGray      = 18;
      Red           = 1;         LightRed      = 11;
      Green         = 2;         LightGreen    = 12;
      Brown         = 3;         Yellow        = 13;
      Blue          = 4;         LightBlue     = 14;
      Magenta       = 5;         LightMagenta  = 15;
      Cyan          = 6;         LightCyan     = 16;
      LightGray     = 7;         White         = 17;


   procedure gotoxy(x,y: integer);
   procedure textColor(c: byte);
   procedure textBackground(c: byte);
   procedure highvideo;
   procedure lowvideo;
   procedure normvideo;
   procedure clrscr;
   procedure clreol;
   function keypressed: boolean;
   function readkey: char;
   procedure delay(ms: longint);



implementation

   procedure gotoxy(x,y: integer);
   begin
      write(#27'[' , y , ';' , x , 'f');
   end;

   procedure textColor(c: byte);
   begin
      if c > 9 then
      begin
         write(#27'[0;1m');
         dec(c,10);
      end
      else
         write(#27'[0m');

      write(#27'[3',c,'m');
   end;

   procedure textBackground(c: byte);
   begin
   end;

   procedure highvideo;
   begin
      write(#27'[1m');
   end;

   procedure lowvideo;
   begin
      write(#27'[0m');
   end;

   procedure normvideo;
   begin
      write(#27'[1m');
   end;

   procedure clrscr;
   begin
      write(#27'[2J');
   end;

   procedure clreol;
   begin
      write(#27'[K');
   end;

   function keypressed: boolean;
   begin
      keypressed := false;
   end;

   function readkey: char;
   begin
      readkey := '?';
   end;

   procedure delay(ms: longint);
   begin
   end;

end.

