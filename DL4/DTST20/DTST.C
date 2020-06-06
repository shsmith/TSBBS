
/*
 * DTST - Special disk test - finds slow sectors
 *
 * Copyright 1988-1990 Samuel H. Smith; All rights reserved.
 *
 * Written 13-feb-88 (rev. 01-may-90)
 *
 */

#define VERSION  "DiskTest v2.0 (5-01-90)   Copyright 1988-1990 S.H.Smith"

#include <bios.h>
#include <ctype.h>
#include <dos.h>
#include <process.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "abs4read.h"

#define SECSIZ   512
#define NSECT    31
char *secbuf;
char *patbuf;

#define DIRPERSEC 16            /* directory entries per sector */


struct bootrec {		/* found at logical sector 0 (absolute read) */
	char jmp[3];
	char oem[8];
	int SectSiz;		/* bytes per sector */
	char ClustSiz;		/* sectors per cluster */
	int ResSecs;		/* reserved sectors before first FAT */
	char FatCnt;		/* number of FATs */
	int RootSiz;		/* max root directory entries (32 bytes each) */
        unsigned sTotSecs;      /* total number or sectors in small partition */
	char Media;		/* media descriptor */
	int FatSize;		/* sectors per fat */
	int TrkSecs;		/* sectors per track */
	int HeadCnt;		/* number of heads */
        long HidnSec;           /* hidden sectors */
        long TotSecs;           /* hidden sectors */

        char filler[0x200 - 0x24];
} bootrec;


#define MAXBAD 2000
unsigned badclusts[MAXBAD];
unsigned badcount = 0;

unsigned reserved_sec;
unsigned cyl_secs;

#define BADCLUST 0xFFF7
#define FATS_PER_FATSEC (SECSIZ / sizeof(unsigned))
unsigned fatbuf[FATS_PER_FATSEC];

int ptrack = -1;
int maxtime = 30;   /* maximum number of ticks for a good read */
unsigned cluster;
int track;

int slows = 0;
int new_bad = 0;
int write_check = 0;


/* --------------------------------------------------------------- */
char *report_error(char result)
{
        switch (result+0x13) {
                case 0x13:      return "Write protect";
                case 0x14:      return "Unknown unit";
                case 0x15:      return "Not ready";
                case 0x16:      return "Unknown command";
                case 0x17:      return "Data error";
                case 0x18:      return "Bad request";
                case 0x19:      return "Seek error";
                case 0x1a:      return "Unknown media";
                case 0x1b:      return "Sector not found";
                case 0x1d:      return "Write fault";
                case 0x1e:      return "Read fault";
                case 0x1f:      return "General failure";
                case 0x20:      return "Share violation";
                case 0x21:      return "Lock violation";
                case 0x22:      return "Bad disk change";

                default:
                        {
                                static char message[80];
                                sprintf(message,"Error %02x",result);
                                return message;
                        }
        }
}



/* --------------------------------------------------------------- */
unsigned sec2clust(long secnum)
{
        if (secnum < reserved_sec)
                return 0;
	else
                return 2 + (secnum - (long)reserved_sec) /
                                  (long)bootrec.ClustSiz;
}

/* --------------------------------------------------------------- */
long clust2sec(unsigned clust)
{
         return (long)(clust - 2) * (long)bootrec.ClustSiz + (long)reserved_sec;
}


/* --------------------------------------------------------------- */
void generate_pattern(void)
{
	int i;

	srand(biostime(0, 0L));

	for (i = 0; i < sizeof(patbuf); i++)
		patbuf[i] = rand();
}


/* --------------------------------------------------------------- */
int exclude_bad_blocks(unsigned cluster, int track)
{
	int i;

	for (i = 0; i < badcount; i++) {
		if (badclusts[i] == cluster) {
			printf("\r  Track %d, cluster %u - Already marked bad\n",
			       track, cluster);
			return 1;
		}
	}

	return 0;
}


/* --------------------------------------------------------------- */
void report_cluster_number(FILE *fd, long secnum, int seccnt, unsigned speed)
{
        if (secnum < reserved_sec)
                 fprintf(fd,"\r  Track %d, sector %u, speed %u mS ",
                         track, secnum, speed);

        else if (seccnt > bootrec.ClustSiz)
                fprintf(fd,"\r  Track %d, clusters %u-%u, speed %u mS ",
                       track,
                       (unsigned)cluster,
                       (unsigned)(cluster + (seccnt / bootrec.ClustSiz) - 1),
                       speed);
	else
                fprintf(fd,"\r  Track %d, cluster %u, speed %u mS ",
		       track, cluster, speed);
}


