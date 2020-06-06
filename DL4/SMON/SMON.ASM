
   title  SMON - Seek Monitor 1.3
   page 60,132

;
; SMON - Disk Seek Monitor             29-Apr-87, S.H.Smith
;                                      (rev 20-Jan-88)
; Revision history:
;   29-apr-87 1.0 initial coding
;   21-may-87 1.1 changed for mono monitor
;   20-sep-87 1.2 added sector count to display
;   20-jan-88 1.3 changed track scaling to allow 1024 tracks
;   27-jan-88 1.4 added 2 digit hex display of sector count; different colors
;

code segment
   assume cs:code,ds:nothing,es:nothing,ss:nothing
   org 100h

entry:
   jmp startup

db 13,10,'Seek monitor 1.4, 27-Jan-88 S.H.Smith (MONO)',13,10
display_segment = 0B000h   ;0b800h for color version

; a binary signature used to tell if already present
binsig dw 0DFABh

;activity flag
active db 0      


;----------------------------------------
; working storage
;

; vector for old interrupt
oldintvec  dd 0

; display segment
dispseg dw display_segment

; current display offset
dispofs dw 0

; saved contents of display
dispsav  dw 0,0,0,0,0,0,0
savesize = 6

;read and write mode status colors
public read_color,write_color,other_color
read_color   db 070h        ;read color
write_color  db 04Fh        ;write color
other_color  db 040h        ;other functions


;========================================
; new interrupt service
;----------------------------------------
newint proc far
   public newint

   cmp active,0              ;already active(recursion)
   jz usenew
   jmp oldintvec             ;jump to the real DOS handler

usenew:
   call display_status       ;display seek status

   mov active,1              ;enter recursion
   pushf
   call oldintvec            ;perform requested function
   mov active,0              ;return from recursion

   call restore_display      ;restore original display

   ret 2                     ;return, throwing away flags from stack
newint endp


;========================================
; display_status
;----------------------------------------

display_status proc near
   public display_status
   push ds
   push es
   push cx
   push si
   push di
   push ax

;
;determine location on screen based on track number for file access
;
   mov al,cl
   mov ah,0
   shl ax,1            ;get 10 bit cyl number for fixed disks
   shl ax,1
   mov al,ch

   push cx
   mov cx,ax
   add ax,ax ;*2
   add ax,cx ;*3
   pop cx
   shr ax,1  ;*1.5
   shr ax,1  ;*.75

   add ax,ax ;*2       ;move 2 spaces for each cylinder
   mov dispofs,ax

;
;save original screen contents
;
   mov si,ax
   mov ds,dispseg
   mov di,offset dispsav
   push cs
   pop es
   cld
   mov cx,savesize
   rep movsw     ;save a copy of the display

;point to screen location for new display
   mov di,dispofs
   mov es,dispseg


;
; determine operation status message based on function code
;
   pop ax                ;get operation code into ah
   push ax

   mov ch,read_color

   mov al,'I'            ;reset/init disk system
   cmp ah,0
   jz dspstat

   mov al,'S'            ;status = S
   cmp ah,1
   jz dspstat

   mov al,'R'            ;read = R
   cmp ah,2
   jz dspstat

   mov al,'?'            ;verify = ?
   cmp ah,4
   jz dspstat

   mov ch,write_color

   mov al,'F'            ;format = F
   cmp ah,5
   jz dspstat

   mov al,'W'            ;write = W
   cmp ah,3
   jz dspstat

; unknown function code, use '*'
   mov ch,other_color
   mov al,'*'

dspstat:
   mov ah,ch
   push ax

   mov al,176   ;'('
   stosw
;
; status code and display attribute known -
; display the active drive letter
;
   mov al,dl             ;drive number
   and al,0Fh            ;strip extra bits

   add al,'A'            ;convert to 'A..G'
   test dl,80h
   jz nothard

   add al,2              ;hard disks start at C
nothard:
   stosw

   pop ax                ;display the function code
   stosw

   pop cx
   push cx
   mov al,cl            ;display sector count
   shr al,1
   shr al,1
   shr al,1
   shr al,1
   and al,0fh
   add al,'0'           ;convert digit to hex
   cmp al,'9'           ;handle A..F
   jbe p0
   add al,7
p0:stosw

   mov al,cl
   and al,0fh
   add al,'0'           ;to hex
   cmp al,'9'           
   jbe p1
   add al,7
p1:stosw

   mov al,176           ;')'
   stosw

   pop ax
   pop di
   pop si
   pop cx
   pop es
   pop ds
   ret
display_status endp


;========================================
; restore_display
;----------------------------------------

restore_display proc near
   public restore_display
   push ds
   push es
   push ax
   push cx
   push si
   push di

   mov si,offset dispsav
   push cs
   pop ds
   mov di,dispofs
   mov es,dispseg
   cld
   mov cx,savesize         ;restore the display
   rep movsw

   pop di
   pop si
   pop cx
   pop ax
   pop es
   pop ds
   ret
restore_display endp



   page
;========================================
; startup code
;----------------------------------------

transient_portion:

startup proc near
   public startup

;
; check for a copy already in memory
;
   mov ax,0
   mov es,ax                 ;segment for vectors
   mov si,13h*4              ;vector address for int 13h

   mov ax,es:[si+2]          ;get current int13 code segment
   mov ds,ax                 ;make it the DS

   mov bx,offset binsig      ;get offset for the binary signature
   mov ax,ds:[bx]            ;load the signature
   cmp ax,binsig             ;is it the same?
   jnz notpresent


;
; already loaded
;
alreadypresent:
   mov bx,offset active      ;get offset of enable flag
   mov al,ds:[bx]
   cmp al,0
   mov al,0
   jnz doenable              ;toggle enable status

   mov al,10
doenable:  
   mov ds:[bx],al
   int 20h                   ;exit to dos


;
; not yet loaded - install new interrupt handler
;
notpresent:
   mov ax,es:[si]            ;save the old DOS service vector
   mov word ptr oldintvec,ax
   mov ax,es:[si+2]
   mov word ptr oldintvec+2,ax

   mov ax,offset newint
   mov es:[si],ax            ;set entry point offset
   mov ax,cs                 ;install the new handler
   mov es:[si+2],ax          ;in this code segment

   mov dx,offset transient_portion
   int 27h                   ;terminate and stay in resident

startup endp
code ends

   end entry


