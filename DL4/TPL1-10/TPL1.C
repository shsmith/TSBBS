

/*
 * TPL1 - Threaded Programming Language / I
 *
 * Copyright 1983, 1989 Samuel H. Smith;  All rights reserved
 *
 *    Do not distribute modified versions without my permission.
 *    Do not remove or alter this notice or any other copyright notice.
 *    If you use this in your own program you must distribute source code.
 *    Do not use any of this in a commercial product.
 *
 * Created: 10-21-83 SHS
 *
 */


#include <stdio.h>
#include <ctype.h>

#define repeat for(;;)



/* definition of first-in last-out stack */

struct stack {                          /* A Stack Structure */
        int  s_ptr;                     /* Stack Pointer */
        int  s_size;                    /* Size Of The Stack */
        int  *s_data;                   /* The Data On The Stack */
};

struct stack _data;                     /* Data Stack */
struct stack _control;                  /* Control Stack */



/* definitions of plist types */

#define D_INT      0            /* a primitive interpreted in compile mode */
#define D_COMP     1            /* a primitive called in compile mode */
#define D_LAYERED  127          /* a layered non-primitive word */

struct plist {                          /* A Primitive-list Structure */
        char   *pl_name;                /* Name Of This List */
        char   pl_type;                 /* Type Of Plist 0=primitive */
        struct plist **pl_funs;         /* Table of sub-lists or a pointer to
                                           the single called by this list */
};

typedef struct plist plist;

#define PRIM plist **            	/* use (PRIM) prefix in dictionary */

typedef int (*funptr)();
#define FUNPTR funptr   		/* use (FUNPTR) prefix to convert
					   sub-plists into function ptrs */

struct plist **curint;                  /* Current Interpreter Word Position */

int    compile;                         /* Compile Mode Flag */
struct plist *defplt[250];              /* Current DEFINE Pointer List */
int    defcnt;                          /* Current DEFINE Pointer Count */
int    errors;                          /* error count in DEFINE */

FILE * infd = stdin;                    /* Current Input File */
char   linebuf[200];                    /* Current Input Line */
int    linepos;                         /* Position In Input Line */
char   wordbuf[100];                    /* Current Input Word */
char   tmpword[100];                    /* Temp buffer for QUOTE primitive */

char   *lastmem;                        /* Last allocated addr for FREEMEM */

#define DICTSIZE  500                   /* Maximum Size Of The Dictionary */
int    dictsize;                        /* Current Size Of The Dictionary */

struct plist    *ifpl,                  /* pl address for "if" function */
                *elsepl,                /*                "else"        */
                *endifpl,               /*                "endif"       */
                *dopl,                  /*                "do"          */
                *whilepl,               /*                "while"       */
                *untilpl,               /*                "until"       */
                *litpl;                 /*                "<lit>"       */

struct plist *pl_init();
struct plist *pl_find();
char *strsave();
char *memalloc();


main()
{
        extern struct plist dict[];

        printf("\nTPL1 - Threaded Programming Language / I   Copyright 1989 Samuel H. Smith\n");

        stk_init(&_data,200);                   /* Allocate Data Stack */
        stk_init(&_control,100);                /* Allocate Control Stack */

        dictsize = 0;
        while (dict[++dictsize].pl_name);       /* Find end of dictionary */

        ifpl    = pl_find("IF");                /* init some pl pointers */
        elsepl  = pl_find("ELSE");
        endifpl = pl_find("ENDIF");
        dopl    = pl_find("DO");
        whilepl = pl_find("WHILE");
        untilpl = pl_find("UNTIL");
        litpl   = pl_find("<LIT>");


        infd = fopen("tpl1dic.tpl","r");        /* Open standard dic file */
        if (infd <= 0) {
                printf("Can't open tpl1dic.tpl\n");
                infd = stdin;
        }

        while (interactive());                  /* Do interactive input */

        exit(0);
}


