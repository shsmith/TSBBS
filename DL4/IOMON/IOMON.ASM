
;------------
; IOMON - Disk I/O Monitor
;------------

; This program will terminate and stay
; resident.  It intercepts the
; disk I/O interrupt and displays
; I/O status information on the
; screen during I/O wait periods.
;
; S.H.Smith, 14-may-86
;

intvec      equ [4ch]           ;offset of interrupt vector to replace
intvec2     equ [4eh]           ;within segment 0


dsphome     equ [0]             ;home position on display
dsploc      equ [9ch]           ;offset of status display within video
dsploc1     equ [9dh]           ;display segment
dsploc2     equ [9eh]
dsploc3     equ [9fh]


            org 100h

; startup entry point
entry       jmp install


; vector for old interrupt
ovect       dw 0
ovect2      dw 0


; segment address for display memory
; filled in by startup code
video_seg   dw 0


; interrupt re-entrance flag - don't botch recursive
; disk/io requests!
actflag     db 0


; previous 2 screen characters and attributes (under the status display)
scrsv1      dw 0
scrsv2      dw 0


; twiddle display index
tw_index    dw 0


; twiddle display characters
tw_table    db 'Ä\³/'


; a signature in bytes
signature   db 0ah,0dh,'IOMON - Disk I/O monitor display',0ah,0dh
            db '$  S.H.Smith, 14-May-86',0ah,0dh
            db 1ah


; user return address pointer
uretIP      dw 0
uretCS      dw 0



;------------
; vector to old disk/IO handler
;------------
o_handler   pop ax
            jmpf cs:ovect         ;to old disk/io handler


;------------
; new disk service interrupt
;------------
n_service   push ax               ;these registers will be used

;
; are we already in a disk/io interrupt?
;
            mov al,cs:actflag
            cmp al,0
            jnz o_handler         ;don't monitor recursive interrupts


;------------
; we are now intercepting the disk/io interrupt
;------------
            pop ax
            pop cs:uretIP         ;get return ip
            pop cs:uretCS         ;get return cs
            popf                  ;throw away unused flags
;
            push ds
            push es
            push bx               ;save scratch registers
            push ax
;
            push cs               ;set ds <- cs
            pop ds
;
            movb actflag,1        ;flag that we are now in a disk/io interrupt


;------------
; save the previous display data
;
            mov ax,video_seg      ;get display segment into es
            mov es,ax
;
            mov ax,es:dsploc      ;save original screen contents
            mov scrsv1,ax
;
            mov ax,es:dsploc2     ;second char
            mov scrsv2,ax


;------------
; display the rotating twiddle character
;
            mov bx,tw_index       
            inc bx
            mov ah,bl             ;advance to next twiddle position
            and ah,3              ;bx=bx mod 4 to rotate through tws
            mov bl,ah
            mov tw_index,bx       ;save next twiddle index
;
            add bx,offset(tw_table)
            mov al,[bx]           ;get the current twiddle character
;
            mov ah,15             ;attribute of twiddle status char
            mov es:dsploc,ax      ;put twiddle status on screen


;------------
; determine operation status message based on function code
;
            pop ax                ;get operation code into ah
            push ax
;
            mov al,49h            ;reset disk system = I
            cmp ah,0
            jz dspstat
;
            mov al,53h            ;status = S
            cmp ah,1
            jz dspstat
;
            mov al,52h            ;read = R
            cmp ah,2
            jz dspstat
;
            mov al,57h            ;write = W
            cmp ah,3
            jz dspstat
;
            mov al,56h            ;verify = V
            cmp ah,4
            jz dspstat
;
            mov al,46h            ;format = F
            cmp ah,5
            jz dspstat
;
; unknown function code, use '*' - this is probably a
; hard disk function
;
            mov al,2ah
            nop


;------------
; display the operation status character
;
dspstat     mov ah,0fh             ;attribute of status char
            mov es:dsploc2,ax      ;put status on screen


;------------
; perform the disk/io function
;
            pop ax
            pop bx
            pop es                ;restore initial entry registers
            pop ds

            int 13h               ;call myself recursively (this call will be
                                  ;  routed to the real int13 handler
            pushf
            push ax
            push es
            push ds

            push cs
            pop ds

            jnc restore           ;skip error handler if the operation worked


;------------
; there was an error; arrange for an error code on screen
;
            push ax
            mov al,ah
            and al,0fh
            add al,30h            ;convert low digit to hex
            mov scrsv2,al         ;and replace old screen contents

            pop ax
            mov al,ah
            shr al                ;move down bits for high digit
            shr al
            shr al
            shr al                ;make high byte hex and put on screen
            and al,0fh
            add al,30h
            mov scrsv1,al

            mov al,0ffh
            mov dsploc1,al        ;make the error code 'flash'
            mov dsploc3,al


;------------
; restore original screen contents
; or display error code in hex
;
restore     mov ax,video_seg      ;get display page into es
            mov es,ax

            mov ax,scrsv1         ;put old data on screen
            mov es:dsploc,ax      ;first char

            mov ax,scrsv2
            mov es:dsploc2,ax     ;second char


;------------
; flag end of interrupt and return to the caller
;
            movb actflag,0        ;flag that we are no longer in an interrupt

            pop ds
            pop es
            pop ax

            popf                  ;get return flags
            jmpf cs:uretIP        ;jump back to user code


;------------
; startup code
;------------
; determine where the video ram is.  this is done by putting a special
; character on the screen and then looking for it in the various video
; ram locations.
;
install     push cs
            pop ds
            mov ah,3              ;get cursor position
            int 10h               ;video bios service
            push ax
            push bx
            push dx               ;save it for later

            mov dx,0
            mov ah,2              ;home the cursor
            int 10h

            mov ah,0ah
            mov al,99h            ;display a funny char at cursor
            mov cx,1
            int 10h
;
; move cursor back to original position
;
            pop dx
            pop bx
            pop ax
            mov ah,2
            int 10h
;
; look for MONO video ram
;
            mov dl,99h
            mov ax,0b000h
            mov es,ax
            cmp dl,es:dsphome
            jz setvseg
;
; look for COLOR video ram
;
            mov ax,0b800h
            mov es,ax
            cmp dl,es:dsphome
            jz setvseg


;------------
; couldn't find video ram; display a message and abort
;
            mov dx,offset(video_err)
            mov ah,9
            int 21h           ;display error message
            int 20h           ;terminate program

video_err   db 'ERROR: Cant find display memory$'


;------------
; display the program signon message now that we are sure
; that we can be installed
;
setvseg     mov video_seg,ax      ;set the display page
            mov dx,offset(signature)
            mov ah,9
            int 21h               ;display signon message

;------------
; now install new interrupt handler
;
            mov ax,0
            mov es,ax
;
; save old disk/io vector
;
            mov ax,es:intvec
            mov ovect,ax

            mov ax,es:intvec2
            mov ovect2,ax
;
; install new vector
;
            mov ax,offset(n_service)
            mov es:intvec,ax      ;entry point offset

            mov ax,cs             
            mov es:intvec2,ax     ;this code segment
;
; set last resident code offset
; and terminate-and-stay-resident
;
            mov dx,offset(install)
            int 27h

;end

