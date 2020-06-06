
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
 * displn - utility library for fast string display
 * Written by Samuel H. Smith, 7-Feb-86 (rev. 23-apr-87)
 *
 *)

const
   low_attr:         integer = 7;
   norm_attr:        integer = 15;
   back_attr:        integer = 0;
   default_disp_seg: integer = $B800;
   slowdisplay:      boolean = false;

type
   popup_string = string[255];

   screenloc =         record
         character:          char;
         attribute:          byte;
   end;
   videoram =          array [0..1999] of screenloc;
   videoptr =          ^videoram;

   window_rec = record
      x1,y1,x2,y2: integer;
      attr:        byte;
   end;

   registers =     record
         ax, bx, cx, dx, bp, si, di, ds, es, flags:         integer;
   end;

var
   cur_window:   window_rec;
   disp_mem:     videoptr;
   disp_seg:     integer;


procedure normvideo;
begin
   textcolor(norm_attr);
   textbackground(back_attr);
   cur_window.attr := norm_attr + back_attr shl 4;
end;

procedure lowvideo;
begin
   textcolor(low_attr);
   textbackground(back_attr);
   cur_window.attr := low_attr + back_attr shl 4;
end;

procedure old_window(x1,y1,x2,y2: integer);  {redefine the old window
                                              command so it can still be
                                              used by other procs}
begin
   window(x1,y1,x2,y2);
end;

procedure window(a1,b1,a2,b2: integer);    {make a new version of window
                                            that saves the current state}
begin
   with cur_window do
   begin
      x1 := a1; y1 := b1;
      x2 := a2; y2 := b2;
      old_window(x1,y1,x2,y2);
   end;
end;

function invisible: boolean;   {is this the invisible program under doubledos?}
var
   reg:  registers;
begin
   reg.ax := $e400;   {doubledos return program status}
   msdos(reg);
   invisible := (lo(reg.ax) = 2) or slowdisplay;
end;


procedure disp (s:                  popup_string);
                                     {very fast dma string display}
var
   index:              integer;
   i:                  integer;
   c:                  char;
   len:                integer;
   max_index:          integer;

begin
   len := ord(s[0]);     {length (s);}

   if invisible or (len < 4) then
                     {can't do dma screens if invisble under doubledos.
                      this is slower than write for short strings}
   begin
      write(s);
      exit;
   end;

   with cur_window do
   begin
      disp_mem := ptr(disp_seg,0);

      index :=(wherey + y1 - 2)* 80 +(wherex + x1 - 2);
      max_index := y2*80;

      for i := 1 to len do
      begin
         c := s [i];

         case c of
            ^H:   index := index - 1;

            ^J:   begin
                     index := index + 80;
                     if index >= max_index then
                     begin
                        write(^J);
                        index := index - 80;
                     end;
                  end;

            ^M:   index := (index div 80)* 80 + x1 - 1;

            ^G:   write(^G);

            else  begin
                     with disp_mem^[index] do
                     begin
                        character := c;
                        attribute := attr;
                     end;

                     index := succ(index);

                     if index >= max_index then
                     begin
                        index := index - 80;
                        writeln;
                     end;
                  end;
         end;
      end;


(* place cursor at end of displayed string *)

      gotoxy((index mod 80)- x1 + 2,(index div 80)- y1 + 2);
   end;
end;

procedure displn(s: popup_string);       {fast display and linefeed}
begin
   disp(s);
   writeln;
end;

procedure init_disp;     {call once before anything else in this library}
begin
   disp_seg := default_disp_seg;   {this needs to check for mono}
   window(1,1,80,25);
   normvideo;
end;

(***** demo main program - delete when this is used as a library ***)

var
   i: integer;

begin
   clrscr;
   for i := 1 to 24 do
   begin
      gotoxy(1,i);
      write(i:2);
      write('--Testing slow string display calls');
   end;

   window(40,5,80,20);
   for i := 1 to 14 do
   begin
      gotoxy(1,i);
      write(i:2);
      write('--Testing slow string display calls');
   end;

   window(1,1,80,25);
   delay(1000);

   init_disp;
   clrscr;

   for i := 1 to 24 do
   begin
      gotoxy(1,i);
      write(i:2);
      disp('--Testing fast string display calls');
   end;

   window(40,5,80,20);
   for i := 1 to 14 do
   begin
      gotoxy(1,i);
      write(i:2);
      disp('--Testing fast string display calls');
   end;

   window(1,1,80,25);
   gotoxy(1,24);
end.


