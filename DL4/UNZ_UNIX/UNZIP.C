
/*
 * Copyright 1989 Samuel H. Smith;  All rights reserved
 *
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 */

/*
 * UnZip - A simple zipfile extract utility
 *
 * To compile:
 *      tcc -B -O -Z -G -mc unzip.c	;turbo C 2.0, compact model
 *	cl /O /AC /G0 /W3 -c unzip.	;msc 5.1, compact model
 *	cc -O -DOLDC -Dunix {-DHIGH_LOW} {-DSHORTC} -c unzip.c	;unix pcc
 *
 * Port to MSC and Unix by George M. Sipe
 *
 */

#define VERSION  \
	"UnZip:  Zipfile Extract v2.0.1 of 09-16-89;  (C) 1989 Samuel H. Smith"

#ifdef	SHORTC
#define	compressed_size		cmpr_sz
#define	extract_zipfile		ext_zip
#define	filename		fn
#define	follower		flwr
#define	hsize_array_byte	hsz_a_byte
#define	last_mod_file_date	mod_fdate
#define	lit_tree_present	lt_present
#define	maxcodemax		mx_cd_mx
#define	number_disk_with_start_central_directory ndwsc
#define	process_central_file_header pcfhdr
#define	process_end_central_dir	pecdir
#define	process_headers		proc_hdrs
#define	total_entries_central_dir tecdir
#define	version_made_by		v_made_by
#define	LoadTrees		LdTrees
#endif	/* SHORTC */

typedef unsigned char byte;	/* code assumes UNSIGNED bytes */
typedef long longint;		/* sizeof must be 4 bytes */
typedef unsigned short word;	/* sizeof must be 2 bytes */
typedef char boolean;

#define STRSIZ 256

#include <stdio.h>
 /* this is your standard header for all C compiles */

#ifndef	OLDC
#include <stdlib.h>
 /* this include defines various standard library prototypes */
#define	VOIDARG	void		/* function definitions support (void) */
#else
#include <ctype.h>
#define	VOIDARG			/* function definitions support () only */
#endif	/* OLDC */


/*
 * SEE HOST OPERATING SYSTEM SPECIFICS SECTION STARTING NEAR LINE 180
 *
 */


/* ----------------------------------------------------------- */
/*
 * Zipfile layout declarations
 *
 */

typedef longint signature_type;


#define LOCAL_FILE_HEADER_SIGNATURE  0x04034b50L


typedef struct local_file_header {
	word version_needed_to_extract;
        word general_purpose_bit_flag;
	word compression_method;
	word last_mod_file_time;
	word last_mod_file_date;
	longint crc32;
	longint compressed_size;
        longint uncompressed_size;
	word filename_length;
	word extra_field_length;
} local_file_header;


#define CENTRAL_FILE_HEADER_SIGNATURE  0x02014b50L


typedef struct central_directory_file_header {
	word version_made_by;
	word version_needed_to_extract;
	word general_purpose_bit_flag;
	word compression_method;
	word last_mod_file_time;
	word last_mod_file_date;
	longint crc32;
	longint compressed_size;
	longint uncompressed_size;
	word filename_length;
	word extra_field_length;
	word file_comment_length;
	word disk_number_start;
	word internal_file_attributes;
	longint external_file_attributes;
	longint relative_offset_local_header;
} central_directory_file_header;


#define END_CENTRAL_DIR_SIGNATURE  0x06054b50L


typedef struct end_central_dir_record {
	word number_this_disk;
#ifndef	TURBOC
	word num_disk_with_start_cent_dir;
	word tot_ents_cent_dir_on_this_disk;
#else
	word number_disk_with_start_central_directory;
	word total_entries_central_dir_on_this_disk;
#endif	/* TURBOC */
	word total_entries_central_dir;
	longint size_central_directory;
	longint offset_start_central_directory;
	word zipfile_comment_length;
} end_central_dir_record;



/* ----------------------------------------------------------- */
/*
 * input file variables
 *
 */

#define INBUFSIZ 0x2000
byte *inbuf;			/* input file buffer - any size is legal */
byte *inptr;

int incnt;
unsigned bitbuf;
int bits_left;
boolean zipeof;

int zipfd;
char zipfn[STRSIZ];
local_file_header lrec;

#ifdef	HIGH_LOW
int w0, w1;			/* word translation indices */
int li0, li1, li2, li3;		/* long int translation indices */
#endif	/* HIGH_LOW */


/* ----------------------------------------------------------- */
/*
 * output stream variables
 *
 */

#define OUTBUFSIZ 0x2000        /* must be 0x2000 or larger for unImplode */
byte *outbuf;                   /* buffer for rle look-back */
byte *outptr;

longint outpos;			/* absolute position in outfile */
int outcnt;			/* current position in outbuf */

int outfd;
char filename[STRSIZ];
char extra[STRSIZ];

#define DLE 144


/* ----------------------------------------------------------- */
/*
 * shrink/reduce working storage
 *
 */

int factor;
byte followers[256][64];
byte Slen[256];

#define max_bits 13
#define init_bits 9
#define hsize 8192
#define first_ent 257
#define clear 256

typedef int hsize_array_integer[hsize+1];
typedef byte hsize_array_byte[hsize+1];

hsize_array_integer prefix_of;
hsize_array_byte suffix_of;
hsize_array_byte stack;

int codesize;
int maxcode;
int free_ent;
int maxcodemax;
int offset;
int sizex;



/* ============================================================= */
/*
 * Host operating system details
 *
 */

