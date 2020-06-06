
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
 * dosmem - Dos Memory Management Unit (3-1-89)
 *
 * This unit allocates memory via DOS so you don't have to reserve
 * heap space in advance.
 *
 *)

{$i prodef.inc}

unit DosMem;

interface
   uses DOS;

   type
      pointer_rec = record
         offset:  word;
         segment: word;
      end;

   function dos_maxavail: longint;
   procedure dos_getmem(var ptrvar; size: word);
   procedure dos_freemem(var ptrvar);


implementation

   function dos_maxavail: longint;
   var
      reg:     registers;
   begin
      reg.ah := $48;    {allocate memory}
      reg.bx := $FFFF;  {more than available, force return of freespace}
      msdos(reg);
      dos_maxavail := longint(reg.bx) shl 4;
   end;

   procedure dos_getmem(var ptrvar; size: word);
   var
      block:   pointer_rec absolute ptrvar;
      mem:     ^char;
      reg:     registers;
      need:    word;

   begin

{$IFDEF XDEBUGGING}
      if debugging then
         writeln(debugfd^,'dos_getmem(ptr=',seg(ptrvar),':',ofs(ptrvar),', size=',size,')');
{$ENDIF}

      need := (size+15) div 16;
      fillchar(reg,sizeof(reg),0);
      reg.ah := $48;    {allocate memory}
      reg.bx := need;
      msdos(reg);

      if ((reg.flags and Fcarry) <> 0) and (reg.bx <> need) then
      begin
         write(^M^J'dos_getmem: Can''t allocate ',size,' bytes.'^M^J'Largest available block is ',reg.bx*16,' bytes.');
         halt(99);
      end;

      block.segment := reg.ax;
      block.offset := 0;

      {initialize the memory to all zeros}
      mem := ptr(block.segment,block.offset);
      fillchar(mem^,size,0);
   end;


   procedure dos_freemem(var ptrvar);
   var
      block:   pointer_rec absolute ptrvar;
      reg:     registers;
   begin
      if (block.segment = 0) and (block.offset = 0) then
         exit;

{$IFDEF XDEBUGGING}
      if debugging then
         writeln(debugfd^,'dos_freemem(ptr=',seg(ptrvar),':',ofs(ptrvar),
            ' @',block.segment,':',block.offset,')');
{$ENDIF}

      reg.ah := $49;    {free memory}
      reg.es := block.segment;
      msdos(reg);

{$IFDEF XDEBUGGING}
      if (reg.flags and Fcarry) <> 0 then
      begin
         writeln(debugfd^,'dos_freemem: dispose failure');
         halt(99);
      end;
{$ENDIF}

      block.segment := 0;
      block.offset := 0;
   end;

end.

