*    1| 
*    2| program mathtest;
*    3| 
*-----| D1 Compiler X0.0 21-Dec-85 S.H.Smith
*-----| 6801 Code Generator
        NAM     MATHT1
*-----| 
*    4| var
        INC     D6801HDR
*    5|    v:    integer(2);
V2      RMB     2
*    6|    b:    integer(1);
B3      RMB     1
*    7|    i:    integer(2);
I4      RMB     2
MSG5    FCB     10
*    8|    msg:  char(10);
*    9| 
*-----| 
        RMB     10
*   10| begin
MATHT1  EQU     *
*-----| 
        JMP     L2
L1      FCB     15
        FCB     102     *f
        FCB     111     *o
        FCB     114     *r
        FCB     32      * 
        FCB     46      *.
        FCB     46      *.
        FCB     46      *.
        FCB     32      * 
        FCB     116     *t
        FCB     111     *o
        FCB     32      * 
        FCB     116     *t
        FCB     101     *e
        FCB     115     *s
        FCB     116     *t
L2      EQU     *
        LDX     #L1
*   11|    writeln('for ... to test');
        JSR     OP_CHAR_WRITELN
        LDX     #1
        PSHX
L3      EQU     *
        PULX
        STX     I4
        LDX     #10
        PSHX
        LDX     I4
        JSR     OP_INTEGER_LT
        TSTA
*-----| 
*   12|    for i := 1 to 10 do
        BNE     L4
        LDX     I4
        JSR     OP_INTEGER_WRITELN
        LDX     I4
        PSHX
        LDX     #1
        JSR     OP_INTEGER_ADD
        PSHX
*-----| 
        JMP     L3
*   13|       writeln(i);
*   14| 
L4      EQU     *
*-----| 
        JMP     L6
L5      FCB     18
        FCB     102     *f
        FCB     111     *o
        FCB     114     *r
        FCB     32      * 
        FCB     46      *.
        FCB     46      *.
        FCB     32      * 
        FCB     100     *d
        FCB     111     *o
        FCB     119     *w
        FCB     110     *n
        FCB     116     *t
        FCB     111     *o
        FCB     32      * 
        FCB     116     *t
        FCB     101     *e
        FCB     115     *s
        FCB     116     *t
L6      EQU     *
        LDX     #L5
*   15|    writeln('for .. downto test');
        JSR     OP_CHAR_WRITELN
        LDAA    #99
        PSHA
L7      EQU     *
        PULA
        STAA    B3
        LDAA    #90
        PSHA
        LDAA    B3
        JSR     OP_BYTE_GT
        TSTA
*-----| 
*   16|    for b := 99 downto 90 do
        BNE     L8
        LDAA    B3
        JSR     OP_BYTE_WRITELN
        LDAA    B3
        PSHA
        LDAA    #1
        TAB             *byte subtract
        PULA
        SUBB
        PSHA
*-----| 
        JMP     L7
*   17|       writeln(b);
*   18| 
L8      EQU     *
*-----| 
        JMP     L10
L9      FCB     26
        FCB     114     *r
        FCB     101     *e
        FCB     112     *p
        FCB     101     *e
        FCB     97      *a
        FCB     116     *t
        FCB     32      * 
        FCB     46      *.
        FCB     46      *.
        FCB     46      *.
        FCB     32      * 
        FCB     117     *u
        FCB     110     *n
        FCB     116     *t
        FCB     105     *i
        FCB     108     *l
        FCB     32      * 
        FCB     118     *v
        FCB     61      *=
        FCB     57      *9
        FCB     57      *9
        FCB     32      * 
        FCB     116     *t
        FCB     101     *e
        FCB     115     *s
        FCB     116     *t
L10     EQU     *
        LDX     #L9
*   19|    writeln('repeat ... until v=99 test');
        JSR     OP_CHAR_WRITELN
*   20|    repeat
L11     EQU     *
        JSR     OP_INTEGER_READLN
*   21|       readln(v);
        STX     V2
*-----| 
        JMP     L13
L12     FCB     26
        FCB     109     *m
        FCB     97      *a
        FCB     116     *t
        FCB     104     *h
        FCB     32      * 
        FCB     116     *t
        FCB     101     *e
        FCB     115     *s
        FCB     116     *t
        FCB     58      *:
        FCB     32      * 
        FCB     118     *v
        FCB     42      **
        FCB     50      *2
        FCB     44      *,
        FCB     32      * 
        FCB     45      *-
        FCB     53      *5
        FCB     44      *,
        FCB     32      * 
        FCB     47      */
        FCB     53      *5
        FCB     44      *,
        FCB     32      * 
        FCB     43      *+
        FCB     53      *5
L13     EQU     *
        LDX     #L12
*   22|       writeln('math test: v*2, -5, /5, +5');
        JSR     OP_CHAR_WRITELN
        LDX     V2
        PSHX
        LDX     #2
        JSR     OP_INTEGER_MUL
*   23|       writeln(v*2);
        JSR     OP_INTEGER_WRITELN
        LDX     V2
        PSHX
        LDX     #5
        JSR     OP_INTEGER_SUB
*   24|       writeln(v-5);
        JSR     OP_INTEGER_WRITELN
        LDX     V2
        PSHX
        LDX     #5
        JSR     OP_INTEGER_DIV
*   25|       writeln(v/5);
        JSR     OP_INTEGER_WRITELN
        LDX     V2
        PSHX
        LDX     #5
        JSR     OP_INTEGER_ADD
*   26|       writeln(v+5);
        JSR     OP_INTEGER_WRITELN
        LDX     V2
        PSHX
        LDX     #99
        JSR     OP_INTEGER_EQ
        TSTA
*-----| 
*   27|    until (v = 99);
*   28| 
        BEQ     L11
*-----| 
        JMP     L15
L14     FCB     9
        FCB     101     *e
        FCB     110     *n
        FCB     100     *d
        FCB     32      * 
        FCB     116     *t
        FCB     101     *e
        FCB     115     *s
        FCB     116     *t
        FCB     115     *s
L15     EQU     *
        LDX     #L14
*   29|    writeln('end tests');
        JSR     OP_CHAR_WRITELN
        LDX     #12345
*   30|    v := 12345;
        STX     V2
        LDX     V2
*   31|    writeln(v);
*   32| 
        JSR     OP_INTEGER_WRITELN
*-----| 
        RTS     *MATHT1
        END     MATHT1
