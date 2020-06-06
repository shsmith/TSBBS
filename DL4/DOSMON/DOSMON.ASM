
   title  DOSMON - DOS Activity Monitor
   page 60,132

;----------------------------------------
; DOSMON - DOS Activity Monitor
;----------------------------------------

;
; This program will terminate and stay resident.  It intercepts the
; DOS service interrupt and displays status information on the
; screen during DOS service execution periods.
;
; S.H.Smith, 15-may-86 (21-Jan-88)
;

vectors segment at 0
   org 84h
   dosvec    dd ?       ;int 21h vector
vectors ends

display segment at 0
   org 72h
   dispcs    dw ?,?,?,?
   dispco    dw ?
   dispip    dw ?,?,?,?
   disptwid  dw ?       ;display location for twiddle
   dispfun   dw ?,?     ;dos function code
   dispend   dw ?
display ends


;----------------------------------------
; startup entry point
;----------------------------------------
code segment
   assume cs:code,ds:nothing,es:nothing,ss:nothing
   org 100h

entry:
   jmp install


;----------------------------------------
; working storage
;----------------------------------------

ovect   dd 0            ;vector for old interrupt

dispseg dw 0            ;segment address for display memory
                        ; filled in by startup code

twindex dw 0            ; twiddle display index
twtab   db "Ä\³/"       ; twiddle display characters

dispcolor = 1fh         ;color for status display

dosip   dw 0            ;registers on stack upon entry
doscs   dw 0
dosflag dw 0


;----------------------------------------
; macros
;----------------------------------------

dispc macro             ;display character in al at es:[bx++2]
   mov ah,dispcolor
   mov es:[bx],ax
   inc bx
   inc bx
endm

putlo macro        ;put a low hex digit on the screen
   local p
   and al,0fh
   add al,'0'           ;convert digit to hex
   cmp al,'9'           ;handle A..F
   jbe p

   add al,7
p: 
   dispc
endm


puthi macro        ;put a hi hex digit on the screen
   shr al,1
   shr al,1
   shr al,1
   shr al,1
   putlo
endm


puthex macro       ;put 2 hex digits on screen (al)
   push ax
   puthi 
   pop ax
   putlo
endm

puthexw macro      ;put 4 hex digits on screen (ax)
   push ax
   mov al,ah
   puthex 
   pop ax
   puthex 
endm


;----------------------------------------
; new DOS service interrupt
;----------------------------------------
new21:
   pop dosflag
   pop doscs
   pop dosip
   push dosip
   push doscs
   push dosflag

   push ds
   push es
   push bx              ;save entry registers
   push ax
   push cs
   pop ds
   assume ds:code

   mov ax,dispseg       ;get display segment into es
   mov es,ax
   mov bx,offset dispcs

;----------------------------------------
; display the caller's CS:IP
;
   mov ax,doscs
   puthexw              ;display cs

   mov al,':'
   dispc

   mov ax,dosip
   puthexw              ;display ip


;----------------------------------------
; display the rotating twiddle character
;
   push bx
   mov bx,twindex       ;get twiddle index
   inc bx
   mov al,bl            ;advance to next twiddle position
   and al,3             ;bx=bx mod 4 to rotate through twiddles
   mov bl,al
   mov twindex,bx       ;save next twiddle index
   mov al,twtab[bx]     ;get the next twiddle character
   pop bx

   dispc

;----------------------------------------
; display the DOS service number in hex
;
   pop ax 
   push ax
   mov al,ah
   puthex dispfun       ;display dos function code



;----------------------------------------
; perform the DOS service function
;
todos:
   assume ds:nothing,es:nothing
   pop ax
   pop bx
   pop es               ;restore initial entry registers
   pop ds
   jmp ovect            ;jump to the real dos handler


;----------------------------------------
; startup code
;----------------------------------------
; determine where the video ram is.  this is done by putting a special
; character on the screen and then looking for it in the various video
; ram locations.

install:
   assume ds:code

   mov ah,3             ;get cursor position
   int 10h              ;video bios service
   push ax
   push bx
   push dx              ;save it for later

   mov dx,0
   mov ah,2             ;home the cursor
   int 10h

   mov ah,0Ah
   mov al,'~'           ;display a funny char at cursor
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
   mov dl,'~'
   mov ax,0b000h
   mov es,ax
   cmp dl,es:[0]
   jz dispfound
;
; look for COLOR video ram
;
   mov ax,0b800h
   mov es,ax
   cmp dl,es:[0]
   jz dispfound
;
; couldn't find video ram; display a message and abort
;
   mov dx,offset cantfind
   mov ah,9
   int 21h              ;display error message
   int 20h              ;terminate program


;----------------------------------------
; display the program signon message now that we are sure
; that we can be installed
;
dispfound:
   mov dl,' '
   mov es:[0],dl
   mov dispseg,ax       ;set the display segment

   mov dx,offset signature
   mov ah,9
   int 21h              ;display signon message

;----------------------------------------
; now install new interrupt handler
;
   mov ax,0
   mov es,ax
   assume es:vectors
;
; save old DOS service vector
;
   mov ax,word ptr dosvec
   mov word ptr ovect,ax
   mov ax,word ptr dosvec+2
   mov word ptr ovect+2,ax
;
; install new vector
;
   mov ax,offset new21  ;entry point offset
   mov word ptr dosvec,ax
   mov ax,cs            ;this code segment
   mov word ptr dosvec+2,ax
;
; set last resident code offset
; and terminate-and-stay-resident
;
   mov dx,offset install
   int 27h                         ;terminate and stay in memory



;----------------------------------------
; messages
;
signature db 10,13,"DOSMON - DOS Activity Monitor",10,13
          db "$  S.H.Smith, 21-Jan-88",10,13,26

cantfind  db "Can't find display memory",10,13,'$'


code ends
   end entry

