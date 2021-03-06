page 66,132
;
; Resident Critical Error Handler
;
; This program is a TSR that traps critical errors and attempts
; to handle them in an intelligent way.
;
; It draws on all available information to present a complete error
; description to the user, and to provide sensible default actions
; when the operator is not present.
;
; Copyright 1989 Samuel H. Smith; All rights reserved.
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

%newpage
;------------------------------------------------
; macro- push all registers
;
pushall macro
        push ax
        push bx
        push cx
        push dx
        push ds
        push es
        push si
        push di
        push bp
endm

;------------------------------------------------
; macro- pop all registers
;
popall macro
        pop bp
        pop di
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
endm

;------------------------------------------------
; macro- clear register
;
clr macro reg
        xor reg,reg
endm


;------------------------------------------------
; macro- dos function call
;
dosDisplay     = 9h
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


;------------------------------------------------
; macro- video function call
;
vidSetcu       = 02h
vidGetcu       = 03h
vidGetch       = 08h
vidPutch       = 09h
vidTty         = 0eh

video   macro funct
        mov ah,funct
        int 10h
endm

;------------------------------------------------
; macro- keyboard function call
;
kbdGetch       = 0
kbdStatus      = 1

keybd   macro funct
        mov ah,funct
        int 16h
endm

%newpage
;------------------------------------------------
; program segment prefix
;
code segment
        assume cs:code, ds:nothing, es:nothing, ss:nothing

        org 012h
int24p  dd      ?       ;pointer to current int24 handler

        org 02ch
envseg  dw      ?       ;environment segment number

        org 80h
tailLen db      ?       ;command tail length
tail    db      ?

        org 100h
entry:
        jmp entryPoint



;------------------------------------------------

signature       db 13,10,'Resident Critical Error Handler v1.4 ',??DATE
                db 13,10,'Copyright 1989, 1990 Samuel H. Smith; ALL RIGHTS RESERVED'
                db 13,10
crlfs           db 13,10,'$'


%newpage
;------------------------------------------------
; table format:
;       db 'initial message....$'
;       db 80h+code,0,'message....$'
;       db 80h+code,0,'message....$'
;       db 0,0,'last message$'
;
; table of extended error messages
;
errorNames     db 'Error: $'
;              db 80h+01h,0,'Function number invalid!$'
;              db 80h+02h,0,'File not found!$'
;              db 80h+03h,0,'Path not found!$'
;              db 80h+04h,0,'Too many open files!$'
               db 80h+05h,0,'Access denied!$'
;              db 80h+06h,0,'Invalid handle!$'
;              db 80h+07h,0,'Memory control block destroyed!$'
;              db 80h+08h,0,'Insufficient memory!$'
;              db 80h+09h,0,'Memory block address invalid!$'
;              db 80h+0Ah,0,'Environment invalid!$'
;              db 80h+0Bh,0,'Format invalid!$'
;              db 80h+0Ch,0,'Access code invalid!$'
;              db 80h+0Dh,0,'Data invalid!$'
;              db 80h+0Fh,0,'Invalid drive!$'
;              db 80h+10h,0,'Attempted to remove current directory!$'
;              db 80h+11h,0,'Not same device!$'
;              db 80h+12h,0,'No more files!$'
               db 80h+13h,0,'Disk write-protected!$'
               db 80h+14h,0,'Unknown unit!$'
               db 80h+15h,0,'Drive not ready!$'
               db 80h+16h,0,'Unknown command!$'
               db 80h+17h,0,'Data error (CRC)!$'
;              db 80h+18h,0,'Bad request structure length!$'
               db 80h+19h,0,'Seek error!$'
               db 80h+1Ah,0,'Unknwon media type (non-DOS disk)!$'
               db 80h+1Bh,0,'Sector not found!$'
               db 80h+1Ch,0,'Printer out of paper!$'
               db 80h+1Dh,0,'Write fault!$'
               db 80h+1Eh,0,'Read fault!$'
               db 80h+1Fh,0,'General failure!$'
               db 80h+20h,0,'Sharing violation!$'
               db 80h+21h,0,'Lock violation!$'
               db 80h+22h,0,'Disk change invalid!$'
               db 80h+23h,0,'FCB unavailable!$'
