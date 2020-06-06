
;------------------------------------------------
; HDL - Hard Disk Look-ahead
;------------------------------------------------

;
; This program will terminate and stay resident.
; It intercepts the disk I/O interrupt and attempts to speed-up disk
; accesses through an intelligent "look ahead" scheme.

; It will take a read for a single sector and turn it into a track read.
; It will then dole out single sectors on subsequent read requests.
; This version will throw away the buffer on any write operation, and
; on non-sequential reads.

; This strategy should speed up things like Turbo Pascal with include
; file compiles.   Programs that alternately read and write will probably
; even slow down.

; Future versions might keep track of the contents of the buffer and
; preserve what can be saved after a write or a nonsequential read.

;
; S.H.Smith, 19-may-86
;


;------------
; External variables
;------------

intvec      equ [4ch]           ;offset of interrupt vector to replace
intvec2     equ [4eh]           ;within segment 0


;------------
; Constants
;------------

drive        equ 2              ;drive number to look ahead on (C)
track_size   equ 52h            ;sectors per track
sect_size    equ 100h           ;size of a sector in words (must be even)


;------------
; Program section
;------------
            org 100h

; startup entry point
entry       jmp startup

; in interrupt flag - prevent recursion
in_int      db 0        ;set to non-0 to disable cache

; is status display enabled?
disp_enabl  db 0

; counter of cache hits
hit_count   dw 0

; current buffer status information
buf_dx      dw 0ffffh   ;drive and head number
buf_cx      dw 0ffffh   ;track and sector number
buf_num     db 0        ;number of sectors in buffer

; a signature in bytes
signature   db 0ah,0dh,'HDL 1.0 - Hard disk look ahead buffer',0ah,0dh
            db '$  S.H.Smith, 23-May-86',0ah,0dh
            db 1ah

; vector for old interrupt
ovect       dw 0
ovect2      dw 0

; user return vector
retv        dw 0
retv2       dw 0
flags       dw 0

; current display offset for 'display' procedure
disp_ofs    dw 0




;------------------------------------------------
; new disk service interrupt
;------------------------------------------------
n_service   proc far
            cmpb cs:in_int,0
            jnz useold            ;if already in an interrupt, pass it thru

            cmp dl,drive          ;use old handler for all other drives
            jnz useold

            cmp ax,201h
            jz new_read

;
; make the buffer contents invalid and perform the io operation
;
passthru    movb cs:buf_num,0     ;set number of sectors in buffer to 0
useold      jmpf cs:ovect         ;branch to the old handler to do the work



;------------
; process read service
;
new_read    pop cs:retv           ;get return vector
            pop cs:retv2
            pop cs:flags          ;drop flags pushed by INT

            movb cs:in_int,1      ;flag that we are in an interrupt

            call checkbuf         ;is the sector in the buffer?
            jnc exit              ;exit with it if it was

            call readtrack        ;read a track into the buffer
            jc error              ;exit now if there was an error

            call checkbuf         ;get the sector from the buffer
            jc error              ;let the real bios handle errors
                                  ;this should never happen

;------------
; return directly to the caller
;
exit        movb cs:in_int,0      ;flag that we are no longer in the int
            jmpf cs:retv          ;jump back to the user


;------------
; disk error - return error code to user
;
error       push ax
            movb cs:disp_enabl,1  ;force display enable
            mov al,'*'            ;process fatal error
            call display
            pop ax
            call status

            movb cs:in_int,0ffh   ;flag cache error and shut down cache

            mov al,1              ;bad command error
            stc                   ;set error flag
            jmpf cs:retv          ;jump back to the user

            endp



;------------------------------------------------
; checkbuf - check buffer contents for current read request.
;            if desired data is in buffer, setup registers and
;            return the data (c clr)
;            otherwise returns (c set)
;
checkbuf    proc near
            push ds
            push es
            push cx
            push bx
            push si
            push di
            push dx
            push ax

            cmp dx,cs:buf_dx       ;is this for the same drive and head?
            jnz checkfail          ;check fails if not

            mov si,offset(buffer)  ;find first sector in buffer
            mov al,cs:buf_num      ;get count of sectors in buffer
            mov dx,cs:buf_cx       ;get track/sector
            inc al                 ;adjust count for first time through loop

checkl      dec al                 ;are we out of sectors to check?
            cmp al,0
            jz checkfail           ;then the check failed

            cmp cx,dx              ;does requested sector match buffer?
            jz checkfound          ;found it!

            add si,sect_size       ;advance data ptr to next buffer
            add si,sect_size       ;(add twice so words=bytes)

            inc dx                 ;adjust dx for next compare
            jmps checkl            ;check more, if needed

;
; found the desired sector - now move it into the user space
; es:bx is user buffer
; cs:si is cache buffer
;
checkfound  pop ax
            pop dx
            push dx
            push ax

            push ax
            mov al,'H'             ;this is a 'hit'
            call display
            pop ax
            call status

            incw cs:hit_count      ;count the cache hit

            mov di,bx              ;make es:di -> user buffer
            mov cx,sect_size       ;size of a sector in WORDS

movloop     mov ax,cs:[si]         ;get a cache byte
            mov es:[di],ax         ;write a user buffer byte
            inc si
            inc si
            inc di                 ;adjust pointers
            inc di
            dec cx                 ;count the word
            jcxz endmov
            jmps movloop           ;move more if needed

