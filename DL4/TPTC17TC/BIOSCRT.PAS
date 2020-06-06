
(*
 * MiniCrt - simplified version of Borland's CRT unit.
 * Does not EVER do direct video.  The standard crt unit
 * locks up multi-taskers with its direct video checking before
 * the user program can turn it off.
 *
 * Samuel H. Smith, 20-dec-87
 *
 *)

{$D-}

unit BiosCrt;

{$S-,I-,R-}

interface
   uses Dos,Crt;

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
      crtfd:        text;
      CheckBreak:   Boolean;   { Enable Ctrl-Break }
      CheckEOF:     Boolean;   { Enable Ctrl-Z }
      DirectVideo:  Boolean;   { Enable direct video addressing }
      DirectSave:   Boolean;   { Copy of original CRT.DirectVideo }
      CheckSnow:    Boolean;   { Enable snow filtering }
      LastMode:     Word;      { Current text mode }
      TextAttr:     Byte;      { Current text attribute }
      WindMin:      Word;      { Window upper left coordinates }
      WindMax:      Word;      { Window lower right coordinates }
      KeyPending:   char;      { Used to parse function/extended keys }

   function KeyPressed: Boolean;
   function ReadKey: Char;

   procedure Window(X1,Y1,X2,Y2: Byte);  {only partial support}

   procedure GotoXY(X,Y: Byte);
   function WhereX: Byte;
   function WhereY: Byte;

   procedure ClrScr;
   procedure ClrEol;

   procedure NormVideo;
   procedure TextColor( a: byte );
   procedure TextBackground( a: byte );
   procedure TextMode(m: word);

   procedure Delay(ms: word);

   procedure AssignCrt(var fd: text);


   (* -------------------------------------------------------- *)
   procedure ScrollUp;
   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   {$F+} function ConOutput(var F: TextRec): integer; {$F-}
   {$F+} function ConOpen(var F: TextRec): Integer; {$F-}


