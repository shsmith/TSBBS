
(*
 * PLAYBACK - Play back music recored from keyboard
 *
 * s.h.smith, 4-jul-86
 *
 *)

{$C-}
{$I sound.inc                4 voice sound library}
{$I play.inc                 play notes}
{$I \shs\tools\regpack.inc   dos register packed type}
{$I \shs\tools\popup.inc     popup/fast display library}


var
   name:  anystring;
   infd:  text[10240];
   skips: real;
   c:     char;

begin
   popup_init;
   clrscr;
   if paramcount = 0 then
   begin
      name := 'COMPOSE';
      displn('Usage:  PLAYBACK <recording filename>');
      writeln;
   end
   else
      name := paramstr(1);

   if pos('.',name) = 0 then
      name := name + '.MUS';


   displn('ÚÄÄ PLAYBACK ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 1.0 (shs, 3-Jul-86) ÄÄ¿');
   displn('³                                                                   ³');
   writeln('³            Playback of:',name:20,'                       ³');
   displn('³                                                                   ³');
   displn('³            Press F10 to abort playback.                           ³');
   displn('³                                                                   ³');
   displn('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
   writeln;

   assign(infd,name);
   reset(infd);

   play_init;
   skips := 0;

   while not eof(infd) do
   begin
      if keypressed then
         read(kbd,c)
      else
         if skips >= 1 then
         begin
            skips := skips - 1;
            c := #0;
         end
         else
            read(infd,c);

      case c of
         #27:
            begin
               if keypressed then
                  read(kbd,c)
               else
                  read(infd,c);

               case c of
                  F10:
                     begin
                        sound_off;
                        close(infd);
                        writeln;
                        halt;
                     end;

                  else
                     display_function_key(c);
                     function_key(c);
               end;
            end;

         #13:
            writeln;

         #1:
            readln(infd,skips);

         #0:
            play(c);

         else
            write(c);
            play(c);
      end;

      tick;
   end;

   sound_off;
   writeln;
end.


