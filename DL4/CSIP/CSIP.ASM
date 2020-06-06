
;------------
; CSIP - CONTINUOUS DISPLAY OF SOME REGISTERS ON SCREEN
;------------

;
; This program will terminate and stay resident.  It intercepts the clock
; tick interrupt, providing a continuous display of selected cpu registers.
;
; samuel h. smith, 12-10-91
;

vectors     segment at 0
                org 4*8
   iovector     dw  ?           ;offset of interrupt vector to replace
   iovector2    dw  ?           ;within segment 0

                org 0417h
   kbdflags     db ?
   scrollbit = 010h             ;scroll-lock bit

                org 0449h
   vidmode      db ?

vectors     ends


code        segment
   org 100h
   assume cs:code,ds:nothing,es:nothing,ss:nothing


; startup entry point
entry:      
   jmp install


; vector for old interrupt
oldhandler  dd 0


; display only after skipping a specified number of interrupts
skip_init = 3
skip_count  db skip_init


; segment address for display memory
disp_seg    dw 0b800h   ;display segment (mono=b000)
disp_ofs    dw 0        ;current display offset
initial_ofs = 120       ;initial display offset
next_ofs    dw 120      ;display offset for next update
last_ofs    = initial_ofs+4*(80*2)
disp_color  = 15        ;display color


; a signature in bytes
signature   db 0ah,0dh,'CSIP - Resident CPU register display.  Samuel H. Smith, 12-27-91'
            db 0ah,0dh,'Press SCROLL LOCK key to toggle SS:SP CS:IP status display.'
            db 0ah,0dh,'$',1ah


; user return address pointer
returnptr   dd 0



;-------------------------------------------------------------------
; new clock tick interrupt
;------------
;
newhandler:
   dec skip_count
   jz continue
   jmp oldhandler

continue:
   pushf
   call oldhandler

   sti

   mov skip_count,skip_init

   pop word ptr returnptr         ;get return ip
   pop word ptr returnptr+2       ;get return cs
   push word ptr returnptr+2
   push word ptr returnptr

   push ds
   push es
   push bx               ;save scratch registers
   push ax

   mov ax,0
   mov es,ax            ;activate display only when scroll-lock active
   assume es:vectors
   test kbdflags,scrollbit
   jnz active
   jmp inactive

active:
   mov ax,next_ofs
   mov disp_ofs,ax
   add ax,80*2
   cmp ax,last_ofs
   jle setofs
   mov ax,initial_ofs

setofs:
   mov next_ofs,ax

;
; display ss:sp
;
   mov ax,ss
   call hexout
   mov al,':'
   call putch
   mov ax,sp
   call hexout
   mov al,' '
   call putch

;
; display cs:ip
;
   mov ax,word ptr returnptr+2
   call hexout
   mov al,':'
   call putch
   mov ax,word ptr returnptr
   call hexout

inactive:
   pop ax
   pop bx
   pop es                ;restore initial entry registers
   pop ds
   assume ds:nothing,es:nothing

   iret

;------------------------------------------------
; hexout - display ax as 4 hex digits
;
hexout      proc near
   call hexbyte   ;output ah byte

   mov ah,al
   call hexbyte   ;output al byte

   ret
hexout   endp



;------------------------------------------------
; hexbyte - display ah as 2 hex digits
;
hexbyte     proc near
   push ax
   mov al,ah
   shr al,1
   shr al,1
   shr al,1
   shr al,1
   and al,0fh
   add al,"0"
   cmp al,3ah
   jb hexok

   add al,7
hexok:
   call putch

   pop ax
   push ax
   mov al,ah
   and al,0fh
   add al,"0"
   cmp al,3ah
   jb hexok2

   add al,7
hexok2:
   call putch
   pop ax
   ret
hexbyte   endp

;------------------------------------------------
; putch - display a message code on the screen
; code in al
;
putch     proc near
   push es
   push bx
   push ax

   mov bx,disp_seg
   mov es,bx
   mov bx,disp_ofs
   inc bx
   inc bx
   mov disp_ofs,bx

   mov ah,disp_color
   mov es:[bx],ax

   pop ax
   pop bx
   pop es
   ret
putch   endp



;----------------------------------------------------------------
; startup code
;------------
;
install:    
   assume ds:code,es:nothing

;------------
; display the program signon message now that we are sure
; that we can be installed
;
   mov dx,offset signature
   mov ah,9
   int 21h               ;display signon message

;
; now install new interrupt handler
;
   mov ax,0
   mov es,ax
   assume es:vectors

;
; determine video ram segment based on video mode
;
   cmp vidmode,7
   jnz colormode

   mov disp_seg,0b000h  ;mono
colormode:

;
; save old vector
;
   mov ax,iovector
   mov word ptr oldhandler,ax
   mov ax,iovector2
   mov word ptr oldhandler+2,ax

;
; install new vector
;
   mov ax,offset newhandler
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