(* -------------------------------------------------------- *)
implementation


   (* -------------------------------------------------------- *)
   procedure update_crt;
   begin
      crt.DirectVideo := DirectVideo;
      crt.CheckSnow   := CheckSnow;
      crt.CheckBreak  := CheckBreak;
      crt.CheckEOF    := CheckEOF;
   end;


   (* -------------------------------------------------------- *)
   function ReadKey: Char;
   var
      reg: registers;
   begin
      crt.DirectVideo := DirectVideo;
      if DirectVideo then
      begin
         ReadKey := crt.ReadKey;
         exit;
      end;

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
      update_crt;
      if DirectVideo then
      begin
         KeyPressed := crt.KeyPressed;
         exit;
      end;

      reg.ax := $0100;   {check for character}
      intr($16,reg);
      KeyPressed := ((reg.flags and FZero) = 0) or (KeyPending <> #0);
   end;


   (* -------------------------------------------------------- *)
   procedure Window(X1,Y1,X2,Y2: Byte);
   begin
      update_crt;
      if DirectVideo then
      begin
         crt.Window(x1,y1,x2,y2);
         exit;
      end;

      WindMin := (X1 + Y1 shl 8) - $0101;
      WindMax := (X2 + Y2 shl 8) - $0101;
      GotoXY(1,1);
   end;


   (* -------------------------------------------------------- *)
   procedure GotoXY(X,Y: Byte);
   var
      reg: registers;
   begin
      update_crt;
      if DirectVideo then
      begin
         crt.GotoXY(x,y);
         exit;
      end;

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
      update_crt;
      if DirectVideo then
      begin
         WhereX := crt.WhereX;
         exit;
      end;

      reg.ah := 3;
      reg.bh := 0;
      intr($10,reg);
      WhereX := reg.dl-lo(WindMin)+1;
   end;

   function WhereY: Byte;
   var
      reg: registers;
   begin
      update_crt;
      if DirectVideo then
      begin
         WhereY := crt.WhereY;
         exit;
      end;

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
      update_crt;
      if DirectVideo then
      begin
         crt.ClrScr;
         exit;
      end;

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
      update_crt;
      if DirectVideo then
      begin
         crt.ClrEol;
         exit;
      end;

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
      update_crt;
      if DirectVideo then
         crt.NormVideo;
      TextAttr := $0f;
   end;

   procedure TextColor( a: byte );
   begin
      update_crt;
      if DirectVideo then
         crt.TextColor(a);
      TextAttr := (TextAttr and $F0) or a;
   end;

   procedure TextBackground( a: byte );
   begin
      update_crt;
      if DirectVideo then
         crt.TextBackground(a);
      TextAttr := (TextAttr and $0F) or (a shl 4);
   end;

   procedure TextMode(m: word);
   begin
      update_crt;
      if DirectVideo then
         crt.TextMode(m);
      LastMode := m;
   end;


   (* -------------------------------------------------------- *)
   procedure Delay(ms: word);
   var
      i: word;
   begin
      update_crt;
      if DirectVideo then
         crt.Delay(ms)
      else
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
   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   var
      P:   Word;
      reg: registers;
      x,y: byte;
      s:   string;

   begin
      update_crt;
      if DirectVideo then
      begin
         Move(F.BufPtr^,s[1],F.BufPos);
         s[0] := chr(F.BufPos);
         F.BufPos := 0;
         write(crtfd,s);
         ConFlush := 0;
         exit;
      end;

      {get present cursor position}
      reg.ah := 3;
      reg.bh := 0;
      intr($10,reg);
      y := reg.dh+1;
      x := reg.dl+1;

      {process each character in the buffer}
      P := 0;
      while P < F.BufPos do
      begin
         reg.al := ord(F.BufPtr^[P]);

         case reg.al of
             7:  write(crtfd,^G);

             8:  if x <= lo(WindMin)+1 then
                 begin
                    dec(y);
                    x := lo(WindMax)+1;
                 end
                 else
                    dec(x);

            10:  if y > hi(WindMax) then   {scroll when needed}
                    ScrollUp
                 else
                    inc(y);

            13:  x := lo(WindMin)+1;

            else 
            begin
                 reg.ah := 9;  {display character with TextAttr}
                 reg.bx := 0;  {... does not move the cursor}
                 reg.cx := 1;
                 reg.bl := TextAttr;
                 intr($10,reg);

                 if x > lo(WindMax) then   {line wrap?}
                 begin
                    if y > hi(WindMax) then   {scroll during wrap?}
                       ScrollUp
                    else
                       inc(y);
                    x := lo(WindMin)+1;
                 end
                 else
                    inc(x);
            end;
         end;

         {position physical cursor}
         reg.ah := 2;   {set cursor position}
         reg.bh := 0;   {page}
         reg.dh := y-1;
         reg.dl := x-1;
         intr($10,reg);

         inc(P);
      end;

      F.BufPos:=0;
      ConFlush := 0;
   end;


   {$F+} function ConOutput(var F: TextRec): integer; {$F-}
   begin
      ConOutput := ConFlush(F);
   end;


   {$F+} function ConOpen(var F: TextRec): Integer; {$F-}
   begin
      F.InOutFunc := @ConOutput;
      F.FlushFunc := @ConFlush;
      F.CloseFunc := @ConFlush;
      F.BufPos := 0;
      ConOpen := 0;
   end;


   (* -------------------------------------------------------- *)
   procedure AssignCrt(var fd: text);
   begin
      with TextRec(fd) do
      begin
         InOutFunc := @ConOutput;
         FlushFunc := @ConFlush;
         OpenFunc  := @ConOpen;
         BufPos := 0;
      end;
   end;


   (* -------------------------------------------------------- *)

begin
   {set local variables according to what CRT initially wants}
   DirectSave  := crt.DirectVideo;
   DirectVideo := crt.DirectVideo;
   CheckSnow   := crt.CheckSnow;
   CheckBreak  := crt.CheckBreak;
   CheckEOF    := crt.CheckEOF;

   DirectVideo := false;        {use local functions for initialization}
   KeyPending := #0;
   AssignCrt(output);
   rewrite(output);
   crt.AssignCrt(crtfd);
   rewrite(crtfd);
   NormVideo;
   Window(1,1,80,25);

   DirectVideo := DirectSave;
   update_crt;
end.