#include <string.h>
 /* this include defines strcpy, strcmp, etc. */

#ifndef	TURBOC
#include <sys/types.h>
 /*
  * this include file defines
  *		dev_t (* device type *)
  * as used in the sys/utime.h and sys/stat.h header files below
  */

#ifndef	OLDC
#include <sys/utime.h>
 /*
  * this include file defines
  *		struct utimbuf (* utime buffer structure *)
  *		utime()        (* utime function *)
  * as used in the set_file_time() function defined below
  */
#endif	/* !OLDC */
#endif	/* !TURBOC */

#ifndef	TURBOC
#include <time.h>
struct ftime {
	unsigned ft_tsec: 5;	/* two seconds */
	unsigned ft_min: 6;	/* minutes */
	unsigned ft_hour: 5;	/* hours */
	unsigned ft_day: 5;	/* days */
	unsigned ft_month: 4;	/* months */
	unsigned ft_year: 7;	/* years  - 1980 */
};
#endif	/* TURBOC */
#ifndef	OLDC
#include <io.h>
#else
#include <sys/file.h>
#ifdef	L_SET
#define	SEEK_SET	L_SET
#else
#define	SEEK_SET	0
#endif	/* L_SET */
#endif	/* OLDC */
 /*
  * this include file defines
  *             struct ftime ...        (* file time/date stamp info *)
  *             int setftime (int handle, struct ftime *ftimep);
  *             #define SEEK_CUR  1     (* lseek() modes *)
  *             #define SEEK_END  2
  *             #define SEEK_SET  0
  */

#include <fcntl.h>
#ifndef	O_BINARY
#define	O_BINARY	0
#endif	/* O_BINARY */
 /*
  * this include file defines
  *             #define O_BINARY 0x8000  (* no cr-lf translation *)
  * as used in the open() standard function
  */

#include <sys/stat.h>
 /*
  * this include file defines
  *             #define S_IREAD 0x0100  (* owner may read *)
  *             #define S_IWRITE 0x0080 (* owner may write *)
  * as used in the creat() standard function
  */

/* #undef HIGH_LOW - define externally */
 /*
  * change 'undef' to 'define' if your machine stores high order bytes in
  * lower addresses.
  */

