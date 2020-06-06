
(*
 * GRAPH3 - Turbo3 Graphics emulation unit
 *
 * This unit was written as a crutch in converting graphics applications
 * from Turbo3 to Turbo6 methods of graphics programming.
 *
 * Written by Samuel H. Smith, 4-21-91
 *
 *)

unit graph3;

interface


{display mode controls}
procedure GraphMode;
procedure TextMode;

{graphics output functions}
procedure Plot(X,Y,Color: Integer);
procedure Draw(X1,Y1,X2,Y2,Color: Integer);

{text output functions in text or graphics modes}
procedure GotoXY(X,Y: Real);
procedure WriteStr(S: String);

{debugging}
procedure message(s: string);

implementation

uses crt,misc,graphics;

const
   graphics_active:     boolean = false;

   Graph_Driver:        integer = 0;
   Graph_Mode:          integer = 0;
   Driver_Path          = '.';

var
   fd: text;

procedure GraphMode;
begin
   writeln(fd,'GraphMode');
   graphics_active := true;

   Graph_Driver := detect;
  {Graph_Driver := CGA;
   Graph_Mode := CGAhi;}

   InitGraph(Graph_Driver,Graph_Mode,Driver_Path);

   graphsup_phys_maxx := GetMaxX-1;
   graphsup_phys_minx := trunc(GetMaxX / 6.4);
   graphsup_phys_miny := trunc(GetMaxY / 1.3);
   graphsup_phys_maxy := trunc(GetMaxY / 7.14);
   graphsup_mark_x    := round(GetMaxX / 130.0);
   graphsup_mark_y    := round(GetMaxY / 100.0);
end;

procedure TextMode;
begin
   writeln(fd,'TextMode');
   CloseGraph;
   graphics_active := false;
end;

procedure Plot(X,Y,Color: Integer);
begin
   writeln(fd,'Plot(X,Y,Color: ',x,' ',y,' ',color,')');
end;

procedure Draw(X1,Y1,X2,Y2,Color: Integer);
begin
   writeln(fd,'Draw(X1,Y1,X2,Y2,Color: ',x1,' ',y1,' ',x2,' ',y2,' ',color,')');
end;

procedure GotoXY(X,Y: Real);
begin
   if graphics_active then
      MoveTo( trunc(MISC_map_value(x,1,80,0,graphsup_phys_maxx)),
              trunc(MISC_map_value(y,1,26,0,graphsup_phys_miny*1.3)) )
   else
      crt.gotoxy(round(x),round(y));
end;

procedure WriteStr(S: String);
begin
   if graphics_active then
      OutText(S);
   else
      write(S);
end;

procedure message(s: string);
begin
   writeln(fd,s);
end;

{initialization}
var
   c: char;
begin
   assign(fd,'graph3.out');
   rewrite(fd);
   settextbuf(fd,c);
end.