;              db 80h+24h,0,'Sharing buffer overflow!$'
               db 80h+26h,0,'Cannot complete file operation!$'
;              db 80h+32h,0,'Network request not supported!$'
               db 80h+33h,0,'Remote computer not listening!$'
;              db 80h+34h,0,'Duplicate name on network!$'
               db 80h+35h,0,'Network name not found!$'
               db 80h+36h,0,'Network busy!$'
               db 80h+37h,0,'Network device no longer exists!$'
;              db 80h+38h,0,'Network BIOS command limit exceeded!$'
               db 80h+39h,0,'Network adapter hardware error!$'
;              db 80h+3Ah,0,'Incorrect response from network!$'
;              db 80h+3Bh,0,'Unexpected network error!$'
;              db 80h+3Ch,0,'Incompatible remote adapter!$'
;              db 80h+3Dh,0,'Print queue full!$'
;              db 80h+3Eh,0,'Queue not full!$'
;              db 80h+3Fh,0,'Not enough space to print file!$'
;              db 80h+40h,0,'Network name was deleted!$'
;              db 80h+41h,0,'Network: Access denied!$'
;              db 80h+42h,0,'Network device type incorrect!$'
               db 80h+43h,0,'Network name not found!$'
;              db 80h+44h,0,'Network name limit exceeded!$'
;              db 80h+45h,0,'Network BIOS session limit exceeded!$'
;              db 80h+46h,0,'Temporarily paused!$'
;              db 80h+47h,0,'Network request not accepted!$'
;              db 80h+48h,0,'Print/disk redirection paused!$'
;              db 80h+49h,0,'Invalid network version!$'
;              db 80h+4Ah,0,'Account expired!$'
;              db 80h+4Bh,0,'Password expired!$'
;              db 80h+4Ch,0,'Login attempt invalid at this time!$'
;              db 80h+50h,0,'File exists!$'
;              db 80h+52h,0,'Cannot make directory!$'
;              db 80h+53h,0,'Fail on INT 24h!$'
;              db 80h+54h,0,'Too many redirections!$'
;              db 80h+55h,0,'Duplicate redirection!$'
;              db 80h+56h,0,'Invalid password!$'
;              db 80h+57h,0,'Invalid parameter!$'
               db 80h+58h,0,'Network write fault!$'
;              db 80h+59h,0,'Function not supported on network!$'
;              db 80h+5Ah,0,'Required system component not installed!$'
               db 0,0,'Undefined!$'


;------------------------------------------------
; table of error areas
;
driveNames      db 'drive $'
                db 80h+'A',0,'A:$'
                db 80h+'B',0,'B:$'
                db 80h+'C',0,'C:$'
                db 80h+'D',0,'D:$'
                db 80h+'E',0,'E:$'
                db 80h+'F',0,'F:$'
                db 80h+'G',0,'G:$'
                db 80h+'H',0,'H:$'
                db 80h+'I',0,'I:$'
                db 80h+'J',0,'J:$'
                db 80h+'K',0,'K:$'
                db 80h+'L',0,'L:$'
                db 80h+'M',0,'M:$'
                db 80h+'N',0,'N:$'
                db 80h+'O',0,'O:$'
                db 80h+'P',0,'P:$'
                db 80h+'Q',0,'Q:$'
                db 80h+'R',0,'R:$'
                db 80h+'S',0,'S:$'
                db 80h+'T',0,'T:$'
                db 80h+'U',0,'U:$'
                db 80h+'V',0,'V:$'
                db 80h+'W',0,'W:$'
                db 80h+'X',0,'X:$'
                db 80h+'Y',0,'Y:$'
                db 80h+'Z',0,'Z:$'
                db 0,0,'?:$'

areaPrefix      db 'Area:  $'
readMsg         db 'Reading from $'
writeMsg        db 'Writing to $'

areaNames       db ' $'
                db 80h+00h,0,'DOS reserved area.$'
                db 80h+01h,0,'File allocation table.$'
                db 80h+02h,0,'Directory area.$'
                db 80h+03h,0,'Data area.$'
                db 0,0,'Undefined.$'

