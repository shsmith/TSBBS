
/*
 * ARC - Shell program for PKARC and PKXARC to emulate operation
 * of ARC.  This is needed for utilities like DELTA that
 * call ARC directly.
 *
 * S.H.Smith, 17-feb-87
 *
 */

#include <stdio.h>
#include <process.h>

main(argc,argv)
int argc;
char *argv[];
{
   int i;

   if (argc < 3) {
      puts("");
      puts("ARC Shell v1.0 (2/17/87 S.H.Smith)  Public Domain Material");
      puts("");
      puts("This is a shell program for PKARC and PKXARC that");
      puts("emulates the operation of ARC51 by reformatting command line");
      puts("arguments and calling PKARC or PKXARC to do the work.");
      puts("");
      puts("Usage:  arc FUNCTION ARCHIVE FILE ... FILEn");
      puts("");
      puts("FUNCTION is one of:");
      puts("     A     Add or update entry");
      puts("     U     Update entry if changed");
      puts("     F     Freshen only entries already in archive");
      puts("     M     Move file into archive and delete original");
      puts("     D     Delete an entry");
      puts("     E     Extract an entry");
      puts("     X     Extract an entry");
      puts("     L     List table of contents");
      puts("     V     Verbose contents listing");
      puts("");
      puts("ARCHIVE is the pathname of the archive to act on.");
      puts("");
      puts("FILE... is an optional list of files.");
      exit(1);
   }

   switch (toupper(argv[1][0])) {
      case 'A':
      case 'U':
      case 'F':
      case 'M':
      case 'D':
      case 'T':
         argv[0] = "pkarc";
         do_spawn(argv);
         break;

      case 'L':
      case 'V':
         argv[0] = "pkxarc";
         argv[1] = "/v";
         do_spawn(argv);
         break;

      case 'E':
      case 'X':
         spawn_pkxarc(argv);
         break;

      default:
         puts("arc: invalid FUNCTION specified");
         exit(1);
   }

}


spawn_pkxarc(argv)
char *argv[];
{
   char dest[80];
   char source[80];
   char *s,*t;

/* copy the extract basename to source */
   s = argv[3];
   t = source;

   while (*s) {
      switch (*s) {
         case ':':
         case '/':
         case '\\':
            t = source;
            s++;
            break;

         default:
            *t++ = *s++;
      }
   }
   *t = 0;

/* format the destination directory into dest */
   strcpy(dest,argv[3]);
   dest[strlen(source)+1] = 0;

/* spawn pkxarc with the formatted args */
   argv[0] = "pkxarc";
   argv[1] = argv[2];
   argv[2] = dest;
   argv[3] = source;

   do_spawn(argv);
}

do_spawn(argv)
char *argv[];
{
/* char **a = argv;
   while (*a)
      puts(*a++); */

   if (spawnvp(0,argv[0],argv))
      puts(" arc: spawn failed");
}

