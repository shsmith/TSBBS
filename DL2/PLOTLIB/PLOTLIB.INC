
(*
 * plotlib - graphics graph plotting package
 *
 *)


(* ------------------------------------------------------------------- *)
{translate logical x location into physical pixel location}

function get_phys_x(vx: real): integer;
var x: real;
begin
   if (vx > maxx) then
      vx := maxx;
   if (vx < minx) then
      vx := minx;

   x := (phys_maxx - phys_minx) * (vx - minx) / (maxx - minx) + phys_minx;
   get_phys_x := trunc(x);
end;



{translate logical y location into physical pixel location}

function get_phys_y(vy: real): integer;
var y: real;
begin
   if (vy > maxy) then
      vy := maxy;
   if (vy < miny) then
      vy := miny;

   y := (phys_maxy - phys_miny) * (vy - miny) / (maxy - miny) + phys_miny;
   get_phys_y := trunc(y);
end;


(* ------------------------------------------------------------------- *)
procedure draw(x1,y1,x2,y2,color: integer);
begin
   SetColor(color);
   Line(x1,y1,x2,y2);
end;

procedure plot(x1,y1,color: integer);
begin
   SetColor(color);
   PutPixel(x1,y1,$FFFF);
end;



(* ------------------------------------------------------------------- *)
{connect two logical points with a line}

procedure connect(x1,y1,x2,y2: real);
var
  px1,py1,px2,py2: integer;
begin
   px1 := get_phys_x(x1);
   if x2 <> x1 then
      px2 := get_phys_x(x2)
   else
      px2 := px1;

   py1 := get_phys_y(y1);
   if y2 <> y1 then
      py2 := get_phys_y(y2)
   else
      py2 := py1;

   if (px1 <> px2) or (py1 <> py2) then
      draw(px1,py1,px2,py2,color)
   else
      plot(px1,py1,color);
end;



{place a tick mark on a point}

procedure tick(x1,y1: real);
begin
   plot(get_phys_x(x1),get_phys_y(y1),color);
end;



(* ------------------------------------------------------------------- *)
{determine a nice looking scale}

procedure determinescale (var world_min:     real;
                          var world_max:     real;
                          var stepsz:        real;
                          var stepcnt:       integer;
                              maxstep:       integer);
      var
         new_min:          real;
         new_max:          real;
         damper:           integer;
         pct:              real;
         range:            real;
         curstep:          integer;
         w:                real;

      const
         limit  =  32000;   {maximum number of iterations to determine
                             the new scale boundries}


(* return next higher stepsize multiplier *)
      function nextstep: real;
      begin
         case curstep of
            1:  nextstep := 2;    {2}
            2:  nextstep := 2.5;  {5}
            3:  nextstep := 2;    {10}
         end;

         curstep := curstep + 1;
         if curstep > 3 then
            curstep := 1;
      end;



(* return number of steps with current stepsz *)
      function nsteps: integer;
         var
            n:  real;

         begin
            if stepsz = 0.0 then
               n := 0.0
            else
               n := (new_max - new_min)/ stepsz + 1.5;

            if n < 0.0 then
               n := 0.0;

            if n >= maxint then
               n := maxint-1.0;

            nsteps := trunc (n);
         end;


   begin                         {determine proper step size}

(* find best step size *)

      new_min := world_min;
      new_max := world_max;
      curstep := 1;
      stepsz := 1;

      while (nsteps < maxstep) and (nsteps > 0) do
            stepsz := stepsz / 10.0;

      while (nsteps > maxstep) and (nsteps > 0) do
            stepsz := stepsz * nextstep;


(*
 * note - this process will take forever if you have a very narrow
 *        range that is sitting on a huge offset.  the damper variable
 *        will cause this routine to give up after limit iterations
 *        if it has not found the endpoints
 *)
      damper := 0;
      repeat

         new_min := 0.0;   {determine even endpoints based on stepsz}
         new_max := 0.0;

         if stepsz <> 0.0 then
         begin
            while (new_min <= world_min) and (damper < limit) do
            begin
               damper := damper + 1;
               new_min := new_min + abs(stepsz)*200.0;
            end;

            w := world_min;
            while (new_min > w) and (damper < limit) do
            begin
               damper := damper + 1;
               new_min := new_min - abs(stepsz);
            end;

            new_max := new_min;
            while (new_max >= world_max) and (damper < limit) do
            begin
               damper := damper + 1;
               new_max := new_max - abs(stepsz);
            end;

            w := world_max;
            while (new_max < w) and (damper < limit) do
            begin
               damper := damper + 1;
               new_max := new_max + abs(stepsz);
            end;
         end;

(* if new min/max causes extra steps, then go to a larger step size
   and try again *)
         stepcnt := nsteps;

         if stepcnt > maxstep then
            stepsz := stepsz * nextstep;

      until stepcnt <= maxstep;

      world_min := new_min;  {assign final return values}
      world_max := new_max;
   end;                       {PLOT_set_scale}



(* ------------------------------------------------------------------- *)
{place a marker at a logical point}