interactive()           /* Do a line of Interactive User-interface */
{
        struct plist *pl;

        if (infd == stdin) {
                printf("\nok\n");       /* prompt stdin reads */
        }

        if (!getline())
                return 0;               /* end of stdin file? */

        while (getword()) {
                if (wordbuf[0] == 0)    /* skip blank words */
                        continue;       

                pl = pl_find(wordbuf);  /* Find And Execute It */
                if (pl == 0) {
                        if (isdigit(wordbuf[0])) {
                                /* Push Literal Numbers */
                                stk_push(&_data,atoi(wordbuf));  
                        }  
                        else {
                                printf("'%s' is undefined.\n",wordbuf);
                        }
                }
                else pl_interp(pl);     /* Else Interpret The Word */
        }

        return 1;
}



/*
 * Pl_init - Initialize A New Primitive-list
 *
 */

struct plist *
pl_init(name,size)
char *name;             /* Name Of The Plist To Create */
int  size;              /* Number Of Functions In The Plist */
{
        struct plist *pl;

        if (dictsize >= DICTSIZE) {
                printf("Dictionary is full\n");
                errors++;
                dictsize--;                     /* Re-define last entry */
        }

        pl = &dict[dictsize++];                 /* Find New Dict Entry */
	pl->pl_funs = (PRIM)memalloc(sizeof(pl) * size);
						/* Alloc The Plist Array */

        stoupper(name);                         /* Make names upper case */
        pl->pl_name = strsave(name);            /* Save the Plist name */
        pl->pl_type = D_LAYERED;                /* A Non-primitive Plist */

        return pl;                              /* Pointer To The New Plist */
}



/*
 * pl_find - find a dictionary entry by name.  returns
 *           address of the located pl entry, 0 if not found
 */

struct plist *
pl_find(str)            /* Find A Dictionary Entry By Keyword */
char *str;
{
        int  i;

        stoupper(str);          /* all words are uppercase */

        /* search backwards to make new definitions faster */

        for (i = dictsize-1; i >= 0; i--)
        {
                if (strcmp(dict[i].pl_name,str) == 0)
                        return &dict[i];
        }

        return 0;               /* Not Found */
}



/*
 * Plist Interpreter -  Recursively Interprets A Plist, Returns
 *                      Number Of Data Slots To Skip
 *
 */

pl_interp(pl)
register struct plist *pl;      /* Pointer To Plist To Be Interpreted */
{
        register struct plist *subpl;
        register struct plist **prvint;
        int (*fun)();


        /* call it directly if it is one of the primitive types */

        if (pl->pl_type != D_LAYERED) {         /* Is This A Primitive? */
		fun = (FUNPTR)pl->pl_funs;      /* Then Run It Directly */
                (*fun)();
                return;
        }


        /* It Is Not A Primitive */

        prvint  = curint;               /* Save Previous Interp Posit */
        curint  = pl->pl_funs;

        repeat {                                /* Interpret Each Function */
                subpl = *curint++;              /* As A Sub-plist */
                if (subpl == 0) break;
                pl_interp(subpl);
        }

        curint  = prvint;                       /* Restore Interp Position */
}


stk_init(stack,size)            /* Initialize New Stack */
struct stack *stack;
int  size;
{
	stack->s_data = (int *)memalloc(size * sizeof(int));
        stack->s_size = size;
        stack->s_ptr  = 0;
}


stk_push(stack,data)            /* Push Data On The Stack */
struct stack *stack;
int data;
{
        if (stack->s_ptr >= stack->s_size) {
                printf("Stack full\n");
                return;
        }
        stack->s_data[stack->s_ptr++] = data;
}


stk_pop(stack)                  /* Pop Data From Top Of Stack */
struct stack *stack;
{
        if (stack->s_ptr == 0) {
                printf("Empty stack\n");
		return 0;
        }
        return stack->s_data[--stack->s_ptr];
}


stk_top(stack)                  /* Get Data At Top Of Stack */
struct stack *stack;
{
        if (stack->s_ptr == 0) {
                printf("Empty stack\n");
		return 0;
        }
        return stack->s_data[stack->s_ptr-1];
}


stk_empty(stack)                /* See If Stack Is Empty */
struct stack *stack;
{
        if (stack->s_ptr == 0)
                return 1;
        else
                return 0;
}


