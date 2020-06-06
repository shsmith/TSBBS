#pragma inline
/*
    abs4read.c - Turbo C 2.0

    abs4read / abs4write functions supporting DOS 4.x and COMPAQ 3.31
    with partitions > 32 MB in addition to previous versions of DOS.

    Christopher Blum            CompuServe 76625,1041
    1022 East Wayne Avenue
    Wooster, Ohio 44691

    *** prototypes in dos.h must be as follows: ***

int _Cdecl abs4read (int drive, int nsects, long lsect, void *buffer);
                                           ****

int _Cdecl abs4write(int drive, int nsects, long lsect, void *buffer);
                                           ****

*/

#include <dos.h>
#include <errno.h>

static struct {                         /* packet for DOS 4.0 */
    long sect;
    int cnt;
    void far *buf;
} d_4;

int abs4read(int drive, int nsects, long lsect, void *buffer)
{
    _AX = _version;                     /* check DOS version */
    asm cmp al,3;
    asm ja new;
    asm jb old;
    asm cmp ah,30;
    asm ja new;

old:    /* code for prior versions of DOS - use registers */

#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    asm push ds;
    asm lds bx,buffer;
#else
    asm mov bx,buffer;
#endif
    asm mov cx,nsects;
    asm mov dx,lsect;
    asm mov al,drive;
    asm int 25h;
    asm pop dx;                         /* discard saved flags */
#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    asm pop ds;
#endif
    asm jmp short done;

new:    /* code for DOS 4.0 and Compaq 3.31 - use packet */

    d_4.sect = lsect;
    d_4.cnt = nsects;
#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    d_4.buf = buffer;
#else
    d_4.buf = MK_FP(_DS, buffer);
#endif
    asm lea bx,d_4;
    asm mov cx,-1;
    asm mov al,drive;
    asm int 25h;
    asm pop dx;                         /* discard saved flags */

done:
    asm jnc good;                       /* test carry for error */
#if defined (__HUGE__)
    asm mov dx,ax;                      /* huge model trashes ax here */
    errno = _DX;
#else
    errno = _AX;
#endif
    asm mov ax,-1;                      /* bad - set errno, return -1 */
    asm jmp short ret;
    asm cmp si,di;     /* never executed - makes C save reg variables */
good:
    asm xor ax,ax;                      /* good - return 0 */
ret:
    return(_AX);
}

int abs4write(int drive, int nsects, long lsect, void *buffer)
{
    _AX = _version;                     /* check DOS version */
    asm cmp al,3;
    asm ja new;
    asm jb old;
    asm cmp ah,30;
    asm ja new;

old:    /* code for prior versions of DOS - use registers */

#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    asm push ds;
    asm lds bx,buffer;
#else
    asm mov bx,buffer;
#endif
    asm mov cx,nsects;
    asm mov dx,lsect;
    asm mov al,drive;
    asm int 26h;
    asm pop dx;                         /* discard saved flags */
#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    asm pop ds;
#endif
    asm jmp short done;

new:    /* code for DOS 4.0 and Compaq 3.31 - use packet */

    d_4.sect = lsect;
    d_4.cnt = nsects;
#if defined(__LARGE__) || defined (__COMPACT__) || defined (__HUGE__)
    d_4.buf = buffer;
#else
    d_4.buf = MK_FP(_DS, buffer);
#endif
    asm lea bx,d_4;
    asm mov cx,-1;
    asm mov al,drive;
    asm int 26h;
    asm pop dx;                         /* discard saved flags */

done:
    asm jnc good;                       /* test carry for error */
#if defined (__HUGE__)
    asm mov dx,ax;                      /* huge model trashes ax here */
    errno = _DX;
#else
    errno = _AX;
#endif
    asm mov ax,-1;                      /* bad - set errno, return -1 */
    asm jmp short ret;
    asm cmp si,di;     /* never executed - makes C save reg variables */
good:
    asm xor ax,ax;                      /* good - return 0 */
ret:
    return(_AX);
}
