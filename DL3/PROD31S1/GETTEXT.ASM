;
; (C)1989 Samuel H. Smith; ALL RIGHTS RESERVED.
; GETTEXT.ASM - Part of GET_TEXT procedure in PROMAIL.INC
;
        mov cx,[>maxpos]        ;cx=maxpos
        mov si,[>rawp]          ;si=rawp

        les bx,[>raw]           ;es:bx=raw^

        xor ah,ah
        mov al,[>tline]         ;di=length(tline)
        mov di,ax

        es:
        mov al,[si+bx-1]        ;c := raw[rawp]

        sub cx,si               ;cx=remaining chars in buffer
        inc si                  ;rawp++
        jcxz break              ;special case-- last char in buf

top:
        cmp al,<$e3             ;end on endline
        jz break

        cmp di,80               ;line full?
        jge linefull

        inc di                  
linefull:
        mov [di+>tline],al      ;line := line + c

        es:
        mov al,[si+bx-1]        ;c := raw[rawp++]
        inc si

        loop top                ;continue until end of buffer
                                ;or endline is seen

break:
        mov [>c],al             ;move registers back into ram
        mov [>rawp],si
        mov ax,di
        mov [>tline],al