charMsg         db 'device '
deviceName      db 'DEV.$'
deviceDriver   dd      0


;------------------------------------------------
; table of error classes
;
classNames      db 'Class: $'
                db 80h+01h,0,'Out of space or I/O channels$'
                db 80h+02h,0,'File or record lock$'
                db 80h+03h,0,'Denied access$'
                db 80h+04h,0,'Internal error$'
                db 80h+05h,0,'Hardware failure$'
                db 80h+06h,0,'System failure$'
                db 80h+07h,0,'Program error$'
                db 80h+08h,0,'Not found$'
                db 80h+09h,0,'Bad format$'
                db 80h+0Ah,0,'Resource locked$'
                db 80h+0Bh,0,'Media error$'
                db 80h+0Ch,0,'Item already exists$'
                db 0,0,'Undefined$'


;------------------------------------------------
; table of error locus codes
;
locusNames      db ' in $'
                db 80h+01h,0,'Unknown.$'
                db 80h+02h,0,'Block(disk) device.$'
                db 80h+03h,0,'Network.$'
                db 80h+04h,0,'Character device.$'
                db 80h+05h,0,'System memory.$'
                db 0,0,'Undefined.$'


;------------------------------------------------
; table of suggested actions
;
suggestNames    db 'Suggested action: $'
                db 80h+01h,0,'Retry the operation.$'
                db 80h+02h,0,'Delay and then retry.$'
                db 80h+03h,0,'Re-enter input.$'
                db 80h+04h,0,'Abort after cleanup.$'
                db 80h+05h,0,'Immediately abort.$'
                db 80h+06h,0,'Ignore the error.$'
                db 80h+07h,0,'Retry after correcting the error.$'
                db 0,0,'Undefined.$'


;------------------------------------------------
; default actions
;       01h retry
;       02h delayed retry
;       03h prompt user to reenter input
;       04h abort after cleanup
;       05h immediate abort
;       06h ignore
;       07h retry after user intervention
;                  ?RRRAAIR
defaultActions db '?RRRRAIR'

SelectedAction  db ?

actionPrefix    db '         Action: (A)bort, (R)etry, (I)gnore, (F)ail? <'
defaultAction   db ?,'> '
                db 17 dup (' ')
                db 17 dup (8)
beep            db 7,'$'


;------------------------------------------------
;
box_top         db '  浜様様様様様様様様様様様裕 CRITICAL ERROR! 突様様様様様様様様様様様様�  '
box_side        db 13,10
                db '                                                                       �  ',13
                db '  �  $'
box_bottom      db 13,10
                db '  藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕  '
                db 13,10,'$'

timeoutCount    dw      182     ;18.2 * 10 = 10 second delay
tickCount       dw      0

messageColor    = 70h           ;reverse black on white

;------------------------------------------------

saveLines       = 7
saveCols        = 76
saveSize        = (saveCols*saveLines)
screenSave      dw      saveSize dup ('SH')

cursorSave      dw      0


errorCount      dw      0       ;count of errors intercepted
autoCount       dw      0       ;count of automatic retries

old_int08       dd      0
old_int1c       dd      0
old_int21       dd      0

old_int24       dd      0

compare_length  = 100           ;bytes to compare of old and
                                ;new int24 handler code

%newpage
;=============================================
; INT 24 - FATAL ERROR HANDLER
;
int24_handler proc near
        pushall

        push cs
        pop ds
        assume ds:code

;       mov allowed_actions,ah
        mov word ptr deviceDriver,si
        mov word ptr deviceDriver+2,bp

        inc errorCount
        call save_screen
        call report_error_details
        call determine_action
        call restore_screen

        popall
        assume ds:nothing
        mov al,selectedAction
        iret
int24_handler endp



