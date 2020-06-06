
;------------
; IOMON - Disk I/O Monitor
;------------

;
; This program will terminate and stay
; resident.  It intercepts the
; disk I/O interrupt and displays
; I/O status information on the
; screen during I/O wait periods.
;
; S.H.Smith, 14-may-86
; rewritten for MASM, s.h.smith, 19-apr-87
;

vectors     segment at 0
               org 4ch
   iovector    dw  ?               ;offset of interrupt vector to replace
   iovector2   dw  ?               ;within segment 0
vectors     ends


display     segment at 0
               org 0
   disp_home   db ?                ;home position on display

               org 9ah
   disp_twiddl   dw ?              ;offset of status display within video
   disp_funcode  dw ?
   disp_drive    dw ?

   bright = 00fh                   ;display attributes
   flash  = 0ffh
   normal = 007h
   dim    = 001h

display     ends


code        segment
   org 100h
   assume cs:code


; startup entry point
entry:      
   jmp install


; vector for old interrupt
old_iovector  dd 0


; segment address for display memory
; filled in by startup code
video_seg   dw 0


; interrupt re-entrance flag - don't botch recursive
; disk/io requests!
actflag     db 0


; previous 2 screen characters and attributes (under the status display)
save_twiddl  dw 0
save_funcode dw 0
save_drive   dw 0


; twiddle display index
tw_index    dw 0


; twiddle display characters
tw_table    db 'Ä\³/'


; a signature in bytes
signature   db 0ah,0dh,'IOMON - Disk I/O monitor display',0ah,0dh
            db '$  S.H.Smith, 18-Apr-87',0ah,0dh
            db 1ah


; user return address pointer
returnptr   dd 0



;-------------------------------------------------------------------
; new disk service interrupt
;------------
;
; are we already in a disk/io interrupt?
;
n_service:  
   cmp actflag,0
   jz n_handler         ;don't monitor recursive interrupts

   jmp old_iovector            ;to old disk/io handler


;------------
; we are now intercepting the disk/io interrupt
;------------
n_handler:  
   pop word ptr returnptr         ;get return ip
   pop word ptr returnptr+2       ;get return cs
   popf                           ;throw away unused flags

   push ds
   push es
   push bx               ;save scratch registers
   push ax

   push cs               ;set ds <- cs
   pop ds
   assume ds:code

   mov actflag,1         ;flag that we are now in a disk/io interrupt


;------------
; save the previous display data
;
   mov ax,video_seg      ;get display segment into es
   mov es,ax
   assume es:display

   mov ax,disp_twiddl         ;save original screen contents
   mov save_twiddl,ax

   mov ax,disp_funcode        ;second char
   mov save_funcode,ax

   mov ax,disp_drive          ;third char
   mov save_drive,ax


;------------
; display the active drive letter
;
   mov al,dl             ;drive number
   and al,0Fh            ;strip extra bits

   add al,'A'            ;convert to 'A..G'
   test dl,80h
   jz nothard

   add al,2              ;hard disks start at C

nothard:
   mov ah,bright
   mov disp_drive,ax


;------------
; display the rotating twiddle character
;
   mov bx,tw_index
   inc bx
   mov ah,bl             ;advance to next twiddle position
   and ah,3              ;bx=bx mod 4 to rotate through tws
   mov bl,ah
   mov tw_index,bx       ;save next twiddle index

   add bx,offset tw_table
   mov al,[bx]           ;get the current twiddle character

   mov ah,bright         
   mov disp_twiddl,ax    ;put twiddle status on screen


;------------
; determine operation status message based on function code
;
   pop ax                ;get operation code into ah
   push ax

   mov al,'I'            ;reset/init disk system
   cmp ah,0
   jz dspstat

   mov al,'S'            ;status = S
   cmp ah,1
   jz dspstat

   mov al,'R'            ;read = R
   cmp ah,2
   jz dspstat

   mov al,'W'            ;write = W
   cmp ah,3
   jz dspstat

   mov al,'V'            ;verify = V
   cmp ah,4
   jz dspstat

   mov al,'F'            ;format = F
   cmp ah,5
   jz dspstat
