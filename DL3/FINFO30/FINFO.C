
/*
 * finfo - dos filter update file size/date info in a file
 *         directory listing.
 *
 * 26-feb-87 s.h.smith
 *
 */

#define VERSION "Finfo v1.6 01-03-89 S.H.Smith"

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <string.h>

#define ft_day    (finfo->date & 31)
#define ft_month  ((finfo->date >> 5) & 15)
#define ft_year   ((finfo->date >> 9) & 127)
struct FIND *finfo;

void clean(char *dir, 
           char *source, 
           char *dest)
        /* clean up a text line that might contain a filename.
           if there is a legal filename, copy it to dest.  otherwise
           dest will contain an empty string */
{
   char *s,*d;
   int ifd;
   char temp[255];

/* make sure source name is legal; this makes pipes from 'dir' and other
   similar utilities work better */

   strcpy(temp,source);
   strcat(temp,"               ");
   temp[12] = 0;

   for (s=temp; (*s) && (*s != '.'); s++)
      ;

   if ((temp[8] == ' ') && (*s != '.'))
      temp[8] = '.';

   s = temp;
   d = dest;
   while (*s) 
   {                   /* copy everything but spaces */
      if (*s != ' ')
         *d++ = *s;
      s++;
   }

   *d = 0;
   strcpy(temp,dir);
   strcat(temp,dest);

/* check the source file; if it is not valid then skip over it */

   finfo = findfirst(temp,0x21);
   if (finfo == NULL) {
      dest[0] = 0;
      return;
   }
}


char *getline(char *buf)
{
   char *bufstart = buf;
   int i;
   int c;
   i = 0;

   for (;;) {
      c = getchar();
      if ((c == EOF) || (c == 26))
         return NULL;
      if ((c == '\n') || (i >= 255)) {
         *buf = 0;
         return bufstart;
      }
      if ((c != 0) && (c != '\r') && (c != 0xFF)) {
         *buf++ = c;
         i++;
      }
   }
}

putln(char *s)
{
      while (*s)
         putchar(*s++);
      putchar('\n');
}

main(int argc, char *argv[])
{
   char line[255];
   char name[255];
   char *rest;
   char buf[BUFSIZ];
   char dir[255];

   setbuf(stdout,buf);

   if (argc == 2) {
      strcpy(dir,argv[1]);
      if (dir[strlen(dir)-1] != '\\')
         strcat(dir,"\\");
   }
   else {
      printf("%s\n",VERSION);
      printf("Usage:   finfo DIRECTORY <filelist >newlist\n");
      printf("Example: finfo C:\\DL1 <C:\\PCB\\GEN\\DIR3 >DIR3.NEW\n");
      exit(1);
   }


/* process all standard input lines */

   while (getline(line) != NULL) {
      clean(dir,line,name);

      if (finfo == NULL)
         putln(line);
      else

      if ((finfo->size <= 0) ||
          (ft_month < 1) || (ft_month > 12) ||
          (ft_day   < 1) || (ft_day   > 31) ||
          (ft_year  < 1) || (ft_year  > 30))
      {
         putln(line);
      }
      else
      {
         if (strlen(line) > 33)
            rest = line+33;
         else
            rest = "";

         printf("%-12s%9ld  %02d-%02d-%02d  ",
                name,
                finfo->size,
                ft_month,
                ft_day,
                ft_year+80);
         putln(rest);
      }
   }

   fflush(stdout);
}


