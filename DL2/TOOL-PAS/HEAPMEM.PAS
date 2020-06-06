
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
 * HeapMem - Heap Memory Management Unit (heap version of DosMem) (3-1-89)
 *
 *)

{$r-,s-}

unit HeapMem;

interface
   uses DOS;

   type
      wordarray = array[1..2] of word;
      wordptr = ^wordarray;

   procedure dos_getmem(var ptrvar; size: word);
   procedure dos_freemem(var ptrvar);


implementation

   procedure dos_getmem(var ptrvar; size: word);
   var
      msize:   wordptr absolute ptrvar;
   begin
      {writeln('getmem ',size);}
      getmem(msize, size+2);
      msize^[1] := size+2;
      msize := @msize^[2];
   end;

   procedure dos_freemem(var ptrvar);
   var
      msize:   wordptr absolute ptrvar;
      i:       integer;
   begin
      i := 0;
      msize := @msize^[i];
      {writeln('freemem ',msize^[1]);}
      freemem(msize,msize^[1]);
   end;

end.

