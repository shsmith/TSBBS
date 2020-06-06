
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
 * pull - utility library for simple "pull-down" windows
 *        uses functions in popup.inc (3-1-89)
 *
 *)

(* ------------------------------------------------------------------- *)
procedure pulldown(topx,topy:    integer;
                   pullno:       integer;
                   parent:       integer;
                   var pull:     pulldown_rec;
                   var sel:      char);
   {pulldown window processor; display the pulldown window and
    select an entry from it}

   procedure display_entry(entry: integer);
   begin
      gotoxy(1,entry);
      disp(' '+pull.line[entry].title);
      clreol;
      gotoxy(2,entry);
   end;

   procedure display_pulldown;
      {open a pulldown window at top-left x and y location.
       use the pull record to describe the options}
   var
      i:             integer;
      active:        integer;
      botx,boty:     integer;
      border:        border_styles;

   begin

   (* determine longest selection title *)
      active := 0;
      pull.longest := 0;
      for i := 1 to max_pulldown do
         with pull.line[i] do
         begin
            if length(title) > pull.longest then
               pull.longest := length(title);
            if action <> unused_entry then
               inc(active);
         end;

   (* determine bottom right location *)
      border := taildouble_border;
      botx := topx + pull.longest + 4;
      boty := topy + active + 1;

      if botx > 79 then
      begin
         border := rtaildouble_border;
         botx := topx + pulldown_table^[parent].longest;
         topx := botx - pull.longest - 4;
      end;

      while boty > 24 do
      begin
         border := double_border;
         dec(topy);
         dec(boty);
      end;

   (* draw the frame *)
      window(1,1,80,25); 
      setcolor(pull.border_fg, pull.border_bg);
      display_border(topx,topy,botx,boty,border);

   (* define the new window and print option descriptions *)
      window(topx+1,topy+1,botx-2,boty-1);
      setcolor(pull.text_fg,pull.text_bg);
      for i := 1 to active do
         display_entry(i);
   end;


   procedure pick_pulldown;
      {select an entry from a pulldown window.
       the pulldown must already be on the display}
   var
      found:   integer;
      i:       integer;
      entry:   integer;
      push:    window_push_rec;

      procedure moveby(by: integer);
      begin
         repeat
            entry := entry + by;
            if entry > max_pulldown then
               entry := 1
            else if entry < 1 then
               entry := max_pulldown;
        until pull.line[entry].action > 0;
      end;

   begin
      (* pick the initial selection *)
      entry := pull.curline;
      if (entry < 1) or  (pull.line[entry].action < 1) then
         moveby(1);

      (* determine what user wants *)
      repeat
         disable_cursor;
         pull.curline := entry;
         found := 0;
         setcolor(pull.select_fg,pull.select_bg);
         display_entry(entry);

         push_window(push);
         window(1,1,80,25);
         sel := IDLE_KEY;
         repeat
            if pulldown_key(pullno,entry,sel) then
               sel := ESC;
            if keypressed then
               sel := upcase(getkey);
         until sel <> IDLE_KEY;
         pop_window(push);

         setcolor(pull.text_fg,pull.text_bg);
         display_entry(entry);
         enable_cursor;

         case sel of
            ESC,
            LEFT,
            RIGHT:     exit;

            UP:        moveby(-1);
            DOWN:      moveby(1);

            NEWLINE:   found := entry;

            else
               begin
                  (* test for capitalized letters *)
                  for i := max_pulldown downto 1 do
                  with pull.line[i] do
                     if pos(sel, title) > 0 then
                     begin
                        entry := i;
                        found := -1;
                     end;

                  if found = 0 then
                  begin
                     if pulldown_key(pullno,entry,sel) then
                        exit;
                  end;
               end;
         end;

         (* an entry was found; select it and perform the action *)
         if found > 0 then
         begin
            entry := found;
            pull.curline := entry;
            setcolor(pull.select_fg,pull.select_bg);
            display_entry(entry);
            if pulldown_action(pullno,entry,pull.line[entry].action,sel) then
               exit;
         end;

      until true=false;
   end;


begin {pulldown}
   pulldown_init(pullno,pull.ainit,sel);

   pulldown_redisp := false;
   display_pulldown;
   pick_pulldown;

   window(1,1,80,25);
   pulldown_exit(pullno,pull.aexit,sel);
end;


(* ------------------------------------------------------------------- *)
procedure open_pulldown(pullno:  integer;
                        parent:  integer;
                        var sel: char);
var
   save: ^window_save_rec;
begin
   new(save);

   repeat
      save_window(save^);
      shadow_display;

      window(1,1,80,25);
      pulldown(wherex,wherey+1,pullno,parent,pulldown_table^[pullno],sel);

      restore_window(save^);
   until not pulldown_redisp;

   dispose(save);
end;


(* ------------------------------------------------------------------- *)
procedure init_pulldown(actionp:        pulldown_actionp;
                        initp:          pulldown_initp;
                        exitp:          pulldown_exitp;
                        keyp:           pulldown_keyp;
                        var tablep;
                        tablesz:        integer;
                        numvars:        integer;
                        numsvars:       integer;
                        configfn:       PathStr);
begin
   pulldown_action := actionp;
   pulldown_init := initp;
   pulldown_exit := exitp;
   pulldown_key := keyp;

   pulldown_table := @tablep;
   pulldown_size := tablesz;

   pulldown_nvars := numvars;
   getmem(pulldown_vars,pulldown_nvars*sizeof(real));
   fillchar(pulldown_vars^,pulldown_nvars*sizeof(real),0);

   pulldown_nsvars := numsvars;
   getmem(pulldown_svars,pulldown_nsvars*sizeof(pulldown_string));
   fillchar(pulldown_svars^,pulldown_nsvars*sizeof(pulldown_string),0);

   pulldown_cnf := configfn;

   init_pop_up;
end;

