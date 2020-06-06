
/*
 * fname - dos filter to clean up a filename list
 * such as that produced by DIR or 'whatsnew'
 *
 * 26-feb-87 s.h.smith
 *
 */

#include <stdio.h>

char name[80];
int count = 0;
int reject = 0;
char *s,*d;
char dest[80];
int ifd;


clean(source)
char *source;
{
/* make sure source name is legal; this makes pipes from 'dir' and other
   similar utilities work better */

   s = source;
   d = dest;
   if (s[8] == ' ')    /* change space into dot for dos DIR-like commands */
      s[8] = '.';
   s[12] = 0;          /* truncate if too long */

   while (*s) 
   {                   /* copy everything but spaces */
      if (*s != ' ')
         *d++ = *s;
      s++;
   }

   *d = 0;
   strcpy(source,dest);


/* check the source file; if it is not valid then skip over it */

   ifd = open(source,0);
   if (ifd <= 0) {
      ++reject;
      return;
   }

   close(ifd);
   printf("%s\n",source);

   ++count;
}


main(argc,argv)
int argc;
char **argv;
{
   fprintf(stderr,"Filename filter 1.0 (shs 26-feb-87)\n");

/* process all standard input lines */

   while (gets(name) != NULL) 
      clean(name);

   fprintf(stderr,"%d file names found  (%d lines rejected)\n",count,reject);
}



