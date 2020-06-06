
(*
 * Copyright 1994 Samuel H. Smith;  All rights reserved
 *
 *)

{$i prodef.inc}
{$M 16000,12000,12000}  {Stack(min=12), minheap(min=40), maxheap}
{$l+,d+}
{$r+}

program protxt;

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
procedure edit_pcbtext(fname1,fname2: anystring);
type
   pcbtext_rec = record
      code:       char;
      prompt:     array[1..79] of char;
   end;

const
   rec_size = sizeof(pcbtext_rec);
   columns = 4;
   lines = 3;
   entries = (21 div lines)*columns;
   max_rec = $FFF0 div rec_size;

type
   list_array = array[1..max_rec] of pcbtext_rec;

var
   fd:   dos_handle;
   rec:  ^list_array;
   rec2: ^list_array;
   recs: word;
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
      y := n*lines+3;
      recn := n+brec;

      if recn > recs then
      begin
         gotoxy(2,y);
         write('':76);
         gotoxy(2,y+1);
         write('':76);
         gotoxy(2,y+2);
         write('':76);
         ex := SHIFT_TAB;
      end
      else

      case fld of
         1: begin
               gotoxy(2,y);
               lowvideo;
               write('Prompt # ',recn:3,':');
               highvideo;
               edit_chars(func,30,y,'Code: ',rec^[recn].code,1,ex);
            end;

         2: if fname2 <> '' then
               edit_chars(func,50,y,'Code: ',rec2^[recn].code,1,ex);

         3: edit_chars(func,2,y+1,'',rec^[recn].prompt,75,ex);

         4: if fname2 <> '' then
               edit_chars(func,2,y+2,'',rec2^[recn].prompt,75,ex);
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

begin
   dos_getmem(rec,sizeof(rec^));
   fillchar(rec^,sizeof(rec^),' ');
   dos_getmem(rec2,sizeof(rec2^));
   fillchar(rec2^,sizeof(rec2^),' ');

   writeln('Loading: ',fname1);
   if not dos_exists(fname1) then
      error('File does not exist: '+fname1);
   fd := dos_open(fname1,open_update);
   if fd = dos_error then
      error('Error opening: '+fname1);
   recs := dos_read(fd,rec^,sizeof(rec^)) div rec_size;
   dos_close(fd);

   if fname2 <> '' then
   begin
      writeln('Loading: ',fname2);
      if not dos_exists(fname2) then
         error('File does not exist: '+fname2);
      fd := dos_open(fname2,open_update);
      if fd = dos_error then
         error('Error opening: '+fname2);
      recs := dos_read(fd,rec2^,sizeof(rec2^)) div rec_size;
      dos_close(fd);
   end;

   brec := 1;
   entry := 1;
   recn := 1;
   if recs = 0 then
      inc(recs);

   if fname2 = '' then
      title_screen(2,24,'Editing: '+fname1)
   else
      title_screen(2,24,'Editing: '+fname1+'  Viewing: '+fname2);

   lowvideo;
   textcolor(Yellow);
   gotoxy(2,25);
   disp('UP/DOWN/TAB [move cursor]');
   gotoxy(68,25);
   disp('ESC [exit]');

   display_screen;

   repeat
      proc_entry(edit);

      case ex of
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

         DOWN:    if entry+columns <= entries then
                     inc(entry,columns)
                  else
                  begin
                     if brec+(entries div columns) <= recs then
                     begin
                        inc(brec);
                        display_screen;
                     end
                  end;

         PGDN:    begin
                     if brec+(entries div columns) <= recs then
                     begin
                        inc(brec,entries div columns);
                        display_screen;
                     end
                     else
                        entry := entries;
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

   writeln('Saving: ',fname1);
   fd := dos_open(fname1,open_update);
   if fd = dos_error then
      error('Cannot update file: '+fname1);
   dos_write(fd,rec^,recs*rec_size);
   dos_close(fd);
   dos_freemem(rec);

   if fname2 <> '' then
   begin
      writeln('Saving: ',fname2);
      fd := dos_open(fname2,open_update);
      if fd = dos_error then
         error('Cannot update file: '+fname2);
      dos_write(fd,rec2^,recs*rec_size);
      dos_close(fd);
      dos_freemem(rec2);
   end;
end;


(* -------------------------------------------------- *)
begin
   if (paramcount < 1) or (paramcount > 2) then
   begin
      writeln('Use this program to edit your PCBoard 14.x-15.x PCBTEXT files.');
      writeln;
      writeln('Usage: protxt [drive:][\path\]pcbtext1 {[drive:][\path\]pcbtext2} ');
   end
   else
      edit_pcbtext(paramstr(1),paramstr(2));

   writeln;
   writeln('ProTxt (2/18/94) Copyright 1994 Samuel H. Smith');
   writeln('Courtesy of: The Tool Shop BBS (818) 891-1344');
end.