procedure marker(x,y: real; style: integer);
begin

   case style of
   1: begin     {place an X on the point}
          draw(get_phys_x(x)-mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)+mark_x,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)-mark_x,get_phys_y(y)+mark_y,
               get_phys_x(x)+mark_x,get_phys_y(y)-mark_y,yellow);
       end;

   2: begin     {place an box around the point}
          draw(get_phys_x(x)-mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)-mark_x,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)+mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)+mark_x,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)-mark_x,get_phys_y(y)+mark_y,
               get_phys_x(x)+mark_x,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)-mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)+mark_x,get_phys_y(y)-mark_y,yellow);
       end;

   3: begin     {place a triangle on the point}
          draw(get_phys_x(x)-mark_x,get_phys_y(y)+mark_y,
               get_phys_x(x)       ,get_phys_y(y)-mark_y,yellow);
          draw(get_phys_x(x)+mark_x,get_phys_y(y)+mark_y,
               get_phys_x(x)       ,get_phys_y(y)-mark_y,yellow);
          draw(get_phys_x(x)+mark_x,get_phys_y(y)+mark_y,
               get_phys_x(x)-mark_x,get_phys_y(y)+mark_y,yellow);
       end;

   4: begin     {place an inverted triangle on the point}
          draw(get_phys_x(x)-mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)       ,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)+mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)       ,get_phys_y(y)+mark_y,yellow);
          draw(get_phys_x(x)+mark_x,get_phys_y(y)-mark_y,
               get_phys_x(x)-mark_x,get_phys_y(y)-mark_y,yellow);
       end;
   end;
end;



(* ------------------------------------------------------------------- *)
{place a label on the y axis}

procedure labely(y: real);
var
   s: string;
begin
   MoveTo(1,get_phys_y(y));
   str(y:12:2,s);
   OutText(s);
end;



(* ------------------------------------------------------------------- *)
{place a tick mark on the y axis}

procedure ticky(y: real);
begin
   draw(trunc(phys_minx-mark_x),get_phys_y(y),
        trunc(phys_minx),       get_phys_y(y),color);
end;



(* ------------------------------------------------------------------- *)
{place a label on the x axis}

procedure labelx(x: real);
var
   s: string;
begin
   MoveTo(get_phys_x(x),trunc(phys_miny)+10);
   str(x:0:2,s);
   OutText(s);
end;



(* ------------------------------------------------------------------- *)
{place a tick mark on the x axis}

procedure tickx(x: real);
begin
   draw(get_phys_x(x),trunc(phys_miny-mark_y),
        get_phys_x(x),trunc(phys_miny),color);
end;



(* ------------------------------------------------------------------- *)
{output the x axis scales}

procedure putxscale;
var
   i,j:    integer;
   y:      real;
   x:      real;
   px,py:  integer;

begin
   x := minx;
   for i := 1 to nxsteps do
   begin
      labelx(x);
      px := get_phys_x(x);

      y := miny;
      for j := 1 to numtics*nysteps do
      begin
         py := get_phys_y(y);
         draw(px,py,px,py,color);
         y := y + ystep/numtics;
      end;

      for j := 1 to numtics do
      begin
         tickx(x);
         x := x + xstep/numtics;
      end;
   end;
end;



(* ------------------------------------------------------------------- *)
{output the y axis scales}

procedure putyscale;
var
   i,j:  integer;
   y:    real;

begin
   y := miny;

   for i := 1 to nysteps do
   begin
      labely(y);
      connect(minx,y,maxx,y);

      for j := 1 to numtics do
      begin
         ticky(y);
         y := y + ystep / numtics;
      end;
   end;
end;



(* ------------------------------------------------------------------- *)
{output the border and scales for the graph}

procedure border;
begin
   determinescale(minx,maxx,xstep,nxsteps,6);
   determinescale(miny,maxy,ystep,nysteps,6);

   color := green;
   putxscale;
   putyscale;

   color := red;
end;



(* ------------------------------------------------------------------- *)
procedure plot_data(variable_number: integer;
                    x:               integer;
                    y:               real);
begin
   tick(int(x),y);

   if (x mod 40) = 0 then
      marker(int(x),y,variable_number);
end;


(* ------------------------------------------------------------------- *)
procedure event(x: integer; note: string);
begin
   connect(int(x),miny,int(x),maxy);
   {writeln(note);}
end;


(* ------------------------------------------------------------------- *)
procedure open_graph;
begin
   Text_Mode := LastMode;
   Graph_Driver := detect;
   InitGraph(Graph_Driver,Graph_Mode,Driver_Path);

   phys_maxx := GetMaxX;
   phys_minx := trunc(int(GetMaxX)/6.2);

   phys_miny := trunc(int(GetMaxY)*154.0/200.0);
   phys_maxy := phys_miny div 5;
end;



(* ------------------------------------------------------------------- *)
procedure close_graph;
begin
   CloseGraph;
   TextMode(Text_Mode);
   window(1,1,80,25);
end;

