;
; Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
;
; This is a component of the ProDoor System.
; Do not distribute modified versions without my permission.
; Do not remove or alter this notice or any other copyright notice.
; If you use this in your own program you must distribute source code.
; Do not use any of this in a commercial product.
;
; ---------------------------------------------------------------------------
;
; ProECHO - Echo command for use in prodoor generated batch scripts.
;
; (3-1-89)
;
; This program is provided courtesy of:
;         The Tool Shop
;         Phoenix, Az
;         (602) 279-2673
;
code segment

                org     80h
tail_length     db      ?               ;length of command tail
tail            db      80h dup(?)      ;the command tail text

                org     100h
                assume  cs:code,ds:nothing,es:nothing,ss:nothing
entryPoint:     jmp     startup

metanewline = 0         ;display the newline character
newline = '~'           ;display a newline (cr/lf)

offline = -1            ;comport when offline
comport         dw      offline            


; ---------------------------------------------------------------------------
;   Working storage
;
copyright       db      newline,'ProEcho (C) 1988, 1989 S.H.Smith; v2.9 03-01-89'
                db      newline,'ProDoor Batch Message Echo Module'
                db      newline,'Courtesy of The Tool Shop BBS, (602) 279-2673'
                db      newline
                db      newline,'Usage:   proecho PORT TEXT ...'
                db      newline,'         (use "',metanewline,'" to insert newlines)'
                db      newline
                db      newline,'Sets ERRORLEVEL 2 if local mode.'
                db      newline,'Sets ERRORLEVEL 1 if carrier is NOT present.'
                db      newline,'Sets ERRORLEVEL 0 if carrier present.'
                db      newline
                db      newline,'Example: proecho 1 ',metanewline
                db              'Testing your uploads.  Please wait...'
                db              metanewline,metanewline
                db      newline,13


; ---------------------------------------------------------------------------
;    entry:     dl      character to output
;               comport com port to echo to 
;
outchar proc near
                push    bx

                mov     ah,2            ;display on screen
                int     21h             

                cmp     comport,offline
                jz      outx            ;no com echo if offline

                push    dx
                mov     al,0
                mov     ah,3            ;carrier status
                mov     dx,comport
                int     14h
                pop     dx              ;no output without carrier
                and     ax,80h
                jz      outx

                mov     al,dl
                mov     ah,1            ;send 1 char, char is in al
                mov     dx,comport
                int     14h

outx:           pop     bx
                ret
outchar endp


; ---------------------------------------------------------------------------
;    entry:     ds:bx   text to display
;               ends on ascii c/r
;
disp proc near
                mov     dl,[bx]
                cmp     dl,13
                jz      displayx
                cmp     dl,metanewline
                jnz     nlcheck

                mov     dl,newline
                jmp     normal

nlcheck:        cmp     dl,newline
                jnz     normal

                mov     dl,13
                call    outchar
                mov     dl,10
normal:
                call    outchar
                inc     bx
                jmp     disp

displayx:       ret
disp endp


; ---------------------------------------------------------------------------
;  startup entry point
;
                assume  ds:code
startup:
                mov     al,tail_length
                cmp     al,2            ;is the comport param present?
                jl      usage

                mov     al,tail+1
                sub     al,'0'+1        ;set comport
                mov     ah,0
                mov     comport,ax

                mov     bx,(offset tail) + 3
                call    disp            ;display command tail
                jmp     terminate


usage:          mov     bx,offset copyright
                call    disp

terminate:
                cmp     comport,offline
                mov     al,2            ;set errorlevel 2 in local mode
                jz      termx

                mov     al,0
                mov     ah,3            ;get carrier status
                mov     dx,comport
                int     14h
                and     ax,80h
                mov     al,1
                jz      termx           ;set errorlevel 1 if no carrier

                mov     al,0            ;set errorlevel 0 if carrier present
termx:
                mov     ah,4ch          ;terminate process
                int     21h
code ends
                end entryPoint


