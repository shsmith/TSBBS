
(*
 * EasyDJ - Convert AS-EASY-AS graphics to DeskJet graphics
 *
 * S.H.Smith, 19-oct-89 (13-nov-89)
 *
 *)

{$undef test}

{$ifdef test}
   {$r+,s-}
{$else}
   {$r-,s-}
{$endif}

{$m 10000,1000,1000}

uses dos, mdosio;

const
   leadpix = 120;    {left margin in pixels}

type
   rastline = array[1..1100] of char;

   pt = record
      o,s: word;
   end;

var
   image:      array[1..1000] of char;
   imagesz:    integer;

   raster:     array[1..34] of rastline;
   rline:      integer;

   fd:         dos_handle;
   buffer:     array[1..10240] of char;
   bnext:      integer;
   blast:      integer;



(* -------------------------------------------------------- *)
procedure bread(var dest: char);
begin
   if bnext > blast then
   begin
      blast := dos_read(fd,buffer,sizeof(buffer));
      bnext := 1;
   end;

   dest := buffer[bnext];
   inc(bnext);
end;


(* -------------------------------------------------------- *)
procedure mread(var d; num: integer);
var
   dest: array[1..10000] of char absolute d;
   i:    integer;

begin
   if (blast-bnext) >= num then
   begin
      move(buffer[bnext],dest[1],num);
      inc(bnext,num);
   end
   else

   for i := 1 to num do
      bread(dest[i]);
end;


(* -------------------------------------------------------- *)
procedure printc(s: string);  {print characters, 3x faster than dos}
var
   reg:  registers;
   i:    integer;
begin
{$ifndef test}
   for i := 1 to length(s) do
   begin
      reg.ax := ord(s[i]);
      reg.dx := 0;
      intr(23, reg);
   end;
{$endif}
end;


(* -------------------------------------------------------- *)
function itoa(i: word): string;
var
   s: string;
begin
   str(i,s);
   itoa := s;
end;


(* -------------------------------------------------------- *)
procedure outpix(bit: byte);
var
   i:    integer;
   b:    integer;
   de:   ^char;
var
   dep:  pt absolute de;

begin
   de := @raster[rline][1];

Inline(
  $8B/$0E/>IMAGESZ/      {   MOV CX,[>IMAGESZ]}
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
   while i < imagesz do
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


(* -------------------------------------------------------- *)
procedure convert_bitstream;
var
   c:    char;
   i:    integer;
   b:    integer;
   sz:   word;

begin
   {determine size of graph segment}
   mread(sz,2);
   if sz+8{?} > imagesz then
      imagesz := sz+8{?};

{writeln('imagesz=',imagesz);}

   if imagesz > sizeof(image) then
   begin
      writeln('image too large; imagesz=',imagesz,' allocated=',sizeof(image));
      halt;
   end;

   {load the pixel image of the graph segment}
   fillchar(image,sizeof(image),0);
   mread(image[1],sz);

   b := $80;
   for i := 1 to 8 do
   begin
      outpix(b);
      b := b shr 1;
      inc(rline);
   end;
end;


(* -------------------------------------------------------- *)
procedure outrast(rl: integer);
var
   i: integer;
   s: integer;
   n: integer;
   c: char;
   sr: ^char;
var
   srp: pt absolute sr;
const
   skip: integer = 0;

begin
   n := imagesz div 8;
   s := 1;
   while (raster[rl][s] = #0) and (s < n) do
      inc(s);
   if s=n then exit;

{  if (skip = 0) then
      skip := s
   else
      s := skip; }
s := 1;

   printc(#27'*b'+itoa(n-s+1+(leadpix div 8))+'W');
   sr := @raster[rl][s];
   if n > sizeof(rastline) then
   begin
      writeln('n(',n,') > ',sizeof(rastline));
      halt;
   end;

   for i := 1 to leadpix div 8 do
      printc(#0);

{$ifndef test}
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
{$endif}

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


(* -------------------------------------------------------- *)
procedure convert_linefeed;
var
   c:    char;
   n:    integer;
begin
   {determine space value}
   bread(c); n := ord(c);
   bread(c);    {skip the c/r}

   if n = 19 then
   begin
      write('.');
      for n := 0 to 6 do
      begin
         outrast(n+1);
         outrast(n+9);
         outrast(n+17);
      end;

      rline := 1;
      {imagesz := 0;}
   end
   else

   if n > 19 then
   begin
      write('+');
      for n := 0 to 7 do
      begin
         outrast(n+1);
         outrast(n+9);
         outrast(n+17);
      end;

      rline := 1;
      {imagesz := 0;}
   end;
end;


(* -------------------------------------------------------- *)
procedure outlrast;
var
   n:    integer;
begin
   write('.');
   for n := 0 to 7 do
   begin
      outrast(n+1);
      outrast(n+9);
      if rline > 17 then
         outrast(n+17);
   end;

   rline := 1;
   {imagesz := 0;}
   fillchar(raster,sizeof(raster),0);
end;


(* -------------------------------------------------------- *)
procedure convert_vspace;
var
   c:    char;
   n:    integer;
begin
   {determine space value}
   bread(c);
   n := ord(c);

{$ifdef test}
   writeln('n=',n,' imagesz=',imagesz);
{$endif}

   if (n = 22) and (rline > 1) then
      outlrast;
end;

(* -------------------------------------------------------- *)

var
   name:    string;
   c:       char;

begin
   if paramcount <> 1 then
   begin
      writeln('Usage: EasyDJ FILE');
      halt;
   end;

   name := paramstr(1);
   fd := dos_open(name,open_read);
   if fd = dos_error then
   begin
      writeln('Can''t open: ',name);
      halt;
   end;

   printc(#27'E');         {reset printer}
   printc(#27'*t150R');    {resolution 300dpi}
   printc(#27'&l66P');     {page length 66 lines}
   printc(#27'&l3A');      {paper 8.5 x 14}
   printc(#27'*rA');       {print from cursor position}
   rline := 1;
   blast := 0;
   bnext := 1;
   imagesz := 0;

   repeat
      bread(c);
      if c = #27 then
      begin
         bread(c);
{$ifdef test}
         write('blast=',blast:4,' ');
         write('esc ',c,' ');
{$endif}
         if (c = 'Z') or (c = 'L') then
            convert_bitstream
         else
         if c = 'J' then
            convert_linefeed
         else
         if c = '3' then
            convert_vspace
         else
         if c = '@' then
            outlrast
         else
         begin
          { printc(#27);
            printc(c); }
            writeln(' unknown esc ',ord(c));
         end;
      end
      else

      if (c = ' ') or (c = #10) or (c = #13) then

      else
         printc(c);

   until blast = 0;

   printc(#27'*rB');    {end graphics}
   printc(#27'E');      {reset printer}
   writeln;
end.

