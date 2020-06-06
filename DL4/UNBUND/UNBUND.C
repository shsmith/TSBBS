
/*
 * unbund - unbundle files combined into unix shell-scripts
 *          using the cat <<key command.
 *
 * Samuel H. Smith, 13-jun-87 (rev. 16-Oct-87)
 *
 * From the Tool Shop,
 *  (602) 279-2673
 *
 * Compile with Turbo-C 1.0
 *
 */

#define VERSION "\nUnbundle 1.3, 16-Oct-87.   Courtesy of The Tool Shop, (602) 279 2673.\n\n"

#include <stdio.h>
#include <stdlib.h>
#include <dir.h>
#include <string.h>


#define MAXLINE 255

typedef char anystring[MAXLINE];

anystring line;
FILE *infd;

/* macro to scan for a character in a string; sets result pointer */
#define SCANCHR(ch,var,res)              \
{  res = var;                            \
   while (( *res ) && ( *res != ch ))    \
      res++;                             \
}


do_cat(void)
        /* process the 'cat' command */
{
        anystring key;
        anystring name;
        FILE *fd;
        char *p;
        char buf[BUFSIZ];

        /* locate the end-stream keyword */
                                /* cat << \SHAR_EOF > 'ispell.man' */
        SCANCHR('<', line, p);

        if ((*p != '<') || (*(p + 1) != '<')) {
                printf("Missing end-stream keyword: %s\n", line);
                return;
        }

        /* extract the keyword from the line */
        strcpy(key, p + 3);
        if (*key == '\'') {
                SCANCHR('\'', key, p);
                *p = 0;
        }
        else {
                SCANCHR(' ', key, p);
                *p = 0;
        }

        if (*key == '\\')
           strcpy(key,key+1);


        /* find the output file redirection */
        SCANCHR('>', line, p);
        if (*p != '>') {
                printf("Missing output redirection: [%s]\n", line);
                return;
        }

        /* extract the name and open the output file */
        SCANCHR('>', line, p);
        strcpy(name, p+2);

        if (*name == '\'') {
                strcpy(name,name+1);
                SCANCHR('\'', name, p);
        }
        else
                SCANCHR(' ', name, p);
        if (*p) *p = 0;

        printf("\nExtract: %s    (%s)", name, key);

        fd = fopen(name, "w");
        if (infd == NULL) {
                printf("unbund(cat):  can't create %s\n",name);
                exit(1);
        }

        setbuf(fd, buf);
        strcat(key, "\n");

        /* copy lines from input to the file until the keyword
           line is seen */

        fgets(line, MAXLINE, infd);
        while (strcmp(line, key) != 0) {
                fputs(line, fd);
                if (fgets(line, MAXLINE, infd) == NULL) {
                        printf("\nUnexpected EOF looking for: %s", key);
                        break;
                }
        }

        fclose(fd);
        printf("\n");
}


do_sed(void)
        /* process the 'sed' command */
{
        anystring key;
        anystring name;
        FILE *fd;
        char *p;
        char buf[BUFSIZ];

        /* locate the end-stream keyword */
        /* sed "s/^X//" >README <<'END_OF_README' */
        SCANCHR('<', line, p);
        if ((*p != '<') || (*(p + 1) != '<')) {
                printf("Missing end-stream keyword: %s\n", line);
                return;
        }

        /* extract the keyword from the line */
        strcpy(key, p + 2);
        if (*key == '\'') {
                strcpy(key,key+1);
                SCANCHR('\'', key, p);
                *p = 0;
        }
        else {
                SCANCHR(' ', key, p);
                *p = 0;
        }


        /* find the output file redirection */
        SCANCHR('>', line, p);
        if (*p != '>') {
                printf("Missing output redirection: [%s]\n", line);
                return;
        }

        /* extract the name and open the output file */
        SCANCHR('>', line, p);
        strcpy(name, p+1);
        SCANCHR(' ', name, p);
        if (*p) *p = 0;

        printf("\nExtract: %s    (%s)", name, key);

        fd = fopen(name, "w");
        if (infd == NULL) {
                printf("unbund(sed):  can't create %s\n",name);
                exit(1);
        }

        setbuf(fd, buf);
        strcat(key, "\n");

        /* copy lines from input to the file until the keyword
           line is seen */

        fgets(line, MAXLINE, infd);
        while (strcmp(line, key) != 0) {
                fputs(line+1, fd);      /* skip leading X on each line */
                if (fgets(line, MAXLINE, infd) == NULL) {
                        printf("\nUnexpected EOF looking for: %s", key);
                        break;
                }
        }

        fclose(fd);
        printf("\n");
}


do_echo(void)
        /* process the shell 'echo' command */
{
        printf("   %s", line);
}


do_mkdir(void)
        /* make a directory */
{
        printf("   %s", line);
        mkdir(line + 7);
}


do_cd(void)
        /* change directories */
{
        printf("   %s", line);
        chdir(line + 4);
}



main(argc, argv)
        int argc;
        char *argv[];

{
        char buf[BUFSIZ];

        printf(VERSION);

        if ((argc - 1) != 1) {
                printf("Usage:  unbundle BUNDLE_FILE\n");
                exit(1);
        }

        printf("Unbundle: %s\n", argv[1]);
        infd = fopen(argv[1], "r");
        if (infd == NULL) {
                printf("  can't open %s\n",argv[1]);
                exit(1);
        }

        setbuf(infd, buf);

        while (fgets(line, MAXLINE, infd) != NULL) {
                if ((strncmp(line, "cat ", 4) == 0))
                        do_cat();
                else if ((strncmp(line, "sed ", 4) == 0))
                        do_sed();
                else if ((strncmp(line, "echo ", 5) == 0))
                        do_echo();
                else if (line[0] == ':')
                        do_echo();
                else if ((strncmp(line, "mkdir ", 6) == 0))
                        do_mkdir();
                else if ((strncmp(line, "cd ", 3) == 0))
                        do_cd();
                else
                        printf("%s", line);
        }

        fclose(infd);
        return 0;
}


