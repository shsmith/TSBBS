
   title  DFA13 - DOS File Accelerator version 1.3
   page 60,132

;
; DFA13 - DOS File Accelerator v1.3        20-Nov-86, S.H.Smith
;
; DFA is a small resident utility that can "accelerate" file access
; in many programs.
;
; DFA predicts when your program will want to read from a file and
; reads the data into a buffer before it is asked for.  This is the
; opposite of a "cache" type program.  A cache keeps data AFTER it has
; been used; DFA gets data BEFORE it is needed.
;
; WARNING: This program goes between your programs and DOS and had
; the potential of causing data loss.  Make sure you have made a backup
; before you try this program.
;
; Written by Samuel H. Smith, 24-may-86
; Assemble with MASM v4.0
;


;----------------------------------------
;
  public bufsize,maxread,status,readhits,realreads,handle,bytesinbuf
  public position,seek_hi,seek_lo,bytesread,oldintvec,retip
  public nametabl,namechg

code segment
   assume cs:code,ds:nothing,es:nothing,ss:nothing
   org 100h

entry:
   jmp startup


;----------------------------------------
; program configuration and statistics (these should not be moved)
;
bufsize    dw 4000h     ;size of the file buffer.
                        ;can be up to 0FC00H.

maxread    dw 1000h     ;largest data read size that will enable
                        ;buffering on a file.
                        ;larger initial reads will not be buffered.

readhits   dw 0         ;count of reads that were satisfied by the buffer

realreads  dw 0         ;count of real reads done through dos on buffered files

bytesinbuf dw 0         ;number of bytes currently in the buffer

namechg    db 0         ;flags that one of the captured filenames has changed

;space for the filenames for each of the 20 handles
nametabl   db 1280 dup (0)

; a binary signature hex 'DFAC' used to tell if DFA is already present
binsig     dw 0DFACh



;----------------------------------------
; file status variables
;

status     db 0         ;acceleration status
       ready = 0           ;ready to accelerate
       recursion = 088h    ;using interrupt recursion
       disabled = 0ffh     ;disabled

nohandle   equ word ptr 03333h
                        ;special handle value when there is no current handle

handle     dw nohandle  ;the file handle for the current file

position   dw 0         ;the next read position of the current file
                        ;from the local buffer

seek_hi    dw 0         ;32 bit base position for current file
seek_lo    dw 0

bytesread  dw 0         ;number of bytes read in current readfrombuf call

openmode   dw 0         ;open access code for last open/creat
nameseg    dw 0
nameofs    dw 0


; a signature in bytes ($ terminated)
signature  db 13,10,'DOS File Accelerator v1.3 (SHS, 20-Nov-86)'
           db 13,10,'Public domain material.  Personal use only.'
           db 13,10,'$'
           db 13,10,'by Samuel H. Smith',
           db 13,10,'   5119 N. 11th Ave 332'
           db 13,10,'   Phoenix, Az 85013'
           db 13,10
           db 1ah




;----------------------------------------
; working storage
;

; vector for old interrupt
oldintvec  dd 0

; user return data
retip     dd 0

retflag   dw 0
localip   dw 0


;----------------------------------------
; macros
;
jbz macro lab
   jb lab
   jz lab
   endm

jahz macro val,lab
   cmp ah,val
   jz lab
   endm

display macro text
   push ds
   push cs
   pop ds
   mov dx,offset text
   mov ah,9
   int 21h
   pop ds
   endm


;========================================
; new interrupt service
;----------------------------------------
newint:
   public newint

   cmp status,disabled ;is DFA disabled?
   jz useold

   jahz 00h,doreset          ;terminate program?
   jahz 31h,doreset          ;keep process?
   jahz 4bh,doreset          ;exec?
   jahz 4ch,doreset          ;terminate?

   cmp status,ready   ;are we already in an interrupt?
   jnz useold

   jahz 3ch,doopen           ;create function?
   jahz 3dh,doopen           ;open function?
   jahz 3eh,doclose          ;close function?
   jahz 3fh,doread           ;read function?
   jahz 40h,dowrite          ;write function?

   cmp ah,42h                ;lseek function?
   jnz useold
   jmp doseek


