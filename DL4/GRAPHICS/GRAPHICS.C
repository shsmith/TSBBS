
/* This library started out for the Microsoft C compiler.  It was converted
   and optimized for the Datalight C compiler by S.H.Smith, 6-dec-86.  */

/*
    MODULE: Graphics package for color graphics modes 320x200 and 640x200.
            Code written for Datalight C Compiler version 2.03 or greater.

        This is simply a two-dimensional graphics package that allows a
        user of Datalight C to display graphics.  The package is as
        follows:

        [ 1 ]   GINIT(mode) initializes the graphics enviroment; mode is a
                one letter literal.  The value of mode may be 'H' for 640x200 
                graphics, 'L' for 320x200 graphics, or 'T' for 80x25 text mode.
                The viewport is initially set to the full size of the screen 
                in either (640 or 320)x200 graphics depending upon the value 
                of [mode].  The window is initialized with the origin at the 
                center of the screen with a range of [-1.0,1.0] in the 'X' 
                direction and a range of [-1.0,1.0] in the 'Y' direction.
                
                NOTE: All data to be ploted will be mapped through the window
                onto the viewport.  The data must be given in the World
                Coordinate system (i.e.  time starting from  t=0 to lets say
                t=60 microrseconds along the X axis and the volume of air in
                a bursting balloon along the Y axis.).  The data is just mapped
                onto the screen.

        [ 2 ]   GCLEAR() clears the graphics screen.

        [ 3 ]   GCOLOR(color) changes pixel color on future writes to the
                graphics screen.  In High resolution mode, the value of
                [color] must be either a 1 (one) for ON or a 0 (zero) for
                OFF.  In Low resolution mode, the value of [color] may be
                in the range of [0,3] which allows 4 (four) colors: three
                colors and one background.  When GINIT is called, the
                color is initialized to [color=1].

        [ 4 ]   GPLOT(Old_x, Old_y) plots a point in world coordinates
                and uses the current color setting.  The point is mapped
                through the window onto the viewport.  After every plot,
                the current point becomes (Old_x, Old_y).

        [ 5 ]   GDRAW(New_x, New_y) draws a line from the current point to
                the point (New_x, New_y) and uses the current color setting.
                After the line is drawn, the final point becomes the current
                point.

        [ 6 ]   GCIRCLE(center_x, center_y, radius) draws a circle with its
                center at the given point with the given radius.  The point
                and radius are given in world corrdinates.  NOTE:  This
                function plots a circular figure; the circle is modified
                by the size of the viewport (the aspect ratio affects the
                shape).  The function works best if the ranges of the
                horizontal and vertical axis are the same.  The figure is
                plotted in the current color.

        [ 7 ]   GWINDOW(Gw_xmin, Gw_ymin, Gw_xmax, Gw_ymax) defines the lower left
                and the upper right points of the world coordinates window.

        [ 8 ]   GVIEW(Gv_xmin, Gv_ymin, Gv_xmax, Gv_ymax) defines the absolute pixel
                values of the upper left and lower right points of the screen.
                NOTE:  For 640x200 graphics. the screen is set up as follows.

                    0,0                                     639,0
                      ******************************************
                      *                                        *
                      *                                        *
                      *                                        *
                      *                                        *
                      *                                        *
                      ******************************************
                    0,199                                   639,199

                    
                and for 320x200 graphics:

                    0,0                                     319,0
                      ******************************************
                      *                                        *
                      *                                        *
                      *                                        *
                      *                                        *
                      *                                        *
                      ******************************************
                    0,199                                   319,199

*/

#include <stdio.h>
#include <math.h>
#include <dos.h>

double
   Gx_old,  Gy_old,
   Gx_new,  Gy_new,
   Gw_xmin, Gw_xmax,
   Gw_ymin, Gw_ymax,
   Gx_mult, Gy_mult;

char
   G_ok = 'n',
   G_crtmode,
   G_mode,
   G_color = 1;

int
   Gx, Gy,
   Gv_xmin, Gv_xmax,
   Gv_ymin, Gv_ymax;

