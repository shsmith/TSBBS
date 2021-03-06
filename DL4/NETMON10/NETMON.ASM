   title  NETMON - Network I/O Monitor 1.0
   page 60,132

;
; NETMON - Network I/O Monitor
;
; This program is a TSR that provides a running display of network i/o
; activity.  Should work with all LANBIOS type networks using interrupt 5c.
;
; Copyright 1993 Samuel H. Smith; All rights reserved.
;
;------------------------------------------------
;
;                                  LICENSE 
;                                  =======
;  SourceWare: What is it? 
;  -----------------------
;
;  SourceWare is my name for a unique concept in user supported
;  software.
;
;  Programs distributed under the SourceWare concept always offer source
;  code.
;
;  This package can be freely distributed so long as it is not modified
;  or sold for profit.  If you use this program regularly or are in a
;  government or corporate environment, you must register after 30 days
;  or discontinue it's use.  The registration fee is $5 per CPU.
;
;  Send your registration to:
;     Samuel H. Smith                 The Tool Shop BBS
;     P.O. Box 4808                   (818) 891-6780 (V.32bis) - FREE NODE
;     Panorama City CA 91412          (818) 891-1344 (V.32bis)
;                                     (818) 891-3772 (HST 9600)
;
;  Why SourceWare? 
;  ---------------
;  Why do I offer source code?  The source code is the key to complete
;  understanding of a program.  You can read it to find out how things
;  are done.  You can also change it to suit your needs, so long as you
;  do not distribute the modified version without my consent.
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
;

;------------------------------------------------
; macro- clear register
;
clr macro reg
        xor reg,reg
endm


;------------------------------------------------
; macro- dos function call
;
dosDispc       = 02h
dosDisplay     = 09h
dosSetvec      = 25h
dosGetvers     = 30h
dosGetvec      = 35h
dosFreemem     = 49h
dosExit        = 4ch
dosErrinfo     = 59h

msdos   macro funct,param
        ifb <param>
           mov ah,funct
        else
           mov ax,(funct*100h)+param
        endif
        int 21h
endm

;------------------------------------------------
; macro- get vector
; exit: vector stored in 'dword ptr ds:dest'
;
getvect macro vectnum,dest
        msdos dosGetvec,vectnum
        mov word ptr dest,bx
        mov word ptr dest+2,es
endm

;------------------------------------------------
; macro- set vector
;
setvect macro vectnum,handler
        lea dx,handler
        msdos dosSetvec,vectnum
endm

;------------------------------------------------
; macro- restore original vector
;
revect macro vectnum,ohandler
        lds dx,es:ohandler
        msdos dosSetvec,vectnum
endm

%newpage
;------------------------------------------------
; program segment prefix
;
code segment
        assume cs:code, ds:nothing, es:nothing, ss:nothing

        org 02ch
envseg  dw      ?       ;environment segment number

        org 80h
tailLen db      ?       ;command tail length
tail    db      ?

        org 100h
entry:
        jmp entryPoint


;------------------------------------------------
; working storage
;
signature       db 00,10,'Network I/O Monitor v1.0 ',??DATE
                db 13,10,'Copyright 1993 Samuel H. Smith; ALL RIGHTS RESERVED'
                db 13,10
crlfs           db 13,10,'$'

;program activity flag
active          db 0

; location of current video mode within segment 0
vidmode = 0449h

; display segment and offset
dispseg         dw 0b000h
dispofs1 = 78*2
dispofs2 = dispofs1+2
dispcolor = 120

; previous display contents
dispsave1       dw 0
dispsave2       dw 0

; twiddle display index
tw_index        dw 0

; twiddle display characters
tw_table        db '���O'

; vector for old interrupt
old_int5c       dd 0


;========================================
; new disk interrupt service
;----------------------------------------
int5c_handler proc far

        cmp active,0            ;already active(recursion)
        jnz useold

        jmp usenew

useold:
        jmp old_int5c           ;jump to the original handler

