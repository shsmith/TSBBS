
/* askyn - ask yes/no question, set errorlevel=1 if yes, 0 if no */ 

/* initial coding, s.h.smith, 1-feb-87 */
/* added -R option to reverse meaning of yes/no */
/* translated to c (with tpc10) 8-feb-87 */

#include <stdio.h>
#include <ctype.h>

int   i;
char  ans;
int   rev;
int   yes,no;

main(argc,argv)
int argc;
char *argv[];
{ 
   if ((argc-1) == 0) 
   { 
      printf("usage:  askyn [-R] prompt\n"); 
      printf("where prompt is the user prompt\n"); 
      printf("returns ERRORLEVEL=1 if user answers Yes\n"); 
      printf("-R option reverses yes/no (i.e. No gives ERRORLEVEL=1)\n"); 
      exit(1);
   } 

   if ((strcmp(argv[1], "-R") == 0)) 
   { 
      yes = 0;
      i = 2; 
   } 
   else 
   { 
      yes = !0;
      i = 1; 
   } 
   no = !yes;

   printf("%s",argv[i]);
   for (i = i + 1; i <= (argc-1); i++) 
      printf(" %s",argv[i]);

   printf("? (Y/N) "); 

   do { 
      ans = toupper(getch());
   }  while ((ans != 'Y') && (ans != 'N'));

   printf("%c\n",ans); 

   if (ans == 'Y')     /* return 1 on yes without -R */
                       /* return 0 on yes with -R */
      exit(yes);
   else
      exit(no);
} 
