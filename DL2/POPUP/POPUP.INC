
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
 * popup - utility library for simple "pop-up" windows (3-1-89)
 *
 *)

const
   low_attr:  integer = 7;
   norm_attr: integer = 15;
   back_attr: integer = 0;

   slowdisplay:      boolean = false;
   default_disp_seg: integer = $B800;

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

   window_save_rec = record
      win:      window_rec;
      scr:      videoram;
      cux,cuy:  integer;
   end;


var
   cur_window:   window_rec;
   saved_window: window_save_rec;
   disp_mem:     videoptr;
   disp_seg:     integer;


procedure determine_video_ptr;     {determine video display area when
                                    running under DESQview - also works
                                    without DESQview}
const
   video_ptr_known: boolean = false;
begin

{   if video_ptr_known then exit; }

   disp_seg := default_disp_seg;

   inline( $55/                    {push bp}
           $a1/disp_seg/           {mov ax,[disp_seg]}
           $8e/$c0/                {mov es,ax}
           $bf/$00/$00/            {mov di,0}
           $b4/$fe/                {mov ah,fe}
           $cd/$10/                {int 10h}
           $5d/                    {pop bp}
           $8c/$06/disp_seg);      {mov [disp_seg],es}

   disp_mem := ptr(disp_seg,0);
   video_ptr_known := true;
end;


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



procedure old_window(win: window_rec);   {redefine the old window
                                          command so it can still be
                                          used by other procs}
begin
   with win do
      window(x1,y1,x2,y2);
end;



procedure window(a1,b1,a2,b2: integer);    {make a new version of window
                                            that saves the current state}
begin
   determine_video_ptr;

   with cur_window do
   begin
      x1 := a1;
      y1 := b1;
      x2 := a2;
      y2 := b2;
   end;

   old_window(cur_window);
end;



function make_string(c: char; len: integer): popup_string;
                                   {make a string by repeating
                                    a character n times}
var
   i:  integer;
   s:  popup_string;
begin
   for i := 1 to len do
      s[i] := c;

   s[0] := chr(len);
   make_string := s;
end;



function invisible: boolean;   {is this the invisible program under doubledos?}
var
   reg:  registers;

begin
   determine_video_ptr;

   reg.ax := $e400;   {doubledos return program status}
   msdos(reg);

   if (lo(reg.ax) = 2) or slowdisplay then
      invisible := true
   else
      invisible := false;
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


   if invisible or (length(s) < 4) then
                     {can't do dma screens if invisble under doubledos.
                      this is slower than write for short strings}
   begin
      write(s);
      exit;
   end;


   with cur_window do
   begin
      len := length (s);
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

            ^M:   index :=(index div 80)* 80 + x1 - 1;

            ^G:   write(^G);

            else  begin
                     with disp_mem^[index] do
                     begin
                        character := c;
                        attribute := attr;
                     end;

                     index := index + 1;

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



procedure open_pop_up(x1,y1,x2,y2: integer; title: popup_string);
                                            {open a titled pop up window
                                             and save previous screen
                                             state so it can be restored}
const
   topleft =           #213;
   topright =          #184;
   botleft =           #212;
   botright =          #190;
   sides =             #179;
   tops =              #205;

var
   i,
   j:                  integer;
   side:               popup_string;
   top:                popup_string;
   bottom:             popup_string;

begin

(* save the current window so it can be restored later *)
   determine_video_ptr;
   saved_window.scr := disp_mem^;
   saved_window.win := cur_window;
   saved_window.cux := wherex;
   saved_window.cuy := wherey;
   window(1,1,80,25);


(* create window section strings *)
   if title <> '' then
      title := ' ' + title + ' ';
                              {leave spaces around the title, if any}


(* top of frame *)
   top := make_string (tops, x2 - length (title)- x1 - 2) + topright;


(* sides of frame *)
   side := '';
   j := 1;

   for i :=(y1 + 1) to (y2 - 1) do
   begin
      side[j]:= sides;
      side[j + 1]:=^H;
      side[j + 2]:=^J;
      j := j + 3;
   end;

   side[0]:= chr (j - 1);


(* bottom of frame *)
   bottom := botleft + make_string (tops, x2 - x1 - 1)+ botright;


(* draw the frame *)
   gotoxy(x1, y1);
   disp(topleft + tops + title + top);

   gotoxy(x1, y1 + 1);
   disp(side);

   gotoxy(x2, y1 + 1);
   disp(side);

   gotoxy(x1, y2);
   disp(bottom);

(* define the new window.  let the caller decide if it needs clearing *)
   window(x1+1,y1+1,x2-1,y2-1);

end;



procedure remove_pop_up;        {restore the screen like it was
                                 before the popup window was opened}
begin

(* restore the windowing settings *)
   cur_window := saved_window.win;
   old_window(cur_window);

(* restore the cursor position *)
   gotoxy(saved_window.cux,saved_window.cuy);

(* restore the display contents *)
   disp_mem^ := saved_window.scr;

(* restore current video mode *)
   if cur_window.attr = low_attr then
      lowvideo
   else
      normvideo;
end;


procedure preserve_screen(name: popup_string);
                                {preserve contents in a named file}
var
   fd:  file of window_save_rec;

begin
   if invisible then
      exit;

   assign(fd,name);
{$I-}
   rewrite(fd);
{$I+}
   if ioresult = 0 then
   begin
      open_pop_up(1,1,5,5,'');
      remove_pop_up;
      write(fd,saved_window);
      close(fd);
   end;
end;


procedure restore_screen(name: popup_string);
                               {restore a preserved screen from a file;
                                don't touch screen if file is missing}
var
   fd:  file of window_save_rec;

begin
   if invisible then
      exit;

   assign(fd,name);
{$I-}
   reset(fd);
{$I+}
   if ioresult = 0 then
   begin
      read(fd,saved_window);
      close(fd);
      remove_pop_up;
   end;

end;


procedure init_pop_up;   {call once before anything else in this library}
begin
   window(1,1,80,25);
   normvideo;
end;

