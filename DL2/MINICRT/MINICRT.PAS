
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
 * MiniCrt - version of Borland's CRT unit that understands and interprets
 * most ANSI codes.  When OVCRT environment variable exists, the unit
 * does not do direct video, allowing operation under window managers
 * and non-standard display environments.
 *
 *)

{$i prodef.inc}
{$s-,r-}

unit MiniCrt;

interface

   uses DOS, Crt;

   function KeyPressed: Boolean;
   function ReadKey: Char;

   procedure Window(X1,Y1,X2,Y2: Byte);  {only partial support}
   procedure SetScrollPoint(Y2: Byte);
   procedure FullScreen;

   procedure GotoXY(X,Y: Integer);
   procedure BiosGotoxy(x,y: byte);
   procedure HideCursor;

   function WhereX: Byte;
   function WhereY: Byte;

   procedure ClrScr;
   procedure ClrEol;

   procedure NormalVideo;
   procedure LowVideo;
   procedure ReverseVideo;
   procedure BlinkVideo;
   procedure SaveColor;
   procedure RestoreColor;

   procedure AnsiAttributes;
   procedure InterpretAnsi(action: char);

   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   {$F+} function ConOutput(var F: TextRec): integer; {$F-}
   {$F+} function ConOpen(var F: TextRec): Integer; {$F-}

   const
      scroll_line:   byte = 23;
      directVideo:   boolean = true;
      ansi_xtab:     array[0..7] of byte = (0,4,2,6,1,5,3,7);
      ansi_savex:    byte = 1;
      ansi_savey:    byte = 1;
      ansi_pending:  boolean = false;
      max_ansi_stack = 10;

      cursor_moved:  boolean = false;

   var
      ansi_fg:       byte;
      ansi_bg:       byte;
      ansi_stack:    array[1..max_ansi_stack] of byte;
      ansi_depth:    integer;
      ansi_val:      word;
      ansi_digits:   boolean;
      ansi_pcolor:   word;

      crtout:        text;  {output through CRT unit}
      stdout:        text;  {output through dos for ANSI compatibility}


implementation


   (* -------------------------------------------------------- *)
   function ReadKey: Char;
   begin
      readkey := crt.readkey;
   end;

   function KeyPressed: Boolean;
   begin
      keypressed := crt.keypressed;
   end;


   (* -------------------------------------------------------- *)
   procedure Window(X1,Y1,X2,Y2: Byte);
   begin
      crt.window(x1,y1,x2,y2);
   end;

   procedure FullScreen;
   begin
      window(1,1,80,scroll_line+2);
   end;

   procedure SetScrollPoint(Y2: Byte);
   begin
      window(1,1,80,y2);
   end;


   (* -------------------------------------------------------- *)
   procedure GotoXY(X,Y: Integer);
   begin
      if x < 1 then x := 1;
      if y < 1 then y := 1;
      crt.gotoxy(x,y);
   end;


   procedure GotoXY2(X,Y: Integer);
   begin
      minicrt.gotoxy(x,y);
      cursor_moved := true;
   end;


   (* -------------------------------------------------------- *)
   procedure BiosGotoxy(x,y: byte);
   begin
      Inline(
        $B4/$02/               {mov ah,2}
        $31/$DB/               {xor bx,bx}
        $8A/$76/<y/            {mov dh,[bp+<y]}
        $FE/$CE/               {dec dh}
        $8A/$56/<x/            {mov dl,[bp+<x]}
        $FE/$CA/               {dec dl}
        $55/                   {push bp}
        $CD/$10/               {int $10}
        $5D);                  {pop bp}
   end;


   (* -------------------------------------------------------- *)
   procedure HideCursor;
   begin
      BiosGotoxy(1,scroll_line+3);
   end;


   (* -------------------------------------------------------- *)
   function WhereX: Byte;
   begin
      wherex := crt.wherex;
   end;

   function WhereY: Byte;
   begin
      wherey := crt.wherey;
   end;


   (* -------------------------------------------------------- *)
   procedure ClrScr;
   begin
      crt.clrscr;
   end;

   procedure ClrEol;
   begin
      crt.clreol;
   end;


   (* -------------------------------------------------------- *)
   procedure NormalVideo;
   begin
      TextColor(White);
      TextBackground(Black);
   end;

   procedure LowVideo;
   begin
      Textcolor(LightGray);
      TextBackground(Black);
   end;

   procedure ReverseVideo;
   begin
      TextColor(Black);
      TextBackground(White);
   end;

   procedure BlinkVideo;
   begin
      TextColor(Blink+Black);
      TextBackground(White);
   end;

   procedure SaveColor;
   begin
      ansi_pcolor := TextAttr;
   end;

   procedure RestoreColor;
   begin
      TextAttr := ansi_pcolor;
   end;


   (* -------------------------------------------------------- *)
   procedure AnsiAttributes;
   var
      i:       integer;
      bright:  boolean;
      blink:   boolean;
      attr:    byte;

   begin
      bright := (TextAttr and $08) <> 0;
      blink  := (TextAttr and $80) <> 0;

      for i := 1 to ansi_depth do
         case ansi_stack[i] of
            0:       begin
                        ansi_fg := 7;
                        ansi_bg := 0;
                        bright := false;
                        blink := false;
                     end;

            1:       bright := true;
            5:       blink := true;

            30..37:  ansi_fg := ansi_xtab[ansi_stack[i]-30];

            40..47:  ansi_bg := ansi_xtab[ansi_stack[i]-40];
         end;

      if (LastMode = Mono) then
         if ansi_bg < ansi_fg then
            ansi_bg := 0
         else
         if ansi_bg > 0 then
         begin
            ansi_fg := 7;
            ansi_bg := 0;
         end;
      attr := (ansi_bg shl 4) + ansi_fg;

      if bright then inc(attr,$08);
      if blink  then inc(attr,$80);
      TextAttr := attr;
   end;


   (* -------------------------------------------------------- *)
   procedure InterpretAnsi(action: char);

   begin
      case action of
         'A':     gotoxy2(wherex,wherey-ansi_stack[1]);
         'B':     gotoxy2(wherex,wherey+ansi_stack[1]);
         'C':     gotoxy2(wherex+ansi_stack[1],wherey);
         'D':     gotoxy2(wherex-ansi_stack[1],wherey);
         'H','f': gotoxy2(ansi_stack[2],ansi_stack[1]);

         'J':     minicrt.clrscr;
         'K':     minicrt.clreol;

         'm':     AnsiAttributes;

         's':     begin
                     ansi_savex := wherex;
                     ansi_savey := wherey;
                  end;

         'u':     gotoxy2(ansi_savex,ansi_savey);
      end;
   end;


   (* -------------------------------------------------------- *)
   {$F+} function ConFlush(var F: TextRec): integer; {$F-}
   var
      p,q:  integer;
      s:    string;

   label
      continue;

   begin
      if F.BufPos > 0 then
      begin
         {convert buffer to a string}
         s[0] := chr(F.BufPos);
         move(F.BufPtr^[0],s[1],length(s));

