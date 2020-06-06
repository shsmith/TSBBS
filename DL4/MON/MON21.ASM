
;----------------------------------------
; MONITOR - Interrupt Activity Monitor
;----------------------------------------
;
; This program will terminate and stay resident.
; It intercepts an interrupt and displays status registers
; on each call to the interrupt.
;
; S.H.Smith, 24-may-86
;

;----------------------------------------
; startup entry point
;----------------------------------------
code segment
   assume cs:code,ds:nothing,es:nothing,ss:nothing
   org 100h

startup:
   jmp install


;----------------------------------------
; program configuration
;----------------------------------------

monint     equ 21h       ;the interrupt number to monitor

init_ofs   equ 40        ;display segment offset for status display

status_msg db "DOS $"    ;prefix string in status display



;----------------------------------------
; working storage
;----------------------------------------

; a signature in bytes ($ terminated)
crlf       db 0ah,0dh,"$"
signature  db "Activity Monitor",0ah,0dh
           db "$  S.H.Smith, 22-May-86",0ah,0dh
           db 1ah

; segment address for display memory
; filled in by startup code
disp_seg   dw 0
disp_ofs   dw 0

; vector for old interrupt
oldintvec  dd 0

; twiddle display index
twindex    dw 0

; twiddle display characters
twtable    db "Ä\³/"



;----------------------------------------
; new interrupt service
;----------------------------------------
newint:
   push ds
   push es
   push bx                   ;save entry registers
   push ax

   mov disp_ofs,init_ofs ;set display offset for messages


;----------------------------------------
; display the status message
;
   mov bx,offset status_msg
   call message              ;display status message prefix

   call twiddle              ;display rotating twiddle

   pop ax
   pop bx
   pop es                    ;restore initial entry registers
   pop ds

   call status               ;display all registers


;----------------------------------------
; perform the interrupt function
;
   jmp oldintvec         ;jump to the real dos handler





;----------------------------------------
; library code
;----------------------------------------

;----------------------------------------
; display $ terminated message
; entry: bx points to message
;
message proc near
msgnext:
   mov al,cs:[bx]
   cmp al,"$"
   jz msgex

   call display
   inc bx
   jmp msgnext

msgex:
   ret
message endp


;----------------------------------------
; display the rotating twiddle character
;
twiddle proc near

   mov bx,twindex         ;get twiddle index
   inc bx
   mov al,bl                 ;advance to next twiddle position
   and al,3                  ;bx=bx mod 4 to rotate through twiddles
   mov bl,al
   mov twindex,bx         ;save next twiddle index

   add bx,offset twtable
   mov al,cs:[bx]            ;get the next twiddle character
   call display
   ret
twiddle endp


;------------------------------------------------
; status - display all registers
;
; display:  "[" ax,bx,cx,dx,es,ds "]"
;
; uses:  disp_seg - display segment
;        disp_ofs - starting offset within display segment
;
status      proc near
   pushf
   push ax

   mov al,"["
   call display

   pop ax
   push ax
   call hexout

   mov ax,bx
   call hexout

   mov ax,cx
   call hexout

   mov ax,dx
   call hexout

   mov ax,es
   call hexout

   mov ax,ds
   call hexout

   mov al,"]"
   call display

   mov al," "
   call display

   pop ax
   popf
   ret
status   endp



;------------------------------------------------
; hexout - display ax as 4 hex digits
;
hexout      proc near
   call hexbyte   ;output ah byte

   mov ah,al
   call hexbyte   ;output al byte

   mov al,"."
   call display

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
   call display

   pop ax
   push ax
   mov al,ah
   and al,0fh
   add al,"0"
   cmp al,3ah
   jb hexok2

   add al,7
hexok2:
   call display
   pop ax
   ret
hexbyte   endp



;------------------------------------------------
; display - display a message code on the screen
; code in al
;
display     proc near
   push es
   push bx
   push ax

   mov bx,disp_seg
   mov es,bx
   mov bx,disp_ofs
   inc bx
   inc bx
   mov disp_ofs,bx

   mov ah,15
   mov es:[bx],ax

   pop ax
   pop bx
   pop es
   ret
display   endp



;----------------------------------------
; startup code
;----------------------------------------
; determine where the video ram is.  this is done by putting a special
; character on the screen and then looking for it in the various video
; ram locations.
;
install:
   push cs
   pop ds

   mov ah,3         ;get cursor position
   int 10h          ;video bios service
   push ax
   push bx
   push dx          ;save it for later

   mov dx,0
   mov ah,2         ;home the cursor
   int 10h

   mov ah,0Ah
   mov al,88h       ;display a funny char at cursor
   mov cx,1
   int 10h
;
; move cursor back to original position
;
   pop dx
   pop bx
   pop ax
   push ax
   push bx
   push dx

   mov ah,2
   int 10h
;
; look for MONO video ram
;
   mov dl,88h
   mov ax,0b000h
   mov es,ax
   cmp dl,es:[0]
   jz foundvid
;
; look for COLOR video ram
;
   mov ax,0b800h
   mov es,ax
   cmp dl,es:[0]
   jz foundvid
;
; couldn"t find video ram; display a message and abort
;
   mov dx,offset errmsg
   mov ah,9
   int 21h           ;display error message
   int 20h           ;terminate program


errmsg db "ERROR: Cant find display memory$"


;----------------------------------------
; found video segment - now remove the
; funny character and print the signon
;
foundvid:
   mov disp_seg,ax     ;set the display segment
;
   pop dx
   pop bx
   pop ax
   push ax
   push bx
   push dx
   mov dx,0
   mov ah,2         ;home the cursor
   int 10h

   mov ah,0Ah
   mov al," "       ;display a space
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


;----------------------------------------
; display the program signon message now that we are sure
; that we can be installed
;
   mov dx,offset crlf
   mov ah,9
   int 21h

   mov dx,offset status_msg
   mov ah,9
   int 21h           ;display signon message, first part

   mov dx,offset signature
   mov ah,9
   int 21h           ;display signon message, rest


;----------------------------------------
; now install new interrupt handler
;
; calculate the vector address for the monitored interrupt
;
   mov bx,monint
   add bx,bx         ;*2
   add bx,bx         ;*4 = offset of vector in segment 0
;
; save old DOS service vector
;
   mov ax,0
   mov es,ax
   mov ax,es:[bx]
   mov word ptr oldintvec,ax

   inc bx
   inc bx
   mov ax,es:[bx]
   mov word ptr oldintvec+2,ax
;
; install new vector
;
   mov ax,cs                   ;this code segment
   mov es:[bx],ax

   dec bx
   dec bx
   mov ax,offset newint       ;entry point offset
   mov es:[bx],ax

;
; set last resident code offset
; and terminate-and-stay-resident
;
   mov dx,offset install
   int 27h          ;terminate and stay in memory

code ends
   end startup

;end
