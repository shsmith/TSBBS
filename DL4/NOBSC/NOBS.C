
/* Filter to remove <CHAR><BACKSPACE> sequences from a file */

#include <stdio.h>

FILE *fin,*fout;
int  c;
char line[132];
char *p;
int  i;

nobs()
{ 
   p=line;
   *p = 0;

   while ((c=fgetc(fin)) >= 0) 
   {
      switch(c) 
      {
         case '\b':
               if ((long)p > (long)line) 
                  p--;
               break;

         case '\n':
               fputs(line,fout);
	       fputc('\n',fout);
               p=line;
               *p=0;
               break;

         case '_':
               if (*p == ' ')
                  *p++ = c;
               else
                  p++;
               break;

         default:
               *p++ = c;
               *p = 0;
               break;
      }
   }

   fputs(line,fout);
   fputc('\n',fout);
}
 

main(argc,argv)
int argc;
char **argv;
{
   fin = stdin;
   fout = stdout;

   switch (argc) {
      case 1:   break;

      case 2:   fin = fopen(argv[1],"r");
		break;

      case 3:   if (argv[1][0] != '-')
		   fin = fopen(argv[1],"r");
      		fout = fopen(argv[2],"w");
		break;

      default:  puts("usage:\tnobs <in >out");
      		puts("\tnobs INFILE >out");
		puts("\tnobs - <in OUTFILE");
		puts("\tnobs INFILE OUTFILE");
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

   nobs();

   fclose(fin);
   fclose(fout);

   exit(0);
}