/* --------------------------------------------------------------- */
void rewrite_block(char disk, long secnum, int seccnt)
 /* perform a READ/WRITE/READ/ReWRITE test */
{
        char result;

        result = abs4write(disk - 'A', seccnt, secnum, patbuf);
	if (result)
                printf("- PATTERN WRITE FAILED! [%s]\n",report_error(result));

        result = abs4read(disk - 'A', seccnt, secnum, patbuf);
	if (result)
                printf("- PATTERN READ FAILED! [%s]\n",report_error(result));

	/* replace original data */
        result = abs4write(disk - 'A', seccnt, secnum, secbuf);
	if (result) {
                printf("- ORIGINAL RE-WRITE FAILED! [%s]\n\n",report_error(result));

                result = abs4write(disk - 'A', seccnt, secnum, secbuf);
		if (result) {
                        printf("- SECOND RE-WRITE FAILED! [%s]\n\n",report_error(result));
			printf("PROGRAM ABORTED - POSSIBLE DATA LOSS!\n");
			exit(1);
		}
	}
}


/* --------------------------------------------------------------- */
unsigned check_block(char disk, long secnum, int seccnt)
 /* test a sector/block, return elapsed time for read.  time < 0 on errors */
{
        char result;
	long start;
	int elapsed;
	unsigned speed;

        cluster = sec2clust(secnum);
        track = secnum / cyl_secs;

/*
printf("\rcheckblock:\tseccnt=%d(@%04x:%04x) secnum=%ld buf=%04x:%04x\n ",
                seccnt,FP_SEG(&seccnt),FP_OFF(&seccnt),
                secnum,
                FP_SEG(secbuf),FP_OFF(secbuf));
*/
        if (seccnt > bootrec.ClustSiz)
                if (exclude_bad_blocks(cluster, track))
                        return 0;

	start = biostime(0, 0L);
        result = abs4read(disk - 'A', seccnt, secnum, secbuf);
	elapsed = biostime(0, start) - start;
	speed = elapsed * 18;

        if ((elapsed > maxtime) || (result)) {
		ptrack = track;
                report_cluster_number(stdout, secnum, seccnt, speed);
        } else

        /* send non-error status to stderr so it won't clutter logfiles */
        if (track != ptrack) {
		ptrack = track;
                report_cluster_number(stderr, secnum, seccnt, speed);
	}


	/* extablish max time for read based on SECOND read request */
/********
        if (maxtime == 999)
		maxtime = 888;
	else if (maxtime == 888)
		maxtime = (elapsed + 1) * 3;
*******/

	/* report errors or slow reads */
	if (result) {
                printf("- HARD ERROR! [%s]\n",report_error(result));
                if (seccnt <= bootrec.ClustSiz)
			new_bad++;
	}
	else if (elapsed > maxtime) {
		printf("- SLOW! (soft errors)\n");
		slows++;
		result = 999;
	}

	if ((result == 0) && write_check)
                rewrite_block(disk, secnum, seccnt);

	if (result)
		return -elapsed;
	else
		return elapsed;
}


/* --------------------------------------------------------------- */
void test_range(char disk, long low, long last)
{
        long current;
        long single;
	int elapsed;
	int nsect;

	if (write_check)
		printf("\nPerforming READ/WRITE test:\n");
	else
		printf("\nPerforming READ test:\n");

	nsect = bootrec.TrkSecs;
	if (nsect > NSECT)
		nsect = NSECT;	/* special case for large-track disks
				 * (bernouli) */

	for (current = low; current <= last - nsect + 1; current += nsect) {

/*
printf("\rrange(1):\t nsect=%d(@%04x:%04x) current=%ld \n",
        nsect,FP_SEG(&nsect),FP_OFF(&nsect),current);
*/
                elapsed = check_block(disk, current, nsect);
/*
printf("\rrange(2):\t nsect=%d(@%04x:%04x) current=%ld elapsed=%u\n",
        nsect,FP_SEG(&nsect),FP_OFF(&nsect),current,elapsed);
*/
                /*
		 * if there was an error then switch to single sectors and
		 * rescan the sectors in question 
		 */
		if ((elapsed < 0) && (nsect > 1)) {


                        for (single = current;
			     single < (current + nsect);
			     single += bootrec.ClustSiz) {
/*
printf("\rrange(3):\t nsect=%d(@%04x:%04x) current=%ld \n",
        nsect,FP_SEG(&nsect),FP_OFF(&nsect),current);
*/
                                elapsed = check_block(disk, single, 1);
/*
printf("\rrange(4):\t nsect=%d(@%04x:%04x) current=%ld elapsed=%u\n",
        nsect,FP_SEG(&nsect),FP_OFF(&nsect),current,elapsed);
*/
                        }
			printf("\r%78s\r", " ");
		}
	}

	printf("\n\nTest completed:\n  %d slow clusters\n  %d new bad clusters\n",
	       slows, new_bad);
}


