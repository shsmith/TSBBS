
(*
 * vectmap - map system interrupt vectors
 *
 * author: S. H. Smith,  10-May-86
 *
 *)

type
   vector = record
      offset: word;
      segment: word;
   end;

   anystring = string[40];

var
   inttab: array[0..$FF] of vector absolute 0:0;



function hex(i: word): anystring;
var
  h: anystring;
  d: integer;
  c: char;

begin
   h := '';

   for d := 1 to 4 do
   begin
      if (i and $0f) > 9 then
         c := chr((i and $0f) + ord('0') + 7)
      else
         c := chr((i and $0f) + ord('0'));

      h := c + h;
      i := i shr 4;
   end;

   hex := h;
end;


procedure display_vector(n: integer);
var
   s: word;
   o: word;

begin

{$i-}
   s := inttab[n].segment;
   o := inttab[n].offset;
   if (s = 0) and (o = 0) then
      exit;

   write( copy(hex(n),3,2), '   ',hex(s),':',hex(o),'  ');

   case s of
      $0000:  write(' Int vectors      ');
      $0040:  write(' ROM BIOS data    ');
      $0050:  write(' DOS data         ');
      $0070:  write(' IO.SYS drivers   ');
      else
           if s = $c800 then
              write(' Fixed disk ROM   ')
           else if s = $f000 then
              write(' System ROM       ')
           else if s = $fc00 then
              write(' BIOS ROM         ')
           else if s = cseg then
              write(' User program     ')
           else if s = inttab[$20].segment then
              write(' DOS              ')
           else if s = inttab[$21].segment then
              write(' DOS enhancement  ')
           else if s = inttab[$24].segment then
              write(' COMMAND.COM      ')
           else if (s < cseg) and (s > inttab[$20].segment) then
              write(' Resident utility ')
           else
              write(' ?                ');
   end;


   case n of
      $00:  write(' Division by zero');
      $01:  write(' Single step');
      $02:  write(' Non-maskable interrupt');
      $03:  write(' DEBUG breakpoint');
      $04:  write(' Arithmetic overflow');
      $05:  write(' Print screen');
      $08:  write(' Hardware clock tick');
      $09:  write(' Keyboard action');
      $0b:  write(' COM2 async port');
      $0c:  write(' COM1 async port');
      $0d:  write(' Vertical retrace');
      $0e:  write(' Diskette attention (completion)');
      $0f:  write(' Printer control');
      $10:  write(' Video display services');
      $11:  write(' Equipment list services');
      $12:  write(' Memory size services');
      $13:  write(' Diskette services');
      $14:  write(' Communication services');
      $15:  write(' Cassette tape services');
      $16:  write(' Standard keyboard services');
      $17:  write(' Printer services');
      $18:  write(' Activate ROM basic');
      $19:  write(' Boot-strap start-up');
      $1a:  write(' Time and date services');
      $1b:  write(' Keyboard break handler');
      $1c:  write(' Clock tick handler');
      $1d:  write(' Video control parameter table');
      $1e:  write(' Disk base table');
      $1f:  write(' High video graphics character table');
      $20:  write(' DOS program terminate service');
      $21:  write(' DOS function call services');
      $22:  write(' User program terminate handler');
      $23:  write(' User keyboard break handler');
      $24:  write(' User critical error handler');
      $25:  write(' DOS absolute disk read');
      $26:  write(' DOS absolute disk write');
      $27:  write(' DOS terminate and stay resident');
      $28..$2F:
            write(' Unknown DOS interrupt');
      $41:  write(' Hard disk 0 parameter table');
      $44:  write(' Low video graphics character table');
      $46:  write(' Hard disk 1 parameter table');
      $48:  write(' Translate PCjr keyboard');
      $49:  write(' Keyboard-supplement device translation table');
      $4a:  write(' User alarm');
      $50:  write(' CMOS timer interrupt');

      else  write(' ?');
   end;

   writeln;
   flush(output);
{$i+}

end;


var
   int:       integer;


begin

{$i-}
   writeln;
   write('VECTMAP - Map of system interrupt vectors');
   writeln('             11-10-88, S.H.Smith');
   writeln;

   writeln;
   writeln('Int   Handler        Handler             Interrupt');
   writeln('no    address      description          description');
   writeln('---  ---------   ---------------   ----------------------');
{$i+}


   for int := 0 to $ff do
      display_vector(int);
end.
