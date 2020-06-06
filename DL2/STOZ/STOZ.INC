
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

(*------------------------------------------
 *
 * ztos - convert a zero terminated string into a turbo string (tpas 4.0)
 *
 *   (C) 1988 Samuel H. Smith (rev. 12-01-88)
 *
   Inline(
     $C4/$7E/$06/           {   les di,[bp]6         ;es:di -> st[0]}
     $26/                   {   es:}
     $8A/$0D/               {   mov cl,[di]          ;cl = length}
     $FE/$C1/               {   inc cl}
                            {next:}
 *
 *)

{$F+} procedure ztos(var z: zstring;
                     var s: string); {$F-}
begin

   Inline(
       $1E             {    push ds                            }
      /$FC             {    cld             ;direction fwd     }
      /$C5/$76/$08     {    lds si,[bp]8    ;ds:si --> z[0]    }
      /$C4/$7E/$04     {    les di,[bp]4    ;es:di --> s[0]    }
      /$47             {    inc di          ;skip over length  }
      /$B1/$FF         {    mov cl,=-1      ;length counter    }

                       { loop:                                 }
      /$FE/$C1         {    inc cl          ;count a byte      }
      /$AC             {    lods(b)         ;al=*ds:si++       }
      /$AA             {    stos(b)         ;*es:di++=al       }
      /$3C/$00         {    cmp al,=0       ;repeat until zero }
      /$75/$F8         {    jnz loop                           }

      /$C5/$7E/$04     {    lds di,[bp]4    ;store the length  }
      /$88/$0D         {    mov [di],cl     ;ds:di=length      }
      /$1F             {    pop ds                             }
   );

end;


(*------------------------------------------
 *
 * stoz - convert a turbo string into a zero terminated string
 *
 *)

{$F+} procedure stoz(var s: string;
                     var z: zstring); {$F-}
begin

   Inline(
       $1E             {    push ds                           }
      /$FC             {    cld             ;direction fwd    }
      /$C4/$7E/$04     {    les di,[bp]4    ;es:di --> z[0]   }
      /$C5/$76/$08     {    lds si,[bp]8    ;ds:si --> s[0]   }
      /$AC             {    lods(b)                           }
      /$8A/$C8         {    mov cl,al                         }
      /$B5/$00         {    mov ch,=0       ;cx is length     }
      /$F2/$A4         {    rep movs(b)     ;copy the string  }
      /$B0/$00         {    mov al,=0                         }
      /$AA             {    stos(b)         ;append the zero  }
      /$1F             {    pop ds                            }
   );

end;