getline()               /* Get A Line Of User Input */
{                       /* return 0 on end of file */
        int  i;
        int  c;

        fflush(stdout);
        i = 0;
        repeat {
                c = fgetc(infd);
                if (c == EOF) {
                        if (infd == stdin)
                                return 0;       /* eof in stdin? */

                        fclose(infd);           /* else go back to stdin */
                        infd = stdin;
                        break;
                }
                if (c == '\n') break;

                linebuf[i++] = c;
        }

        linebuf[i] = 0;
        linepos = 0;
        return 1;
}


getword()       /* Get A Word From Current Line, Return 0 End Of Line */
{               /* return 0 on end of line */
        char c;
        int  i;

        fflush(stdout);

        if (linebuf[linepos] == 0)
                return 0;      /* End Of Line? */

        i = 0;
        repeat {
                c = linebuf[linepos];
                if (c == 0) break;
                linepos++;
                if (isspace(c)) break;

                wordbuf[i++] = c;
        }
        
        wordbuf[i] = 0;

        return 1;
}


nextword()              /* Get Next Word From User Input */
{                       /* return 0 on end of file */
        repeat {
                while (getword() == 0) {
                        if (getline() == 0)
                                return 0;       /* end of file? */
                }
                if (wordbuf[0]) break;          /* skip blank words */
        }
        return 1;
}


char *
strsave(str)            /* Save string and return pointer to it */
char *str;
{
        char *buf;

        buf = memalloc(strlen(str)+1);
        strcpy(buf,str);
        return buf;
}


stoupper(str)           /* map string to upper case */
char *str;
{
        while (*str) {
                if (islower(*str))
                        *str = toupper(*str);
                str++;
        }
}


char *
memalloc(size)          /* allocate memory buffer */
int size;
{
        char *mem;
	mem = (char *)malloc(size);
        if (mem == 0) {
                printf("Out of memory, size=%d\n",size);
                errors++;
        }

        lastmem = mem + size;           /* save last allocation for FREEMEM */
        return mem;
}


/*
 *
 * Library of Primitive (core) Functions
 *
 * These are the functions that make up the default (or core) dictionary
 * of TPL1.  The standard dictionary is defined entirely in terms of
 * these primitive functions.
 *
 */

/*
 * DEFINE - this is the basic word definition function.  
 *
 * define builds a new dictionary entry with the threaded dictionary
 * entries of the words going into the deinition.  Literal numbers are
 * compiled as "<LIT>" calls.  Primitives of type "1" are called to
 * do their own compiles.  Primitives of type "0" are simple threaded
 * into the definition.
 *
 * syntax:      : NAME   <word> <word> ... <word> ;
 *
 */

DEFINE()                /* Define A New Word   : Name ... ;  */
{
        struct plist *pl;
        int  (*fun)();
        char name[40];
        int  j;

        if (compile) {
                printf("Missing ';' or nested define\n");
                errors++;
        }

        nextword();
        strcpy(name,wordbuf);           /* get name of word to define */
        pl = pl_find(wordbuf);
        if (pl != 0) {
                printf("'%s' redefined.\n",wordbuf);
        }

        errors = 0;
        compile = 1;
        defcnt = 0;                     /* flag compile mode */
        repeat {
                nextword();
                if (strcmp(wordbuf,";") == 0)
                        break;          /* End Definition? */

                pl = pl_find(wordbuf);
                if (pl == 0) {
                        if (isdigit(wordbuf[0])) {
                                defplt[defcnt++] = litpl;
				defplt[defcnt++] = (plist *)atoi(wordbuf);
                        }
                        else {
                                printf("'%s' is undefined.\n",wordbuf);
                                errors++;
                        }
                }
                else {
                        if (pl->pl_type == D_COMP) {    /* Needs Compile? */
				fun = (FUNPTR)pl->pl_funs;
                                (*fun)();               /* then call it */
                        }
                        else {
                                defplt[defcnt++] = pl;  /* Add The Function */
                        }
                }

                if (defcnt > 240) {
                        printf("Definition too long\n");
                        errors++;
                }
        }

        defplt[defcnt++] = 0;                   /* Mark End Of List */
        compile = 0;

        if (errors) 
                return;                         /* dont define if errors */

        pl = pl_init(name,defcnt);              /* Make The Dictionary Entry */
        for (j = 0; j < defcnt; j++)            /* Copy The Plist Pointers */
                pl->pl_funs[j] = defplt[j];
}