;
; unknown function code, use '*' - this is probably a
; hard disk function
;
   mov al,'*'


;------------
; display the operation status character
;
dspstat:    
   mov ah,bright          
   mov disp_funcode,ax    ;put status on screen


;------------
; perform the disk/io function
;
   pop ax
   pop bx
   pop es                ;restore initial entry registers
   pop ds
   assume es:nothing,ds:nothing

   int 13h               ;call myself recursively (this call will be
                         ;  routed to the real int13 handler
   pushf
   push ax
   push es
   push ds

   push cs
   pop ds
   assume ds:code

   push ax
   mov ax,video_seg      ;get display page into es
   mov es,ax
   pop ax
   assume es:display

   jnc restore           ;skip error handler if the operation worked


;------------
; there was an error; arrange for an error code on screen
;
   push ax
   mov al,ah
   and al,0fh
   add al,'0'            ;convert low digit to hex
   cmp al,'9'
   jle hex1
   add al,7

hex1:       
   mov ah,flash            ;make the code flash
   mov save_funcode,ax     ;and replace old screen contents

   pop ax
   mov al,ah
   shr al,1              ;move down bits for high digit
   shr al,1
   shr al,1
   shr al,1              ;make high byte hex and put on screen
   and al,0fh
   add al,'0'
   cmp al,'9'
   jle hex1
   add al,7

hex2:       
   mov ah,flash
   mov save_twiddl,ax

   mov ax,disp_drive        ;leave drive letter on screen
   mov ah,flash
   mov save_drive,ax


;------------
; restore original screen contents
; or display error code in hex
;
restore:    
   mov ax,save_twiddl       ;put old data on screen
   mov disp_twiddl,ax       ;first char

   mov ax,save_funcode
   mov disp_funcode,ax      ;second char

   mov ax,save_drive
   mov disp_drive,ax        ;second char


;------------
; flag end of interrupt and return to the caller
;
   mov actflag,0           ;flag that we are no longer in an interrupt

   pop ds
   pop es
   pop ax
   assume ds:nothing,es:nothing

   popf                    ;get return flags
   jmp returnptr           ;jump back to user code



;----------------------------------------------------------------
; startup code
;------------
; determine where the video ram is.  this is done by putting a special
; character on the screen and then looking for it in the various video
; ram locations.
;
install:    
   assume ds:code,es:nothing

   mov ah,3              ;get cursor position
   int 10h               ;video bios service

   push ax
   push bx
   push dx               ;save it for later

   mov dx,0
   mov ah,2              ;home the cursor
   int 10h

   mov ah,0ah
   mov al,0FFh            ;display a funny char at cursor
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
   mov ax,0b000h
   mov es,ax
   assume es:display

   mov dl,0FFh
   cmp dl,disp_home
   jz setvseg
;
; look for COLOR video ram
;
   mov ax,0b800h
   mov es,ax
   cmp dl,disp_home
   jz setvseg


;------------
; couldn't find video ram; display a message and abort
;
   mov dx,offset video_err
   mov ah,9
   int 21h           ;display error message
   int 20h           ;terminate program

video_err   db 'ERROR: Cant find display memory$'


;------------
; display the program signon message now that we are sure
; that we can be installed
;
setvseg:    
   mov video_seg,ax      ;set the display page
   mov dx,offset signature
   mov ah,9
   int 21h               ;display signon message

;------------
; now install new interrupt handler
;
   mov ax,0
   mov es,ax
   assume es:vectors
;
; save old disk/io vector
;
   mov ax,iovector
   mov word ptr old_iovector,ax

   mov ax,iovector2
   mov word ptr old_iovector+2,ax
;
; install new vector
;
   mov ax,offset n_service
   mov iovector,ax      ;entry point offset

   mov ax,cs
   mov iovector2,ax     ;this code segment
;
; set last resident code offset
; and terminate-and-stay-resident
;
   mov dx,offset install
   int 27h

code        ends
            end  entry

