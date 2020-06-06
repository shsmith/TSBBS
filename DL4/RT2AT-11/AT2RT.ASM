
;------------------------------------------------------------------------------
;
; at2rt.asm     s.h.smith. 2-sep-87 (rev 3-sep-87)
;
; makes an old AT style keyboard act more like a RT (101) style
;
;------------------------------------------------------------------------------
; definition of keyboard mapping:
;
;   AT keyboard        function
;     CTRL               ALT
;     ALT                CTRL
;
ctrl_bit   = 4          ;shift state codes
alt_bit    = 8
lock_bit   = 040h

ctrl_key   = 01dh       ;physical key scan codes
alt_key    = 038h
lock_key   = 03ah       ;caps-lock

;define what each key will do after translation
new_ctrl   = alt_bit
new_alt    = ctrl_bit
;new_lock   = ctrl_bit

;
;
kb_data       equ 60h                       ;keyboard data port
kb_ctrl       equ 61h                       ;keyboard control port
eoi           equ 20h                       ;8259 EOI value
int_ctrl      equ 20h                       ;8259 port address

bios_data     segment at 40h                ;BIOS data area

              org 17h
kb_status     db ?                          ;keyboard status byte

              org 1Ah
buffer_head   dw ?                          ;pointer to keyboard buffer head
buffer_tail   dw ?                          ;pointer to keyboard buffer tail

              org 80h
buffer_start  dw ?                          ;starting keyboard buffer address
buffer_end    dw ?                          ;ending keyboard buffer address
bios_data     ends

code            segment para public 'code'    ;code segment
                assume cs:code
                org 100h
begin:          jmp initialize                ;goto initialization code

copyright       db 'at2rt.com 1.1, s.h.smith',1Ah

old9h           label dword
old9h_vector    dw 2 dup (?)             ;storage for interrupt 9 vector

;

;------------------------------------------------------------------------------
;Interrupt 9 handler.  Execution comes here when a key is pressed or released.
;------------------------------------------------------------------------------
new9h         proc near
              sti                           ;set interrupt enable flag
              push ax
              in al,kb_data                 ;get scan code from keyboard

              mov ah,new_alt
              cmp al,alt_key                ;Alt key pressed?
              je key_down
              cmp al,alt_key+128            ;Alt key released?
              je key_up

              mov ah,new_ctrl
              cmp al,ctrl_key               ;Ctrl key pressed?
              je key_down
              cmp al,ctrl_key+128           ;Ctrl key released?
              je key_up

;             mov ah,new_lock
;             cmp al,lock_key               ;Lock key pressed?
;             je key_down
;             cmp al,lock_key+128           ;Lock key released?
;             je key_up

exit:         pop ax                        ;restore AX
              jmp old9h                     ;goto old interrupt handler
new9h         endp


;------------------------------------------------------------------------------
;A key was pressed.  Set the specified shift bit.
;
key_down:     push ds
              push ax

              push ax
              call reset_kb                 ;acknowledge the key
              mov ax,bios_data              ;point DS to BIOS data area
              mov ds,ax
              assume ds:bios_data
              pop ax

              or kb_status,ah               ;set the specified bit

              pop ax
              pop ds 
              assume ds:nothing
              jmp end_int                   ;exit

;------------------------------------------------------------------------------
;A key was released.  Clear the specified shift bit.
;
key_up:       push ds
              push ax

              push ax
              call reset_kb                 ;acknowledge the key
              mov ax,bios_data              ;point DS to BIOS data area
              mov ds,ax
              assume ds:bios_data
              pop ax

              not ah
              and kb_status,ah              ;clear the specified bit

              pop ax
              pop ds 
              assume ds:nothing
              jmp end_int                   ;exit


;------------------------------------------------------------------------------
;A key was pressed.  Toggle the specified shift bit.
;
key_toggle:   push ds
              push ax

              push ax
              call reset_kb                 ;acknowledge the key
              mov ax,bios_data              ;point DS to BIOS data area
              mov ds,ax
              assume ds:bios_data
              pop ax

              xor kb_status,ah              ;toggle the specified bit

              pop ax
              pop ds 
              assume ds:nothing
              jmp end_int                   ;exit

;------------------------------------------------------------------------------
;A key was pressed.  Ignore it.
;
key_ignore:   push ds
              push ax
              call reset_kb                 ;acknowledge the key
              pop ax
              pop ds 
              assume ds:nothing
              jmp end_int                   ;exit

;------------------------------------------------------------------------------
;
end_int:      mov al,eoi                    ;issue EOI to 8259 controller
              out int_ctrl,al
              pop ax                        ;clean up the stack
              iret                          ;return from interrupt


;------------------------------------------------------------------------------
;RESET_KB resets the keyboard to acknowledge the current key
;------------------------------------------------------------------------------
reset_kb      proc near
              in al,kb_ctrl                 ;get control port value
              mov ah,al                     ;save it
              or al,80h                     ;set high bit of control value
              out kb_ctrl,al                ;send reset value
              mov al,ah                     ;get original control value
              out kb_ctrl,al                ;enable keyboard
              ret                           ;done
reset_kb      endp


;------------------------------------------------------------------------------
;INITIALIZE prepares the body of the program for residency.
;------------------------------------------------------------------------------
initialize    proc near
;
;Save the old interrupt 9 vector and replace it with a new one.
;
              mov ax,3509h                  ;get current interrupt 9 vector
              int 21h
              mov old9h_vector,bx           ;save it
              mov old9h_vector[2],es

              mov ah,25h                    ;point to NEW9H routine
              lea dx,new9h                  ;and install it
              int 21h
;
;Terminate
;
              mov dx,offset initialize      ;set last resident address
              int 27h                       ;terminate-but-stay-resident
initialize    endp
code          ends
              end begin
