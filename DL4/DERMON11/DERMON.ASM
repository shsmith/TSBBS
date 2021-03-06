   title  DERMON - Disk Error Monitor 1.1
   page 60,132

;
; DERMON - Disk Error Monitor
;
; This program is a TSR that records the last several disk errors
; and reports them on demand.
;
; Copyright 1990 Samuel H. Smith; All rights reserved.
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
;  or sold for profit.  If you find that this program is valuable, you
;  can send me a donation for what you think it is worth.  I suggest
;  about $10.
;
;  Send your contributions to:
;     Samuel H. Smith                 The Tool Shop BBS
;     5119 N. 11th Ave., #332         (602) 264-3969 (2400) - Free node
;     Phoenix AZ 85013                (602) 279-0230 (HAYES 9600)
;                                     (602) 279-2673 (HST 9600)
;
;  Why SourceWare? 
;  ---------------
;  Why do I offer source code?  Why isn't the donation manditory?  The
;  value of good software should be self-evident.  The source code is
;  the key to complete understanding of a program.  You can read it to
;  find out how things are done.  You can also change it to suit your
;  needs, so long as you do not distribute the modified version without
;  my consent.
;
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
signature       db 00,10,'Disk Error Monitor v1.1 ',??DATE
                db 13,10,'Copyright 1990 Samuel H. Smith; ALL RIGHTS RESERVED'
                db 13,10
crlfs           db 13,10,'$'

;program activity flag
active db 0      

; vector for old interrupt
old_int13  dd 0

;error result log
maxEntries = 50         ;maximum number of error log entries
logNext         dw 0    ;index to next log table entry

logAx           dw maxEntries dup(0)
logCx           dw maxEntries dup(0)
logDx           dw maxEntries dup(0)
logResult       dw maxEntries dup(0)    ;0=unused table entry

;total number of disk errors
errorCount     dw 0


;========================================
; new disk interrupt service
;----------------------------------------
int13_handler proc far

   cmp active,0              ;already active(recursion)
   jnz useold

   cmp ah,02h   ;read
   jz usenew
   cmp ah,03h   ;write
   jz usenew
   cmp ah,04h   ;verify
   jz usenew
   cmp ah,0ah   ;long read
   jz usenew
   cmp ah,0bh   ;long write
   jz usenew
   cmp ah,0ch   ;seek to cylinder
   jz usenew

useold:
   jmp old_int13             ;jump to the real DOS handler

usenew:
   mov active,1              ;enter recursion

   push bx                   ;record current activity
   mov bx,logNext
   add bx,bx
   mov logAx[bx],ax
   mov logCx[bx],cx
   mov logDx[bx],dx
   mov word ptr logResult[bx],0
   pop bx

   pushf
   call old_int13            ;perform requested function
   jnc noerror

   inc errorCount

   push bx                   ;record error result
   mov bx,logNext
   add bx,bx
   mov logResult[bx],ax
   mov bx,logNext
   inc bx
   cmp bx,maxEntries
   jl advance

   clr bx

advance:
   mov logNext,bx
   pop bx

noerror:
   mov active,0              ;return from recursion
   ret 2                     ;exit interrupt handler, drop caller's flags

int13_handler endp

%newpage
; =============================================
; end of resident portion of code
;
resident:

; calculate size of resident portion in bytes and segments

TSRsize = (offset(resident)-offset(entry))
TSRsegs = (TSRsize / 16)


; initialization messages

license         db 'This program can be freely distributed so long as it is not modified',13,10
                db 'or sold for profit.  If you find that this program is valuable, you',13,10
                db 'can send me a donation for what you think it is worth.  I suggest',13,10
                db 'about 10 dollars.',13,10
                db 13,10
                db 'Send your registrations to:        The Tool Shop BBS',13,10
                db '   Samuel H. Smith                 (602) 264-3969 (2400) - Free node',13,10
                db '   5119 N. 11th Ave., #332         (602) 279-2673 (HST 9600)',13,10
                db '   Phoenix AZ 85013                (602) 279-0230 (HAYES 9600)',13,10
                db 13,10
                db 'IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY',13,10
                db 'LOST PROFITS,  LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL',13,10
                db 'DAMAGES ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR',13,10
                db 'FOR ANY CLAIM BY ANY OTHER PARTY.',13,10
                db 13,10

usages          db 'Usage:  DERMON/I     ;install in memory.',13,10
                db '        DERMON/U     ;un-install.',13,10
                db '        DERMON/C     ;display disk error counters.',13,10
                db '        DERMON/Z     ;zero error counters.',13,10
                db '$'