LITERAL()               /* Place A Literal Value On The Data Stack */
{
        stk_push(&_data,*curint++);
}


DROP()                  /* Drop Top Of Stack Value */
{
        stk_pop(&_data);
}


DUP()                   /* Duplicate Top Of Stack Value */
{
        stk_push(&_data,stk_top(&_data));
}


SWAP()                  /* Swap Top 2 Stack Values */
{
        int  i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data,i);
        stk_push(&_data,j);
}


ADD()                   /* Add Top 2 Stack Values */
{
        int  i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j+i);
}


SUBTRACT()              /* Subtract Top 2 Stack Values */
{
        int  i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j-i);
}


MULTIPLY()              /* Multiply Top 2 Stack Values */
{
        int  i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j*i);
}


DIVIDE()                /* Divide Top 2 Stack Values */
{
        int  i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j/i);
}


PUTCHAR()               /* Print  Out Character On Top Of Stack */
{
        putchar(stk_pop(&_data));
}


PUTINT()                /* Print  Out Integer On Top Of Stack */
{
        printf("%d",stk_pop(&_data));
}


UPUTINT()               /* Print  Out Unsigned Integer On Top Of Stack */
{
        printf("%u",stk_pop(&_data));
}


GETCHAR()               /* Get Character To Top Of Stack */
{
        stk_push(&_data,fgetc(infd));
}


GETINT()                /* Get Integer To Top Of Stack */
{
        int  i = 0;
        nextword();
        i = atoi(wordbuf);
        stk_push(&_data,i);
}


VARIABLE()              /* VARIABLE name - declare integer */
{
        struct plist *pl;
        nextword();
        pl = pl_init(wordbuf,3);
        pl->pl_funs[0] = litpl;
	pl->pl_funs[1] = (plist *)memalloc(sizeof(int));
        pl->pl_funs[2] = 0;
}


BUFFER()                /* size BUFFER name - declare character buffer */
{
        struct plist *pl;
        nextword();
        pl = pl_init(wordbuf,3);
        pl->pl_funs[0] = litpl;
	pl->pl_funs[1] = (plist *)memalloc(stk_pop(&_data));
        pl->pl_funs[2] = 0;
}


CONSTANT()              /* value CONSTANT name - declare constant */
{
        struct plist *pl;
        nextword();
        pl = pl_init(wordbuf,3);
        pl->pl_funs[0] = litpl;
	pl->pl_funs[1] = (plist *)stk_pop(&_data);
        pl->pl_funs[2] = 0;
}


COMMENT()               /* comment to be ignored */
{
        repeat {
                if (nextword() == 0)
                        break;          /* end of file? */

                if (strcmp(wordbuf,"*/") == 0)
                        break;          /* end of comment? */
        }
}


PRQUOTE()                               /* Print  Literal String ." ... " */
{
        int  i;

        repeat {
                nextword();
                if (strcmp(wordbuf,"\"") == 0) break;
                if (compile) {
                        defplt[defcnt++] = litpl;
			defplt[defcnt++] = (plist *)strsave(wordbuf);
                        defplt[defcnt++] = pl_find("TYPESTR");
                }
                else {
                        printf("%s ",wordbuf);
                }
        }

}


SPACES()                        /* Print  Spaces */
{
        int i;
        i = stk_pop(&_data);
        while (i--)
                putchar(' ');
}


NEWLINE()               /* Print  Newline */
{
        putchar('\n');
}


TYPESTR()               /* Type String Pointed To By Top Of Stack */
{
        printf("%s ",stk_pop(&_data));
}


QUOTE()                 /* Put address of string on stack */
{
        nextword();

        if (compile) {
                defplt[defcnt++] = litpl;
		defplt[defcnt++] = (plist *)strsave(wordbuf);
        }
        else {
                strcpy(tmpword,wordbuf);
                stk_push(&_data,tmpword);
        }
}


