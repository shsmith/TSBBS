
(*
 * Copyright 1994 Samuel H. Smith;  All rights reserved
 *
 *)

{$i prodef.inc}
{$M 16000,12000,12000}  {Stack(min=12), minheap(min=40), maxheap}
{$l+,d+}
{$r+}

program ProCMD;

uses
   Dos,
   Crt,
   DosMem,
   MdosIO,
   Tools,
   DispEdit {,Helpme};
     

(* -------------------------------------------------- *)
procedure error(why: string);
begin
   writeln('Error: '+why);
   halt(99);
end;

(* -------------------------------------------------- *)
procedure title_screen(y1,y2: integer; title: string);
begin
   clear_screen;
   textcolor(Green);
   display_border(1,y1,79,y2,mixed_border);


   textcolor(Yellow);
   gotoxy(1,1);
   write('':40-length(title) div 2,title);
   clreol;
   textcolor(White{LightCyan});
end;


(* -------------------------------------------------- *)
procedure edit_charz  ( func:      edit_functions;
                        x,y:       integer;
                        prompt:    string;
                        var data;
                        width:     integer;
                        var term:  char );
var
   cdata:   array[1..255] of char absolute data;
   i:       integer;
begin
   i := 1;
   while (i < width) and (cdata[i] <> #0) do
      inc(i);
   while (i <= width) do
   begin
      cdata[i] := ' ';
      inc(i);
   end;

   edit_chars(func,x,y,prompt,data,width,term);

   i := width;
   while (i > 0) and (cdata[i] = ' ') do
   begin
      cdata[i] := #0;
      dec(i);
   end;

   while i > 0 do
   begin
      cdata[i] := upcase(cdata[i]);
      dec(i);
   end;
end;


(* -------------------------------------------------- *)
procedure edit_cmdlist(fname: anystring);
type
   cmdlist_rec = record
      command:    array[1..14] of char;
      undef1:     byte;
      level:      byte;
      replace:    array[1..39] of char;
      undef2:     array[1..9] of char;
   end;

const
   rec_size = sizeof(cmdlist_rec);
   entries = 17*3;
   columns = 3;
   max_rec = $7000 div rec_size;

type
   list_array = array[1..max_rec] of cmdlist_rec;

var
   fd:   dos_handle;
   rec:  ^list_array;
   recs: integer;
   recn: integer;
   brec: integer;
   ex:   char;
   entry:integer;
   fld:  integer;

   procedure proc_entry(func:  edit_functions);
   var
      n:    integer;
      y:    integer;

   begin
      n := ((entry-1) div columns);
      fld := ((entry-1) mod columns)+1;
      y := n+6;
      recn := n+brec;

      if recn > recs then
      begin
         gotoxy(3,y);   write('':75);
         ex := UP;
      end
      else

      case fld of
         1: begin
               gotoxy(2,y);
               lowvideo;
               write(recn:3,')');
               highvideo;
               edit_charz(func,7,y,  '',rec^[recn].command,15,ex);
            end;

         2: edit_byte(func,28,y,'',rec^[recn].level,3,0,255,ex);
         3: edit_charz(func,37,y,'',rec^[recn].replace,39,ex);
      end;
   end;

   procedure display_screen;
   var
      n: integer;
      p: integer;
   begin
      p := entry;
      for n := 1 to entries do
      begin
         entry := n;
         proc_entry(display);
      end;
      entry := p;
   end;

   procedure delete_rec;
   var
      n: integer;
   begin
      if (recn > recs) or (recs < 2) then exit;
      dec(recs);
      for n := recn to recs do
         rec^[n] := rec^[n+1];
      display_screen;
   end;

   procedure sort_rec;
   var
      n: integer;
      temp: cmdlist_rec;
      swapped: boolean;
   begin
      if (recs < 2) then exit;
      repeat
         swapped := false;
         for n := 1 to recs-1 do
            if chr(rec^[n].level)+rec^[n].command >
               chr(rec^[n+1].level)+rec^[n+1].command then
            begin
               temp := rec^[n];
               rec^[n] := rec^[n+1];
               rec^[n+1] := temp;
               swapped := true;
            end;
      until not swapped;
      display_screen;
   end;

   procedure insert_rec;
   var
      n: integer;
   begin
      if recs >= max_rec then
         exit;
      inc(recn);
      if recn <= recs then
         for n := recs downto recn do
            rec^[n+1] := rec^[n];
      inc(recs);
      fillchar(rec^[recn],rec_size,0);
      display_screen;
   end;

begin
   writeln('Loading: ',fname);

   if not dos_exists(fname) then
      error('File does not exist: '+fname);

   fd := dos_open(fname,open_update);
   if fd = dos_error then
      error('Error opening: '+fname);

   dos_getmem(rec,sizeof(rec^));
   fillchar(rec^,sizeof(rec^),' ');
   recs := dos_read(fd,rec^,sizeof(rec^)) div rec_size;
   dos_close(fd);

   brec := 1;
   entry := 1;
   recn := 1;
   if recs = 0 then
      inc(recs);

   title_screen(3,23,'Editing: '+fname);

   lowvideo;
   gotoxy(4,4);
   write('   Command            Security   PPE/MNU File -or- Keystroke Replacement');
   gotoxy(4,5);
   write('   様様様様様様様様   様様様様   様様様様様様様様様様様様様様様様様様様様');

   textcolor(Yellow);
   gotoxy(2,24);
   disp('ALT-I [insert]       UP/DOWN/TAB [move cursor]');
   gotoxy(2,25);
   disp('ALT-D [delete]       ALT-S [sort]');
   gotoxy(68,25);
   disp('ESC [exit]');

   display_screen;

   repeat
      proc_entry(edit);

      case ex of
         ALT_D:   delete_rec;
         ALT_I:   insert_rec;
         ALT_S:   sort_rec;

         PGUP:    begin
                     if brec > (entries div columns) then
                        dec(brec,entries div columns)
                     else
                     begin
                        brec := 1;
                        entry := 1;
                     end;
                     display_screen;
                  end;

         UP:      if entry > columns then
                     dec(entry,columns)
                  else
                  begin
                     if brec > 1 then
                     begin
                        dec(brec);
                        display_screen;
                     end
                  end;

         DOWN:    if entry+3 <= entries then
                     inc(entry,columns)
                  else
                  begin
                     if brec < recs then
                     begin
                        inc(brec);
                        display_screen;
                     end
                  end;

         PGDN:    begin
                     if brec + entries div columns <= recs then
                        inc(brec,entries div columns)
                     else
                        entry := entries;
                     display_screen;
                  end;

         TAB, ENTERKEY:
            if (brec < recs) and (entry = entries) then
            begin
               inc(brec);
               dec(entry,columns-1);
               display_screen;
            end
            else
            if entry < entries then
               inc(entry);

         SHIFT_TAB:
            if (brec > 1) and (entry = 1) then
            begin
               dec(brec);
               inc(entry,columns-1);
               display_screen;
            end
            else
            if entry > 1 then
               dec(entry);
      end;
   until ex = ESC;

   textbackground(black);
   textcolor(white);
   clrscr;

   writeln('Saving: ',fname);

   fd := dos_create(fname);
   if fd = dos_error then
      error('Cannot create file: '+fname);

   dos_write(fd,rec^,recs*rec_size);
   dos_close(fd);
   dos_freemem(rec);
end;


(* -------------------------------------------------- *)
begin
   if paramcount <> 1 then
   begin
      writeln('Use this program to edit your PCBoard 15.x CMD.LST files.');
     writeln;
      writeln('Usage: procmd [drive:][\path\]cmd.lst');
   end
   else
      edit_cmdlist(paramstr(1));

   writeln;
   writeln('ProCmd (2/18/94) Copyright 1994 Samuel H. Smith');
   writeln('Courtesy of: The Tool Shop BBS (818) 891-1344');
end.

