
{$r-,s-}

(*
 * EPDJ - Convert epson graphics to DeskJet graphics
 *
 * A post-processor for ORCAD generated print files.
 * S.H.Smith, 19-oct-89
 *
 *)

{$m 10000,10000,10000}

uses dos, mdosio;

const
   version = 'EPDJ - Epson to DeskJet graphics converter (S.H.Smith, 10-26-90)';

type
   rastline = array[1..1000] of char;

   pt = record
      o,s: word;
   end;

var
   image:      array[1..8000] of char;
   imageSz:    integer;

   raster:     array[1..32] of rastline;
   rLine:      integer;

var
   fd:         dos_handle;
   buffer:     array[1..20480] of char;
   bNext:      integer;
   bLast:      integer;

const
   lMargin:    integer = 0;

procedure bRead(var dest: char);
begin
   if bNext > bLast then
   begin
      bLast := dos_read(fd,buffer,sizeof(buffer));
      bNext := 1;
   end;

   dest := buffer[bNext];
   inc(bNext);
end;


procedure mRead(var d; num: integer);
var
   dest: array[1..10000] of char absolute d;
   i:    integer;

begin
   if (bLast-bNext) >= num then
   begin
      move(buffer[bNext],dest[1],num);
      inc(bNext,num);
   end
   else

   for i := 1 to num do
      bRead(dest[i]);
end;


procedure printS(s: string);  {print characters, 3x faster than dos}
var
   reg:  registers;
   i:    integer;
begin
   if s[1] = ^L then
      lMargin := 0;
   for i := 1 to length(s) do
   begin
      reg.ax := ord(s[i]);
      reg.dx := 0;
      intr(23, reg);
   end;
end;


function itoa(i: word): string;
var
   s: string;
begin
   str(i,s);
   itoa := s;
end;


procedure outPix(bit: byte);
var
   i:    integer;
   b:    integer;
   de:   ^char;
var
   dep:  pt absolute de;

begin
   de := @raster[rLine][1];

Inline(
  $8B/$0E/>imageSz/      {   MOV CX,[>imageSz]}
  $8A/$46/<BIT/          {   MOV AL,[BP+<BIT]}
  $BF/>IMAGE/            {   MOV DI,>IMAGE}
  $C4/$76/<DE/           {   LES SI,[BP+<DE]}
                         {NEXT:}
  $83/$F9/$01/           {   CMP CX,1}
  $7E/$5B/               {   JLE LAST}
  $30/$E4/               {   XOR AH,AH}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT0}
                         {BIT1:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT1}
                         {BIT2:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT2}
                         {BIT3:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT3}
                         {BIT4:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT4}
                         {BIT5:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT5}
                         {BIT6:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT6}
                         {BIT7:}
  $47/                   {   INC DI}
  $84/$05/               {   TEST AL,[DI]}
  $75/$2D/               {   JNZ SETBIT7}
                         {BIT8:}
  $47/                   {   INC DI}
  $26/                   {   ES:}
  $88/$24/               {   MOV [SI],AH}
  $46/                   {   INC SI}
  $83/$E9/$08/           {   SUB CX,8}
  $EB/$C8/               {   JMP NEXT}
                         {SETBIT0:}
  $80/$C4/$80/           {   ADD AH,128}
  $EB/$CE/               {   JMP BIT1}
                         {SETBIT1:}
  $80/$C4/$40/           {   ADD AH,64}
  $EB/$CE/               {   JMP BIT2}
                         {SETBIT2:}
  $80/$C4/$20/           {   ADD AH,32}
  $EB/$CE/               {   JMP BIT3}
                         {SETBIT3:}
  $80/$C4/$10/           {   ADD AH,16}
  $EB/$CE/               {   JMP BIT4}
                         {SETBIT4:}
  $80/$C4/$08/           {   ADD AH,8}
  $EB/$CE/               {   JMP BIT5}
                         {SETBIT5:}
  $80/$C4/$04/           {   ADD AH,4}
  $EB/$CE/               {   JMP BIT6}
                         {SETBIT6:}
  $80/$C4/$02/           {   ADD AH,2}
  $EB/$CE/               {   JMP BIT7}
                         {SETBIT7:}
  $80/$C4/$01/           {   ADD AH,1}
  $EB/$CE);              {   JMP BIT8}
                         {LAST:}


