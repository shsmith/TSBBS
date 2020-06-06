
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
 * border.inc - draw a border around a window
 *
 * S.H.Smith, 14-Nov-87
 *
 *)

type
  border_styles = (blank_border,          single_border,
                   double_border,         mixed_border,
                   taildouble_border,
                   solid_border,          evensolid_border,
                   thinsolid_border,      lohatch_border,
                   medhatch_border,       hihatch_border);

const
  border_table:  array[blank_border..hihatch_border] of string[8] =
    ('        ',  { blank     }         '⁄ƒø≥≥¿ƒŸ',  { single    }
     '…Õª∫∫»Õº',  { double    }         '’Õ∏≥≥‘Õæ',  { mixed     }
     'ÃÕª∫∫»Õº',  { taildouble}
     '€€€€€€€€',  { solid     }         '€ﬂ€€€€‹€',  { evensolid }
     'ﬁﬂ›ﬁ›ﬁ‹›',  { thinsolid }         '∞∞∞∞∞∞∞∞',  { lohatch   }
     '±±±±±±±±',  { medhatch  }         '≤≤≤≤≤≤≤≤'); { hihatch   }

procedure display_border(topx,topy,botx,boty: integer;
                         style: border_styles);
   (* display a window border.  enter with desired color settingx*)
var
   left:        string[80];
   right:       string[80];
   top:         string[80];
   bottom:      string[80];
   width:       integer;
   b:           string[8];
   i,j:         integer;

const
   topleft  = 1;    {border character locations in border strings}
   tophor   = 2;
   topright = 3;
   leftver  = 4;
   rightver = 5;
   botleft  = 6;
   bothor   = 7;
   botright = 8;

   filler = ^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J^@^H^J;

begin
   b := border_table[style];
   width := botx - topx - 2;

(* top and bottom of frame *)
   bottom[0]    := chr(width+2);
   top[0]       := chr(width+2);
   top[1]       := b[topleft];
   for i := 2 to width+1 do
      top[i] := b[tophor];
   top[width+2] := b[topright];
   
   bottom[0]       := chr(width+2);
   bottom[1]       := b[botleft];
   for i := 2 to width+1 do
      bottom[i] := b[bothor];
   bottom[width+2] := b[botright];
   

(* sides of frame *)
   left := filler + filler;
   right := left;
   j := 1;
   for i := 2 to boty - topy do
   begin
      left[j]:= b[leftver];
      right[j]:= b[rightver];
      j := j + 3;
   end;
   left[0]:= chr (j - 1);
   right[0]:= left[0];

(* draw the frame *)
   gotoxy(topx,topy);     write(top);
   gotoxy(topx,topy+1);   write(left);
   gotoxy(botx-1,topy+1); write(right);
   gotoxy(topx,boty);     write(bottom);
end;

