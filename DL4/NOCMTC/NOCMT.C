
/* Filter to remove comments from asmgen output */

#include <stdio.h>

FILE *fin,*fout;
int  c;
char line[255];
char *p;

procline()
{
   *p=0;
	while ((p>=line) && (*p <= ' '))
	   p--;							/* remove trailing spaces */
   ++p;
	*p=0;

   if ((*line == 'L') && (strlen(line) > 6)) 
		*line=0;						/* ignore Lxxxx EQU statements */

	if (*line) {					/* output only non-blank lines */
		fputs(line,fout);
		fputc('\n',fout);
	}

	line[10]=0;
	if (!strcmp(line," ADD SP,OF"))
	   fputc('\n',fout);		/* blank line after stack cleanup
										following C function calls */

   if (line[1] == 'J')
		fputc('\n',fout);		/* add a blank line after any jump */

	p=line;						/* prepare for next line */
	*p=0;
}


nocmt()
{ 
   p=line;
   *p=0;

   while ((c=fgetc(fin)) >= 0) 
   {
      switch(c) 
      {
         case ';':
				do c = fgetc(fin);
				while ((c!='\n') && (c>=0))
				   ;							/* ignore all chars after ';' */
				procline();
				break;

		   case ':':
				*p++ = c;
				*p = 0;
			   if (strlen(line) == 6) {
				   fputc('\n',fout);		/* put blank line before labels */
				   procline();				/* put label on line before statement */
				}
				break;

         case '\n':
				procline();					/* process the line when newline seen */
            break;

	      case '\r':
				break;

			case '\t':						/* map tabs into spaces */
			   *p++ = ' ';
				break;

         default:							/* accumulate all other chars */
            *p++ = c;
            break;
      }
   }
}
 

main(argc,argv)
int argc;
char **argv;
{
   fin = stdin;
   fout = stdout;

   switch (argc) {
      case 1:  break;

      case 2:  fin = fopen(argv[1],"r");
					break;

      case 3:  if (argv[1][0] != '-')
		   		   fin = fopen(argv[1],"r");
      			fout = fopen(argv[2],"w");
					break;

      default: puts("usage:\tnocmt <in >out");
      			puts("\tnocmt INFILE >out");
					puts("\tnocmt - <in OUTFILE");
					puts("\tnocmt INFILE OUTFILE");
					exit(1);
   }

   if (fin == NULL) {
      puts("can't open input");
      exit(1);
   }

   if (fout == NULL) {
      puts("can't open output");
      exit(1);
   }

   nocmt();

   fclose(fin);
   fclose(fout);

   exit(0);
}