;---------------------------------------------
;  AH: bit 7 = 0 disk I/O error
;            = 1 other error -- if block device, bad FAT
;                            -- if char device, code in DI
;      bit 6  unused
;      bit 5 = 1 if Ignore allowed, 0 if not (DOS 3+)
;      bit 4 = 1 if Retry allowed, 0 if not (DOS 3+)
;      bit 3 = 1 if Fail allowed, 0 if not (DOS 3+)
;      bit 2 \ disk area of error  00 = DOS area  01 = FAT
;      bit 1 /                     10 = root dir  11 = data area
;      bit 0 = 1 if write, 0 if read
;
;  AL = drive number if AH bit 7 = 1, otherwise undefined
;
;  BP:SI -> header of device driver for which error occurred
;           block device if high bit of BP:[SI+4] set
;
report_error_area proc near
        assume ds:code
        push ax                         ;ah=type/area/allowed
                                        ;al=drive number
        lea si,box_side
        call display_string

        lea si,areaPrefix
        call display_string

        lea si,readMsg                 ;display "read" or "write"
        test ah,1
        jz not_write

        lea si,writeMsg

not_write:
        call display_string

        test ah,80h
        jz is_disk

        push ds
        assume ds:nothing

        lds si,deviceDriver
        add si,0ah                      ;start of device name

        lea di,deviceName
        push cs
        pop es

        movsb                           ;copy 3 bytes
        movsb
        movsb

        pop ds
        assume ds:code

        lea si,charMsg                 ;display "in serial device"
        call display_string
        jmp short report_end

is_disk:
        pop ax
        push ax
        push ax
        add al,'A'
        mov ah,al
        lea si,driveNames
        call table_lookup               
        pop ax

        shr ah,1                        ;display area code
        and ah,3
        lea si,areaNames
        call table_lookup               

report_end:
        pop ax
        ret
report_error_area endp


; ---------------------------------------------
;
report_error_details proc near
        assume ds:code
        push ax

        lea si,box_top
        call display_string

        clr bx
        msdos dosErrinfo

        lea si,errorNames               ;error [what]
        mov ah,al
        call table_lookup

        pop ax
        call report_error_area          ;while read/write disk area

        lea si,box_side
        call display_string

        mov ah,bh
        lea si,classNames               ;class: out of storage, etc.
        call table_lookup

        mov ah,ch
        lea si,locusNames               ;in block device/network/serial
        call table_lookup

        lea si,box_side
        call display_string

        clr bh                          
        mov al,defaultActions[bx]      ;lookup default action from table
        mov defaultAction,al

        mov ah,bl
        lea si,suggestNames
        call table_lookup
        ret
report_error_details endp



; ---------------------------------------------
; Handler must return:
;
; suggested action codes
;       01h retry
;       02h delayed retry
;       03h prompt user to reenter input
;       04h abort after cleanup
;       05h immediate abort
;       06h ignore
;       07h retry after user intervention
;
; exit: selectedAction
;       AL = 00 ignore error
;          = 01 retry operation
;          = 02 terminate program through INT 22h
;          = 03 fail system call in progress (DOS 3+)
;
; allowed_actions
;       bit 5 = 1 if Ignore allowed, 0 if not (DOS 3+)
;       bit 4 = 1 if Retry allowed,  0 if not (DOS 3+)
;       bit 3 = 1 if Fail allowed,   0 if not (DOS 3+)
;

determine_action proc near
        assume ds:code
        lea si,box_bottom
        call display_string

        lea si,actionPrefix
        call display_string

        call flush_key

get_action:
        call get_key

        mov al,0
        cmp ah,'I'
        jz action_ok

        inc al
        cmp ah,'R'
        jz action_ok

        inc al
        cmp ah,'A'
        jz action_ok

        inc al
        cmp ah,'F'
        jz action_ok

        lea si,beep
        call display_string

        jmp short get_action

action_ok:
        mov selectedAction,al
        ret
determine_action endp

%newpage
; =============================================
; get keyboard input.  provide default after delay
;
get_key proc near
        assume ds:code
        mov tickCount,0

get_wait:
        mov ax,tickCount
        cmp ax,timeoutCount
        jge automatic_default

        keybd kbdStatus
        jz get_wait

        keybd kbdGetch

        cmp al,13       ;convert <enter> to default action
        jz  use_default

        and al,5fh      ;map to upper case
        mov ah,al
        ret

automatic_default:
        inc autoCount

use_default:
        mov ah,defaultAction
        ret
get_key endp


; =============================================
; flush keyboard buffer - discard type ahead
;
flush_key proc near
        assume ds:code
flush_next:
        keybd kbdStatus
        jz flush_exit

        keybd kbdGetch
        jmp short flush_next

