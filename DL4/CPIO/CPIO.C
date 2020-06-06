
/*
 * cpio - a unix-like copy utility for DOS
 *
 * 16-feb-87 s.h.smith - initial coding
 * 22-nov-87 s.h.smith - updated for turbo-c 1.0)
 *
 */

#include <alloc.h>
#include <ctype.h>
#include <dos.h>
#include <fcntl.h>
#include <io.h>
#include <process.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BufferSize 0xD000

int query = 0;
FILE *con;
FILE *kbd;
char *fbuf;


copyfile(char *source, char *destdir)
{
   char *s,*d;
   char dest[80];
   int ifd,ofd;
   unsigned n,w;
   char ans[80];
   struct ftime timestamp;


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

   ifd = open(source, O_RDONLY+O_BINARY);
   if (ifd <= 0)
      return;



/* format destination filename */

   strcpy(dest,destdir);

   if ( (dest[strlen(dest)-1] != '\\') &&
        (dest[strlen(dest)-1] != '/'))
      strcat(dest,"/");

   strcat(dest,source);


/* query user if -q option was specified */

   fprintf(con,"Copy %12s to %s ",source,dest);
   fflush(con);

   if (query) 
   {
      fprintf(con,"(y/n)? ");
      fflush(con);

      fgets(ans,sizeof(ans),kbd);
      if (toupper(ans[0]) != 'Y')
      {
         close(ifd);
         return;
      }
   }


/* copy the file */

   ofd = 0;

   do 
   {
   /* read a source block */

      n = read(ifd,fbuf,BufferSize);
      fprintf(con,".");
      fflush(con);


   /* create output file on first block */

      if (ofd == 0)
      {
         ofd = open(dest, O_WRONLY + O_BINARY + O_CREAT);
         if (ofd <= 0) 
         {
            fprintf(con," can't create: %s\n",dest);
            close(ifd);
            fflush(con);
            exit(1);
         }
      }

   /* write out the block */

      w = write(ofd,fbuf,n);
      if (w != n) 
      {
         fprintf(con," write error\n");
         close(ofd);
         close(ifd);
         unlink(dest);
         fflush(con);
         return;
      }

   }  while (n == BufferSize);


/* clean up and return */

   getftime(ifd,&timestamp);
   setftime(ofd,&timestamp);
   close(ifd);
   close(ofd);
   fprintf(con,"\n");
   fflush(con);
}


usage(void)
{
   fprintf(con,"Usage:    cpio [-q] DESTINATION_DIRECTORY <FILELIST\n");
   fprintf(con,"Example:  dir *.x | cpio /libdir/\n");
   fflush(con);
   exit(1);
}


main(argc,argv)
int argc;
char **argv;
{
   char name[80];
   char dest[80];
   int i;


/* initialize */

   kbd = fopen("con","r");
   con = fopen("con","w");
   strcpy(dest,"");


/* process arguments */

   for (i=1; i<argc; i++) 
   {
      if (argv[i][0] == '-')    /* args starting with - are options */
      {
         switch(argv[i][1]) 
         {
            case 'q':
            case 'Q':
               query = 1;
               break;

            default:
               fprintf(con,"Invalid option: %s\n",argv[1]);
               usage();
         }
      }

      else if (dest[0] == 0)     /* otherwise args are destination dir */
         strcpy(dest,argv[i]);

      else 
      {
         fprintf(con,"Too many destination directories: %s\n",argv[i]);
         usage();
      }
   }


/* make sure the required args are present */

   if (dest[0] == 0)
   {
      fprintf(con,"You must specify a destination directory.\n");
      usage();
   }


/* allocate copy buffer */

   fbuf = (char *)malloc(BufferSize);
   if (fbuf == NULL) 
   {
      fprintf(con,"Not enough memory to allocate %u byte buffer.\n",BufferSize);
      fflush(con);
      exit(1);
   }

/* process all standard input lines */

   while (gets(name) != NULL) 
   {
      copyfile(name,dest);
   }

}