ermonLoaded     db 'DERMON installed.',13,10,'$'
ermonRemoved    db 'DERMON unInstalled.',13,10,'$'
othersLoaded    db 'Other programs loaded after DERMON -- cannot unInstall.',13,10,'$'
alreadyLoaded   db 'Already loaded!',13,10,'$'
notLoaded       db 'DERMON is not resident.  Use DERMON/I first.',13,10,'$'


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

        cmp al,'Z'
        jnz checkC

        call zeroStats
        jmp short exitProgram

checkC:
        cmp al,'C'
        jnz checkU

        call reportStats
        jmp short exitProgram

checkU:
        cmp al,'U'
        jnz checkI

        call unInstall
        jmp short exitProgram

checkI:
        cmp al,'I'
        jnz usage
        jmp short newInstall


; ---------------------------------------------
; DERMON/? - display license and usage messages
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
        mov byte ptr cs:signature,10    ;this keeps cache and non-active
                                        ;copies from returning the correct
                                        ;signature pattern
        msdos dosExit,0


; ---------------------------------------------
; DERMON/I - new installation - hook vectors and go resident
;
newInstall:
        lea dx,signature
        call disps

        call checkPresent
        lea dx,alreadyLoaded
        jz installExit

        getvect 13h,old_int13           ;save original handler vectors

        setvect 13h,int13_handler       ;install new handlers

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
; exit: Z       DERMON is present,
;               es-> resident code segment
;
;       NZ      not present
;
checkPresent proc near
        mov ax,cs               ;start one segment below here
        dec ax
        mov es,ax

checkSegment:
        lea bx,signature        ;cs:bx -> local signature
checkNext:
        mov al,ds:[bx]          ;get next byte from local message
        cmp al,'$'              ;end of message?
        jz checkExit            ;already present if so

        cmp al,es:[bx]          ;compare next byte to int13 handler
        jnz checkFail           ;new installation if mismatch

        inc bx                  ;got a match, try the next char
        jmp short checkNext

checkFail:
        mov ax,es
        dec ax                  ;try next lower segment
        mov es,ax
        jnz checkSegment

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
; DERMON/u - uninstall and exit
;
unInstall proc near
        call checkPresent
        lea dx,notLoaded
        jnz unExit

        mov bx,es               ;bx->tsr code segment
        mov ax,ds
        sub ax,bx               ;calculate memory usage after DERMON tsr

        lea dx,othersLoaded
        cmp ax,(TSRsegs+50)     ;amount of allowed overhead for DOS/PSP, etc.
        jge unExit              ;insure that others are not loaded after

        assume ds:nothing
        revect 13h,old_int13    ;unhook disk services interrupt

        msdos dosFreemem        ;dealloc the tsr's code segment

        push cs
        pop ds
        assume ds:code

        lea dx,ermonRemoved
unExit:
        call disps
        ret
unInstall endp


; ---------------------------------------------
; DERMON/C - report error counts
;
reportPrefix    db 13,10,'Disk Error Monitor Status:$'
errorCounts     db 'disk errors.',13,10,'$'

tablePrefix     db 13,10
                db 'Function  Drive  Head  Cylinder  Sector  Count    Error Description',13,10
                db '--------  -----  ----  --------  ------  -----  ---------------------------',13,10,'$'

reportStats proc near
        call checkPresent
        lea dx,notLoaded
        jnz reportExit

        push es
        pop ds
        assume ds:code          ;ds->resident code segment

        lea dx,reportPrefix
        call disps

        mov ax,errorCount
        call decimal

        lea dx,errorCounts
        cmp errorCount,0
        jz reportExit

        call disps

        lea dx,tablePrefix
        call disps

        clr bx
reportNext:
        cmp word ptr logResult[bx],0
        jz reportSkip

        call reportFun          ;AH=function
        call reportDrive        ;report drive/head/sector
        call reportResult

        lea dx,crlfs
        call disps

reportSkip:
        inc bx
        inc bx
        cmp bx,(maxEntries*2)
        jl reportNext
        ret

reportExit:
        call disps
        ret
reportStats endp


; ---------------------------------------------
; report disk function
;       AH=bios function
;
funRead         db ' Read   $'
funWrite        db ' Write  $'
funVerify       db ' Verify $'
funSeek         db ' Seek   $'
funBad          db ' Unknown$'

reportFun proc near
        mov ax,logAx[bx]

        lea dx,funRead
        cmp ah,02h
        jz outFun
        cmp ah,0ah
        jz outFun

        lea dx,funWrite
        cmp ah,03h
        jz outFun
        cmp ah,0bh
        jz outFun

        lea dx,funVerify
        cmp ah,04h
        jz outFun

        lea dx,funSeek
        cmp ah,0ch
        jz outFun

        lea dx,funBad
outFun:
        call disps
        ret
reportFun endp