flush_exit:
        ret
flush_key endp


;------------------------------------------------
; display buffer using messageColor
; entry: ds:si -> message
;
display_string proc near
        assume ds:code
        push ax
        push bx
        push cx

disp_next:
        lodsb
        cmp al,'$'
        jz disp_exit

        cmp al,7        ;bell
        jz nocolor
        cmp al,8        ;backspace
        jz nocolor
        cmp al,10       ;linefeed
        jz nocolor
        cmp al,13       ;return
        jz nocolor

        clr bh
        mov bl,messageColor
        mov cx,1
        video vidPutch

nocolor:
        mov bl,messageColor
        video vidTty
        jmp short disp_next

disp_exit:
        pop cx
        pop bx
        pop ax
        ret
display_string endp


;-------------------------------------------------------------
; table_lookup
;
; entry:        ds:si = table head
;               ah    = entry code
;
table_lookup proc near
        assume ds:code
        push si
        call display_string     ;display initial message from table
        pop si

        add ah,80h              ;adjust for 80h+ in table codes

next:
        lodsb                   ;skip to the end of the message
        cmp al,'$'
        jnz next

        lodsb                   ;get entry code
        cmp al,0
        jz Found

        cmp al,ah
        jnz next

found:
        inc byte ptr [si]       ;count this message
        inc si                  ;and skip the counter
        call display_string     ;display what was found
        ret
table_lookup endp



; ---------------------------------------------
; save user screen
;
save_screen proc near
        assume ds:code
        pushall

        clr bx
        video vidGetcu
        mov cursorSave,dx

        push cs
        pop es
        lea di,screenSave
        clr dx

next_line:
        call save_line
        inc dh
        cmp dh,saveLines
        jnz next_line

        clr bx
        clr dx
        video vidSetcu

        popall
        ret
save_screen endp


; ---------------------------------------------
; save line
;
; entry:        es:di   buffer
;               dx      starting cursor
; exit:         saves dh,si
;
save_line proc near
        assume ds:code
        clr dl

next_col:
        push dx
        clr bx
        video vidSetcu

        video vidGetch
        stosw

        pop dx
        inc dl
        cmp dl,saveCols
        jnz next_col

        ret
save_line endp


; ---------------------------------------------
; restore user screen
;
restore_screen proc near
        assume ds:code

        lea si,screenSave
        clr dx

rnext_line:
        call restore_line
        inc dh
        cmp dh,saveLines
        jnz rnext_line

        mov dx,cursorSave
        clr bx
        video vidSetcu
        ret
restore_screen endp


; ---------------------------------------------
; restore line
;
; entry:        ds:si   buffer
;               dx      starting cursor
; exit:         saves dh,si
;
restore_line proc near
        assume ds:code
        clr dl

rnext_col:
        push dx
        clr bx
        video vidSetcu

        lodsw
        mov bl,ah
        mov cx,1
        video vidPutch

        pop dx
        inc dl
        cmp dl,saveCols
        jnz rnext_col

        ret
restore_line endp


%newpage
; ---------------------------------------------
; INT 08H - HARDWARE CLOCK TICK HANDLER
;
; Count passing clock ticks while attempting to re-install fatal
; error handler.  
;
int08_handler proc far
        assume ds:nothing
        inc tickCount          ;count clock ticks-- used to detect timeout
        call install_handler
        jmp old_int08
int08_handler endp


; ---------------------------------------------
; INT 1cH - USER CLOCK TICK HANDLER
;
; Count passing clock ticks while attempting to re-install fatal
; error handler.  
;
;int1c_handler proc far
;        assume ds:nothing
;        inc tickCount          ;count clock ticks-- used to detect timeout
;       call install_handler
;        jmp old_int1c
;int1c_handler endp


; ---------------------------------------------
; INT 21H - DOS FUNCTION HANDLER
;
; Attempt to re-install fatal error handler.
;
int21_handler proc far
        assume ds:nothing
        call install_handler
        jmp old_int21
int21_handler endp