;----------------------------------------
; use old interrupt handler
;----------------------------------------

useold:
   public useold
   jmp oldintvec         ;jump to the real DOS handler


   page
;----------------------------------------
; doreset - process DOS functions that reset all files
;----------------------------------------

doreset proc near
   public doreset

   cmp handle,nohandle
   jz resetx                 ;use old handler if no current file

   call setfilepos           ;set file position and let dos take over

resetx:
   mov status,ready          ;clear recursion flag because sometimes
                             ;dos never returns (as with ctrl-break)

   jmp useold                ;let dos do it's work

doreset endp


;----------------------------------------
; doopen - process DOS open function
;----------------------------------------

doopen proc near
   public doopen

   mov openmode,ax
   mov nameseg,ds
   mov nameofs,dx

   call calldos              ;let DOS open the file

   pushf
   jc openex

   call grabname             ;grab and keep the filename

   cmp handle,ax             ;if its not the current file handle
   jnz openex                ;then there's nothing more to do

   mov handle,nohandle       ;we just re-opened the current file -
                             ;reset handle to purge previous buffering
openex:
   popf

   jmp return

doopen endp


;----------------------------------------
; dowrite - process DOS functions that close or modify files
;----------------------------------------

dowrite proc near
   public dowrite

   cmp bx,handle
   jnz writex                ;use old handler if no current file

   call setfilepos           ;set file position and let dos take over

writex:
   jmp useold                ;and let dos do it's work

dowrite endp


;----------------------------------------
; doclose - process DOS functions that close or modify files
;----------------------------------------

doclose proc near
   public doclose

   call dropfile

   cmp bx,handle
   jnz closex                ;use old handler if no current file

   call setfilepos           ;set file position and let dos take over

closex:
   jmp useold                ;and let dos do it's work

doclose endp



   page
;----------------------------------------
; doread - process DOS read function
;
; This procedure is the heart of the program.  It will decide if
; read requests should be buffered or processed by DOS.
; It switches buffering to a new file when needed.
;----------------------------------------

doread proc near
   public doread

   cmp bx,handle             ;is this the current file?
   jz readagain              ;then read from it again

   cmp cx,maxread            ;is this read for a fairly small buffer?
   jb readswitch             ;switch buffering to this file if it is

   inc realreads             ;count this as a "real" read through dos
   inc readhits              ;count this as a "logical" read through dos
   jmp useold                ;just let DOS do the read
                             ;and keep the current file

;
; time to switch buffering to a different file
;
readswitch:
   public readswitch

   cmp handle,nohandle       ;is there a current file?
   jz newfile                ;open new file if not

; unbuffer the current file
   call setfilepos           ;there is a current file - reset it to it's
                             ;current position so DOS can take over on later
                             ;read requests.

;
; start buffering a new file
;
newfile:
   public newfile

   mov namechg,1
   mov handle,bx             ;make this the new current file
   call getfilepos           ;get and save the current file position

   call loadbuf              ;load a buffer from the file

;
; try to read from the current buffered file
;
readagain:
   public readagain

   cmp cx,bufsize            ;is the read request too big for the buffer?
   jbz oktoread

   call setfilepos           ;set file position and let dos take over
   jmp useold


oktoread:
   call readfrombuf          ;read data from the current buffer
   jmp return

doread endp


   page
;----------------------------------------
; doseek - process DOS lseek function
;----------------------------------------

doseek proc near
   public doseek

   cmp bx,handle
   jnz seekx                 ;use old handler if no current file

;
; a better version would attempt to salvage data already in
; the buffer.  this version just throws away the buffer.
;
   call setfilepos           ;set file position and let dos take over

seekx:
   jmp useold                ;and let dos do it's work

doseek endp


   page
;----------------------------------------
; readfrombuf - read some user data from current position
;               in the local buffer
;----------------------------------------

