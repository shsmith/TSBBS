
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
 * PCB ProDOOR - display protocol table user interface (3-1-89)
 *
 *)

procedure display_protocol_table;
   (* list each protocol table entry; shows actual external commands *)
var
   i:     integer;

begin
   for i := 1 to cnf.protocol_count do
      if nomore = false then
         with cnf.protocol_table[i] do
         begin
            newline;
            case mode of
               TX:   dWHITE('Transmit ');
               RX:   dWHITE('Receive ');
            end;

            disp(title^);
            disp('.  (');
            disp(ftoa(peffic*100,0,0)+'%');
            if efree then
               disp(', MNP');
            displn(')');

            if nomore then ;
            dCYAN('   ');
            displn{_nopath}(command^);
         end;

   wait_for_enter;
end;