int debug_mode = 0;

union REGS G_regs;


#define absv(a)     ((a) > 0 ? (a) : -(a))
#define maxv(a,b)   ((a) > (b) ? (a) : (b))
#define minv(a,b)   ((a) < (b) ? (a) : (b))



/*****************************************************************************/

Gcheck()
{
    if ( G_ok != 'y') {
        printf("\nGCLEAR: graphics not initialized. See GINIT.\n");
        exit(1);
    }
}


/*****************************************************************************/

GINIT(mode)
char mode;
{
    int i;

    if ( mode == 'L' || mode == 'l' ) {
        Gv_xmax = 319;
        G_crtmode = 0x04;
        G_mode = 'L';
        G_ok = 'y';
    }
    else if ( mode == 'H' || mode == 'h' ) {
        Gv_xmax = 639;
        G_crtmode = 0x06;
        G_mode = 'H';
        G_ok = 'y';
    }
    else if ( mode == 'T' || mode == 't' ) {
        Gv_xmax = 79;
        G_crtmode = 0x02;
        G_mode = 'T';
        G_ok = 'n';
    }
    else {
        printf("\nGINIT: can't open graphics mode: %c\n", mode);
        exit(1);
    }

    G_regs.h.ah = 0x00;
    G_regs.h.al = G_crtmode;
    int86(0x10, &G_regs, &G_regs);

    Gx_old = Gx_new = Gy_old = Gy_new = Gv_xmin = Gv_ymin = 0;
    Gv_ymax = 199;
    Gw_xmin = Gw_ymin = -1.0;
    Gw_xmax = Gw_ymax =  1.0;
    Gx_mult = (double)(Gv_xmax - Gv_xmin) / (Gw_xmax - Gw_xmin);
    Gy_mult = (double)(Gv_ymax - Gv_ymin) / (Gw_ymax - Gw_ymin);
    G_color = 1;

    if ( G_ok == 'y' )
       GCLEAR();
}

/*****************************************************************************/

GCLEAR()
{
   Gcheck();

/* text mode to erase display */
    G_regs.h.ah = 0x00;
    G_regs.h.al = 0x02;
    int86(0x10, &G_regs, &G_regs);

/* reset to graphics mode */
    G_regs.h.ah = 0x00;
    G_regs.h.al = G_crtmode;
    int86(0x10, &G_regs, &G_regs);
}

/*****************************************************************************/

GCOLOR(c)
char c;
{
    Gcheck();
    G_color = c;
}

/*****************************************************************************/


GWINDOW(xmin,ymin,xmax,ymax)   /* set world coordinates */
double xmin,ymin,xmax,ymax;
{
    Gcheck();
    Gw_xmin = xmin;
    Gw_ymin = ymin;
    Gw_xmax = xmax;
    Gw_ymax = ymax;
    Gx_mult = (double)(Gv_xmax - Gv_xmin) / (Gw_xmax - Gw_xmin);
    Gy_mult = (double)(Gv_ymax - Gv_ymin) / (Gw_ymax - Gw_ymin);
}

/*****************************************************************************/


GVIEW(xmin,ymin,xmax,ymax)   /* set physical graphic area */
int xmin,ymin,xmax,ymax;
{
    Gcheck();
    Gv_xmin = xmin;
    Gv_ymin = ymin;
    Gv_xmax = xmax;
    Gv_ymax = ymax;
    Gx_mult = (double)(Gv_xmax - Gv_xmin) / (Gw_xmax - Gw_xmin);
    Gy_mult = (double)(Gv_ymax - Gv_ymin) / (Gw_ymax - Gw_ymin);
}

/*****************************************************************************/

GPLOT(x,y)
double x,y;
{
     if (debug_mode > 0)
     {
        if ((x > maxv(Gw_xmin,Gw_xmax)) || (x < minv(Gw_xmin,Gw_xmax)) ||
            (y > maxv(Gw_ymin,Gw_ymax)) || (y < minv(Gw_ymin,Gw_ymax)))
               printf("plot: illegal %g,%g\n",x,y);
     }

     Gx = Gx_old = (double)Gv_xmin + Gx_mult * (x - Gw_xmin);
     Gy = Gy_old = (double)Gv_ymax - Gy_mult * (y - Gw_ymin);
     Gputdot();
}

