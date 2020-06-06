
/* speed benchmark for 'tpl1' language  */


variable a1
variable a2

: bench
        ." speed benchmark (2000 passes) " newline
        0 a1 !
        do
                0 a2 !
                do
                        a2 inc          /* 1000 pass inner loop         */
                        a2 @ 1000 <
                while
                a1 inc                  /* 2 pass outer loop            */
                a1 @ 2 <
        while 
        7 putchar
        ." end benchmark " newline 
;



/*
 * language feature tests -
 *
 *      do while
 */

: dowhile
        10 do
                ." Value = " dup . newline
                1+
                dup 20 <
        while
        ." <20 end dowhile test, tos = " . newline newline
;



/*
 * do until test
 *
 */

: dountil
        10 do
                ." Value = " dup . newline
                1+
                dup 19 >
        until
        ." >19 end dountil test, tos = " . newline newline
;



/*
 * do break while test
 *
 */

: dobreak
        1 do
                ." val= " dup . newline
                dup 5 ==
                if
                        ." break " newline
                        break
                endif
                1+
                dup 10 ==
        until
        ." end loop, val= " . newline
;



/*
 * do continue while test
 *
 */

: docont
        1 do
                1+
                ." val= " dup . newline
                dup 5 <=
                if
                        ." continue " newline
                        continue
                endif
                ." <after continue> " newline
                dup 10 ==
        until
        ." end loop, val= " . newline
;



/*
 * true/false printer for if/then and relational testing
 *
 */

: truefalse
        if
                ." TRUE "
        else
                ." FALSE "
        endif
        newline
;


/*
 * define some constants for relational tests
 *
 */

: five  ." five "       5 ;
: six   ." six "        6 ;
: seven ." seven "      7 ;
: ten   ." ten "        10 ;



/*
 * test the various relational operators
 *
 */

: .eq.  ." == "
        five six == truefalse
        six five == truefalse
        six  six == truefalse
        newline
;


: .lt.  ." < "
        five six < truefalse
        six five < truefalse
        six  six < truefalse
        newline
;


: .le.  ." <= "
        five six <= truefalse
        six five <= truefalse
        six  six <= truefalse
        newline
;


: .gt.  ." > "
        five six > truefalse
        six five > truefalse
        six  six > truefalse
        newline
;


: .ge.  ." >= "
        five six >= truefalse
        six five >= truefalse
        six  six >= truefalse
        newline
;


: .ne.  ." != "
        five six != truefalse
        six five != truefalse
        six  six != truefalse
        newline
;


/*
 * .tests runs the actual .??. tests
 *
 */

: .tests
        ." relational operator tests: " newline
        .eq.
        .lt.
        .le.
        .gt.
        .ge.
        .ne.
        ." end of relational operator tests. " newline
;