usenew:
        mov active,1            ;enter recursion

        push es
        push ax
        push bx
        push cx

        mov ah,es:[bx]          ;get netbios command code

        mov al,'L'              ;listen for call = L
        cmp ah,11h
        jz dspstat

        mov al,'N'              ;send data via NCB_LSN = N
        cmp ah,14h
        jz dspstat

        mov al,'R'              ;receive from a session
        cmp ah,15h
        jz dspstat

        mov al,'A'              ;receive from any session
        cmp ah,16h
        jz dspstat

        mov al,'M'              ;send multiple buffers = M
        cmp ah,17h
        jz dspstat

        mov al,'D'              ;send or receive datagrams
        cmp ah,20h
        jz dspstat
        cmp ah,21h
        jz dspstat
        cmp ah,23h
        jz dspstat

        mov al,'S'              ;get adaptor status
        cmp ah,33h
        jz dspstat

        mov al,'W'              ;send data without ACK
        cmp ah,71h
        jz dspstat
        cmp ah,72h
        jz dspstat
;
; unknown function code, use '*'
;
        mov al,2ah

; display the status code
dspstat:
        mov dispseg,0b800h         ;color default segment
        mov bx,0
        mov es,bx
        cmp byte ptr es:vidmode,7
        jnz colormode

        mov dispseg,0b000h  ;mono

colormode:
        mov bx,dispseg
        mov es,bx

        mov cx,es:dispofs1
        mov dispsave1,cx        ;save previous display contents
        mov cx,es:dispofs2
        mov dispsave2,cx

        mov ah,dispcolor        ;attribute of status char
        mov es:dispofs2,ax      ;display current status character

        mov bx,tw_index
        inc bx
        mov ah,bl               ;advance to next twiddle position
        and ah,7                ;bx=bx mod 8 to rotate through tws
        mov bl,ah
        mov tw_index,bx         ;save next twiddle index

        add bx,offset tw_table
        mov al,cs:[bx]          ;get the current twiddle character

        mov ah,dispcolor        ;attribute of twiddle status char
        mov es:[dispofs1],ax    ;put twiddle status on screen

        pop cx
        pop bx
        pop ax
        pop es

        pushf
        call old_int5c          ;perform requested function

        pushf
        push es
        push bx
        push ax

        mov bx,dispseg
        mov es,bx

        mov ax,dispsave1        ;get previous display contents
        mov es:dispofs1,ax      ;restore it to the screen
        mov ax,dispsave2        ;get previous display contents
        mov es:dispofs2,ax      ;restore it to the screen

        pop ax
        pop bx
        pop es
        mov active,0            ;return from recursion

        popf
        ret 2                   ;exit interrupt handler, drop caller's flags

int5c_handler endp

%newpage
; =============================================
; end of resident portion of code
;
resident:

; calculate size of resident portion in bytes and segments

TSRsize = (offset(resident)-offset(entry))
TSRsegs = (TSRsize / 16)


; initialization messages

license         db 'This package can be freely distributed so long as it is not modified or',13,10
                db 'sold for profit.  If you use this program regularly or are in a',13,10
                db 'government or corporate environment, you must register after 30 days or',13,10
                db 'discontinue it''s use.  The registration fee is 5 dollars US per CPU.',13,10
                db 13,10
                db 'Send your registration to:',13,10
                db '   Samuel H. Smith                 The Tool Shop BBS',13,10
                db '   P.O. Box 4808                   (818) 891-6780 (V.32bis) - FREE NODE',13,10
                db '   Panorama City CA 91412          (818) 891-1344 (V.32bis)',13,10
                db '                                   (818) 891-3772 (HST 9600)',13,10
                db 13,10
                db 'IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY',13,10
                db 'LOST PROFITS,  LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL',13,10
                db 'DAMAGES ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR',13,10
                db 'FOR ANY CLAIM BY ANY OTHER PARTY.',13,10
                db 13,10

usages          db 'Usage:  NETMON/I     ;install in memory.',13,10
                db '        NETMON/U     ;un-install.',13,10
                db '$'

ermonLoaded     db 'NETMON installed.',13,10,'$'
ermonRemoved    db 'NETMON unInstalled.',13,10,'$'
othersLoaded    db 'Other programs loaded after NETMON -- cannot unInstall.',13,10,'$'
alreadyLoaded   db 'Already loaded!',13,10,'$'
notLoaded       db 'NETMON is not resident.  Use NETMON/I first.',13,10,'$'