/*****************************************************************************/

GDRAW(x,y)
double x,y;
{
    double dx,dy;
    int xd,yd;
    int adx,ady;
    int i,n;

     if (debug_mode > 0)
     {
        if ((x > maxv(Gw_xmin,Gw_xmax)) || (x < minv(Gw_xmin,Gw_xmax)) ||
            (y > maxv(Gw_ymin,Gw_ymax)) || (y < minv(Gw_ymin,Gw_ymax)))
               printf("draw: illegal %g,%g\n",x,y);
     }

    Gx_new = (double)Gv_xmin + Gx_mult * (x - Gw_xmin);
    dx = (Gx_new - Gx_old);
    adx = dx;
    adx = absv(adx);

    Gy_new = (double)Gv_ymax - Gy_mult * (y - Gw_ymin);
    dy = (Gy_new - Gy_old);
    ady = dy;
    ady = absv(ady);

/* stop now if no movement is needed */
    n = maxv(adx,ady) * 2;
    if (n == 0)
        return;

   if (debug_mode > 1)
      printf("%g,%g to %g,%g c=%d \r",
             Gx_old, Gy_old,
             Gx_new, Gy_new,
             G_color);

/* move only in y direction */
    if (adx == 0) 
    {
       Gx = Gx_old;
       Gy = minv(Gy_new,Gy_old);
       for (i = 0; i <= ady; i++)
       {
          Gputdot();
          Gy += 1;
       }
    }
    else 

/* move only in x direction */
    if (ady == 0)
    {
       Gy = Gy_old;
       Gx = minv(Gx_new,Gx_old);
       for (i = 0; i <= adx; i++)
       {
          Gputdot();
          Gx += 1;
       }
    }
    else

/* move along a diagonal */
    if (ady == adx)
    {
       if (Gx_new > Gx_old) xd = 1; else xd = -1;
       if (Gy_new > Gy_old) yd = 1; else yd = -1;
       Gx = Gx_old;
       Gy = Gy_old;
       for (i = 0; i <= adx; i++)
       {
          Gputdot();
          Gx += xd;
          Gy += yd;
       }
    }
    else

/* move both x and y (slowly) */
    {
       dx /= (double)n;
       dy /= (double)n;

       for (i = 0; i <= n; ++i)  {
           Gx = Gx_old;
           Gx_old += dx;

           Gy = Gy_old;
           Gy_old += dy;

           Gputdot();
       }
    }

/* record endpoint for next call */
    Gx_old = Gx_new;
    Gy_old = Gy_new;
}

/*****************************************************************************/

/***
GCIRCLE(x,y,r)
double x, y, r;
{
    double theta, omega;

    if ( (x+r) > Gw_xmax || (x-r) < Gw_xmin ||
         (y+r) > Gw_ymax || (y-r) < Gw_ymin || r <= 0.0  ) {
        printf("\nGCIRCLE: out of range.\n");
        exit(1);
    }

    GPLOT(x+r,y);
    for ( theta = 0.0 ; theta <= 360.0 ; theta += 0.5 ) {
        omega = theta * ( 3.14159 / 180.0 );
        GDRAW( x + r*cos(omega), y + r*sin(omega) );
    }
}
***/

/*****************************************************************************/

Gputdot()
{
    if ( (Gx < Gv_xmin) || (Gx > Gv_xmax) || (Gy < Gv_ymin) || (Gy > Gv_ymax) )
       return;

    G_regs.h.ah = 0x0c;       /* write dot function */
    G_regs.h.al = G_color;
    G_regs.x.dx = Gy;
    G_regs.x.cx = Gx;
    int86(0x10, &G_regs, &G_regs);
}

/*****************************************************************************/
