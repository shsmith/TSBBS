page 66,132

;*******************************************************************************
;
; BEEPER - Resident BEEP Handler
;
; This program is a TSR that traps bios BEEP signals and converts them
; background beeps with a command-line controlled frequency.
;
; Copyright 1992 Samuel H. Smith; All rights reserved.
;
;*******************************************************************************
;
;  This FREEWARE package can be freely distributed so long as it is not
;  modified or sold for profit.
;
;  The author can be contacted at:
;     Samuel H. Smith                 The Tool Shop BBS
;     P.O. Box 4808                   (818) 891-6780 (HAYES 9600) - Free node
;     Panorama City, CA 91412         (818) 891-3772 (HST 9600)
;                                     (818) 891-1344 (Four lines V.32Bis)
;
;  Copyright
;  ---------
;  If you modify this program,  I would appreciate a copy of the new
;  source code.  I am holding the copyright on the source code,  so
;  please don't delete my name from the program files or from the
;  documentation.
;
;                               DISCLAIMER
;                               ==========
;  I make no warranty of any kind, express or implied, including without
;  limitation, any warranties of merchantability and/or fitness for a
;  particular purpose.  I shall not be liable for any damages, whether
;  direct, indirect, special or consequential arising from a failure of
;  this program to operate in the manner desired by the user.  I shall
;  not be liable for any damage to data or property which may be caused
;  directly or indirectly by the use of this program.
;
;  IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY
;  LOST PROFITS,  LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL
;  DAMAGES ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR
;  FOR ANY CLAIM BY ANY OTHER PARTY.
;

code segment
                assume  cs:code, ds:nothing, ss:nothing, es:nothing

;*******************************************************************************
; program segment prefix
;
                org 80h
tailLen         db ?            ; command tail length
tail            db ?            ; command tail text

                org 100h
start:          jmp entry


;*******************************************************************************
; working storage
;

freq_divisor    dw 0C00h        ; base frequency divisor

max_pending = 10                ; maximum number of beeps to keep pending
bells_pending   db 0            ; number of beeps currently pending

bell_state      db 0            ; sounding state for current beep

old_int8        dd 0            ; old int 8h handler
old_int10       dd 0            ; old int 10h handler


;*******************************************************************************
;*
;*  new_int8 - replacement timer tick interrupt handler
;*
;*******************************************************************************

new_int8 proc near
                push ax

                cmp bells_pending,0
                jne bell_active

use_old8:       pop ax
                jmp old_int8

bell_active:    inc bell_state
                cmp bell_state,1
                je begin_sound
                cmp bell_state,3
                je begin_nosound
                cmp bell_state,4
                je end_bell
                jmp use_old8

begin_sound:    mov ax,freq_divisor
                out 42h,al
                mov al,ah
                out 42h,al
                in al,61h
                or al,3
                out 61h,al
                jmp use_old8

begin_nosound:  in al,61h
                and al,0FCh
                out 61h,al
                jmp use_old8

end_bell:       mov bell_state,0
                dec bells_pending
                jmp use_old8

new_int8 endp

;*******************************************************************************
;*
;*  new_int10 - replace bios video services handler
;*
;*******************************************************************************

new_int10 proc near

                cmp ax,0E07h            ; check for bell request
                je count_bell

                cmp ax,'BE'
                jne use_old10
                cmp bx,'EP'
                jne use_old10

                xchg bx,ax              ; test to see if 'bell' is loaded
		iret				

use_old10:      jmp cs:old_int10

count_bell:     cmp cs:bells_pending,max_pending
                jge fin_int10           ; discard this beep if maximum
                                        ; number of beeps already pending

                inc cs:bells_pending

fin_int10:      sti
		iret				

new_int10 endp

;*******************************************************************************
;*
;*  entry - install new bell handler if needed
;*
;*******************************************************************************

entry:          push cs
                pop ds
                assume ds:code

                mov ax,'BE'
                mov bx,'EP'
                int 10h                 ; check for previous install
                xor ax,'EP'
                xor bx,'BE'
                or ax,bx
                jne not_installed

                lea dx,already_installed_msg
                mov ah,9
                int 21h                 ; Display string
                int 20h                 ; Program terminate

not_installed:  lea si,tail

check_tail:     lodsb
                cmp al,13
                jz usage
                cmp al,' '
                je check_tail
                cmp al,'0'
                jb usage
                cmp al,'9'
                ja usage

                ;valid parameter found- alter MSB of freq_divisor and install
                mov ah,byte ptr freq_divisor+1
                sub al,'0'
                sub ah,al
                mov byte ptr freq_divisor+1,ah
                jmp install


usage:          lea dx,usage_msg
                mov ah,9
                int 21h                 ; Display string
                int 20h                 ; Program terminate

install:        mov ax,3508h
                int 21h                 ; Get interrupt vector 08h
                mov di,offset old_int8
                mov Word Ptr [di],bx
                mov Word Ptr [di+2],es

                mov ax,3510h
                int 21h                 ; Get interrupt vector 10h
                mov di,offset old_int10
                mov Word Ptr [di],bx
                mov Word Ptr [di+2],es

                mov dx,offset new_int8
                mov ax,2508h
                int 21h                 ; Set interrupt vector 08h

                mov dx,offset new_int10
                mov ax,2510h
                int 21h                 ; Set interrupt vector 10h

                lea dx,now_installed_msg
                mov ah,9
                int 21h                 ; Display string

                mov dx,offset entry
                int 27h                 ; Terminate and stay resident

;*******************************************************************************

cr = 13
lf = 10

already_installed_msg   db cr,lf,7
                        db '*** Error - BEEPER already installed!',cr,lf
                        db '$'

usage_msg               db cr,lf
                        db 'A base frequency code between 0 and 9 must be specified.',cr,lf
                        db 'Usage: BEEPER [0..9]',cr,lf
                        db '$'

now_installed_msg       db cr,lf,7
                        db 'BEEPER (2/16/93) Copyright 1993 Samuel H. Smith',cr,lf
                        db 'Beeper installed!',cr,lf
                        db '$'

code ends
                end start

