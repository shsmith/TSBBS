
data segment
   p1h dw 0
   p1l dw 0

   p2h dw 0
   p2l dw 0

   rh  dw 0
   rl  dw 0
data ends

code segment
     assume cs:code,ds:data

addl proc
   mov ax,p1l
   add ax,p2l
   mov rl,ax
   mov ax,p1h
   adc ax,p2h
   mov rh,ax
addl endp

subl proc
   mov ax,p1l
   sub ax,p2l
   mov rl,ax
   mov ax,p1h
   sbb ax,p2h
   mov rh,ax
subl endp

multl proc
   mov ax,p1l
   mov cx,p2l
   imul cx
   mov rl,ax
   mov rh,cx
multl endp

divl proc
   mov ax,p1l
   mov dx,p1h
   mov cx,p2l
   idiv cx
   mov rl,ax    ;quotient
   mov p1l,dx   ;remainder
divl endp

code ends
   end

