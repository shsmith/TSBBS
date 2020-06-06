
/*
 * rm - remove 1 or more files
 *
 * s.h.smith, 9-jan-87
 *
 */

#include <stdio.h>

main(argc,argv)
int argc;
char **argv;
{
/* if (argc == 1)
      printf("usage: rm file ... filen\n");
*/

   while (argc > 1) {
      argc--;
      argv++;
      printf("%s",*argv);
      if (unlink(*argv))
         printf(" - can't remove\n");
      else
         printf(" removed\n");
   }
}