; ---------------------------------------------
; Attempt to re-install fatal error handler.  This is required
; because command.com tends to over-ride any resident error handlers.
;
install_handler proc near
        assume ds:nothing
        pushall

        clr ax                  ;find current fatal handler
        mov es,ax
        les di,es:[24h*4]

; replace current handler if it is below us (probably command.com)

        mov ax,es
        mov dx,cs
        cmp ax,dx
        jbe replace

; if current handler is AFTER us, look at the handler code to see if it
; is another copy of command.com.  this allows us to handle nested
; command.com's while still preserving application handlers.

        lds si,cs:old_int24
        mov cx,compare_length
        rep cmpsw
        jcxz replace

        jmp short keep

; if dos or command.com stole the handler, we now take it back.
; this also performs the initial installation upon startup

replace:
        clr ax
        mov es,ax
        mov word ptr es:[24h*4],offset int24_handler
        mov word ptr es:[24h*4+2],cs

keep:
        popall
        ret
install_handler endp


%newpage
; =============================================
; end of resident portion of code
;
resident:

; calculate size of resident portion in bytes and segments

fatal_size = (offset(resident)-offset(entry))
fatal_segs = (fatal_size / 16) + 32


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

usages          db 'Usage:  FATAL/I     ;install in memory.',13,10
                db '        FATAL/U     ;un-install.',13,10
                db '        FATAL/C     ;display critical error count.',13,10
                db '        FATAL/Z     ;zero critical error count.',13,10
                db '$'

needDos30       db 'DOS 3.0 or later required!',13,10,'$'

fatalLoaded     db 'FATAL v1.4 installed.',13,10,'$'
fatalRemoved    db 'FATAL unInstalled.',13,10,'$'
tableZeroed     db 'Error tables zeroed.',13,10,'$'
othersLoaded    db 'Other programs loaded after FATAL -- cannot unInstall.',13,10,'$'
alreadyLoaded   db 'Already loaded!',13,10,'$'
notLoaded       db 'Fatal is not resident.  Use FATAL/I first.',13,10,'$'

reportPrefix    db 13,10,'FATAL v1.4 status:',13,10,'$'
errorCounts     db 'Critical errors.',13,10,'$'
autoCounts      db 'Automatic retries.','$'
drivePrefix     db 'Drive: $'
locusPrefix     db 'Locus:$'


; ---------------------------------------------
; program entry point
;
entryPoint proc near
        push cs
        pop ds
        assume ds:code

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
; fatal/? - display license and usage messages
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
        msdos dosExit,0


; ---------------------------------------------
; fatal/I - new installation - hook vectors and go resident
;
newInstall:
        lea dx,signature
        call disps

        msdos dosGetvers                ;verify dos 3 or later
        lea dx,needDos30
        cmp al,2
        jle installExit

        call checkPresent
        lea dx,alreadyLoaded
        jz installExit

        getvect 08h,old_int08           ;save original handler vectors
        getvect 21h,old_int21
;       getvect 1ch,old_int1c
        getvect 24h,old_int24

        setvect 08h,int08_handler       ;install new handlers
;       setvect 1ch,int1c_handler
        setvect 21h,int21_handler

        lea dx,fatalLoaded
        call disps

        lea dx,resident                 ;terminate and stay resident
        int 27h

installExit:
        jmp short exitWithMessage
entryPoint endp


; =============================================
; check if fatal is already present
;
; exit: Z       fatal is present,
;               es-> resident code segment
;
;       NZ      not present
;
checkPresent proc near
        msdos dosGetvec,24h     ;es:xx -> current int24 handler

        lea bx,signature        ;cs:bx -> local signature
checkNext:
        mov al,ds:[bx]          ;get next byte from local message
        cmp al,'$'              ;end of message?
        jz checkExit            ;already present if so

        cmp al,es:[bx]          ;compare next byte to int24 handler
        jnz checkExit           ;new installation if mismatch

        inc bx                  ;got a match, try the next char
        jmp short checkNext

checkExit:
        ret
checkPresent endp


; ---------------------------------------------
; display message in code segment
;
disps proc near
        push ds
        push cs
        pop ds
        msdos dosDisplay
        pop ds
        ret
disps endp


