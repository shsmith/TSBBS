
(*
 * COMPOSE - Record/compose music from keyboard
 *
 * s.h.smith, 4-jul-86
 *
 *)

{$C-}
{$I sound.inc                4 voice sound library}
{$I play.inc                 note playing library}
{$I \shs\tools\regpack.inc   dos register packed type}
{$I \shs\tools\popup.inc     popup/fast display library}


var
   ptime:  real;
   outfd:  text[10240];
   name:   anystring;
   c:      char;
   sharpen: boolean;

begin
   popup_init;
   clrscr;

   if paramcount = 0 then
   begin
      name := 'COMPOSE';
      displn('Usage:  COMPOSE <recording filename>');
      writeln;
   end
   else
      name := paramstr(1);

   if pos('.',name) = 0 then
      name := name + '.MUS';


   displn('��� COMPOSE/RECORD �������������������������� 1.0 (shs, 3-Jul-86) �Ŀ');
   displn('�                                                                   �');
   displn('�          Sustain:   F1/F2            Pitch:     RIGHT/LEFT        �');
   displn('�          Loudness:  F3/F4            Octave:    UP/DOWN           �');
   displn('�          Natural:   F5/F6off         Sharpen:   HOME              �');
   displn('�                                      Translate: F8                �');
   displn('�          Exit:      F10              Display:   F9                �');
   displn('�                                                                   �');
   displn('�������������������������������������������������������������������Ĵ');
   writeln('�        Recording composition in: ',name:20,'             �');
   displn('���������������������������������������������������������������������');
   writeln;


   assign(outfd,name);
   rewrite(outfd);

   play_init;
   ptime := 0;
   sharpen := false;

   repeat
      if keypressed then
      begin
         read(kbd,c);

         case c of
            #27:
               if keypressed then
               begin
                  read(kbd,c);

                  if not (c in [F9,HOME]) then   {don't record these keys}
                  begin
                     writeln(outfd,#1,time-ptime:0:0);
                     ptime := time;
                     write(outfd,#27,c);
                  end;

                  case c of
                     HOME:
                        sharpen := true;
                                   {make next note sharp}
                     F9:
                        begin
                           writeln;
                           if natural then
                              write('Natural keyboard')
                           else
                              write('Conventional keyboard');
                           write  (',  Sustain = ',sustain);
                           write  (',  Attenuation = ',level);
                           writeln(',  "C" frequency = ',base_pitch*octave:0:2);
                        end;

                     F10:
                        begin
                           sound_off;
                           close(outfd);
                           writeln;
                           halt;
                        end;

                     else
                        display_function_key(c);
                        function_key(c);
                  end;
               end;

            #13:
               begin
                  writeln;
                  write(outfd,c);
               end;

            else
               if sharpen then
               begin
                  c := upcase(c);
                  sharpen := false;
               end;

               writeln(outfd,#1,time-ptime:0:0);
               ptime := time;
               write(outfd,c);

               if not translate then
                  write(c);
               play(c);
         end;
      end
      else
         play(#0);

      tick;
   until true = false;
end.


