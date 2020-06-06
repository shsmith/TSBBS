
unit Helpme;

interface
   uses Crt, DispEdit, DosMem;

const
   maxsub = 7;
   maxkey = 200;
   keylen = 30;

type
   keyword_rec = record
      loc:           word;
      width,lines:   byte;
      id:            string[keylen];
   end;

   sublist_rec = array[1..maxsub] of byte;

   procedure help_on_tap(level:  integer;
                         x,y:    integer;
                         keyno:  byte;
                         var     keytab;
                         var     htext);


implementation

   procedure help_on_tap(level:  integer;
                         x,y:    integer;
                         keyno:  byte;
                         var     keytab;
                         var     htext);
   var
      keywords:   array[1..maxkey] of keyword_rec absolute keytab;
      help_text:  array[1..maxint] of byte absolute htext;
      disp:       ^display_image_rec;
      p:          integer;
      str:        ^string;
   const
      ex:         char = '?';


      procedure display_help;
      begin
         with keywords[keyno] do
         begin
            window(1,1,80,25);
            textBackground(Black);
            textColor(LightRed);

            while x+width+4 > 79 do
               dec(x);
            while y+lines+2 > 25 do
               dec(y);
            display_border(x,y,x+width+5,y+lines+2,single_border);

            textBackground(Blue);
            textColor(White);
            gotoxy(x+2,y);
            write(id);

            window(x+1,y+1,x+width+3,y+lines+1);
            textColor(Yellow);
            clrscr;

            p := loc;
            inc(p,maxsub);

            repeat
               str := @help_text[p];
               inc(p,length(str^)+1);

               if str^ <> #0 then
                  displn(' '+str^);
            until str^ = #0;
         end;
      end;


      procedure process_subtopics;
      var
         subs: ^sublist_rec;
         fld:  integer;
         xx:   sublist_rec;
         escx: integer;

      begin
         with keywords[keyno] do
         begin
            textbackground(Black);
            textcolor(white);

            subs := @help_text[loc];
            for fld := 1 to maxsub do
            begin
               xx[fld] := wherex+1;
               if subs^[fld] > 0 then
               with keywords[subs^[fld]] do
               begin
                  gotoxy(wherex+1,wherey);
                  write(' '+id+' ');
               end;
            end;

            escx := wherex+1;
            fld := maxsub+2;
            ex := DOWN;
            if keyno <> 1 then
               edit_funkey(display,escx,wherey,' Index ',F1,ex);

            repeat
               if (fld = maxsub+1) and (keyno <> 1) then
                  edit_funkey(edit,escx,wherey,' Index ',F1,ex)
               else

               if fld = maxsub+2 then
                  edit_funkey(edit,escx+8,wherey,' ESC ',ESC,ex)
               else

               if subs^[fld] > 0 then
               with keywords[subs^[fld]] do
                  edit_funkey(edit,xx[fld],wherey,' '+id+' ',chr(fld+ord('@')),ex);

               ex := upcase(ex);
               if ex = ' ' then ex := DOWN;
               if (ex = ^H) or (ex = DEL) then ex := UP;
               if ex = LEFT then ex := UP;
               if ex = RIGHT then ex := DOWN;
               select_next_entry(edit,fld,maxsub+2,ex);

               if (ex >= 'A') and (ex <= chr(maxsub+ord('@'))) then
                  if (subs^[fld] > 0) then
                  begin
                     help_on_tap(level+1,x+2,y+1,subs^[fld],keytab,htext);
                     if ex = ESC then
                        ex := '?';
                  end;

            until (ex = ESC) or (ex = F1);
         end;
      end;


   begin
      dos_getmem(disp,sizeof(disp^));
      save_display(disp^);

      repeat
         shadow_display;
         display_help;
         process_subtopics;

         if (ex = F1) and (level = 1) then
         begin
            keyno := 1;
            ex := '?';
         end;

         restore_display(disp^);
      until (ex = ESC) or (ex = F1);

      dos_freemem(disp);
   end;

end.

