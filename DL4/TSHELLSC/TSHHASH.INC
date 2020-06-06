
#log Keyword hashing

(*------------------------------------------
 *
 * key_hash
 *    use a hashing function to find the calc key for a
 *    key string in the define table.
 *    overflows handled elsewhere.
 *
 *)

function key_hash(var keys: anystring): integer;
var
   hash:   integer;
   i:      integer;

begin

   hash := 0;

(*
 *    for i := 0 to ord(keys[0]) do
 *       hash := hash xor (ord(keys[i]) - i + ord(keys[0]));
 *)

   Inline(
    $C4/$76/$04      {    les si,[bp]4   ;es:si --> keys[0] }

   /$26/$8A/$0C      {    mov cl,es:[si] ;cx=count          }
   /$B5/$00          {    mov ch,=0                         }
   /$41              {    inc cx                            }

   /$8B/$46/$FC      {    mov ax,[bp]-4  ;hash              }

                     { next:                                }
   /$8A/$F5          {    mov dh,ch                         }
   /$26/$8A/$14      {    mov dl,es:[si] ;dx=*key++         }
   /$46              {    inc si                            }

   /$28/$CA          {    sub dl,cl      ;-i                }
   /$33/$C2          {    xor ax,dx                         }

   /$E2/$F4          {    loop next                         }

   /$89/$46/$FC  );  {    mov [bp]-4,ax  ;result -->hash    }

   key_hash := (abs(hash) mod max_define) + 1;
end;

