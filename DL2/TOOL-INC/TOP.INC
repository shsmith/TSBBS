
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

(* ------------------------------------------------------------------- *)
procedure top_menu(topx,topy:   integer);
   {top level pulldown window processor; display the top level window
    and process pulldowns related to it}

   procedure display_entry(entry: integer);
   var
      i,x: integer;
   begin
      x := topx+1;
      for i := 1 to entry-1 do
         x := x + length(pulldown_table^[0].line[i].title) + 3;

      gotoxy(x,topy);
      disp(' '+pulldown_table^[0].line[entry].title+' ');
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
         with pulldown_table^[0].line[i] do
            if action <> unused_entry then
               inc(active);


   (* display the border *)
      window(1,1,80,25);
      setcolor(pulldown_table^[0].border_fg, pulldown_table^[0].border_bg);

      if topy > 1 then
      begin
         gotoxy(topx,topy-1);
         disp('Ú');
         for i := 1 to active-1 do
            disp(make_string('Ä',length(pulldown_table^[0].line[i].title)+2) + 'Â');
         disp(make_string('Ä',length(pulldown_table^[0].line[active].title)+2) + '¿');
      end;

      gotoxy(topx,topy);
      disp('³');
      for i := 1 to active do
         disp(make_string(' ',length(pulldown_table^[0].line[i].title)+2) + '³');

      gotoxy(topx,topy+1);
      disp('À');
      for i := 1 to active-1 do
         disp(make_string('Ä',length(pulldown_table^[0].line[i].title)+2) + 'Á');
      disp(make_string('Ä',length(pulldown_table^[0].line[active].title)+2) + 'Ù');

   (* print option descriptions *)
      setcolor(pulldown_table^[0].text_fg, pulldown_table^[0].text_bg);
      for i := 1 to active do
         display_entry(i);
   end;


   procedure pick_top;
      {select an entry from a pulldown window.
       the pulldown must already be on the display}
   var
      found:   integer;
      i:       integer;
      sel:     char;

      procedure moveby(by: integer);
      begin
         repeat
            top_entry := top_entry + by;
            if top_entry > max_pulldown then
               top_entry := 1
            else if top_entry < 1 then
               top_entry := max_pulldown;
         until pulldown_table^[0].line[top_entry].action <> unused_entry;
      end;

      procedure select_top;
      var
         push: window_push_rec;
      begin
         disable_cursor;
         push_window(push);
         window(1,1,80,25);
         sel := IDLE_KEY;
         repeat
            if pulldown_key(0,top_entry,sel) then
               sel := ESC;
            if keypressed then
               sel := upcase(getkey);
         until sel <> IDLE_KEY;
         pop_window(push);
         enable_cursor;
      end;


(* ------------------------------------------------------------------- *)
   begin
      (* pick the initial selection *)
      if top_entry = 0 then
         moveby(1);

      (* process top level options *)
      repeat
         setcolor(pulldown_table^[0].select_fg, pulldown_table^[0].select_bg);
         display_entry(top_entry);

         if top_pulled then
            open_pulldown(pulldown_table^[0].line[top_entry].action,0,sel)
         else
            select_top;

         setcolor(pulldown_table^[0].text_fg, pulldown_table^[0].text_bg);
         display_entry(top_entry);

         case sel of
            LEFT:      moveby(-1);
            RIGHT:     moveby(1);

            DOWN,
            NEWLINE:   top_pulled := true;
            ESC:       top_pulled := false;

            quit_sel:  exit;

            else
            begin
               (* test for capitalized letters *)
               found := 0;
               for i := max_pulldown downto 1 do
               with pulldown_table^[0].line[i] do
                  if pos(sel, title) > 0 then
                  begin
                     top_entry := i;
                     found := -1;
                  end;

               if found = 0 then
               begin
                  if pulldown_key(0,top_entry,sel) then
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