; ---------------------------------------------
; program entry point
;
entryPoint proc near
        push cs
        pop ds
        assume ds:code

        mov byte ptr signature,13       ;this keeps cache and non-active
                                        ;copies from returning the correct
                                        ;signature pattern
        lea si,tail
checkTail:
        lodsb
        cmp al,13
        jz usage

        cmp al,'/'
        jz checkOption
        cmp al,'-'
        jz checkOption
        jmp short checkTail

checkOption:
        lodsb
        and al,0ffh-20h         ;map to upper case

        cmp al,'U'
        jnz checkI

        call unInstall
        jmp short exitProgram

checkI:
        cmp al,'I'
        jnz usage
        jmp short newInstall


; ---------------------------------------------
; NETMON/? - display license and usage messages
;
usage:
        lea dx,signature
        call disps

        mov al,tailLen
        cmp al,0
        lea dx,usages
        jnz exitWithMessage

        lea dx,license
;       jmp short exitWithMessage


; ---------------------------------------------
exitWithMessage:
        call disps

exitProgram:
        mov byte ptr signature,10    ;this keeps cache and non-active
                                        ;copies from returning the correct
                                        ;signature pattern
        msdos dosExit,0


; ---------------------------------------------
; NETMON/I - new installation - hook vectors and go resident
;
newInstall:
        lea dx,signature
        call disps

        call checkPresent
        lea dx,alreadyLoaded
        jz installExit

        getvect 5ch,old_int5c           ;save original handler vectors

        setvect 5ch,int5c_handler       ;install new handlers

        mov es,envseg
        msdos dosFreemem                ;dealloc the tsr's environment segment

        lea dx,ermonLoaded
        call disps

        lea dx,resident                 ;terminate and stay resident
        int 27h

installExit:
        jmp short exitWithMessage
entryPoint endp


; =============================================
; check if dermon is already present
;
; exit: Z       NETMON is present,
;               es-> resident code segment
;
;       NZ      not present
;
checkPresent proc near
        getvect 5ch,old_int5c   ;get current handler vector
        les bx,old_int5c

        lea bx,cs:signature        ;cs:bx -> local signature
checkNext:
        mov al,ds:[bx]          ;get next byte from local message
        cmp al,'$'              ;end of message?
        jz checkExit            ;already present if so

        cmp al,es:[bx]          ;compare next byte to int5c handler
        jnz checkFail           ;new installation if mismatch

        inc bx                  ;got a match, try the next char
        jmp short checkNext

checkFail:
        inc ax                  ;not found, set NZ condition
checkExit:
        ret
checkPresent endp


; ---------------------------------------------
; display message in code segment
;       DX=offset message
;
disps proc near
        push bx
        push ds

        push cs
        pop ds
        msdos dosDisplay

        pop ds
        pop bx
        ret
disps endp


; ---------------------------------------------
; dispc - display a character
;       AL=character to display
;
dispc proc near
        push dx
        push bx

        mov dl,al
        msdos dosDispc

        pop bx
        pop dx
        ret
dispc endp


; ---------------------------------------------
; spaces - display a specified number of spaces
;       AX=number of spaces
;
spaces proc near
        push dx

spaceNext:
        cmp ax,0
        jz spaceExit

        push ax
        mov al,' '
        call dispc
        pop ax

        dec ax
        jmp short spaceNext

spaceExit:
        pop dx
        ret
spaces endp


; ---------------------------------------------
; NETMON/u - uninstall and exit
;
unInstall proc near
        call checkPresent
        lea dx,notLoaded
        jnz unExit

        mov bx,es               ;bx->tsr code segment
        mov ax,ds
        sub ax,bx               ;calculate memory usage after NETMON tsr

        lea dx,othersLoaded
        cmp ax,(TSRsegs+50)     ;amount of allowed overhead for DOS/PSP, etc.
        jge unExit              ;insure that others are not loaded after

        assume ds:nothing
        revect 5ch,old_int5c    ;unhook disk services interrupt

        msdos dosFreemem        ;dealloc the tsr's code segment

        push cs
        pop ds
        assume ds:code

        lea dx,ermonRemoved
unExit:
        call disps
        ret
unInstall endp

code ends
        end entry

