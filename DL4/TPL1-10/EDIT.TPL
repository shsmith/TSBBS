
/*
 * edit - a simple editor for tpl/I
 *
 */


/*
 * global editor variables
 *
 */
        variable edit-line              /* current line */
        variable edit-column            /* current column */
40      buffer   edit-file              /* current filename */
        variable edit-fd                /* current file descriptor */

21      constant edit-maxline           /* highest line number */
79      constant edit-maxcol            /* highest column number */

81 20 * buffer   edit-screen            /* editor screen buffer */


/*
 * editor utility functions
 *
 */

: set   swap ! ;                /* VARIABLE VALUE set - like store */

: c!                            /* VALUE VARIABLE c! - store char - slow */
        dup @                   /* get 16bit value */
        256 / 256 *             /* strip off lower 8 bits */

        d->c                    /* save upper bits for later */
        swap                    /*  change A B C on stack into B A C */
        c->d

        +                       /* add the high bits of the word */
        set                     /* and store them */
;


: c@                            /* VARIABLE c@ - load 8 char - slow */
        @                       /* get 16bit value */
        dup 256 / 256 *         /* strip low bits from a copy */
        -                       /* and subtract that from value */
;                               /* leaving the 8bit value */


: gotoxy                        /* X Y gotoxy - set cursor position */
        27   putchar            /* ESC */
        89   putchar            /* Y */
        32 + putchar            /* line number */
        32 + putchar            /* column number */
;


: screenxy                      /* X Y screenxy - get address of screen */
                                /*                buffer at X/Y location */
        edit-maxcol * +
        edit-screen +
;


/* 
 * KEY edit-key
 *
 * Process editor keys - this is the main editor function 
 *
 */

: edit-key
        dup 32 < if
                dup  5 == if    edit-line dec           endif   /* ^E up */
                dup  1 == if    edit-column dec         endif   /* ^A left */
                dup 24 == if    edit-line inc           endif   /* ^X down */
                dup  6 == if    edit-column inc         endif   /* ^F right */
                dup 13 == if    edit-line inc
                                edit-column set 0       endif   /* RETURN */
        else
                dup putchar             /* else put the char on screen */
                edit-column inc         /* and move right */
        endif
        drop

        edit-line @
        dup 0            < if   drop 0                  endif   /* <0 == 0 */
        dup edit-maxline > if   drop edit-maxline       endif
        edit-line !

        edit-column @
        dup 0            < if   drop 0                  endif
        dup edit-maxcol  > if   drop edit-maxcol        endif
        edit-column !

        edit-column @
        edit-line @
        gotoxy
;


/*
 * stubbed main edit routine
 *
 */

: edit
        cls
        0 0 gotoxy

        do
                getchar
                dup 27 == if
                        break           /* exit edit? */
                else
                        edit-key        /* process edit key */
                endif
        1 while
        drop
        cls
;