(***
if length(s) = 6 then
if s = #27'[0;1m' then
begin
   inc(q);
   dec(q);
end;
****)

         {continue where we left off if an ansi sequence was split
          between output buffers}
         if ansi_pending then
         begin
            q := 1;
            goto continue;
         end;

         {interpret escape sequences, but pass everything else to CRT}
         repeat
            {find next escape code in line}
            p := 0;
            Inline(                  {p := cpos(#27,s);}
              $8D/$BE/>s/            {   lea di,[bp+>s]}
              $B0/$1B/               {   mov al,27}
              $30/$ED/               {   xor ch,ch}
              $36/$8A/$0D/           {   ss: mov cl,[di]}
              $89/$CB/               {   mov bx,cx}
              $47/                   {   inc di}
              $FC/                   {   cld}
              $36/$F2/$AE/           {   ss: repnz scasb}
              $75/$05/               {   jnz notfound}
              $29/$CB/               {   sub bx,cx}
              $89/$5E/<p);           {   mov [bp+<p],bx}
                                     {notfound:}

            if p > 0 then
            begin
               {output the CRT part}
               if p > 1 then
                  {$i-} write(crtout,copy(s,1,p-1)); {$i+}

               fillchar(ansi_stack,sizeof(ansi_stack),1);
               ansi_depth := 0;
               ansi_val := 0;
               ansi_digits := false;
               ansi_pending := true;

               {find end of the ESC sequence}
               q := p+1;
               while ansi_pending and (q < length(s)) do
               begin
                  inc(q);
continue:
                  case s[q] of
                  '0'..'9':   {collect digits}
                     begin
                        ansi_val := 10*ansi_val + ord(s[q])-ord('0');
                        ansi_digits := true;
                     end;

                  ';':        {push current digits on parameter stack}
                     if ansi_depth < max_ansi_stack then
                     begin
                        inc(ansi_depth);
                        if ansi_digits then
                        begin
                           if ansi_val > 255 then ansi_val := 255;
                           ansi_stack[ansi_depth] := ansi_val;
                           ansi_digits := false;
                        end;
                        ansi_val := 0;
                     end;

                  'a'..'z','A'..'Z':   {perform action}
                     begin
                        if (ansi_depth < max_ansi_stack) and ansi_digits then
                        begin
                           inc(ansi_depth);
                           ansi_stack[ansi_depth] := ansi_val;
                        end;

                        InterpretAnsi(s[q]);
                        ansi_pending := false;
                     end;
                  end;
               end;

               {delete the escape sequence from output and check for another}
               delete(s,1,q);
            end;

         until (p=0) or (s='');

         {output remainder (or entire) line through CRT}
         if s <> '' then
            {$i-} write(crtout,s); {$i+}

         F.BufPos:=0;
      end;

      ConFlush := 0;
   end;


   (* -------------------------------------------------------- *)
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
begin
   if (pos('/BIO',GetEnv('PCB')) > 0) or (GetEnv('OVCRT') <> '') then
      directVideo := false;

   crt.directvideo := directvideo;
   ansi_fg := TextAttr and $07;
   ansi_bg := (TextAttr shr 4) and $07;

   {determine scroll line if ega/vga in >25 line modes}
   if directVideo then
      Inline(
        $31/$DB/                 {xor bx,bx}
        $8E/$C3/                 {mov es,bx}
        $26/$F6/$06/$87/$04/$08/ {test byte es:[$487],8}
        $75/$13/                 {jnz noega}
        $B8/$30/$11/             {mov ax,$1130}
        $8A/$16/>scroll_line/    {mov dl,[>scroll_line]}
        $FE/$C2/                 {inc dl}
        $55/                     {push bp}
        $CD/$10/                 {int $10}
        $5D/                     {pop bp}
        $FE/$CA/                 {dec dl}
        $88/$16/>scroll_line);   {mov [>scroll_line],dl}
                               {noega:}

   FullScreen;

   TextRec(output).BufPos    := 0;
   TextRec(output).InOutFunc := @ConOutput;
   TextRec(output).FlushFunc := @ConFlush;
   TextRec(output).OpenFunc  := @ConOpen;

   {$i-}
   assign(stdout,'');
   rewrite(stdout);
   assignCrt(crtout);
   rewrite(crtout);
   {$i+}
end.
