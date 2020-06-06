page 66,132
;--------------------------------------------------------------------------
; FATAL - INT_24h MSDOS 3.0 ++ Error Handler
; Re-written by : James D. Traill : 24th April 1992
; Principal Application: Unattended BBSes & recovery of data off hard disks!
; -- without having to be there!
; -- Plus some moron doesn't crash the BBS by dropping to DOS and then
;    accessing the floppy drive(s) (Memories of Matan 1989 ... in Tokyo.)
;---------------------------------------------------------------------------
; This Version 2.0 will be extended to support Waszir_Toys: "PC_WatchDog"
; this hardware connects to telephone line, parallel port, power supply,
; reset and 2 solid state relays with standard power supply plugs and 
; sockets.
; If you choose to connect to the parallel port, an upgraded version of
; this INT_24h handler will send commands to the "PC_WatchDog". Thus enabling
; true HARDWARE REST and/or power on-off sequence to take place.
; For instance if the BBS/System fails to perform following power up
; then a 2nd attempt will be made, failing that a backup computer and
; modem can be brought in action via "PC_Watchdog".
; "PC_WatchDog" will also have its own very simple but effective WatchDog.
; Failing that maybe a speaker should issue cries for help!
;
;---------------------------------------------------------------------------
; There are other software programs like "PHONEV4.COM" and CRASH107 (no good
; for 286/386 systems using memory managers), these can be combined.
; Still when the 386CPU hits a "Cli" instruction and stays there with its
; interrupts disabled, there ain't much you can do.  Typical of those
; narrow minded US engineers. Takes the Japanese to include WatchDog circuits
; in their CPUs. If the Hitachi H8/3332 microcomputer can have a WatchDog
; circuit, why in hell can't the 386, 486, 386SL and clones?!!!
; (Ah, maybe there was an MBA in the management structure! Exterminate him!)
;
;---------------------------------------------------------------------------
; I hope that I can get enough control of my time (management I find leaves
; little time for engineering...) to finish "PC_WatchDog" by end of May.
; I have built similar things before. 'cas I won't have time to perfect
; all the possible functions I might need. I will let functions be as
; programmable as much as possible. Design will use standard cheap
; microcomputers I use in my NOTEBOOK PC design business.
; Cost ? Retail $100?  : Let's see. I'll stick to the K.I.S. principal.
; --- I desperately need this installed on Tokyo BBS, which is totally
; unattended.... Its like Voyager II...
; Also worried about theft. So am considering attachment of security device
; and alarm -- based upon Australian NESS Security's products.
;--- Finally : Constructive FEEDBACK WELCOME 
;
; BBS: = +81.3.3813-1169 Tokyo "Silent Running BBS" User #2
; FAX: = +61.3.723-7535
; COMPUSERVE #100036,675
;
;---------------------------------------------------------------------------
; Revisions : By The Waszir
; 27th April 1992 :: Major Hacking
; --- Corrected spelling mistakes! -- If you want to (C) bad English
;     then (i) you are a turd! (ii) See a Shrink! (Do not pass GO!)
; --- Several critical potential problems corrected.
;     jbe --> Blos branch instructions. Logical not arithmetic compares
;     for address comparisons! He just failed Waszir's job interview!
;
; --- Reduced time spent in Int_08h & Int_21h Handlers.
; --- For BBS use. Many Options added. Easy to change.
; --- Add "B" option == Re-Boot System (Serious Error)
; --- Separate : Memory, Network, Floppy Disk, Hard Disk & Comms Errors
; --- Default : Floppy Access Error --> Abort
; ---           Memory --> Re-Boot System
; ---           Network --> 1.5 Seconds Delay (RETRY)
; ---           Other Retries --> 5 seconds delay
; - Ability to alter operation of FATAL aleady installed
;
;   Example: Initial BBS system start-up => Constant re-try of hard disk errors
;            After BBS start-up to alter FATAL parameters to Abort then to
;            to Re-Boot System if errors continue.
;-----------
; 29th April 1992
; - add intercepting re-boot traps for "Divide by Zero", NMI and Illegal opcode
;   interrupts  -- Extra install option to enable "Install /IxW <cr>"
; - 1-MAY-1992
; - Internal SS:SP Stack Implemented
; - Use of Stack Reduced, Corrected Memory offset & segment calculations
; - Added Silly Messages - 'cas fed up with long n'winding original disclaimer
; - 5th May 1992 : "FATAL /i" & "FATAL /B" correctly supported --> Re-Boot
;   Version 2.03
;-----------
; 12th May 1992  FATAL205.LZH : Fatal Version 2.05
; - Extended Timer for reset of Auto_count from 10 seconds to 30 seconds
;   This for Hard Disks that take some time to retry errors, so that
;   to avoid system getting stuck on a hard disk error indefinitely!
; - Also to show true no. of Auto-Counts : new Variable "Total_Auto_Counts"
;
; End of Waszir's Verbal Masturbations-
;
;=============================================================================
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
;                                  LICENSE
;                                  =======
;  SourceWare: What is it?
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
;  Why SourceWare?
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
;----------------------------------------------
; Waszir's Comment! : Rule No. 1 = "NO MORONS!"
;                     Rule No. 2 = "NO MBA's!"
;                     Rule No. 3 => Like this program? Then you can either
; get on with your job, and stop masturbating on-line (I was told not too.)
; Or buy 100,000 Notebook Keyboard & I/O (power, battery, etc. management) ICS
; from me. Tell me your interest for PAL <--> NTSC converters. Tell me how
; much interest you have in "PC WATCHDOG" external unit. Or failing all this
; send me a highly attractive, intelligent, sharp, sensual woman. 165cm-175cm
; tall, 23 --> 45 years old, <hey> <hey>. Hardware Knowledge required.
; etc.. of course wearing tight leather & PVC outfits . . . 
; <just something to prove to my wife (SWMBO) that I am a man and not just
;  a bloody boringgggggg engineerrrrrrrrr>
; (ps. hope to design upmarket vibrators. The motor control on the present
;  ones from Japan (USA vibs are GROSS) are poor indeed, need 4 or 8 bit
;  microcontroller. So guess when I get around to designing high-tech sex-toys
;  we'll need some honest volunteers.)
; (Gee, hope I've offended all you feminists out there! Whoooppeee!)
;
 
;------------------------------------------------
	Include	Mac88.Lib
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
dosDisplay     = 09h
dosSetvec      = 25h
dosGetvers     = 30h
dosGetvec      = 35h
dosFreemem     = 49h
dosExit        = 4Ch
dosErrinfo     = 59h
DosTsr         = 31h			; DOS Exit as a TSR

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

signature       db 13,10,'Resident Critical Error Handler V2.05 12-May-1992'
                db 13,10,'(C) 1989 Samuel H. Smith; ALL RIGHTS RESERVED'
		db 13,10,'(C) 1992 James D. Traill (The Waszir) within 10 light years of Earth'
                db 13,10
crlfs           db 13,10,'$'


 
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
               db 80h+1Ah,0,'Unknown media type (non-DOS disk)!$'
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
                db 80h+'G',0,'G:$'
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
                db 80h+02h,0,'Temporary situation (file or record lock)$'
                db 80h+03h,0,'Authorization (denied access)$'
                db 80h+04h,0,'Internal error$'
                db 80h+05h,0,'Hardware failure$'
                db 80h+06h,0,'System failure$'
                db 80h+07h,0,'Application program error$'
                db 80h+08h,0,'Item not found$'
                db 80h+09h,0,'Bad format$'
                db 80h+0Ah,0,'Resource locked$'
                db 80h+0Bh,0,'Media error$'
                db 80h+0Ch,0,'Item already exists$'
                db 80h+0Dh,0,'Unknown$'
                db 80h+0Eh,0,'[E]$'
                db 80h+0Fh,0,'[F]$'
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
                db 80h+06h,0,'[6]$'     
                db 80h+07h,0,'[7]$'     ;what do these represent?
                db 80h+08h,0,'[8]$'     ;I can't find them in any reference.
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
; Re-Written by JDT : April 1992. For better control over errors for
; each type of Device.
;
; Memory --> Re-Boot
; Serial --> Retry --> Abort --> Re-Boot
; Floppy Disk ---> Abort --> Re-Boot
; Hard Disk ---> Retry --> Abort ---> Re-Boot
;

defaultActions	db '?RRRRRRR'		; 0:HD Default Actions 
		db '?RRRRRRR'		; 1:NWK Network Default Actions
		db '?RRRRRRR'		; 2:SRL Default Actions
		db '?AAAAAIA'           ; 3:FD Default Actions
; Time Out Action		;
		db '?AAAAAAA'		; 0:HD Default Actions 
		db '?AAAAAAA'		; 1:NWK Network Default Actions
		db '?AAAAAAA'		; 2:SRL Default Actions
		db '?BBBBBBB'           ; 3:FD Default Actions
		;

TimeOut_Action	db	00	; A=ABORT, R=RETRY, I=IGNORE, F=FAIL, B=BOOT

Previous_Error	db	0FFh	; Same Error?
Previous_drive	db	0FFh	; Same Drive?

actionPrefix    db '    Action: (A)bort, (R)etry, (I)gnore, (F)ail? <'
defaultAction   db ?,'> '
                db 12 dup (' ')
                db 12 dup (8)
SelectedAction  db ?
beep            db 7,'$'

Default_Mode	Db	00
Extended_Modes	Db	00

;------------------------------------------------
;
box_top         db '  ษอออออออออออออออออออต CRITICAL ERROR! ฦออออออออออออออออออออป  '
box_side        db 13,10
                db '                                                             บ  ',13
                db '  บ  $'
box_bottom      db 13,10
                db '  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ  '
                db 13,10,'$'

TimeOut_HD	= 91		;   5 seconds
TimeOut_Network = 27		; 1.5 seconds
TimeOut_Comms	= 91		;   5 seconds
TimeOut_FD	= 91		;   5 seconds
;
TimeOut_Max	= 546		; = longest "TimeOut_xxx" + 25 seconds
;
TimeOut_Count	Dw	TimeOut_HD, TimeOut_Network, TimeOut_Comms, TimeOut_FD
;
timeoutCount    dw      91     ; 18.2 * 5 = 5 second delay ; Network = 1.5 seconds => 27
tickCount       dw      0
Last_TickCount	dw	0  ; Reset AutoCount if time since last error is greater
			   ; than Maximum error time wait + 5 seconds.
                           ; Else it would be impossible from several hard disk
                           ; errors on a particular drive partition!

messageColor    = 70h           ;reverse black on white

;------------------------------------------------

saveLines       = 7
saveCols        = 66
saveSize        = (saveCols*saveLines)
screenSave      dw      saveSize dup ('SH')

cursorSave      dw      0

Auto_TimeOut	= 5	; 5 Standard tries
TimeOut_Limit	= 15	; The absolute limit

errorCount      dw      0       ;count of errors intercepted
autoCount       dw      0       ;count of automatic retries
Total_Auto_Counts dw	0	; Not Reset Total no. of Auto-Retries

Prev_SP		dw	000	; previous Stack Pointer
Prev_SS		dw	000	; previous Stack Segment
TSR_Stack	dw	100 Dup (0)
TSR_Stack_Top	dw	000	;


old_int00	dd	0	; Divide by Zero
old_int02	dd	0	; NMI
old_int06	dd	0	; Illegal Opcode
;
old_int08       dd      0
old_int1c       dd      0
old_int21       dd      0

old_int24       dd      0

;; System_ReBoot	dw	0000,0FFFFh

compare_length  = 100           ;bytes to compare of old and
                                ;new int24 handler code

 
;=============================================
; INT 24 - FATAL ERROR HANDLER
;
int24_handler proc near
	Push	DS
	Push	CS
	Pop	DS

        assume ds:code

	Mov	DS:Prev_SP,SP		; Save SP
	Mov	DS:Prev_SS,SS		; Save SS
	Push	CS
	Pop	SS
	Mov	SP,Offset TSR_Stack_Top	; Change to TSR's Internal Stack!
	Push	Ax
	Push	Bx
	Push	Cx
	Push	Dx
	Push	Si
	Push	Di
	Push	Bp
	Push	ES

;       mov allowed_actions,ah
        mov word ptr deviceDriver,si
        mov word ptr deviceDriver+2,bp

        inc errorCount
        call save_screen
        call report_error_details
        call determine_action
        call restore_screen

	Pop	ES
	Pop	Bp
	Pop	Di
	Pop	Si
	Pop	Dx
	Pop	Cx
	Pop	Bx
	Pop	Ax
	Mov	SS,DS:Prev_SS		; Restore System's Stack
	Mov	SP,DS:Prev_SP
        mov al,selectedAction      ; 0=Ignore, 1=Retry, 2=Abort
	Pop	DS
	;
        assume ds:nothing
	;
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
        push ax

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
;
;----------------------------------------------------------------------
;     DI = 0000h = Write Protect
;	   0001h = Invalid
;	   0002h = Drive Not Ready
;	   0003h = Invalid CMD
;	   0004h = CRC Error
;	   0005h = Bad Request
;	   0006h = Seek Error
;	   0007h = Unknown Medium
;	   0008h = Sector Not Found
;	   0009h = No Paper
;	   000Ah = Write Error
;	   000Bh = Read Error
;	   000Ch = General Error
	
is_disk:			; AL=disk drive ID number - 0=A ; 1=B
	Pop	Ax
	Push	Ax
        Push	Ax		; AH bit 0 = 0 = Read
        add al,'A'              ;        0 = 1 = Write
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

	Push	Dx
	Push	Di
	Push	DS
	Push	ES
	clr bx
        msdos dosErrinfo
	Pop	ES
	Pop	DS
	Pop	Di
	Pop	Dx

        lea si,errorNames               ;error [what]
        mov ah,al
        call table_lookup

        pop ax
        call report_error_area          ;while read/write disk area
	Push	Ax
	
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
	Pop	Ax

	Cmp	Ch,01h			;
	Blos	Re_Boot1		;
	Cmp	Ch,05h			; Memory or invalid Device?
	Blo	cont_1
Re_Boot1:
	Mov	defaultAction,'B'	; ---> Re-Boot
	Br	error_1			; Memory Error
	;
cont_1:
	Cmp	TimeOut_Action,'R'	; Always Retry?
	Bne	not_retry_1
	Mov	Al,'R'			; Retry
	Jmp	Set_Default		;
	;
not_retry_1:
	Cmp	TimeOut_Action,'I'	; Always Ignore?
	Bne	not_ignore_1
	Mov	Al,'I'			; Ignore
	Jmp	Set_Default		;
	;
not_ignore_1:
	Cmp	TimeOut_Action,'A'	; Always Abort?
	Bne	not_abort_1
	Mov	Al,'A'			; Abort
	Jmp	Set_Default		;
	;
not_abort_1:
	Cmp	TimeOut_Action,'F'	; Always Fail?
	Bne	not_fail_1
	Mov	Al,'F'			; FAIL
	Jmp	Set_Default		;
	;
not_fail_1:
		
        clr bh                          ;
	Sub	Ch,02			; Create Index --> Table
	Bne	not_Block1		; 0 = Block, 1= Network, 2=Serial
	Cmp	Al,2			; Floppy or Hard Disk?
	Bhis	Hard_Disk
	Mov	Ch,03			; => 3 = Floppy Disk
Hard_Disk:
not_Block1:
	Push	Bx
	Mov	Bl,Ch			; Index to Time out value
	Clr	Bh
	Sal	Bx,1
	Mov	Bx,TimeOut_Count[Bx]	; Get no. of ticks
	Mov	timeoutCount,Bx		; Set no. of ticks
	Pop	Bx
	;
	Cmp	Previous_Error,Ch	; Same Error as Before
	Bne	new_device
	;
	Cmp	Ch,01			; Network
	Beq	network_1
	Cmp	Ch,02			; Comms (Serial / Parallel)
	Beq	Comms_1
	Cmp	Previous_Drive,Al	; same drive accessed?
	Beq	same_error
new_device:
	Mov	Previous_Drive,Al	; Save Drive type
	Mov	Previous_Error,Ch	;
	Mov	AutoCount,00		; Reset - new error!
	Br	Fresh_Error
	;
network_1:
Comms_1:	
same_error:

Fresh_Error:
	Mov	Si,tickCount		; Get Present Ticks Counter
	Mov	Last_TickCount,Si	; Store --> Last_Ticks Counter
	Cmp	AutoCount,Auto_TimeOut	;
	Blos	Normal_Action
	Cmp	AutoCount,TimeOut_Limit	; Give up! Limit
	Blos	TimeOut_1		; Not yet --
	Mov	Al,TimeOut_Action	; What to do?
	Cmp	Al,'B'			; Re-Boot? & Default Setting ?
	Beq	Set_Default
	Sub	Al,2			; C--> A, D--> B, H--> F, K--> I
	Br	Set_Default		; T--> R
	;
TimeOut_1:
	Add	Ch,04h			; --> Time Out Action
Normal_Action:
	Shl	Ch,1			; 8 bytes per table entry
	Shl	Ch,1
	Shl	Ch,1
	And	Bl,07h
	Or	Bl,Ch			; Table Index
	;
        mov	Al,defaultActions[Bx]	;lookup default action from table
Set_Default:
        mov	defaultAction,Al

error_1:
        mov ah,bl
        lea si,suggestNames
        call table_lookup
        ret
	;
report_error_details endp

;-------------------------------------------------------------------
Re_Boot_Handler	proc	near
	MOV	AX,0FC00h                            ; from "BOOT.COM"
	MOV	ES,AX
	MOV	ES:BYTE PTR [0000],00
	MOV	AX,0FFFFh
	MOV	ES,AX
	MOV	ES:BYTE PTR [0000],00
	MOV	DX,40F8h
	IN	AL,DX
	MOV	DX,40FCh
	IN	AL,DX
	MOV	AX,0040h
	MOV	ES,AX
	MOV	ES:WORD PTR [0072h],1234h
	MOV	AX,0FFFFh
	PUSH	AX
	XOR	AX,AX
	PUSH	AX
	RETF

;	Jmp	Near	System_Re_Boot

Re_Boot_Handler	endp


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

	Cmp	Ah,'B'			; Re-Boot System?
	Beq	Re_Boot_Handler		; Yes

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

 
; =============================================
; get keyboard input.  provide default after delay
;
get_key proc near
        assume ds:code
        mov tickCount,0
	Sti				; Double sure interrupts Enabled
get_wait:
        mov	ax,tickCount
        cmp	ax,timeoutCount
        Bhis	automatic_default

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
	Inc	Total_Auto_Counts
	;
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
        Call save_line
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


 
; ---------------------------------------------
; INT 08H - HARDWARE CLOCK TICK HANDLER
;
; Count passing clock ticks while attempting to re-install fatal
; error handler.  
;
int08_handler proc far
        assume ds:nothing
        Inc	tickCount		; count clock ticks-- used to detect timeout
	;
	Push	Si			; Reset Auto_Count if over "TimeOut_Max" seconds since last error.
	Mov	Si,tickCount		; Present 18.2-per-second counter
	Sub	Si,Last_TickCount	; Previous tick-count @ Error
	Cmp	Si,TimeOut_Max
	Blo	Probably_Same_Error
	Mov	AutoCount,00		; Reset -> new error
Probably_Same_Error:
	Pop	Si
	;
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
;______________________________________________
;
; INT 00 - Divide By Zero : Handler
;
int00_handler proc far
	Jmp Re_Boot_Handler

int00_handler endp
;
;______________________________________________
;
; INT 02 - NMI : Handler
;
int02_handler proc far
	Jmp Re_Boot_Handler

int02_handler endp
;
;______________________________________________
;
; INT 06 - Illegal Opcode : Handler
;
int06_handler proc far
	Jmp Re_Boot_Handler

int06_handler endp
;
;----------------------------------------------
; Attempt to re-install fatal error handler.  This is required
; because command.com tends to over-ride any resident error handlers.
;
install_handler proc near
        assume ds:nothing
	Push	Cx
	Push	Si
	Push	Di
	Push	DS
	Push	ES

        Clr	Si                  ; find current fatal handler
        Mov	ES,Si
        LES	Di,ES:[24h*4]

; replace current handler if it is below us (probably command.com)

        mov Si,ES
        mov Cx,CS
        cmp Si,Cx
        Blos replace

; if current handler is AFTER us, look at the handler code to see if it
; is another copy of command.com.  this allows us to handle nested
; command.com's while still preserving application handlers.

        LDS	Si,CS:old_int24
        Mov	Cx,compare_length
        Rep cmpsw
        Jcxz replace

        jmp short keep

; if dos or command.com stole the handler, we now take it back.
; this also performs the initial installation upon startup

replace:
        Clr Cx
        mov ES,Cx
        mov word ptr es:[24h*4],offset int24_handler
        mov word ptr es:[24h*4+2],CS

keep:
	Pop	ES
	Pop	DS
	Pop	Di
	Pop	Si
	Pop	Cx
        Ret
install_handler endp


 
; =============================================
; end of resident portion of code
;
resident:

; calculate size of resident portion in bytes and segments

;fatal_size = (offset(resident)-offset(entry))
;fatal_size = offset(resident)
;fatal_segs = ((fatal_size + 15) / 16)

; initialization messages
; verbal masturbation time!

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
                db 'FOR ANY CLAIM BY ANY OTHER PARTY.',13,10,10
		db 'Masochated by "The Waszir" 1-MAY-1992 : For BBS and data recovery use.',13,10
		db '(C) within 10 light years of Earth. Send Money and Erotic Women (preferred!)',13,10
		db 'Waszir => [Earth]<FAX: +61.3.723-7535 | BBS: +81.3.3813-1169 User #2>',13,10
                db 13,10

usages          db 'Usage:  FATAL /I    ; Install.',13,10
                db '        FATAL /U    ; Remove from operation.',13,10
                db '        FATAL /C    ; Display critical error counters.',13,10
                db '        FATAL /Z    ; Zero critical error counters.',13,10
		db '        FATAL /?    ; Information.',13,10
		db ' ------------------------------------------------------------------',13,10
		db '        FATAL /IR   ; Always Retry & if not installed then install.',13,10
		db '        FATAL /II   ; Always Ignore & if not installed then install.',13,10
		db '        FATAL /IA   ; Always Abort & if not installed then install.',13,10
		db '        FATAL /IF   ; Always Fail & if not installed then install.',13,10

		db ' ------------------------------------------------------------------',13,10
		db '                      Follow default settings until Time/Retry LIMIT.',13,10
		db '        FATAL /IT   ; RETRY at limit & if not installed then install.',13,10
		db '        FATAL /IK   ; IGNORE at limit & if not installed then install.',13,10

		db '        FATAL /IC   ; ABORT at limit & if not installed then install.',13,10

		db '        FATAL /IH   ; FAIL at limit & if not installed then install.',13,10
		db '        FATAL /ID   ; RE-BOOT at limit & if not installed then install.',13,10
		db '        FATAL /IxW  ; Install re-boot traps for Interrupts 0, 2 & 6.',13,10
		db '                      Where "/Ix => x = other options, put "x" for default.',13,10
                db '$'

needDos30       db 'DOS 3.0 or later required!',13,10,'$'

fatalLoaded     db 'FATAL TSR V2.05 Installed.',13,10,'$'
fatalRemoved    db 'FATAL 2.05 Removed.',13,10,'$'
tableZeroed     db 'Error tables zeroed.',13,10,'$'
othersLoaded    db 'Other programs loaded after FATAL -- cannot Remove TSR.',13,10,'$'
alreadyLoaded   db 'TSR Already loaded!',13,10,'$'
New_Parameters	db 'TSR already loaded - new parameters installed.',13,10,'$'

Free_Memory_Error db 'TSR Memory could not be freed successfully -- ERROR!',13,10

notLoaded       db 'FATAL TSR not resident.  Use FATAL/I first.',13,10,'$'
Settings_Altered	db 'FATAL TSR Settings Altered.',13,10,'$'

reportPrefix    db 13,10,'FATAL V2.05 status:',13,10,'$'
errorCounts     db 'Critical errors.',13,10,'$'
autoCounts      db 'Automatic retries.','$'
drivePrefix     db 'Drive: $'
locusPrefix     db 'Locus:$'

Install_Parameters	db 'RIAFTKCHDB'

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
usage:   ; if just "FATAL <cr>" show short notice and how to use
	 ; else show
        lea	dx,signature
        call	disps

        mov	al,tailLen
        cmp	al,0
        lea	dx,usages
        Beq	exitWithMessage

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
	Push	Si
        Lea	Dx,signature
        call	disps
	;
        msdos dosGetvers                ;verify dos 3 or later
        Lea dx,needDos30
	;
	Pop	Si
        cmp	Al,2
        Bhi	Dos_Ok
	Jmp	installExit

Dos_Ok:
	Lodsb	; Byte Ptr [Si]+
	And	Al,0FFh-20h
	Mov	Bx,10			; 10 characters permitted
Next_Parameter:
	Cmp	Al,Install_Parameters - 1[Bx]
	Beq	Ok_Parameter
	Dec	Bx
	Bne	Next_Parameter
	Mov	Default_Mode,01		; Initialized to default mode
	Mov	Al,'B'			; Re-Boot is default
Ok_Parameter:
	Mov	TimeOut_Action,Al	; Action to take
	Lodsb	; Byte Ptr [Si]+
	And	Al,0FFh-20h
	Cmp	Al,'W'			; Install Traps for Int 00, 02 & 06?
	Bne	No_Traps_in
	Or	Extended_Modes,01	; Set Trap Mode
No_Traps_in:
	;
        Call	checkPresent
        Lea	Dx,alreadyLoaded
	Bne	Install_this_TSR
	Cmp	ES:Previous_Error,0FCh	; De-activated TSR?
	Beq	Install_this_TSR
	Jmp	Already_Installed
	;
Install_this_TSR:
        getvect 08h,old_int08           ;save original handler vectors
        getvect 21h,old_int21
        getvect 24h,old_int24

        setvect 08h,int08_handler       ;install new handlers
        setvect 21h,int21_handler

	Test	Extended_Modes,01	; Extended Mode : Re-Boot on NMI etc?
	Beq	Normal_Traps
	;
	getvect	00h,old_int00		; Save original Div/0 Interrupt Handler
	getvect 02h,old_int02		; Save original NMI Interrupt Handler
	getvect 06h,old_int06		; Save original Illegal opcode Handler
	;
	setvect 00h,int00_handler	; Re-Boot on Div/0
	setvect	02h,int02_handler	; Re-Boot on NMI
	setvect	06h,int06_handler	; Re-Boot on Illegal Opcode
	;
Normal_Traps:

        Lea dx,fatalLoaded
        Call disps

        Lea	Dx,resident             ; terminate and stay resident
;
;	int	27h
;
;	Mov	ES,CS:EnvSeg		; Return Environment Memory
;	msdos	dosFreemem		; 49h

	Add	Dx,15			; Get TSR Segment Size
	Shr	Dx,1
	Shr	Dx,1
	Shr	Dx,1
	Shr	Dx,1
        msdos	DosTsr,0		; 31h Exit --> Terminate & Stay Resident

;----------------------------------------------------------------
Already_Installed:
	Cmp	Default_Mode,01		; No change?
	Beq	Default_Mode_1
	Mov	Al,DS:TimeOut_Action	; Change variable in installed TSR
	Mov	ES:TimeOut_Action,Al	; Action to take
	;
	Lea	Dx,New_Parameters	; Message "New-parameters installed".
Default_Mode_1:
	;
installExit:
        jmp	exitWithMessage
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
	Beq	Its_Installed
	Jmp	unExit
	;
Its_Installed:
        mov bx,ES               ;bx->tsr code segment
        mov ax,CS:envseg
        sub ax,bx               ;calculate memory usage after fatal tsr
	Mov	Dx,Offset Resident + 31
	Shr	Dx,1
	Shr	Dx,1
	Shr	Dx,1
	Shr	Dx,1
        Cmp	Ax,Dx       ;amount of allowed overhead for DOS/PSP, etc.
        Lea	Dx,othersLoaded
        Bhi	unExit              ;insure that others are not loaded after

        assume ds:nothing
	Push	DS
        revect 21h,old_int21    ;unhook dos interrupt
        revect 08h,old_int08    ;unhook timer interrupt
        revect 24h,old_int24    ;unhook critical error interrupt
	;
	Test	ES:Extended_Modes,01	; were traps in place?
	Beq	No_trappings
	revect	00h,old_int00	; Restore Div/0
	revect	02h,old_int02
	revect	06h,old_int06
	;
No_Trappings:
	Mov	ES:Previous_Error,0FCh	; TSR is de-activated
	Pop	DS
	;
	Push	ES
	LES	Dx,ES:old_int24			; Put into present int24 trap location
	Mov	Word Ptr DS:int24p,Dx
	Mov	Word Ptr DS:int24p + 2,ES	; this should fix the system crash problem!
		; so that when this program exits, original "INT_24" vector will be restored

	Pop	ES
	;
	push es
	mov es,es:envseg
	msdos dosFreemem			; dealloc the tsr's environment segment
	Mov	Dx,Offset Free_Memory_error	; Any Errors?
	pop es              
	Bcs	Free_Error_1
	;
        msdos dosFreemem       ;dealloc the tsr's code segment
	Mov	Dx,Offset Free_Memory_error	; Any Errors?
	Bcs	Free_Error_1
	;
        assume ds:code

        Lea dx,fatalRemoved
Free_Error_1:
	;
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
        Mov	Ax,Total_Auto_Counts
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