GETSTR()                /* Put address of USER INPUT string on stack */
{
        if (compile) {
                defplt[defcnt++] = pl_find("\"");
        }
        else {
                nextword();
                strcpy(tmpword,wordbuf);
                stk_push(&_data,tmpword);
        }
}


LOADFILE()              /* redirect input from QUOTEd string */
{
        char *fn;

        if (infd != stdin) {
                fclose(infd);
                infd = stdin;
        }

	fn = (char *)stk_pop(&_data);
        infd = fopen(fn,"r");
        if (infd <= 0) {
                printf("Can't read '%s'\n",fn);
                infd = stdin;
        }
}


PRDICT()        /* print contents of dictionary */
{
        int i;
        extern struct plist dict[];

        for (i=0; i<dictsize; i++) {
                printf("%13s  ",dict[i].pl_name);
                if (i%5 == 4)
                        putchar('\n');
        }
}


FETCH()         /* replace address with integer contents */
{
        int *dat;
	dat = (int *)stk_pop(&_data);
        stk_push(&_data,*dat);
}


STORE()         /* store tos-1 data at tos address */
{
        int *dat;
	dat = (int *)stk_pop(&_data);
        *dat = stk_pop(&_data);
}


DO()            /* DO .... t/f UNTIL */
{
        stk_push(&_control,curint);
}


UNTIL()         /* DO .... t/f UNTIL */
{
        int predicate;

        predicate = stk_pop(&_data);
        if (predicate) {
                stk_pop(&_control);
        }
        else {
		curint = (PRIM)stk_top(&_control);
        }
}


WHILE()         /* DO .... t/f WHILE */
{
        int predicate;

        predicate = stk_pop(&_data);
        if (predicate == 0) {
                stk_pop(&_control);
        }
        else {
		curint = (PRIM)stk_top(&_control);
        }
}


CONTINUE()      /* DO .. CONTINUE .. t/f WHILE */
{
	curint = (PRIM)stk_top(&_control);
}


BREAK()         /* DO ... BREAK ... WHILE */
{
        struct plist *pl;

	while ((pl = *curint++) != 0) {
                if (pl == whilepl) break;
                if (pl == untilpl) break;
        }

        stk_pop(&_control);
}


DOIF()          /* t/f IF ... [ELSE] ... ENDIF */
{
        int predicate;
        struct plist *pl;

        predicate = stk_pop(&_data);
        if (predicate)
                return;         /* do nothing if true */


        /* else skip to next ELSE or ENDIF */

	while ((pl = *curint++) != 0) {
                if (pl == elsepl) break;
                if (pl == endifpl) break;
        }
}


DOELSE()                /* t/f IF ... ELSE ... ENDIF */
{
        struct plist *pl;
                
	while ((pl = *curint++) != 0) {
                if (pl == endifpl) break;
        }
}



ENDIF()                 /* t/f IF ... ENDIF */
{
        /* no op statement */
}


LESSTHAN()              /* relational operator */
{
        int i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j<i);
}


ULESSTHAN()             /* unsigned lessthan */
{
        unsigned i,j;
        i = stk_pop(&_data);
        j = stk_pop(&_data);
        stk_push(&_data, j<i);
}


NOT()                   /* replace non-0 with 0 on stack */
{
        stk_push(&_data, ! stk_pop(&_data));
}


DOEXIT()                /* exit to system */
{
        exit(0);
}


PLFIND()                /* find a word, replace with pl address */
{
        stk_push(&_data,pl_find(stk_pop(&_data)));
}


PLPRINT()       /* print definition of a pl pointer */
{
        struct plist *pl,**subpl;

	pl = (plist *)stk_pop(&_data);
        if (pl == 0)
                return;

        printf(": %s\t",pl->pl_name);
        if (pl->pl_type != 127) {
                printf("(primitive) ");
        }
        else {
                subpl = pl->pl_funs;
                repeat {
                        pl = *subpl++;
                        if (pl == 0) break;
                        if (pl == litpl) {
                                printf("%d ",*subpl++);
                        }
                        else {
                                printf("%s ",pl->pl_name);
                        }
                }
        }
        printf(";\n");
}


