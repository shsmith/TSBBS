
(* intrtest - test unit for INTRCOMM unit *)

uses CRT, INTRCOMM;

const
   comport = 0;   {com1}
   comspeed = 1200;

var
   quit: boolean;
   c:    char;

procedure menu;
var
   sp:   word;
begin
   writeln;
   write('Function: (L)owerDTR, (R)aiseDTR, (B)aud, (F)lush, (Q)uit? ');
   c := upcase(readkey);
   writeln(c);

   case c of
      'L':  INTR_lower_dtr;

      'R':  INTR_raise_dtr;

      'B':  begin
               write('Speed: ');
               readln(sp);
               INTR_set_baud_rate(sp);
            end;

      'F':  INTR_flush_com;

      'Q':  quit := true;

      else  writeln('?invalid?');
   end;
end;

begin
   writeln;
   writeln('INTRCOMM test unit; ESC for menu.');
   writeln;

   INTR_init_com(comport);
   INTR_set_baud_rate(comspeed);
   quit := false;

   repeat
      if INTR_receive_ready then
      begin
         c := INTR_receive_data;
         write(c);
      end;

      if keypressed then
      begin
         c := readkey;
         if c = #27 then
            menu
         else
         if c = ^C then
            quit := true
         else
            INTR_transmit_data(c);
      end;
   until quit;

   INTR_uninit_com;
end.


