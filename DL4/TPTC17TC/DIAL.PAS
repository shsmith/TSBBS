
(*
 * Usage: DIAL xxx-xxxx
 *)

program Dial;
  {dials number on command line to Hayes compatible modem on COM1}

const
  Com_Base = $3F8;            {Use 3F8 for COM1, 2F8 for COM2}

  {Offsets from Com_Base for async control ports             }
  RX = 0;                     {Receiver Buffer Register      }
  TX = 0;                     {Transmitter Buffer Register   }
  LC = 3;                     {Line Control Register         }
  MC = 4;                     {Modem Control Register        }
  LS = 5;                     {Line Status Register          }
  DLL = 0;                    {Divisor Latch, Low Order Byte }
  DLH = 1;                    {Divisor Latch, High Order Byte}

  No_Parity = $03;

type
   anystring = string[80];


procedure send(command: anystring);
var
   P: integer;
   C: char;
   I: integer;

begin

  {send string to modem}
  for P := 1 to length(command) do
  begin
    C := command[P];
    Port[com_base+TX] := C;
    repeat
    until Port[com_base+LS] >= $20;
    P := Succ(P);

    I := 0;
    repeat
      I := Succ(I);
    until I >= 1000;
  end;
end;


begin
  {init modem}
  Port[com_base+LC] := $83; {Set baud rate, No parity, 8 bits}
  Port[com_base+DLL] := 96; {1200 baud}
  Port[com_base+DLH] := 0;
  Port[com_base+LC] := No_Parity;
  Port[com_base+MC] := $03; {Turn ON DTR and RTS}

  {set up modem control string}
  send('ATDT' + paramstr(1) + ^M);
end.