DTOC()          /* move top of data stack to control stack */
{
        stk_push(&_control,stk_pop(&_data));
}


CTOD()          /* move top of control stack to data stack */
{
        stk_push(&_data,stk_pop(&_control));
}


PLSIZE()        /* return size of a plist (dictionary) entry */
{
        stk_push(&_data,sizeof(struct plist));
}


FREEMEM()       /* return number of bytes of free memory */
{
        char i;         /* this method might not work on all systems */

        stk_push(&_data,&i - lastmem);
}

        

/*
 * Dictionary of Primitive Functions
 *
 */

struct plist dict[DICTSIZE] = {
        {"<LIT>",       D_INT,  (PRIM)LITERAL},
        {"(PLFIND)",    D_INT,  (PRIM)PLFIND},
        {"(PLPRINT)",   D_INT,  (PRIM)PLPRINT},
        {"(PLSIZE)",    D_INT,  (PRIM)PLSIZE},
        {"DROP",        D_INT,  (PRIM)DROP},
        {"DUP",         D_INT,  (PRIM)DUP},
        {"SWAP",        D_INT,  (PRIM)SWAP},
        {"D->C",        D_INT,  (PRIM)DTOC},
        {"C->D",        D_INT,  (PRIM)CTOD},
        {"+",           D_INT,  (PRIM)ADD},
        {"-",           D_INT,  (PRIM)SUBTRACT},
        {"*",           D_INT,  (PRIM)MULTIPLY},
        {"/",           D_INT,  (PRIM)DIVIDE},
        {"@",           D_INT,  (PRIM)FETCH},
        {"!",           D_INT,  (PRIM)STORE},
        {"<",           D_INT,  (PRIM)LESSTHAN},
        {"U<",          D_INT,  (PRIM)ULESSTHAN},
        {"/*",          D_COMP, (PRIM)COMMENT},
        {"\"",          D_COMP, (PRIM)QUOTE},
        {".\"",         D_COMP, (PRIM)PRQUOTE},
        {":",           D_COMP, (PRIM)DEFINE},
        {"DO",          D_INT,  (PRIM)DO},
        {"UNTIL",       D_INT,  (PRIM)UNTIL},
        {"WHILE",       D_INT,  (PRIM)WHILE},
        {"BREAK",       D_INT,  (PRIM)BREAK},
        {"CONTINUE",    D_INT,  (PRIM)CONTINUE},
        {"IF",          D_INT,  (PRIM)DOIF},
        {"ELSE",        D_INT,  (PRIM)DOELSE},
        {"ENDIF",       D_INT,  (PRIM)ENDIF},
        {"NOT",         D_INT,  (PRIM)NOT},
        {"VARIABLE",    D_INT,  (PRIM)VARIABLE},
        {"CONSTANT",    D_INT,  (PRIM)CONSTANT},
        {"BUFFER",      D_INT,  (PRIM)BUFFER},
        {"PUTCHAR",     D_INT,  (PRIM)PUTCHAR},
        {"C.",          D_INT,  (PRIM)PUTCHAR},
        {"I.",          D_INT,  (PRIM)PUTINT},
        {".",           D_INT,  (PRIM)PUTINT},
        {"U.",          D_INT,  (PRIM)UPUTINT},
        {"GETCHAR",     D_INT,  (PRIM)GETCHAR},
        {"GETINT",      D_INT,  (PRIM)GETINT},
        {"GETSTR",      D_COMP, (PRIM)GETSTR},
        {"SPACES",      D_INT,  (PRIM)SPACES},
        {"NEWLINE",     D_INT,  (PRIM)NEWLINE},
        {"TYPESTR",     D_INT,  (PRIM)TYPESTR},
        {"LOADFILE",    D_INT,  (PRIM)LOADFILE},
        {"EXIT",        D_INT,  (PRIM)DOEXIT},
        {"FREEMEM",     D_INT,  (PRIM)FREEMEM},
        {".DICT",       D_INT,  (PRIM)PRDICT},
        {0,0,0}                                 /* end of dictionary */
};