readfrombuf proc near
   public readfrombuf

   sti
   call pushall

   push ds
   pop es
   mov di,dx                 ;destination is users buffer -> es:di

   mov dx,bytesinbuf         ;dx=bytes left in buffer
                             ;cx=user requested bytecount

   cmp cx,dx                 ;all ok if reading less than what's left in
   jbz haveenough            ;the buffer

;
; not enough data in buffer to fulfill the read request
; re-buffer the file to see if we can get enough data
;
   mov bx,handle
   call setfilepos

   mov handle,bx
   call getfilepos

   call loadbuf              ;get the next block from dos

   mov dx,bytesinbuf         ;get new bytecount
                             ;(might be 0 again if EOF)

   cmp cx,dx                 ;is there enough this time?
   jbz haveenough

   mov cx,dx                 ;read only what's left if not
                             ;(this must be the end of file)

;
; there should be enough data in the buffer to do the read
; copy the data from the buffer into the users data area
;
haveenough:
   public haveenough

   push cs
   pop ds
   mov si,position           ;source is position in local buffer -> ds:si
   add si,offset buffer

   push cx                   ;save the bytecount
   jcxz copydone             ;don't copy if nothing to do

   cld                       ;move in forward direction
   rep movsb                 ;move the block as a "string"
                             ;cx bytes from ds:si to es:di

copydone:
   public copydone

   sub si,offset buffer      ;adjust buffer position
   mov position,si

   pop ax                    ;get bytecount
   mov bytesread,ax
   mov bx,ax
   mov ax,bytesinbuf         ;adjust bytes remaining in buffer
   sub ax,bx
   mov bytesinbuf,ax

   inc readhits              ;count this read as a buffer hit

   call popall

   mov ax,bytesread          ;return number of bytes read
   clc                       ;clear c to indicate success
   ret

readfrombuf endp


   page
;----------------------------------------
; loadbuf - read a buffer full of data from the current file
;----------------------------------------

loadbuf proc near
   public loadbuf

   call pushall

   push cs
   pop ds
   mov dx,offset buffer      ;read into ds:dx

   mov cx,bufsize            ;size of read

   mov ah,3fh                ;read from file function code

   mov bx,handle             ;file to read from

   call calldos              ;let DOS do the read

   mov position,0
   mov bytesinbuf,ax         ;save number of bytes read into buffer

   inc realreads             ;count this as a "real" read through dos

   call popall
   ret

loadbuf endp


   page
;----------------------------------------
; setfilepos - do a DOS lseek to current position of the
;              current file
;----------------------------------------

setfilepos proc near
   public setfilepos

   call pushall

   mov ah,42h                ;lseek function
   mov al,0                  ;absolute mode
   mov cx,seek_hi
   mov dx,seek_lo            ;seek back to file base position
   mov bx,handle
   call calldos

   mov ah,42h                ;lseek function
   mov al,1                  ;relative to current position mode
   mov cx,0
   mov dx,position           ;and advance to match buffered reads
   mov bx,handle
   call calldos

   mov seek_hi,dx            ;save file base position for "setfilepos"
   mov seek_lo,ax

   mov bytesinbuf,0          ;clear buffer in case of error
   mov position,0
   mov handle,nohandle
   mov namechg,1

   call popall
   ret

setfilepos endp


   page
;----------------------------------------
; getfilepos - get the current position if the
;              selected file
;----------------------------------------

getfilepos proc near
   public getfilepos

   call pushall

   mov ah,42h                ;lseek
   mov al,1                  ;relative to current position
   mov cx,0
   mov dx,0
   mov bx,handle
   call calldos              ;dos lseek to get current file position

   mov seek_hi,dx            ;save file base position for "setfilepos"
   mov seek_lo,ax
   mov position,0

   call popall
   ret

getfilepos endp


   page
;----------------------------------------
; call DOS with current registers and return
; to caller for more processing
;----------------------------------------

calldos proc near
   public calldos

   mov status,recursion       ;flag that we are using recursion
   int 21h                    ;call myself recursively (ok because of flag)
   mov status,ready
   ret