endmov      pop ax
            mov ax,0               ;indicate no errors (needed?)
            push ax
            clc                    ;clr c to indicate success
            jmps checkex


checkfail   pop ax
            mov ax,100h            ;indicate error
            push ax
            stc                    ;set c to indicate failure

checkex     pop ax
            pop dx
            pop di
            pop si
            pop bx
            pop cx
            pop es
            pop ds
            ret
            endp


;------------------------------------------------
; readtrack - read a track of data starting with the requested
;             sector.  prepare for return on the first sector
;             to user.
;
readtrack   proc near
            push ds
            push es
            push dx
            push cx
            push bx
            push bp
            push si
            push di

            mov ah,2              ;read function
            mov al,1              ;one sector will surely work

            cmp dl,80h            ;is this an advanced hd function?
            jnz havesects

            mov al,track_size     ;read full disk track is possible
            mov cl,1              ;start at head of track?

havesects   mov cs:buf_num,al
            mov cs:buf_cx,cx      ;save sector ID in buffer header
            mov cs:buf_dx,dx

            push cs
            pop es
            mov bx,offset(buffer) ;make es:bx -> cache buffer

            int 13h               ;call myself recursively to do the work
                                  ;(recursion is OK because of in_int flag)
            jnc readok

;
; the read failed
;
            push ax
            movb cs:disp_enabl,1  ;force display enable
            mov al,'E'            ;read error
            call display
            pop ax
            call status

            movb cs:buf_num,0     ;empty the buffer

            stc                   ;set c to indicate error
            jmps readex

;
; the read was successful
;
readok      decw cs:hit_count     ;adjust hit count because this wasn't really
                                  ;a buffer hit at all
            clc                   ;clear c to indicate success

readex      pop di
            pop si
            pop bp
            pop bx
            pop cx
            pop dx
            pop es
            pop ds
            ret
            endp



;------------------------------------------------
; status - display full operation status
; displays the following values:
;    '[' buf_dx.buf_cx.buf_num
;    '=' dx.cx.ax
;    '@' es.bx ']'
;
status      proc near
            pushf
            push ax

            mov al,'['
            call display

            mov ax,cs:buf_dx
            call hexout

            mov ax,cs:buf_cx
            call hexout

            mov al,cs:buf_num
            mov ah,0
            call hexout

            mov al,'='
            call display

            mov ax,dx
            call hexout

            mov ax,cx
            call hexout

            pop ax
            push ax
            call hexout

            mov al,'@'
            call display

            mov ax,es
            call hexout

            mov ax,bx
            call hexout

            mov al,']'
            call display
            mov al,' '
            call display

            pop ax
            popf
            ret
            endp



;------------------------------------------------
; hexout - display ax as 4 hex digits
;
hexout      proc near

            call hexbyte   ;output ah byte

            mov ah,al
            call hexbyte   ;output al byte

            mov al,'.'
            call display

            ret
            endp



;------------------------------------------------
; hexbyte - display ah as 2 hex digits
;
hexbyte     proc near
            push ax
            mov al,ah
            shr al
            shr al
            shr al
            shr al
            and al,0fh
            add al,'0'
            cmp al,3ah
            jb hexok

            add al,7
hexok       call display

            pop ax
            push ax
            mov al,ah
            and al,0fh
            add al,'0'
            cmp al,3ah
            jb hexok2

            add al,7
hexok2      call display
            pop ax
            ret
            endp



;------------------------------------------------
; display - display a message code on the screen
; code in al
;
display     proc near
            push es
            push bx
            push ax

            cmpb cs:disp_enabl,1    ;is display enabled?
            jne displayex           ;skip display if not

            mov bx,0b800h
            mov es,bx

            mov bx,cs:disp_ofs
            inc bx
            inc bx
            and bh,3
            mov cs:disp_ofs,bx

            mov ah,15
            mov es:[bx],ax

displayex   pop ax
            pop bx
            pop es
            ret
            endp


;------------------------------------------------
;                 startup code
;------------------------------------------------

startup     proc near

            push cs
            pop ds

            mov dx,offset(signature)
            mov ah,9
            int 21h               ;display signon message

;
; hook myself into the disk services interrupt
;
            mov ax,0              ;assume es=int vector segment
            mov es,ax

            mov ax,es:intvec      ;save the old vector
            mov ovect,ax
            mov ax,es:intvec2
            mov ovect2,ax

            mov ax,offset(n_service)
            mov es:intvec,ax      ;entry point offset
            mov ax,cs
            mov es:intvec2,ax     ;this code segment

;
; clear the buffer memory
;
            mov dl,'-'            ;clear the buffer memory
            mov dh,'+'            ;to this pattern

            mov al,track_size     ;make room for 1 hard disk track
            inc al                ;and 1 extra sector for slop (needed?)

            mov bx,offset(buffer) ;start of the buffer

clrsect     mov cx,sect_size      ;clear a sector buffer

clrword     mov [bx],dx           ;clear a word buffer
            inc bx
            inc bx                ;advance to next word
            dec cx                ;count the word
            jcxz nextsect         ;more bytes in this sector?
            jmps clrword

nextsect    dec al
            cmp al,0               ;more sectors to clear?
            ja clrsect


;
; resident buffer has been cleared - now terminate
;
            inc bx
            mov dx,bx             ;pointer beyond last byte of resident section
            int 27h               ;terminate and stay resident


buffer      ds 0                  ;lookahead buffer starts here

            endp
;end

