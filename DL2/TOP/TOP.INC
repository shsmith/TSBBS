
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
 * top - utility library for simple "pull-down" windows
 *        uses functions in popup.inc (3-1-89)
 *
 *)

procedure select_pulled(pullno:   integer;
                        var sel:  char);
   (* select and execute a pulldown window *)
var
   save: window_save_rec;
begin
   save_window(save);
   window(1,1,80,25);
   pulldown(wherex-0,wherey+1,pullno,pull_table[pullno],sel);
   restore_window(save);
end;


procedure top_menu(topx,topy:   integer;
                   var top:     pulldown_rec);
   {top level pulldown window processor; display the top level window
    and process pulldowns related to it}

   procedure display_entry(entry: integer);
   var
      i,x: integer;
   begin
      x := topx+1;
      for i := 1 to entry-1 do
         x := x + length(top.line[i].title) + 3;

      gotoxy(x,topy);
      disp(' '+top.line[entry].title+' ');
      gotoxy(x+1,topy);
   end;

   procedure display_top;
      {open a pulldown window at top-left x and y location.
       use the top record to describe the options}
   var
      i,
      j:                  integer;
      active:             integer;
   begin

   (* count active entries *)
      active := 0;
      for i := 1 to max_pulldown do
         with top.line[i] do
            if action <> unused_entry then
               inc(active);


   (* display the border *)
      window(1,1,80,25);
      setcolor(top.border_fg, top.border_bg);

      if topy > 1 then
      begin
         gotoxy(topx,topy-1);
         disp('Ú');
         for i := 1 to active-1 do
            disp(make_string('Ä',length(top.line[i].title)+2) + 'Â');
         disp(make_string('Ä',length(top.line[active].title)+2) + '¿');
      end;

      gotoxy(topx,topy);
      disp('³');
      for i := 1 to active do
         disp(make_string(' ',length(top.line[i].title)+2) + '³');

      gotoxy(topx,topy+1);
      disp('À');
      for i := 1 to active-1 do
         disp(make_string('Ä',length(top.line[i].title)+2) + 'Á');
      disp(make_string('Ä',length(top.line[active].title)+2) + 'Ù');

   (* print option descriptions *)
      setcolor(top.text_fg, top.text_bg);
      for i := 1 to active do
         display_entry(i);
   end;


   procedure pick_top;
      {select an entry from a pulldown window.
       the pulldown must already be on the display}
   var
      pulled:  boolean;
      found:   integer;
      entry:   integer;
      i:       integer;
      sel:     char;

      procedure moveby(by: integer);
      begin
         repeat
            entry := entry + by;
            if entry > max_pulldown then
               entry := 1
            else if entry < 1 then
               entry := max_pulldown;
         until top.line[entry].action <> unused_entry;
      end;

      procedure select_top;
      begin
         sel := upcase(getkey);
      end;


   begin
      (* pick the initial selection *)
      pulled := false;
      entry := 0;
      moveby(1);

      (* process top level options *)
      repeat
         setcolor(top.select_fg, top.select_bg);
         display_entry(entry);

         if pulled then
            select_pulled(top.line[entry].action,sel)
         else
            select_top;

         setcolor(top.text_fg, top.text_bg);
         display_entry(entry);

         case sel of
            LEFT:      moveby(-1);
            RIGHT:     moveby(1);

            DOWN,
            NEWLINE:   pulled := true;
            ESC:       pulled := false;

            quit_sel:  exit;

            else
            begin
               (* test for capitalized letters *)
               found := 0;
               for i := max_pulldown downto 1 do
               with top.line[i] do
                  if pos(sel, title) > 0 then
                  begin
                     entry := i;
                     found := -1;
                  end;

               if found = 0 then
               begin
                  if pulldown_key(0,entry,sel) then
                     exit;
               end;
            end;
         end;

      until true=false;
   end;


begin {pulldown}
   display_top;
   pick_top;
   window(1,1,80,25);
end;

