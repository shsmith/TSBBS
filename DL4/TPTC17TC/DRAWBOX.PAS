uses crt;
procedure DrawBox(col1, row1, col2, row2, frame : integer);
type
    cvec6 = array[1..6] of char;
    cptr = ^cvec6;
const
    V1 = #179;   UR1 = #191;   UL1 = #218;
    V2 = #186;   UR2 = #187;   UL2 = #201;
    H1 = #196;   LR1 = #217;   LL1 = #192;
    H2 = #205;   LR2 = #188;   LL2 = #200;

    SFRAME : cvec6 = (UL1,H1,UR1,V1,LL1,LR1);
    DFRAME : cvec6 = (UL2,H2,UR2,V2,LL2,LR2);
var
   framedef : cptr;
   i,j : integer;

begin
     if frame <> 0 then
     begin
          case frame of
             1 : framedef := addr(SFRAME);
             2 : framedef := addr(DFRAME);
          end;

          {with framedef^,framedef^[3], SFRAME[3], i, SFRAME do ;}

          GotoXY(col1, row1);
          write(framedef^[1]);
          for i := col1 + 1 to col2 - 1 do
              write(framedef^[2]);
          write(framedef^[3]);
          for i := row1 + 1 to row2 - 1 do
          begin
                GotoXY(col1, i);
                write(framedef^[4]);
                GotoXY(col2, i);
                write(framedef^[4])
          end;
          GotoXY(col1, row2);
          write(framedef^[5]);
          for i := col1 + 1 to col2 - 1 do
              write(framedef^[2]);
          write(framedef^[6])
    end
end;

begin
   DrawBox(5,3,70,20,2);
   DrawBox(10,10,60,17,1);
   gotoxy(1,23);
end.

