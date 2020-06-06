
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

   (* -------------------------------------------------------- *)
   function ReadKey: Char;
   var
      reg: registers;
   begin
      reg.ax := $0700;   {direct console input}
      msdos(reg);
      ReadKey := chr(reg.al);
   end;


   (* -------------------------------------------------------- *)
   function KeyPressed: Boolean;
   var
      reg: registers;
   begin
      reg.ax := $0b00;   {ConInputStatus}
      msdos(reg);
      KeyPressed := (reg.al = $FF);
   end;

