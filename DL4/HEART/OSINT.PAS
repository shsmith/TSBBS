
(* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * OPERATING SYSTEM INTERFACES
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *)

unit osint;

interface
   function time: real;
   function timeText: string;
   procedure normvideo;
   procedure highvideo;
   function screenlines: integer;

implementation
   uses crt, dos;

   {time - read time-of-day (in seconds since midnight) from system clock}
   function time: real;
   var
      hours, mins, secs:  real;
      reg:                registers;
   begin
      reg.ax := $2c00;
      msdos(reg);
      hours := int(hi(reg.cx));
      mins  := int(lo(reg.cx));
      secs  := int(hi(reg.dx)) + int(lo(reg.dx))/100.0;
      time  := secs + (mins*60.0) + (hours*3600.0);
   end;

   {read system clock and format into HH:MM:SS time of day string}
   function timeText: string;
      function itoa(i: integer): string;
      begin
         itoa := chr(((i div 10) mod 10)+ord('0'))+chr((i mod 10)+ord('0'));
      end;
   var
      reg:     registers;
   begin
      reg.ax := $2c00;
      msdos(reg);
      timeText := itoa(hi(reg.cx))+':'+itoa(lo(reg.cx))+':'+itoa(hi(reg.dx));
   end;

   {normal and highlighted video}
   procedure normvideo;
   begin
      textcolor(white);
   end;

   procedure highvideo;
   begin
      textcolor(lightgray);
   end;

   {determine number of lines in current video mode}
   const
      scroll_line: byte = 25;  {must be in data segment}

   function screenlines: integer;
   begin
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
        $88/$16/>scroll_line     {mov [>scroll_line],dl}
                               {noega:}
      );
      screenlines := scroll_line+2;
   end;

end.