calldos endp


;----------------------------------------
; return to user from an interrupt service
;----------------------------------------

return proc near
   public return

   pop word ptr retip
   pop word ptr retip+2   ;get the user return address
   pop retflag            ;throw away the flags from the int instruction

   jmp retip              ;jump back to the user code

return endp


   page
;----------------------------------------
; grabname - grab and store the filename used in
;            an open or create call
;----------------------------------------

grabname proc near
   public grabname
   call pushall

   push cs
   pop es

   mov cl,6
   mov ah,0
   shl ax,cl                   ;handle = handle <<6 = handle * 64
   add ax,offset nametabl      ;get table base address
   mov di,ax

   mov ax,openmode
   cmp ah,3ch
   mov ah,'C'
   jz setmode

   mov ah,'R'
   cmp al,0
   jz setmode

   mov ah,'W'
   cmp al,1
   jz setmode

   mov ah,'U'

setmode:
   mov es:[di],ah
   inc di

   mov si,nameofs
   mov ds,nameseg

copyname:
   mov al,ds:[si]
   inc si
   mov es:[di],al
   inc di
   cmp al,0
   jnz copyname

   mov namechg,1
   call popall
   ret
grabname endp


;----------------------------------------
; dropfile - drop a name from the filename list
;----------------------------------------

dropfile proc near
   call pushall

   mov cl,6
   mov ax,bx
   mov ah,0
   shl ax,cl                   ;handle = handle <<6 = handle * 64
   add ax,offset nametabl      ;get table base address
   mov di,ax
   mov byte ptr cs:[di],'.'
   mov namechg,1

   call popall
   ret
dropfile endp


   page
;----------------------------------------
; push all registers
;
pushall proc near
   public pushall

   pop localip
   pushf
   push dx
   push cx
   push bx
   push ax
   push bp
   push si
   push di
   push es
   push ds
   jmp localip

pushall endp


;----------------------------------------
; pop all registers
;
popall proc near
   public popall

   pop localip
   pop ds
   pop es
   pop di
   pop si
   pop bp
   pop ax
   pop bx
   pop cx
   pop dx
   popf
   jmp localip

popall endp


   page
;========================================
; startup code
;----------------------------------------

   even                      ;force even address
buffer db 0                  ;the file buffer starts here
   public buffer


nowpresent:
   db 13,10,'DFA is already loaded in memory$'

nowenabled:
   db 13,10,'File acceleration is Enabled',13,10,'$'

nowdisabled:
   db 13,10,'File acceleration is Disabled',13,10,'$'


startup proc near
   public startup

   display signature         ;display signon message

;
; check for a copy of DFA already in memory
;
   mov ax,0
   mov es,ax                 ;segment for vectors
   mov si,21h*4              ;vector address for int 21h

   mov ax,es:[si+2]          ;get current int21 code segment
   mov ds,ax                 ;make it the DS
   mov bx,offset binsig      ;get offset for the binary signature
   mov ax,ds:[bx]            ;load the signature
   cmp ax,binsig             ;is it the same?
   jnz notpresent


;
; DFA is already loaded - toggle enable/disable
;
alreadypresent:
   display nowpresent        ;say that program is already present

   mov bx,offset status      ;get offset of enable flag
   mov ax,ds:[bx]
   cmp ax,disabled
   jz doenable


dodisable:                   ;if enabled, then toggle to disabled
   mov ax,disabled
   mov ds:[bx],ax
   display nowdisabled       ;tell the user
   int 20h                   ;and exit to dos


doenable:                    ;if disabled, then toggle to enable
   mov ax,ready
   mov ds:[bx],ax
   display nowenabled        ;tell the user
   int 20h                   ;and exit to dos


;
; DFA not yet loaded - install new interrupt handler
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

   display nowenabled        ;say that acceleration is enabled

   mov dx,offset buffer
   add dx,bufsize            ;reserve space for the buffer
   int 27h                   ;terminate and stay in resident

startup endp

code ends

   end entry


