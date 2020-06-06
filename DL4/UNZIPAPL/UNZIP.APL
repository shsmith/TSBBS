UNZIP is copyrighted by Samuel H. Smith and is presented as "FREEWARE".
STRIP is donated to the public domain by Martin E. Peckham.

Unzip, in its present shape, will only work with the APW shell. There is no
reason preventing the compilation of the source code using the Aztec C
compiler for ProDOS or DOS 3.3 other than I don't use the Aztec compiler
any more. It would not be too difficult to put prompting in so that it
could be run from GSOS, but adding the ROM Tool Kit calls to make it look
'nice' is more than I am willing to do. Besides, it's my opinion that
unzip will be used the most when porting MSDOS C and Pascal source files
to the APW environment.

Unzip supports the normal ProDOS path conventions, but nothing fancy like
wild card expansion. It expects to work on one 'zip' file at a time.

I have only modified the C source files. The Pascal source files are as
distributed by Mr. Smith except that I ran them through STRIP. I have
added two files. LOCAL.H and MAKEFILE. Local.h has a few of the Apple
specific items and makefile is for use by my shareware MAKE program to
automate the compile and link.

I have included my STRIP program which I developed because I needed
something to make porting MSDOS source easier. The source for STRIP
is included but only the object for 'SETARGV'. Setargv.c is a copy-
righted file but the object code is not copyrighted. setargv()
expands any wild cards (i.e. a '=' or a '?') in the command tail. argc
and argv are passed to setargv() and are modified as side-effects of
calling setargv(). See strip.c for the usage of setargv().

Strip replaces carriage-return/linefeed combinations with a single
carriage-return, expands TABs to every 4th column, and gobbles the
Ctrl-Zs that pad some MSDOS text files. Note that there is a command
line switch that allows for a different tab stop.

Strip will only affect those files that have TEXT, BINARY or SRC file types.

Usage:
        unzip zipfile           this assumes a '.ZIP' extension
        unzip zipfile.zip

        strip -t8 filename      changes tabs to every 8th column
        strip =                 'strips' all files in the directory
        strip ?.c ?.h           prompts for files that end in '.C' & '.H'