(********
   i := 1;
   while i < imageSz do
   begin
      b := 0;
      if (ord(image[i  ]) and bit) <> 0 then inc(b,$80);
      if (ord(image[i+1]) and bit) <> 0 then inc(b,$40);
      if (ord(image[i+2]) and bit) <> 0 then inc(b,$20);
      if (ord(image[i+3]) and bit) <> 0 then inc(b,$10);
      if (ord(image[i+4]) and bit) <> 0 then inc(b,$08);
      if (ord(image[i+5]) and bit) <> 0 then inc(b,$04);
      if (ord(image[i+6]) and bit) <> 0 then inc(b,$02);
      if (ord(image[i+7]) and bit) <> 0 then inc(b,$01);

      de^ := chr(b);
      inc(dep.o);   {inc(c);}
      inc(i,8);
   end;
*********)
end;


procedure convert_bitstream;
var
   c:    char;
   i:    integer;
   b:    integer;

begin
   {determine size of graph segment}
   mRead(imageSz,2);

   {load the pixel image of the graph segment}
   mRead(image[1],imageSz);

   b := $80;
   for i := 1 to 8 do
   begin
      outPix(b);
      b := b shr 1;
      inc(rLine);
   end;
end;


procedure outRast(rl: integer);
var
   i: integer;
   s: integer;
   n: integer;
   c: char;
   sr: ^char;
var
   srp: pt absolute sr;

begin
   n := imageSz div 8;
   s := 1;
   while (raster[rl][s] = #0) and (s < n) do
      inc(s);
   if s=n then exit;

   if lMargin = 0 then
      lMargin := s
   else
      s := lMargin;

   printS(#27'*b'+itoa(n-s+1)+'W');
   sr := @raster[rl][s];

Inline(
  $8B/$4E/<N/            {   MOV CX,[BP+<N]}
  $2B/$4E/<S/            {   SUB CX,[BP+<S]}
  $41/                   {   INC CX}
  $C4/$7E/<SR/           {   LES DI,[BP+<SR]}
                         {NEXT:}
  $26/                   {   ES:}
  $8A/$05/               {   MOV AL,[DI]}
  $47/                   {   INC DI}
  $30/$E4/               {   XOR AH,AH}
  $31/$D2/               {   XOR DX,DX}
  $51/                   {   PUSH CX}
  $55/                   {   PUSH BP}
  $CD/$17/               {   INT 23}
  $5D/                   {   POP BP}
  $59/                   {   POP CX}
  $E2/$F0);              {   LOOP NEXT}

(*******
   for i := s to n do
   begin
      c := sr^;
      inc(srp.o);
      reg.ax := ord(c);
      reg.dx := 0;
      intr(23, reg);
   end;
*******)
end;


procedure convert_linefeed;
var
   c:    char;
   n:    integer;
begin
   {determine space value}
   bRead(c); n := ord(c);
   bRead(c);    {skip the c/r}

   if n = 19 then
   begin
      write('.');
      for n := 0 to 6 do
      begin
         outRast(n+1);
         outRast(n+9);
         outRast(n+17);
      end;

      rLine := 1;
   end
   else

   if n > 19 then
   begin
      write('+');
      for n := 0 to 7 do
      begin
         outRast(n+1);
         outRast(n+9);
         outRast(n+17);
      end;

      rLine := 1;
   end;
end;


var
   name:    string;
   c:       char;

begin
   writeln(version);
   if paramcount <> 1 then
   begin
      writeln('Usage: epdj FILE');
      halt;
   end;

   name := paramstr(1);
   fd := dos_open(name,open_read);
   if fd = dos_error then
   begin
      writeln('Can''t open: ',name);
      halt;
   end;

   printS(#27'E');         {reset printer}
   printS(#27'*t300R');    {resolution 300dpi}
   printS(#27'&l66P');     {page length 66 lines}
   printS(#27'&l3A');      {paper 8.5 x 14}
   printS(#27'*rA');       {print from cursor position}
   rLine := 1;
   bLast := 0;
   bNext := 1;

   repeat
      bRead(c);
      if c = #27 then
      begin
         bRead(c);
         if c = 'Z' then
            convert_bitstream
         else
         if c = 'J' then
            convert_linefeed
         else
         begin
            printS(#27);
            printS(c);
            writeln(' unknown esc ',ord(c));
         end;
      end
      else
         printS(c);
   until bLast = 0;

   printS(#27'*rB');    {end graphics}
   printS(#27'E');      {reset printer}
   writeln;
end.