/* --------------------------------------------------------------- */
void get_disk_information(char disk)
{
	unsigned fatsec;
	unsigned bufpos;
	unsigned cluster;
        char result;
        FILE *fd;
        char name[] = "x:\\$$$$$$$$.$$$";

        printf("\nDisk %c:\n", disk);


        /* force dos to access this drive -- otherwise int 0x25 won't work */
        name[0] = disk;
        fd = fopen(name,"r");
        if (fd != NULL)
                fclose(fd);


        /* read boot record */
        result = abs4read(disk - 'A', 1, 0, (char *)&bootrec);
	if (result) {
                printf("CANNOT READ BOOT RECORD! [%s]\n",report_error(result));
		exit(1);
	}


        /* for dos 3.3 or 4.0 small partitions, discard high word of hidden
           sector count and convert 16 bit sector count to 32 bits.
           otherwise we are under dos 4.0 and have a large partition */

        if (bootrec.sTotSecs != 0) {
            bootrec.HidnSec &= 0x0000ffff;
            bootrec.TotSecs = bootrec.sTotSecs;
        }

        reserved_sec = bootrec.ResSecs +
		(bootrec.FatCnt * bootrec.FatSize) +
		(bootrec.RootSiz / DIRPERSEC);

	cyl_secs = bootrec.TrkSecs * bootrec.HeadCnt;

	printf("  Number of heads. . . . %d\n", bootrec.HeadCnt);
	printf("  Number of tracks . . . %d\n", bootrec.TotSecs / cyl_secs);
	printf("  Sectors per track. . . %d\n", bootrec.TrkSecs);
	printf("  Sectors per cluster. . %d\n", bootrec.ClustSiz);
	printf("  Total clusters . . . . %u\n", sec2clust(bootrec.TotSecs));

        printf("  Bad cluster numbers. . ");

        cluster = 0;
        for (fatsec = 1; fatsec <= bootrec.FatSize; fatsec++) {
                result = abs4read(disk - 'A', 1, fatsec, (char *)fatbuf);
		if (result) {
                        printf("\n\nERROR READING FAT SECTOR %u! [%s]\n",
                                fatsec,report_error(result));
			exit(1);
		}

                for (bufpos = 0; bufpos < FATS_PER_FATSEC; bufpos++) {
			if (fatbuf[bufpos] == BADCLUST) {
				badclusts[badcount] = cluster;
				badcount++;

				printf("%-5u ", cluster);
				if ((badcount % 9) == 0)
					printf("\n                         ");
			}
                        cluster++;
                }
	}

	if (badcount == 0)
		printf("None");
	printf("\n");
}


/* --------------------------------------------------------------- */
void usage(void)
{
        printf("\n%s\n\n", VERSION);
        printf("Usage:\tdisktest D: [<lowclust> <hiclust>] [-W]\n");
        printf("\t-W\tenables the nondestructive READ/WRITE test.\n\n");
	printf("DTST is a small utility that is used to check out your hard disks.  It\n");
        printf("has the special ability to report 'slow' sectors.  These are sectors\n");
	printf("that read properly, but often require retries.  I feel that such sectors\n");
	printf("are on the verge of failure and should quickly be locked out before they\n");
	printf("cause any harm.  USE AT YOUR OWN RISK.\n");
	exit(1);
}


/* --------------------------------------------------------------- */
void decode_option(char *option)
{
        if (strcmp(option, "-W") == 0)
                write_check = 1;
	else
		usage();
}


/* --------------------------------------------------------------- */
main(int argc, char **argv)
{
	char disk;
        long lowsec, hisec;

	if (argc == 1)
		usage();

        secbuf = (char *) malloc(NSECT * SECSIZ);
        patbuf = (char *) malloc(NSECT * SECSIZ);
        if ((secbuf == NULL) || (patbuf == NULL)) {
                printf("Can't allocate buffers\n");
                exit(1);
        }

        disk = argv[1][0];
	if (islower(disk))
		disk = toupper(disk);

	get_disk_information(disk);
	lowsec = 0;
	hisec = bootrec.TotSecs;

	switch (argc) {
	case 2:
		break;		/* default to whole disk */

	case 3:
		decode_option(argv[2]);
		break;

	case 5:
		decode_option(argv[4]);

	case 4:
                lowsec = clust2sec(atoi(argv[2]));
                hisec = clust2sec(atoi(argv[3]));
		break;

	default:
		usage();
	}

	generate_pattern();
	test_range(disk, lowsec, hisec);

        return new_bad;
}