void set_file_time(VOIDARG)
 /*
  * set the output file date/time stamp according to information from the
  * zipfile directory record for this file 
  */
{
	union {
                struct ftime ft;        /* system file time record */
		struct {
                        word ztime;     /* date and time words */
                        word zdate;     /* .. same format as in .ZIP file */
		} zt;
	} td;

	/*
	 * set output file date and time - this is optional and can be
	 * deleted if your compiler does not easily support setftime() 
	 */
#ifdef	TURBOC
	td.zt.ztime = lrec.last_mod_file_time;
	td.zt.zdate = lrec.last_mod_file_date;

	setftime(outfd, &td.ft);
#else

#define leap(y)	 (((y) % 4 == 0 && (y) % 100 != 0) || (y) % 400 == 0)
#define nleap(y) (((y) - 1969) / 4 - ((y) - 1901) / 100 + ((y) - 1601) / 400)

	static char month_lengths[] =
		{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	int day_of_year, year;
#ifndef	OLDC
	struct utimbuf times;
#else
	struct utimbuf {
		time_t actime;		/* file accessed time */
		time_t modtime;		/* file updated time */
	} times;
#endif	/* OLDC */

	/*
	 * this is the standard Unix implementation (also fully
	 * compatible with MSC)
	 */

	close(outfd);
	td.zt.ztime = lrec.last_mod_file_time;
	td.zt.zdate = lrec.last_mod_file_date;
	year = td.ft.ft_year + 1980;
	if (td.ft.ft_month < 1 || td.ft.ft_month > 12 || td.ft.ft_day < 1
		|| td.ft.ft_day > month_lengths[td.ft.ft_month-1]
		&& !(td.ft.ft_month == 2 && td.ft.ft_day == 29 && leap (year))
		|| td.ft.ft_hour > 23 || td.ft.ft_min > 59 ||
		td.ft.ft_tsec*2 > 59)
		return;
	day_of_year = td.ft.ft_day - 1;
	if (td.ft.ft_month > 2 && leap(year)) ++day_of_year;
	while (--td.ft.ft_month > 0)
		day_of_year += month_lengths[td.ft.ft_month - 1];
	times.modtime = (86400 * (long)(day_of_year + 365 * (year - 1970) 
		+ nleap (year)) + 3600 * (td.ft.ft_hour-1) + 60 * td.ft.ft_min
		+ td.ft.ft_tsec*2);
#ifdef	HAVE_TZ
	tzset();
	times.modtime += timezone;
#endif	/* HAVE_TZ */
	times.actime = times.modtime;
	utime(filename, &times);
#endif	/* !TURBOC */
}


int create_output_file(VOIDARG)
 /* return non-0 if creat failed */
{
	/* create the output file with READ and WRITE permissions */
	outfd = creat(filename, S_IWRITE | S_IREAD | S_IREAD >> 3
			| S_IREAD >> 6);
	if (outfd < 1) {
		printf("Can't create output: %s\n", filename);
		return 1;
	}

	/*
	 * close the newly created file and reopen it in BINARY mode to
	 * disable all CR/LF translations 
	 */
	close(outfd);
	outfd = open(filename, O_RDWR | O_BINARY);

	/* write a single byte at EOF to pre-allocate the file */
#ifdef	tx
	fsetsize(outfd, lrec.uncompressed_size);
#endif	/* tx */
        lseek(outfd, lrec.uncompressed_size - 1L, SEEK_SET);
	write(outfd, "?", 1);
	lseek(outfd, 0L, SEEK_SET);
	return 0;
}


int open_input_file(VOIDARG)
 /* return non-0 if creat failed */
{
	/*
	 * open the zipfile for reading and in BINARY mode to prevent cr/lf
	 * translation, which would corrupt the bitstreams 
	 */

	zipfd = open(zipfn, O_RDONLY | O_BINARY);
	if (zipfd < 1) {
		printf("Can't open input file: %s\n", zipfn);
		return (1);
	}
	return 0;
}


#ifdef HIGH_LOW

#ifndef	OLDC
void swap_bytes(word *wordp)
#else
void swap_bytes(wordp)
word *wordp;
#endif	/* OLDC */
 /* convert intel style 'short int' variable to host format */
{
	char *charp = (char *) wordp;
	char temp[2];

	temp[0] = charp[w0];
	temp[1] = charp[w1];
	charp[0] = temp[0];
	charp[1] = temp[1];
}

#ifndef	OLDC
void swap_lbytes(longint *longp)
#else
void swap_lbytes(longp)
longint *longp;
#endif	/* OLDC */
 /* convert intel style 'long' variable to host format */
{
	char *charp = (char *) longp;
	char temp[4];

	temp[0] = charp[li0];
	temp[1] = charp[li1];
	temp[2] = charp[li2];
	temp[3] = charp[li3];
	charp[0] = temp[0];
	charp[1] = temp[1];
	charp[2] = temp[2];
	charp[3] = temp[3];
}

#endif	/* HIGH_LOW */



/* ============================================================= */

int FillBuffer(VOIDARG)
 /* fill input buffer if possible */
{
	int readsize;

        if (lrec.compressed_size <= 0)
		return incnt = 0;

        if (lrec.compressed_size > INBUFSIZ)
		readsize = INBUFSIZ;
	else
                readsize = (int) lrec.compressed_size;
	incnt = read(zipfd, inbuf, readsize);

        lrec.compressed_size -= incnt;
	inptr = inbuf;
	return incnt--;
}

#ifndef	OLDC
int ReadByte(unsigned *x)
#else
int ReadByte(x)
unsigned *x;
#endif	/* OLDC */
 /* read a byte; return 8 if byte available, 0 if not */
{
	if (incnt-- == 0)
		if (FillBuffer() == 0)
			return 0;

	*x = *inptr++;
	return 8;
}


/* ------------------------------------------------------------- */
static unsigned mask_bits[] =
        {0,     0x0001, 0x0003, 0x0007, 0x000f,
                0x001f, 0x003f, 0x007f, 0x00ff,
                0x01ff, 0x03ff, 0x07ff, 0x0fff,
                0x1fff, 0x3fff, 0x7fff, 0xffff
        };


#ifndef	OLDC
int FillBitBuffer(register int bits)
#else
int FillBitBuffer(bits)
register int bits;
#endif	/* OLDC */
 /* read a byte; return 8 if byte available, 0 if not */
{
	/* get the bits that are left and read the next word */
	unsigned temp;
        register int result = bitbuf;
	int sbits = bits_left;
	bits -= bits_left;

	/* read next word of input */
	bits_left = ReadByte(&bitbuf);
	bits_left += ReadByte(&temp);
	bitbuf |= (temp << 8);
	if (bits_left == 0)
		zipeof = 1;

	/* get the remaining bits */
        result = result | (int) ((bitbuf & mask_bits[bits]) << sbits);
        bitbuf >>= bits;
        bits_left -= bits;
        return result;
}

#define READBIT(nbits,zdest,ztype) \
	{ if (nbits <= bits_left) \
		{ zdest = ztype(bitbuf & mask_bits[nbits]); \
		bitbuf >>= nbits; bits_left -= nbits; } \
	else zdest = ztype(FillBitBuffer(nbits));}

/*
 * macro READBIT(nbits,zdest,ztype)
 *  {
 *      if (nbits <= bits_left) {
 *          zdest = ztype(bitbuf & mask_bits[nbits]);
 *          bitbuf >>= nbits;
 *          bits_left -= nbits;
 *      } else
 *          zdest = ztype(FillBitBuffer(nbits));
 *  }
 *
 */


/* ------------------------------------------------------------- */

#include "crc32.h"


/* ------------------------------------------------------------- */

void FlushOutput(VOIDARG)
 /* flush contents of output buffer */
{
	UpdateCRC(outbuf, outcnt);
	write(outfd, outbuf, outcnt);
	outpos += outcnt;
	outcnt = 0;
	outptr = outbuf;
}

#define OUTB(intc) { *outptr++=intc; if (++outcnt==OUTBUFSIZ) FlushOutput(); }

/*
 *  macro OUTB(intc)
 *  {
 *      *outptr++=intc;
 *      if (++outcnt==OUTBUFSIZ)
 *          FlushOutput();
 *  }
 *
 */


/* ----------------------------------------------------------- */

void LoadFollowers(VOIDARG)
{
        register int x;
        register int i;

	for (x = 255; x >= 0; x--) {
                READBIT(6,Slen[x],(byte));
		for (i = 0; i < Slen[x]; i++) {
                        READBIT(8,followers[x][i],(byte));
		}
	}
}


/* ----------------------------------------------------------- */
/*
 * The Reducing algorithm is actually a combination of two
 * distinct algorithms.  The first algorithm compresses repeated
 * byte sequences, and the second algorithm takes the compressed
 * stream from the first algorithm and applies a probabilistic
 * compression method.
 */

int L_table[] = {0, 0x7f, 0x3f, 0x1f, 0x0f};

int D_shift[] = {0, 0x07, 0x06, 0x05, 0x04};
int D_mask[]  = {0, 0x01, 0x03, 0x07, 0x0f};

int B_table[] = {8, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
		 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6,
		 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7,
		 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
		 8, 8, 8, 8};

/* ----------------------------------------------------------- */

void unReduce(VOIDARG)
 /* expand probablisticly reduced data */
{
        register int lchar;
        int nchar;
        int ExState;
        int V;
        int Len;

        factor = lrec.compression_method - 1;
	ExState = 0;
	lchar = 0;
	LoadFollowers();

        while (((outpos+outcnt) < lrec.uncompressed_size) && (!zipeof)) {
		if (Slen[lchar] == 0)
                        READBIT(8,nchar,(int))      /* ; */
                else
		{
                        READBIT(1,nchar,(int));
                        if (nchar != 0)
                                READBIT(8,nchar,(int))      /* ; */
                        else
			{
                                int follower;
                                int bitsneeded = B_table[Slen[lchar]];
                                READBIT(bitsneeded,follower,(int));
                                nchar = followers[lchar][follower];
			}
		}

		/* expand the resulting byte */
		switch (ExState) {

		case 0:
                        if (nchar != DLE)
                                OUTB((byte) nchar) /*;*/
			else
				ExState = 1;
			break;

		case 1:
                        if (nchar != 0) {
                                V = nchar;
				Len = V & L_table[factor];
				if (Len == L_table[factor])
					ExState = 2;
				else
					ExState = 3;
			}
			else {
                                OUTB(DLE);
				ExState = 0;
			}
			break;

                case 2: {
                                Len += nchar;
				ExState = 3;
			}
			break;

                case 3: {
				register int i = Len + 3;
				int offset = (((V >> D_shift[factor]) &
                                          D_mask[factor]) << 8) + nchar + 1;
                                longint op = (outpos+outcnt) - offset;

				/* special case- before start of file */
				while ((op < 0L) && (i > 0)) {
					OUTB(0);
					op++;
					i--;
				}

				/* normal copy of data from output buffer */
				{
					register int ix = (int) (op % OUTBUFSIZ);

                                        /* do a block memory copy if possible */
                                        if ( ((ix    +i) < OUTBUFSIZ) &&
                                             ((outcnt+i) < OUTBUFSIZ) ) {
                                                memcpy(outptr,&outbuf[ix],i);
                                                outptr += i;
                                                outcnt += i;
                                        }

                                        /* otherwise copy byte by byte */
                                        else while (i--) {
                                                OUTB(outbuf[ix]);
                                                if (++ix >= OUTBUFSIZ)
                                                        ix = 0;
                                        }
                                }

				ExState = 0;
			}
			break;
		}

                /* store character for next iteration */
                lchar = nchar;
        }
}


/* ------------------------------------------------------------- */
/*
 * Shrinking is a Dynamic Ziv-Lempel-Welch compression algorithm
 * with partial clearing.
 *
 */

void partial_clear(VOIDARG)
{
        register int pr;
        register int cd;

	/* mark all nodes as potentially unused */
	for (cd = first_ent; cd < free_ent; cd++)
		prefix_of[cd] |= 0x8000;

	/* unmark those that are used by other nodes */
	for (cd = first_ent; cd < free_ent; cd++) {
		pr = prefix_of[cd] & 0x7fff;	/* reference to another node? */
                if (pr >= first_ent)            /* flag node as referenced */
			prefix_of[pr] &= 0x7fff;
	}

	/* clear the ones that are still marked */
	for (cd = first_ent; cd < free_ent; cd++)
		if ((prefix_of[cd] & 0x8000) != 0)
			prefix_of[cd] = -1;

	/* find first cleared node as next free_ent */
        cd = first_ent;
        while ((cd < maxcodemax) && (prefix_of[cd] != -1))
                cd++;
        free_ent = cd;
}


/* ------------------------------------------------------------- */

void unShrink(VOIDARG)
{
#define  GetCode(dest) READBIT(codesize,dest,(int))

	register int code;
	register int stackp;
	int finchar;
	int oldcode;
	int incode;


	/* decompress the file */
	maxcodemax = 1 << max_bits;
	codesize = init_bits;
	maxcode = (1 << codesize) - 1;
	free_ent = first_ent;
	offset = 0;
	sizex = 0;

	for (code = maxcodemax; code > 255; code--)
		prefix_of[code] = -1;

	for (code = 255; code >= 0; code--) {
		prefix_of[code] = 0;
		suffix_of[code] = (byte) code;
	}

	GetCode(oldcode);
	if (zipeof)
		return;
	finchar = oldcode;

        OUTB((byte) finchar);

        stackp = hsize;

	while (!zipeof) {
		GetCode(code);
		if (zipeof)
			return;

		while (code == clear) {
			GetCode(code);
			switch (code) {

			case 1:{
					codesize++;
					if (codesize == max_bits)
						maxcode = maxcodemax;
					else
						maxcode = (1 << codesize) - 1;
				}
				break;

			case 2:
				partial_clear();
				break;
			}

			GetCode(code);
			if (zipeof)
				return;
		}


		/* special case for KwKwK string */
		incode = code;
		if (prefix_of[code] == -1) {
                        stack[--stackp] = (byte) finchar;
			code = oldcode;
		}


		/* generate output characters in reverse order */
		while (code >= first_ent) {
                        stack[--stackp] = suffix_of[code];
			code = prefix_of[code];
		}

		finchar = suffix_of[code];
                stack[--stackp] = (byte) finchar;


                /* and put them out in forward order, block copy */
                if ((hsize-stackp+outcnt) < OUTBUFSIZ) {
                        memcpy(outptr,&stack[stackp],hsize-stackp);
                        outptr += hsize-stackp;
                        outcnt += hsize-stackp;
                        stackp = hsize;
                }

                /* output byte by byte if we can't go by blocks */
                else while (stackp < hsize)
                        OUTB(stack[stackp++]);


		/* generate new entry */
		code = free_ent;
		if (code < maxcodemax) {
			prefix_of[code] = oldcode;
			suffix_of[code] = (byte) finchar;

			do
				code++;
			while ((code < maxcodemax) && (prefix_of[code] != -1));

			free_ent = code;
		}

		/* remember previous code */
		oldcode = incode;
	}

}


/* ------------------------------------------------------------- */ 
/*
 * Imploding
 * ---------
 *
 * The Imploding algorithm is actually a combination of two distinct
 * algorithms.  The first algorithm compresses repeated byte sequences
 * using a sliding dictionary.  The second algorithm is used to compress
 * the encoding of the sliding dictionary ouput, using multiple
 * Shannon-Fano trees.
 *
 */ 

#define maxSF 256

   typedef struct sf_entry { 
                 word         Code; 
                 byte         Value; 
                 byte         BitLength; 
              } sf_entry; 

   typedef struct sf_tree {   /* a shannon-fano tree */ 
      sf_entry     entry[maxSF];
      int          entries;
      int          MaxLength;
   } sf_tree; 

   typedef sf_tree      *sf_treep; 

   sf_tree      lit_tree; 
   sf_tree      length_tree; 
   sf_tree      distance_tree; 
   boolean      lit_tree_present; 
   boolean      eightK_dictionary; 
   int          minimum_match_length;
   int          dict_bits;


#ifndef	OLDC
void SortLengths(sf_tree *tree)
#else
void SortLengths(tree)
sf_tree *tree;
#endif	/* OLDC */
  /* Sort the Bit Lengths in ascending order, while retaining the order
    of the original lengths stored in the file */ 
{ 
   int          x;
   int          gap;
   sf_entry     t; 
   boolean      noswaps;
   int          a, b;

   gap = tree->entries / 2; 

   do { 
      do { 
         noswaps = 1;
         for (x = 0; x <= (tree->entries - 1) - gap; x++) 
         { 
            a = tree->entry[x].BitLength; 
            b = tree->entry[x + gap].BitLength; 
            if ((a > b) || ((a == b) && (tree->entry[x].Value > tree->entry[x + gap].Value))) 
            { 
               t = tree->entry[x]; 
               tree->entry[x] = tree->entry[x + gap]; 
               tree->entry[x + gap] = t; 
               noswaps = 0;
            } 
         } 
      }  while (!noswaps);

      gap = gap / 2; 
   }  while (gap > 0);
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void ReadLengths(sf_tree *tree)
#else
void ReadLengths(tree)
sf_tree *tree;
#endif	/* OLDC */
{ 
   int          treeBytes;
   int          i;
   int          num, len;

  /* get number of bytes in compressed tree */
   READBIT(8,treeBytes,(int));
   treeBytes++; 
   i = 0; 

   tree->MaxLength = 0;

 /* High 4 bits: Number of values at this bit length + 1. (1 - 16)
    Low  4 bits: Bit Length needed to represent value + 1. (1 - 16) */
   while (treeBytes > 0)
   {
      READBIT(4,len,(int)); len++;
      READBIT(4,num,(int)); num++;

      while (num > 0)
      {
         if (len > tree->MaxLength)
            tree->MaxLength = len;
         tree->entry[i].BitLength = (byte) len;
         tree->entry[i].Value = (byte) i;
         i++;
         num--;
      }

      treeBytes--;
   } 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void GenerateTrees(sf_tree *tree)
#else
void GenerateTrees(tree)
sf_tree *tree;
#endif	/* OLDC */
     /* Generate the Shannon-Fano trees */ 
{ 
   word         Code;
   int          CodeIncrement;
   int          LastBitLength;
   int          i;


   Code = 0;
   CodeIncrement = 0; 
   LastBitLength = 0; 

   i = tree->entries - 1;   /* either 255 or 63 */ 
   while (i >= 0) 
   { 
      Code += CodeIncrement; 
      if (tree->entry[i].BitLength != (byte) LastBitLength) 
      { 
         LastBitLength = tree->entry[i].BitLength; 
         CodeIncrement = 1 << (16 - LastBitLength); 
      } 

      tree->entry[i].Code = Code; 
      i--; 
   } 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void ReverseBits(sf_tree *tree)
#else
void ReverseBits(tree)
sf_tree *tree;
#endif	/* OLDC */
 /* Reverse the order of all the bits in the above ShannonCode[]
    vector, so that the most significant bit becomes the least
    significant bit. For example, the value 0x1234 (hex) would become
    0x2C48 (hex). */ 
{ 
   int          i;
   word         mask;
   word         revb;
   word         v;
   word         o;
   int          b;


   for (i = 0; i <= tree->entries - 1; i++) 
   { 
        /* get original code */ 
      o = tree->entry[i].Code; 

        /* reverse each bit */ 
      mask = 0x0001;
      revb = 0x8000;
      v = 0;
      for (b = 0; b <= 15; b++) 
      { 
           /* if bit set in mask, then substitute reversed bit */ 
         if ((o & mask) != 0) 
            v = v | revb; 

           /* advance to next bit */ 
         revb = (revb >> 1);
         mask = (mask << 1);
      } 

        /* store reversed bits */ 
      tree->entry[i].Code = v; 
   } 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void LoadTree(sf_tree *tree, int treesize)
#else
void LoadTree(tree, treesize)
sf_tree *tree;
int treesize;
#endif	/* OLDC */
     /* allocate and load a shannon-fano tree from the compressed file */ 
{ 
   tree->entries = treesize; 
   ReadLengths(tree); 
   SortLengths(tree); 
   GenerateTrees(tree); 
   ReverseBits(tree); 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void LoadTrees(void)
#else
void LoadTrees()
#endif	/* OLDC */
{ 
   /* bit 1... */
   eightK_dictionary = (boolean) ((lrec.general_purpose_bit_flag & 0x02) != 0);
   /* bit 2... */
   lit_tree_present = (boolean) ((lrec.general_purpose_bit_flag & 0x04) != 0);

   if (eightK_dictionary) 
      dict_bits = 7;
   else 
      dict_bits = 6; 

   if (lit_tree_present) 
   { 
      minimum_match_length = 3; 
      LoadTree(&lit_tree,256); 
   } 
   else 
      minimum_match_length = 2; 

   LoadTree(&length_tree,64); 
   LoadTree(&distance_tree,64); 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void ReadTree(sf_tree *tree, int *dest)
#else
void ReadTree(tree, dest)
sf_tree *tree;
int *dest;
#endif	/* OLDC */
     /* read next byte using a shannon-fano tree */ 
{ 
   int          bits = 0;
   word         cv = 0;
   int          cur = 0;
   int          b;

   *dest = -1;   /* in case of error */ 

   for (;;)
   { 
      READBIT(1,b,(int));
      cv = cv | (b << bits);
      bits++; 

      /* this is a very poor way of decoding shannon-fano.  two quicker
         methods come to mind:
            a) arrange the tree as a huffman-style binary tree with
               a "leaf" indicator at each node,
         and
            b) take advantage of the fact that s-f codes are at most 8
               bits long and alias unused codes for all bits following
               the "leaf" bit.
      */

      while (tree->entry[cur].BitLength < (byte) bits) 
      { 
         cur++; 
         if (cur >= tree->entries) 
            return; /* data error */
      } 

      while (tree->entry[cur].BitLength == (byte) bits) 
      { 
         if (tree->entry[cur].Code == cv) 
         { 
            *dest = tree->entry[cur].Value; 
            return; 
         } 

         cur++; 
         if (cur >= tree->entries) 
            return; /* data error */
      } 
   } 
} 


/* ----------------------------------------------------------- */ 

#ifndef	OLDC
void unImplode(void)
#else
void unImplode()
#endif	/* OLDC */
     /* expand imploded data */ 

{ 
   int          lout;
   longint      op;
   int          Length;
   int          Distance;

   LoadTrees(); 

   while ((!zipeof) && ((outpos+outcnt) < lrec.uncompressed_size))
   { 
      READBIT(1,lout,(int));

      if (lout != 0)   /* encoded data is literal data */ 
      { 
         if (lit_tree_present)  /* use Literal Shannon-Fano tree */
            ReadTree(&lit_tree,&lout);
         else 
            READBIT(8,lout,(int));

         OUTB((byte) lout);
      } 
      else             /* encoded data is sliding dictionary match */
      {                
         READBIT(dict_bits,lout,(int));
         Distance = lout; 

         ReadTree(&distance_tree,&lout); 
         Distance |= (lout << dict_bits);
         /* using the Distance Shannon-Fano tree, read and decode the
            upper 6 bits of the Distance value */ 

         ReadTree(&length_tree,&Length); 
         /* using the Length Shannon-Fano tree, read and decode the
            Length value */

         Length += minimum_match_length; 
         if (Length == (63 + minimum_match_length)) 
         { 
            READBIT(8,lout,(int));
            Length += lout; 
         } 

        /* move backwards Distance+1 bytes in the output stream, and copy
          Length characters from this position to the output stream.
          (if this position is before the start of the output stream,
          then assume that all the data before the start of the output
          stream is filled with zeros) */ 

         op = (outpos+outcnt) - Distance - 1L;

          /* special case- before start of file */
          while ((op < 0L) && (Length > 0)) {
                  OUTB(0);
                  op++;
                  Length--;
          }

          /* normal copy of data from output buffer */
          {
                  register int ix = (int) (op % OUTBUFSIZ);

                  /* do a block memory copy if possible */
                  if ( ((ix    +Length) < OUTBUFSIZ) &&
                       ((outcnt+Length) < OUTBUFSIZ) ) {
                          memcpy(outptr,&outbuf[ix],Length);
                          outptr += Length;
                          outcnt += Length;
                  }

                  /* otherwise copy byte by byte */
                  else while (Length--) {
                          OUTB(outbuf[ix]);
                          if (++ix >= OUTBUFSIZ)
                                  ix = 0;
                  }
         }
      } 
   } 
} 



/* ---------------------------------------------------------- */

void extract_member(VOIDARG)
{
        unsigned b;

	bits_left = 0;
	bitbuf = 0;
	incnt = 0;
	outpos = 0L;
	outcnt = 0;
	outptr = outbuf;
	zipeof = 0;
	crc32val = 0xFFFFFFFFL;


	/* create the output file with READ and WRITE permissions */
	if (create_output_file())
		exit(1);

        switch (lrec.compression_method) {

	case 0:		/* stored */
		{
			printf(" Extracting: %-12s ", filename);
			while (ReadByte(&b))
				OUTB((byte) b);
		}
		break;

        case 1: {
			printf("UnShrinking: %-12s ", filename);
			unShrink();
		}
		break;

	case 2:
	case 3:
	case 4:
        case 5: {
			printf("  Expanding: %-12s ", filename);
			unReduce();
		}
		break;

        case 6: {
                        printf("  Exploding: %-12s ", filename);
                        unImplode();
		}
		break;

        default:
		printf("Unknown compression method.");
	}


	/* write the last partial buffer, if any */
	if (outcnt > 0) {
		UpdateCRC(outbuf, outcnt);
		write(outfd, outbuf, outcnt);
	}

	/* set output file date and time */
	set_file_time();

	close(outfd);

	crc32val = -1 - crc32val;
        if (crc32val != lrec.crc32)
                printf(" Bad CRC %08lx  (should be %08lx)", lrec.crc32, crc32val);

	printf("\n");
}


/* ---------------------------------------------------------- */

#ifndef	OLDC
void get_string(int len, char *s)
#else
void get_string(len, s)
int len;
char *s;
#endif	/* OLDC */
 /* read a byte; return 8 if byte available, 0 if not */
{
	read(zipfd, s, len);
	s[len] = 0;
}


/* ---------------------------------------------------------- */

void process_local_file_header(VOIDARG)
{
	if ((long) &lrec.crc32 ==
			(long) &lrec.last_mod_file_date
			+ sizeof(lrec.last_mod_file_date))
		read(zipfd, (char *) &lrec, sizeof(lrec));
	else {
		read(zipfd, (char *) &lrec, (unsigned)
			((long) &lrec.last_mod_file_date
			+ sizeof(lrec.last_mod_file_date)
			- (long) &lrec));
		read(zipfd, (char *) &lrec.crc32, (unsigned)
			((long) &lrec.extra_field_length
			+ sizeof(lrec.extra_field_length)
			- (long) &lrec.crc32));
	}

#ifdef HIGH_LOW
	swap_bytes(&lrec.version_needed_to_extract);
	swap_bytes(&lrec.general_purpose_bit_flag);
	swap_bytes(&lrec.compression_method);
	swap_bytes(&lrec.last_mod_file_time);
	swap_bytes(&lrec.last_mod_file_date);
	swap_lbytes(&lrec.crc32);
	swap_lbytes(&lrec.compressed_size);
	swap_lbytes(&lrec.uncompressed_size);
	swap_bytes(&lrec.filename_length);
	swap_bytes(&lrec.extra_field_length);
#endif	/* HIGH_LOW */

	get_string(lrec.filename_length, filename);
	get_string(lrec.extra_field_length, extra);
#ifdef	unix
	{
		char *cp;
		for (cp = filename; *cp; ++cp)
			if (isupper(*cp)) *cp = tolower(*cp);
	}
#endif	/* unix */
	extract_member();
}


/* ---------------------------------------------------------- */

void process_central_file_header(VOIDARG)
{
	central_directory_file_header rec;
	char filename[STRSIZ];
	char extra[STRSIZ];
	char comment[STRSIZ];

	if ((long) &rec.external_file_attributes ==
			(long) &rec.internal_file_attributes
			+ sizeof(rec.internal_file_attributes))
		read(zipfd, (char *) &rec, sizeof(rec));
	else {
		read(zipfd, (char *) &rec, (unsigned)
			((long) &rec.internal_file_attributes
			+ sizeof(rec.internal_file_attributes)
			- (long) &rec));
		read(zipfd, (char *) &rec.external_file_attributes, (unsigned)
			((long) &rec.relative_offset_local_header
			+ sizeof(rec.relative_offset_local_header)
			- (long) &rec.external_file_attributes));
	}

#ifdef HIGH_LOW
	swap_bytes(&rec.version_made_by);
	swap_bytes(&rec.version_needed_to_extract);
	swap_bytes(&rec.general_purpose_bit_flag);
	swap_bytes(&rec.compression_method);
	swap_bytes(&rec.last_mod_file_time);
	swap_bytes(&rec.last_mod_file_date);
	swap_lbytes(&rec.crc32);
	swap_lbytes(&rec.compressed_size);
	swap_lbytes(&rec.uncompressed_size);
	swap_bytes(&rec.filename_length);
	swap_bytes(&rec.extra_field_length);
	swap_bytes(&rec.file_comment_length);
	swap_bytes(&rec.disk_number_start);
	swap_bytes(&rec.internal_file_attributes);
	swap_lbytes(&rec.external_file_attributes);
	swap_lbytes(&rec.relative_offset_local_header);
#endif	/* HIGH_LOW */

        get_string(rec.filename_length, filename);
	get_string(rec.extra_field_length, extra);
	get_string(rec.file_comment_length, comment);
#ifdef	unix
	{
		char *cp;
		for (cp = filename; *cp; ++cp)
			if (isupper(*cp)) *cp = tolower(*cp);
	}
#endif	/* unix */
}


/* ---------------------------------------------------------- */

void process_end_central_dir(VOIDARG)
{
	end_central_dir_record rec;
	char comment[STRSIZ];

	read(zipfd, (char *) &rec, sizeof(rec));

#ifdef HIGH_LOW
	swap_bytes(&rec.number_this_disk);
#ifndef	TURBOC
	swap_bytes(&rec.num_disk_with_start_cent_dir);
	swap_bytes(&rec.tot_ents_cent_dir_on_this_disk);
#else
	swap_bytes(&rec.number_disk_with_start_central_directory);
	swap_bytes(&rec.total_entries_central_dir_on_this_disk);
#endif	/* TURBOC */
	swap_bytes(&rec.total_entries_central_dir);
	swap_lbytes(&rec.size_central_directory);
	swap_lbytes(&rec.offset_start_central_directory);
	swap_bytes(&rec.zipfile_comment_length);
#endif	/* HIGH_LOW */

	get_string(rec.zipfile_comment_length, comment);
}


/* ---------------------------------------------------------- */

void process_headers(VOIDARG)
{
	longint sig;

	while (1) {
		if (read(zipfd, (char *) &sig, sizeof(sig)) != sizeof(sig))
			return;

#ifdef HIGH_LOW
		swap_lbytes(&sig);
#endif	/* HIGH_LOW */

                if (sig == LOCAL_FILE_HEADER_SIGNATURE)
			process_local_file_header();
                else if (sig == CENTRAL_FILE_HEADER_SIGNATURE)
			process_central_file_header();
                else if (sig == END_CENTRAL_DIR_SIGNATURE) {
			process_end_central_dir();
			return;
		}
                else {
			printf("Invalid Zipfile Header (0x%.8lx)\n", sig);
			return;
		}
	}

}


/* ---------------------------------------------------------- */

void extract_zipfile(VOIDARG)
{
	/*
	 * open the zipfile for reading and in BINARY mode to prevent cr/lf
	 * translation, which would corrupt the bitstreams 
	 */

	if (open_input_file())
		exit(1);

#ifdef HIGH_LOW
	{
		word w_sig;
		longint li_sig;
		char *bp, *bp0 = (char *)&li_sig, *bp3 = ((char *)&li_sig)+3;

		if (read(zipfd, (char *) &w_sig, 2) == 2)
			if (w_sig == (LOCAL_FILE_HEADER_SIGNATURE & 0xffff)) {
				w0 = 0;
				w1 = 1;
			} else {
				w0 = 1;
				w1 = 0;
			}
		lseek(zipfd, 0L, SEEK_SET);
		if (read(zipfd, (char *) &li_sig, 4) == 4)
			if (li_sig == LOCAL_FILE_HEADER_SIGNATURE) {
				li0 = 0;
				li1 = 1;
				li2 = 2;
				li3 = 3;
			} else {
				li0 = li1 = li2 = li3 = 0;
				for (bp = bp0; bp < bp3; ++bp, ++li0)
					if (*bp < 0x4b && !(*bp & 0x01))
						break;
				for (bp = bp0; bp < bp3; ++bp, ++li1)
					if (*bp < 0x4b && (*bp & 0x01))
						break;
				for (bp = bp0; bp < bp3; ++bp, ++li2)
					if (*bp == ((LOCAL_FILE_HEADER_SIGNATURE
							>> 8) & 0xffL))
						break;
				for (bp = bp0; bp < bp3; ++bp, ++li3)
					if (*bp == (LOCAL_FILE_HEADER_SIGNATURE
							& 0xffL))
						break;
			}
		lseek(zipfd, 0L, SEEK_SET);
	}
#endif	/* HIGH_LOW */

	process_headers();

	close(zipfd);
}


/* ---------------------------------------------------------- */
/*
 * main program
 *
 */

#ifndef	OLDC
void main(int argc, char **argv)
#else
void main(argc, argv)
int argc;
char **argv;
#endif	/* OLDC */
 /* read a byte; return 8 if byte available, 0 if not */
{
	if (argc != 2) {
                printf("\n%s\nCourtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.\n\n",VERSION);
		printf("You may copy and distribute this program freely, provided that:\n");
		printf("    1)   No fee is charged for such copying and distribution, and\n");
		printf("    2)   It is distributed ONLY in its original, unmodified state.\n\n");
		printf("If you wish to distribute a modified version of this program, you MUST\n");
		printf("include the source code.\n\n");
		printf("If you modify this program, I would appreciate a copy of the  new source\n");
		printf("code.   I am holding the copyright on the source code, so please don't\n");
		printf("delete my name from the program files or from the documentation.\n\n");
                printf("IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY LOST\n");
                printf("PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES\n");
                printf("ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR FOR ANY\n");
                printf("CLAIM BY ANY OTHER PARTY.\n\n");
                printf("Usage:  UnZip FILE[.zip]\n");
                exit(1);
	}

	/* .ZIP default if none provided by user */
	strcpy(zipfn, argv[1]);
	if (strchr(zipfn, '.') == NULL)
		strcat(zipfn, ".zip");

        /* allocate i/o buffers */
	inbuf = (byte *) (malloc(INBUFSIZ));
	outbuf = (byte *) (malloc(OUTBUFSIZ));
	if ((inbuf == NULL) || (outbuf == NULL)) {
		printf("Can't allocate buffers!\n");
		exit(1);
	}

        /* do the job... */
        extract_zipfile();
	exit(0);
}

