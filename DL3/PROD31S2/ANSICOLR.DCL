
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
{color selection constants}
type
   color_string = string8;

{default colors}
const
   ansi_ccolor:  color_string = 'none';

   ansi_colors:  array[0..8] of color_string =
        ('0', '1;31', '1;32', '1;33', '1;34', '1;35', '1;36', '1;37', '0');

   ansi_default = 0;
   ansi_red     = 1;
   ansi_green   = 2;
   ansi_yellow  = 3;
   ansi_blue    = 4;
   ansi_magenta = 5;
   ansi_cyan    = 6;
   ansi_white   = 7;
   ansi_gray    = 8;

   graphics:     boolean = false;  {is graphics mode active?}
   
