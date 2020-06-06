
        page ,132
;
; Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
;
; This is a component of the ProDoor System.
; Do not distribute modified versions without my permission.
; Do not remove or alter this notice or any other copyright notice.
; If you use this in your own program you must distribute source code.
; Do not use any of this in a commercial product.
;
;
; Qread - quick version of ReadLn for text files
;         Used by Qread unit.
;
; Written by Samuel Smith, 11-19-88
;

code segment byte public
        assume cs:code
        public qReadLn

; -------------------------------------------------------------
;
; structure of text file record
;
textfile struc
        handle  dw ?    ;dos handle
        mode    dw ?    ;open mode
        bufSize dw ?    ;size of file buffer
        priv1   dw ?
        bufPos  dw ?    ;position of next read within file buffer
        bufEnd  dw ?    ;position past last byte of file buffer
        bufPtr  dd ?    ;pointer to file file buffer
textfile ends

        
; -------------------------------------------------------------
;
; procedure qReadLn( var fd: text;
;                    var dest: string;
;                    maxlen: word );
;

; structure of stack frame --
fileptr equ dword ptr [bp+0ch]  ;pointer to text file record
destptr equ dword ptr [bp+08h]  ;pointer to destination string
maxlen  equ word  ptr [bp+06h]  ;maximum length of destination string
curpos  equ dx
curend  equ bx

qReadLn proc far
        push bp
        mov bp,sp               ;create stack frame
        push ds

        lds si,fileptr          ;ds:si -> textfile
        mov curpos,bufpos[si]   ;current file buffer position
        mov curend,bufend[si]   ;end of file buffer position

        lds si,bufptr[si]       ;ds:si -> file buffer
        add si,curpos           ;            [bufpos]

        les di,destptr          ;es:di -> dest
        inc di

        mov cx,maxlen           ;initial destination space
        jmp short NextChar      ;get first character

;
; main character loop
;
StoreChar:
        stosb                   ;dest[len++] = c

; process next character in file buffer
NextChar:
        cmp curpos,curend       ;end of file buffer?
        jz NextBuffer

; have a character in the file buffer - get it
HaveChar:
        lodsb                   ;c = buf[bufptr++]
        inc curpos

        cmp al,26
        jle CheckControl

; it is a normal character - add it to the destination buffer
NormChar:
        loop StoreChar          ;dec cx, jnz
        jmp short qEndLine

;
; check control characters
;
CheckControl:
        cmp al,26               ;^Z? end of file
        jz qEndFile
        cmp al,10               ;lf? end of line
        jz qEndLine
        cmp al,13               ;cr? skip it
        jz NextChar
        jmp short NormChar
 
;
; file buffer is empty - get another one
;
NextBuffer:
        lds si,fileptr          ;ds:si -> textfile
        call qFillBuf

        mov curend,bufend[si]
        xor curpos,curpos       ;bufpos=0
        lds si,bufptr[si]       ;ds:si -> file buffer

        cmp curend,curpos
        jnz HaveChar

;
; end of file - return dest = ^Z unless dest has data in it
;
qEndFile:
        cmp cx,maxlen
        jnz qEndLine

        mov al,26
        stosb                   ;dest = ^Z
        dec cx

;
; end of line - set line length and return
;
qEndLine:
        lds si,fileptr          ;ds:si -> textfile
        mov bufpos[si],curpos   ;update file buffer position

        mov ax,maxlen
        sub ax,cx               ;calculate destination bytes used
        les di,destptr          ;es:di -> dest
        mov es:[di],al          ;update destination length

        pop ds
        pop bp
        ret 10                  ;dispose of 10 parameter bytes
qReadLn endp


; -------------------------------------------------------------
;
; fill file buffer
;
; from  handle[si]      dos handle
;       bufptr[si]      data buffer
;       bufsize[si]     data buffer size
;
; sets  bufpos[si]      to 0
;       bufend[si]      to bytes read
;
; preserves dx, cx, bx, ds, es, si, di
;

qFillBuf proc near
        push dx
        push cx
        push bx

        mov ax,3f00h            ;read
        mov bx,handle[si]       ;dos handle
        mov cx,bufsize[si]      ;file buffer size
        push ds
        lds dx,bufptr[si]       ;file buffer pointer
        int 21h                 ;perform the read
        pop ds
        mov bufend[si],ax       ;bytes read
        mov bufpos[si],0        ;bytes used

        pop bx
        pop cx
        pop dx
        ret
qFillBuf endp

code ends
end


