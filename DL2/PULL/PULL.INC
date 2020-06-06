
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

const
   max_pulldown = 10;

   quit_sel = #255;      {special select value to quit top menu}
   divider_entry = -254; {special action value for divider lines}
   unused_entry  = -255; {special action value for unused pulldown entries}

type
   pulldown_entry = record
      title:  string[40];
      action: integer;
   end;

   pulldown_rec = record
      border:    border_styles;
      border_fg: byte;
      border_bg: byte;
      text_fg:   byte;
      text_bg:   byte;
      select_fg: byte;
      select_bg: byte;
      ainit:     integer;
      aexit:     integer;
      line:      array[1..max_pulldown] of pulldown_entry;
   end;


function pulldown_action(pullno:   integer;   (* pulldown menu number *)
                         entry:    integer;   (* entry in pulldown menu *)
                         action:   integer;   (* action code *)
                         var sel:  char)      (* select key *)
                             : boolean;       (* true to force menu exit *)
   {pulldown action routine; called when a pulldown entry is selected}
forward;

procedure pulldown_init(pullno:    integer;
                        action:    integer;
                        var sel:   char);
   {pulldown init routine; called when a pulldown menu is opened}
forward;

procedure pulldown_exit(pullno:    integer;
                        action:    integer;
                        var sel:   char);
   {pulldown exit routine; called when a pulldown menu is closed}
forward;

function pulldown_key   (pullno:   integer;   (* pulldown menu number *)
                         entry:    integer;   (* entry in pulldown menu *)
                         var sel:  char)      (* select key *)
                             : boolean;       (* true to force menu exit *)
   {process unknown keys}
forward;


procedure pulldown(topx,topy:   integer;
                   pullno:      integer;
                   var pull:    pulldown_rec;
                   var sel:     char);
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
      i:            integer;
      longest:      integer;
      active:       integer;
      botx,boty:    integer;

   begin

   (* determine longest selection title *)
      active := 0;
      longest := 0;
      for i := 1 to max_pulldown do
         with pull.line[i] do
         begin
            if length(title) > longest then
               longest := length(title);
            if action <> unused_entry then
               inc(active);
         end;

   (* determine bottom right location *)
      botx := topx + longest + 4;
      boty := topy + active + 1;
      while botx > 79 do
      begin
         dec(topx);
         dec(botx);
      end;
      while boty > 24 do
      begin
         dec(topy);
         dec(boty);
      end;

   (* draw the frame *)
      window(1,1,80,25); 
      setcolor(pull.border_fg, pull.border_bg);
      display_border(topx,topy,botx,boty,pull.border);

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
      found: integer;
      i:     integer;
      entry: integer;

      procedure moveby(by: integer);
      begin
         repeat
            entry := entry + by;
            if entry > max_pulldown then
               entry := 1
            else if entry < 1 then
               entry := max_pulldown;
        until pull.line[entry].action >= 0;
      end;


   begin
      (* pick the initial selection *)
      entry := 0;
      moveby(1);

      (* determine what user wants *)
      repeat
         found := 0;
         setcolor(pull.select_fg,pull.select_bg);
         display_entry(entry);

         sel := upcase(getkey);

         setcolor(pull.text_fg,pull.text_bg);
         display_entry(entry);

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
            setcolor(pull.select_fg,pull.select_bg);
            display_entry(entry);

            if pulldown_action(pullno,entry,
                               pull.line[entry].action,sel) then
               exit;
         end;

      until true=false;
   end;


begin {pulldown}

   pulldown_init(pullno,pull.ainit,sel);
   display_pulldown;
   pick_pulldown;
   window(1,1,80,25);
   pulldown_exit(pullno,pull.aexit,sel);

end;

