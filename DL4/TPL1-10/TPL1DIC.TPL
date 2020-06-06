
/*
 * Standard dictionary for 'tpl1'
 *      Threaded Programming Language / I
 *
 * Created by Samuel H. Smith, 10-22-83
 *
 */

newline
." Loading standard dictionary... "


/* make some better relational tests    */

: >=    < not ;                 /* greater than or equal        */
: >     swap < ;                /* greater than                 */
: <=    > not ;                 /* less than or equal           */
: ==    - not ;                 /* equal values                 */
: !=    - ;                     /* not equal                    */
: bool  not not ;               /* convert value into t/f       */
: and   bool swap bool * bool ; /* logical and                  */
: or    bool swap bool + bool ; /* logical or                   */


/* make some utility commands   */

: nl    newline ;               /* abbreviated newline          */
: help  " helpfile loadfile ;   /* print helpfile               */
        
: cls   27 putchar ." [2J " ;   /* clear screen                 */

: noop ;                        /* no operation                 */

: ?     @ . ;                   /* print variable contents      */
: 1+    1 + ;                   /* add 1 to value               */
: 1-    1 - ;                   /* subtract 1 from value        */
: inc   dup @ 1+ swap ! ;       /* increment variable           */
: dec   dup @ 1- swap ! ;       /* decrement variable           */

: decode (PLFIND) (PLPRINT) ;   /* " word decode - decode word  */

: dict                          /* decode entire dictionary     */
        " <lit> (plfind)                /* find first           */
        do
                dup (plprint)           /* decode it            */
                (plsize) + dup @        /* find next            */
        while
        drop ;


: free  ." Free memory = "      /* print amount of free memory  */
        freemem u. ;


/*
 * load filename - simplified load command
 *
 */

: load
        getstr
        ." Loading: "
        dup typestr 
        newline
        loadfile
;


: /bench        " bench.tpl     loadfile ;
: /edit         " edit.tpl      loadfile ;



/*
 * end of startup, print free memory and go into
 * the interactive programming mode.
 *
 */

newline
newline
free
newline