; ---------------------------------------------
; report drive/head/track/sector
;       DH=drive
;       DL=head
;       CH=track
;       CL=sector
;       AL=sector count
;
reportDrive proc near

;display drive letter
        mov ax,4
        call spaces
        mov dx,logDx[bx]
        mov al,dl

        cmp al,7fh      ;floppy drives
        jb notHard

        and al,7fh
        add al,2        ;hard drives start with C

notHard:
        add al,'A'
        call dispc
        mov al,':'
        call dispc

;display head number
        mov ax,1
        call spaces
        mov dx,logDx[bx]
        clr ah
        mov al,dh
        call decimal
                                
;display cylinder number
        mov ax,3
        call spaces
        mov cx,logCx[bx]
        clr ah
        mov al,cl
        shl ax,1
        shl ax,1
        mov al,ch               ;calculate 10 bit cylinder number
        call decimal

;display sector number
        mov ax,2
        call spaces
        mov cx,logCx[bx]
        clr ah
        mov al,cl
        and al,00111111b        ;isolate sector number
        clr ah
        call decimal

;display sector count
        mov ax,2
        call spaces
        mov ax,logAx[bx]
        clr ah
        call decimal
        ret
reportDrive endp


; ---------------------------------------------
; report error code
;       AH=error code
;
resultTable db 001h,'Bad command$'
            db 002h,'Address mark not found$'
            db 003h,'Write attempted on write-protected disk$'
            db 004h,'Sector not found$'
            db 005h,'Reset failed$'
            db 006h,'Diskette changed$'
            db 007h,'Parameter act. failed$'
            db 008h,'DMA overrun$'
            db 009h,'DMA across 64K boundary$'
            db 00Ah,'Bad sector detected$'
            db 00Bh,'Bad track detected$'
            db 00Ch,'Unsupported track$'
            db 00Dh,'Invalid number of sectors on format$'
            db 00Eh,'Control data address mark detected$'
            db 00Fh,'DMA arbitration error$'
            db 010h,'Bad CRC/ECC$'
            db 011h,'Data ECC corrected$'
            db 020h,'Controller failure$'
            db 040h,'Seek failed$'
            db 080h,'Time out$'
            db 0AAh,'Drive not ready$'
            db 0BBh,'Undefined error$'
            db 0CCh,'Write fault$'
            db 0E0h,'Status register error$'
            db 0FFh,'Sense operation failed$'
            db 000h,'Unknown error$'     ;must be last!
            
reportResult proc near
        mov ax,3
        call spaces

        lea si,resultTable
        mov ax,logResult[bx]

checkResult:
        cmp cs:[si],ah
        jz foundResult
        cmp byte ptr cs:[si],0
        jz foundResult

findNext:
        inc si
        cmp byte ptr cs:[si],'$'
        jnz findNext
        inc si
        jmp short checkResult

foundResult:
        mov dx,si
        inc dx
        call disps
        ret
reportResult endp


; ---------------------------------------------
; convert number to decimal,
;       outputs 5 digits with leading spaces
;       ax  number to convert
;
decBuf db '00000'
decEnd db ' $'

decimal proc near
        assume ds:nothing
        push si
        push bx
        push cx
        push dx

        lea bx,decBuf
        mov cx,5
        mov dl,' '
decClear:
        mov cs:[bx],dl
        inc bx
        loop decClear

        mov cx,5                ;convert 5 digits
        mov si,10               ;divisor

decNext:
        clr dx                  ;convert AX -> DX:AX

        div si                  ;divide number by 10. Remainder is in
                                ; DX--this is a one-digit decimal
                                ; number.  Number/10 is in AX

        add dl,'0'              ;convert remainder to a text character
        dec bx                  ;put this digit in the string and
        mov cs:[bx],dl          ;point to the location for the
                                ; next most-significant digit
        cmp ax,0
        jz decLast              ;stop when 0 is reached

        loop decNext

decLast:
        lea dx,decBuf
        call disps

        pop dx
        pop cx
        pop bx
        pop si
        ret
decimal endp


; ---------------------------------------------
; DERMON/Z - zero error counts
;
tableZeroed     db 'Error tables zeroed.',13,10,'$'

zeroStats proc near
        call checkPresent
        lea dx,notLoaded
        jnz zeroExit

        push es
        pop ds
        assume ds:code  ;ds->resident code segment

        clr ax
        mov errorCount,ax
        mov logNext,ax

        mov bx,ax
zeroNext:
        mov word ptr logResult[bx],0
        inc bx
        inc bx
        cmp bx,(maxEntries*2)
        jl zeroNext

        lea dx,tableZeroed
zeroExit:
        call disps
        ret
zeroStats endp

code ends
        end entry

