
/*
 * trim - trim PCBoard caller log files 
 *        Removes all entries before a specified date
 *
 * S.H.Smith, 16-Jun-87
 *
 * Revision history:
 *   28-Jul-87 1.1  Added support for PCBoard 12.0 format caller log entries.
 *                  Still support 11.8 and(probably) earlier versions.
 *                  (THIS VERSION DOES *NOT* WORK ON PCB 12.0!)
 *
 *   03-Oct-87 1.2  Corrected for proper operation on PCB 12.0
 *
 */

#define VERSION "\nPCBoard Caller Log 'Trimmer' 1.2, 03-Oct-87 S.H.Smith\n"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <dos.h>
#include <io.h>
#include <string.h>


/* an entry in the caller log file */
struct entry_rec {
        char            text[62];
        char            cr;
        char            lf;
};


#define MAX_ENTRY 750

struct entry_rec entry[MAX_ENTRY];
int   entries;


int   infd, outfd;
char  first_date[7];
int   first = 1;
int   skipped = 0;
int   copied = 0;



#define format_date(from, to)                   \
        /* from = mm-dd-yy,  to = yymmdd */     \
{                                               \
        to[0] = from[6];                        \
        to[1] = from[7];                        \
        to[2] = from[0];                        \
        to[3] = from[1];                        \
        to[4] = from[3];                        \
        to[5] = from[4];                        \
        to[6] = 0;                              \
}                                               \


#define valid_date(date)                        \
        /* verify MM-DD-YY format date */       \
        ((date[2] == '-') && (date[5] == '-'))



read_entries(void)
/* read a block of records from the log file */
{
        unsigned        size;
        size = read(infd, (char *)entry, sizeof(entry));
        entries = size / sizeof(struct entry_rec);
}


write_entries(void)
/* determine if any entries are to be skipped, write the rest */
{
        unsigned        i;
        char           *date;
        char            cdate[7];
        unsigned        size;
        unsigned        written;
        unsigned        keep;

        /* skip records if first one has not yet been found */
        if (first) {
                for (i = 0; i < entries; i++) {

                        if ((i < entries-1) && (entry[i].text[0] == '*')) {

                                date = entry[i+1].text;
                                if (date[2] == ':')
                                   date += 7;   /* pcboard 11.8 format */
                                else
                                   date += 0;   /* pcboard 12.0 format */

                                if (valid_date(date)) {

                                        format_date(date, cdate);
                                        if (strcmp(cdate, first_date) >= 0) {
                                                first = 0;
                                                break;
                                        }
                                }
                        }
                }

        } else
                i = 0;

        /* copy remaining records */
        keep = entries - i;
        copied += keep;
        skipped += (entries-keep);

        size = keep * sizeof(struct entry_rec);
        written = write(outfd, (char *)(entry + i), size);

        if (written != size) {
                printf("Write failure on output file (disk full?)\n");
                close(outfd);
                close(infd);
                exit(1);
        }
}



determine_first_date(int n)
/* determine first_date as n days before today */
{
        int m,d,y;
        int monthdays[] = { 0, 31, 28, 31, 30, 31, 30, 
                               31, 31, 30, 31, 30, 31 };
        struct date today;


        /* get today's date from DOS */
        getdate(&today);
        y = today.da_year - 1900;
        m = today.da_mon;
        d = today.da_day;


        /* backup N days */
        while (n--) {
                if (d > 1)
                        d--;
                else 
                if (m > 1) {
                        m--;
                        d = monthdays[m];
                }
                else {
                        y--;
                        m = 12;
                        d = monthdays[m];
                }
        }

        /* format the date for comparison */
        sprintf(first_date,"%02d%02d%02d",y,m,d);
        printf("Skipping all records before %02d-%02d-%02d\n",m,d,y);
}



main(int argc, char *argv[])
{
        if (argc != 4) {
                printf(VERSION);
                printf("\nUsage:\ttrimlog DAYS INFILE OUTFILE\n\n");
                printf("DAYS\tis the number of days of log data to retain\n");
                printf("INFILE\tis the input file, usually /pcb/main/caller\n");
                printf("OUTFILE\tis the new file to write, cannot be the same as INFILE\n");
                return 1;
        }

        determine_first_date( atoi(argv[1]) );

        infd = open(argv[2], O_RDONLY + O_BINARY);
        if (infd < 1) {
                printf("Can't open input file, %s\n", argv[2]);
                exit(1);
        }

        if (!strcmp(argv[2], argv[3])) {
                printf("Input and output files must be different!\n");
                exit(1);
        }

        outfd = open(argv[3], O_WRONLY + O_BINARY + O_CREAT);
        if (outfd < 1) {
                printf("Can't create output file, %s\n", argv[3]);
                exit(1);
        }

        do {
                read_entries();
                write_entries();
                putchar('.');
        } while (entries == MAX_ENTRY);

        close(infd);
        close(outfd);

        printf("\n%u records skipped\n", skipped);
        printf("%u records copied\n", copied);
        return 0;
}

