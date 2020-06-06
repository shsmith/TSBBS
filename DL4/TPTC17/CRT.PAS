
(*
 * Simplified version of Borland's CRT unit. Does not EVER do
 * direct video.  The standard crt unit locks up multi-taskers with its
 * direct video checking before the user program can turn it off.
 *
 * Samuel H. Smith, 20-dec-87 (rev. 5-01-88)
 *
 *)

unit Crt;

{$S-,I-,R-}

interface
   uses Dos;

   const
     { CRT modes }
     BW40          = 0;            { 40x25 B/W on Color Adapter }
     CO40          = 1;            { 40x25 Color on Color Adapter }
     BW80          = 2;            { 80x25 B/W on Color Adapter }
     CO80          = 3;            { 80x25 Color on Color Adapter }
     Mono          = 7;            { 80x25 on Monochrome Adapter }
     Font8x8       = 256;          { Add-in for ROM font }

     { Mode constants for 3.0 compatibility }
     C40           = CO40;
     C80           = CO80;

     { Foreground and background color constants }
     Black         = 0;
     Blue          = 1;
     Green         = 2;
     Cyan          = 3;
     Red           = 4;
     Magenta       = 5;
     Brown         = 6;
     LightGray     = 7;

     { Foreground color constants }
     DarkGray      = 8;
     LightBlue     = 9;
     LightGreen    = 10;
     LightCyan     = 11;
     LightRed      = 12;
     LightMagenta  = 13;
     Yellow        = 14;
     White         = 15;

     { Add-in for blinking }
     Blink         = 128;

   var
      CheckBreak:   Boolean;   { Enable Ctrl-Break }
      CheckEOF:     Boolean;   { Enable Ctrl-Z }
      DirectVideo:  Boolean;   { Enable direct video addressing }
      CheckSnow:    Boolean;   { Enable snow filtering }
      LastMode:     Word;      { Current text mode }
      TextAttr:     Byte;      { Current text attribute }
      WindMin:      Word;      { Window upper left coordinates }
      WindMax:      Word;      { Window lower right coordinates }
      KeyPending:   char;      { Used to parse function/extended keys }


   function KeyPressed: Boolean;
   function ReadKey: Char;

   procedure Window(X1,Y1,X2,Y2: Byte);
   procedure GotoXY(X,Y: Byte);
   function WhereX: Byte;
   function WhereY: Byte;
   procedure ClrScr;
   procedure ClrEol;
   procedure ScrollUp;

   procedure NormVideo;
   procedure LowVideo;
   procedure HighVideo;
   procedure TextColor( a: byte );
   procedure TextBackground( a: byte );
   procedure TextMode( m: byte );

   procedure Delay(ms: word);


(* -------------------------------------------------------- *)
implementation


   (* -------------------------------------------------------- *)
   function ReadKey: Char;
   var
      reg: registers;
   begin
      if KeyPending <> #0 then
      begin
         ReadKey := KeyPending;
         KeyPending := #0;
         exit;
      end;

      reg.ax := $0000;   {wait for character}
      intr($16,reg);

      if reg.al = 0 then
         KeyPending := chr(reg.ah);

      ReadKey := chr(reg.al);
   end;


   (* -------------------------------------------------------- *)
   function KeyPressed: Boolean;
   var
      reg: registers;
   begin
      reg.ax := $0100;   {check for character}
      intr($16,reg);
      KeyPressed := ((reg.flags and FZero) = 0) or (KeyPending <> #0);
   end;


   (* -------------------------------------------------------- *)
   procedure Window(X1,Y1,X2,Y2: Byte);
   begin
      WindMin := (X1 + Y1 shl 8) - $0101;
      WindMax := (X2 + Y2 shl 8) - $0101;
      GotoXY(1,1);
   end;


   (* -------------------------------------------------------- *)
   procedure GotoXY(X,Y: Byte);
   var
      reg: registers;
   begin
      dec(x);
      dec(y);
      reg.ah := 2;   {set cursor position}
      reg.bh := 0;   {page}
      reg.dx := x + (y shl 8) + WindMin;
      intr($10,reg);
   end;


   (* -------------------------------------------------------- *)
   function WhereX: Byte;
   var
      reg: registers;
   begin
      reg.ah := 3;
      reg.bh := 0;
      intr($10,reg);
      WhereX := reg.dl-lo(WindMin)+1;
   end;

   function WhereY: Byte;
   var
      reg: registers;
   begin
      reg.ah := 3;
      reg.bh := 0;
      intr($10,reg);
      WhereY := reg.dh-hi(WindMin)+1;
   end;


   (* -------------------------------------------------------- *)
   procedure ClrScr;
   var
      reg: registers;
   begin
      reg.ah := 6;       {scroll up}
      reg.al := 0;       {blank window}
      reg.cx := WindMin; {upper left}
      reg.dx := WindMax; {lower line}
      reg.bh := TextAttr;
      intr($10,reg);
      GotoXY(1,1);
   end;


   (* -------------------------------------------------------- *)
   procedure ClrEol;
   var
      reg: registers;
   begin
      {get present cursor position}
      reg.ah := 3;
      reg.bh := 0;
      intr($10,reg);
      reg.cx := reg.dx;

      reg.ah := 6;  {scroll up}
      reg.al := 0;  {blank window}
      reg.dl := lo(WindMax); {end of line}
      reg.bh := TextAttr;
      intr($10,reg);
   end;


   (* -------------------------------------------------------- *)
   procedure NormVideo;
   begin
      TextAttr := $0f;
   end;
   procedure LowVideo;
   begin
      TextAttr := $07;
   end;
   procedure HighVideo;
   begin
      TextAttr := $0f;
   end;

   procedure TextColor( a: byte );
   begin
      TextAttr := (TextAttr and $F0) or a;
   end;

   procedure TextBackground( a: byte );
   begin
      TextAttr := (TextAttr and $0F) or (a shl 4);
   end;

   procedure TextMode( m: byte );
   begin
      LastMode := m;
   end;


   (* -------------------------------------------------------- *)
   procedure Delay(ms: word);
   var
      i: word;
   begin
      while ms > 0 do
      begin
         for i := 1 to 123 do;
         dec(ms);
      end;
   end;


   (* -------------------------------------------------------- *)
   procedure ScrollUp;
   var
      reg: registers;
   begin
      reg.ah := 6;       {scroll up}
      reg.al := 1;       {lines}
      reg.cx := WindMin; {upper left}
      reg.dx := WindMax; {lower right}
      reg.bh := TextAttr;
      intr($10,reg);
   end;


   (* -------------------------------------------------------- *)
begin
   DirectVideo := false;
   CheckSnow := false;
   CheckBreak := false;
   CheckEOF := false;
   KeyPending := #0;
   NormVideo;
   Window(1,1,80,25);
end.