; ---------------------------------------------
; fatal/u - uninstall and exit
;
unInstall proc near
        call checkPresent
        lea dx,notLoaded
        jnz unExit

        mov bx,es               ;bx->tsr code segment
        mov ax,ds
        sub ax,bx               ;calculate memory usage after fatal tsr

        lea dx,othersLoaded
        cmp ax,fatal_segs       ;amount of allowed overhead for DOS/PSP, etc.
        jge unExit              ;insure that others are not loaded after

        assume ds:nothing
        revect 21h,old_int21    ;unhook dos interrupt
;       revect 1ch,old_int1c    ;unhook timer interrupt
        revect 08h,old_int08    ;unhook timer interrupt
        revect 24h,old_int24    ;unhook critical error interrupt

        push es
        mov es,es:envseg
        msdos dosFreemem       ;dealloc the tsr's environment segment

        pop es              
        msdos dosFreemem       ;dealloc the tsr's code segment

        push cs
        pop ds
        assume ds:code

        lea dx,fatalRemoved
unExit:
        call disps
        ret
unInstall endp


; ---------------------------------------------
; fatal/C - report critical error counts
;
reportStats proc near
        call checkPresent
        lea dx,notLoaded
        jnz reportExit

        push es
        pop ds
        lea dx,reportPrefix
        mov ax,errorCount
        call decimal

        lea dx,errorCounts
        mov ax,autoCount
        call decimal

        lea dx,autoCounts
        call disps

        mov ax,errorCount
        cmp ax,0
        jz reportFinish         ;finish now if no errors to report

        lea si,errorNames
        mov dx,si
        call dumpTable

        lea si,classNames
        mov dx,si
        call dumpTable

        lea si,locusNames
        lea dx,locusPrefix
        call dumpTable

        lea si,driveNames
        lea dx,drivePrefix
        call dumpTable

        lea si,areaNames
        lea dx,areaPrefix
        call dumpTable

        lea si,suggestNames
        mov dx,si
        call dumpTable

reportFinish:
        lea dx,crlfs
reportExit:
        call disps
        ret
reportStats endp


;-------------------------------------------------------------
; dumpTable - display usage counts for a code table
; entry:  ds:si = table head
;            dx = table name
;
dumpTable proc near
        push dx
        lea dx,crlfs
        call disps
        pop dx
        call disps

dumpNext:
        lodsb                   ;skip to the end of the message
        cmp al,'$'
        jnz dumpNext

        lodsw                   ;get entry code+activity count
        cmp ah,0                ;skip entries with count=0
        jnz dumpEntry
        jmp short dumpAgain

dumpEntry:
        push ax
        mov al,ah
        clr ah
        lea dx,crlfs
        call decimal

        mov dx,si
        call disps
        pop ax

dumpAgain:
        cmp al,0
        jnz dumpNext

        ret
dumpTable endp


; ---------------------------------------------
; convert number to decimal
;       dx  initial message
;       ax  number to convert
;
decBuf db '00000'
decEnd db ' $'

decimal proc near
        assume ds:nothing
        push si

        push ax
        call disps
        pop ax

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

        pop si
        ret
decimal endp


; ---------------------------------------------
; fatal/Z - zero critical error counts
;
zeroStats proc near
        call checkPresent
        lea dx,notLoaded
        jnz zeroExit

        push es
        pop ds
        assume ds:code  ;ds->resident code segment

        clr ax
        mov errorCount,ax
        mov autoCount,ax
        mov errorCount,ax

        lea si,errorNames
        call zeroTable

        lea si,classNames
        call zeroTable

        lea si,locusNames
        call zeroTable

        lea si,driveNames
        call zeroTable

        lea si,areaNames
        call zeroTable

        lea si,suggestNames
        call zeroTable

        lea dx,tableZeroed
zeroExit:
        call disps
        ret
zeroStats endp


;-------------------------------------------------------------
; zeroTable - zero usage counts for a code table
; entry:  ds:si = table head
;
zeroTable proc near

zeroNext:
        lodsb                           ;skip to the end of the message
        cmp al,'$'
        jnz zeroNext

        lodsw                           ;get entry code+activity count
        mov byte ptr ds:[si-1],0        ;zero error count

        cmp al,0
        jnz zeroNext

        ret
zeroTable endp

code ends
        end entry

