
/* Modified by Neil Wilson from unzip program to unzip a zipfile spread over
   one or more floppy disks.
   Date of modification completion 11/01/90  */
/* Original unzip.c utililty written by Samual Smith. */

/*
 * UnZip - A simple zipfile extract utility
 *
 * To compile:
 *      tcc -B -O -Z -G -mc unzip.c        ;turbo C 2.0, compact model
 *
 */

char *zipfn;
#define VERSION  "UnZip:  Zipfile Extract v2.0 (C) of 09-09-89;  (C) 1989 Samuel H. Smith"

typedef unsigned char byte;	/* code assumes UNSIGNED bytes */
typedef long longint;
typedef unsigned word;
typedef char boolean;

#define STRSIZ 256

#include <stdio.h>
 /* this is your standard header for all C compiles */

#include <stdlib.h>
 /* this include defines various standard library prototypes */


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
	word number_disk_with_start_central_directory;
	word total_entries_central_dir_on_this_disk;
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
byte *inbuf;            /* input file buffer - any size is legal */
byte *inptr;

int incnt;
unsigned bitbuf;
int bits_left;
boolean zipeof;

int zipfd;
/*char zipfn[STRSIZ];*/
local_file_header lrec;


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

#include <io.h>
 /*
  * this include file defines
  *             struct ftime ...        (* file time/date stamp info *)
  *             int setftime (int handle, struct ftime *ftimep);
  *             #define SEEK_CUR  1     (* lseek() modes *)
  *             #define SEEK_END  2
  *             #define SEEK_SET  0
  */

#include <fcntl.h>
 /*
  * this include file defines
  *             #define O_BINARY 0x8000  (* no cr-lf translation *)
  * as used in the open() standard function
  */

#include <sys/stat.h>
#include <sys/types.h>
 /*
  * this include file defines
  *             #define S_IREAD 0x0100  (* owner may read *)
  *             #define S_IWRITE 0x0080 (* owner may write *)
  * as used in the creat() standard function
  */

#undef HIGH_LOW
 /*
  * change 'undef' to 'define' if your machine stores high order bytes in
  * lower addresses.
 */

void wait(void)
{
  char c;
  close(0);
  open("CON",O_RDONLY);
  c=getch();
  if (c==27) exit(0);
}


int findperiod(char *str, int *count)
{
  while (*count!=9) {
    *count=*count+1;
    if (str[*count] == '.')
      return 1;
    else if (*count==9)
      return 0;
  }
}




int parser(char *str1,char *str2)
{
  int t1;
  int count1=0,count2=0;
  int bd=1;
  int noterror=1,no_match=1;
  while ((noterror) || (no_match)) {
    switch (str1[count1]) {
      case '*': if (bd) {
                  t1=findperiod(str1,&count1);
                  if (!t1) return 1;
                  findperiod(str2,&count2);
                  count1++;
                  count2++;
                  bd=0;
                }
                else if (!bd)
                  return 1;
                break;

      case '?' : count1++;
                 count2++;
                 break;

      case '.' : if (!bd)
                  return 0;
                else if (count1==0)
                  return 0;
                else if (str2[count2]!='.')
                  return 0;
                bd=0;
                count1++;
                count2++;
                break;
      default : if ((str1[count1]==0) && (str2[count2]==0))
                  return 1;
                else if (count2==11)
                  return 1;
                else if (str1[count1]!=str2[count2])
                  return 0;
                count1++;
                count2++;
                break;
    }
  }
}



char *flname;
int flag;
void setflag(void)
{
  if (parser(flname,filename))
    flag=1;
  else flag=0;
}


#include <dir.h>
struct ffblk ffblk;
void filefind(char **pattern)
{
  int temp;
  temp=getdisk();
  setdisk(0);
  findfirst(*pattern,&ffblk,0);
  *pattern = ffblk.ff_name;
  setdisk(temp);
  printf("zip file found - %s\n",*pattern);
}

#include <dos.h>
union REGS regs;
int drivenumber=0;
void RsetFlppy()
{
  regs.h.ah=0x00;
  regs.h.dl=drivenumber;
  int86(0x13,&regs,&regs);
}

int ChkDrvSz(int flpyNm)
{
  regs.h.ah=0x08;
  regs.h.dl=flpyNm;
  int86(0x13,&regs,&regs);
  return regs.h.bl;
/*  bl =
    01h = 5.25  360k
    02h = 5.25  1.2m
    03h = 3.5   720k
    04h = 3.5   1.44m
*/
}

int IsDrvRdy()
{
  int x=1;
  while (x<3)
  {
    regs.h.ah=0x04;
    regs.h.al=0x01;
    regs.h.ch=0x00;
    regs.h.cl=0x01;
    regs.h.dh=0x00;
    int86(0x13,&regs,&regs);
    if (x==1) RsetFlppy();
    else return regs.h.ah;
    x++;
  }
  return 0;
/*  ah=0 : Successfull, otherwise not successfull */
}

void set_file_time(void)
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

	td.zt.ztime = lrec.last_mod_file_time;
	td.zt.zdate = lrec.last_mod_file_date;

	setftime(outfd, &td.ft);
}


int create_output_file(void)
 /* return non-0 if creat failed */
{
	/* create the output file with READ and WRITE permissions */
      if (flag) {
        outfd = creat(filename, S_IWRITE | S_IREAD);
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
            lseek(outfd, lrec.uncompressed_size - 1L, SEEK_SET);
        write(outfd, "?", 1);
        lseek(outfd, 0L, SEEK_SET);
        return 0;
      }
}
char disks[13];
int disk;
int open_input_file(void)
 /* return non-0 if creat failed */
{
    char ch;
    int t=0;
    /*
	 * open the zipfile for reading and in BINARY mode to prevent cr/lf
	 * translation, which would corrupt the bitstreams 
	 */
    while (IsDrvRdy())
    {
      RsetFlppy();
        printf("\n");
        printf("The DRIVE is not ready.\n");
        printf("If you would close the DOOR on the DRIVE we could get busy,\n");
        printf("as it is kind of drafty in here.\n");
        wait();
    }
    zipfd = open(zipfn, O_RDONLY | O_BINARY);
	if (zipfd < 1) {
		printf("Can't open input file: %s\n", zipfn);
		return (1);
	}
    read(zipfd,disks,sizeof(disks));            /**********/
    disk=disks[12];                             /**********/
    printf("number of disks %d\n",disk);        /**********/
    disk=disk-1;
    return 0;
}


#ifdef HIGH_LOW

void swap_bytes(word *wordp)
 /* convert intel style 'short int' variable to host format */
{
	char *charp = (char *) wordp;
	char temp;

	temp = charp[0];
	charp[0] = charp[1];
	charp[1] = temp;
}

void swap_lbytes(longint *longp)
 /* convert intel style 'long' variable to host format */
{
	char *charp = (char *) longp;
	char temp[4];

	temp[3] = charp[0];
	temp[2] = charp[1];
	temp[1] = charp[2];
	temp[0] = charp[3];

	charp[0] = temp[0];
	charp[1] = temp[1];
	charp[2] = temp[2];
	charp[3] = temp[3];
}

#endif



/* ============================================================= */
char *ctemp;
int FillBuffer(void)
 /* fill input buffer if possible */
{
    int readsize;

    if (lrec.compressed_size <= 0)
		return incnt = 0;

    if (lrec.compressed_size > INBUFSIZ)
		readsize = INBUFSIZ;
	else
        readsize = (int) lrec.compressed_size;
    incnt = read(zipfd,inbuf,readsize);
    checkout(incnt,readsize,inbuf);
    incnt = readsize;
    lrec.compressed_size -= incnt;                   /*********/
	inptr = inbuf;
    return incnt--;
}

int ReadByte(unsigned *x)
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


int FillBitBuffer(register int bits)
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

#define READBIT(nbits,zdest) { if (nbits <= bits_left) { zdest = (int)(bitbuf & mask_bits[nbits]); bitbuf >>= nbits; bits_left -= nbits; } else zdest = FillBitBuffer(nbits);}

/*
 * macro READBIT(nbits,zdest)
 *  {
 *      if (nbits <= bits_left) {
 *          zdest = (int)(bitbuf & mask_bits[nbits]);
 *          bitbuf >>= nbits;
 *          bits_left -= nbits;
 *      } else
 *          zdest = FillBitBuffer(nbits);
 *  }
 *
 */


/* ------------------------------------------------------------- */

#include "crc32.h"


/* ------------------------------------------------------------- */

void FlushOutput(void)
 /* flush contents of output buffer */
{
	UpdateCRC(outbuf, outcnt);
    if (flag)
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

void LoadFollowers(void)
{
        register int x;
        register int i;

	for (x = 255; x >= 0; x--) {
                READBIT(6,Slen[x]);
		for (i = 0; i < Slen[x]; i++) {
                        READBIT(8,followers[x][i]);
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

void unReduce(void)
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
                        READBIT(8,nchar)      /* ; */
                else
		{
                        READBIT(1,nchar);
                        if (nchar != 0)
                                READBIT(8,nchar)      /* ; */
                        else
			{
                                int follower;
                                int bitsneeded = B_table[Slen[lchar]];
                                READBIT(bitsneeded,follower);
                                nchar = followers[lchar][follower];
			}
		}

		/* expand the resulting byte */
		switch (ExState) {

		case 0:
                        if (nchar != DLE)
                                OUTB(nchar) /*;*/
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

void partial_clear(void)
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

void unShrink(void)
{
        #define  GetCode(dest) READBIT(codesize,dest)

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
		suffix_of[code] = code;
	}

	GetCode(oldcode);
	if (zipeof)
		return;
	finchar = oldcode;

        OUTB(finchar);

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
                        stack[--stackp] = finchar;
			code = oldcode;
		}


		/* generate output characters in reverse order */
		while (code >= first_ent) {
                        stack[--stackp] = suffix_of[code];
			code = prefix_of[code];
		}

		finchar = suffix_of[code];
                stack[--stackp] = finchar;


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
			suffix_of[code] = finchar;

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

   enum { maxSF        = 256 };

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


void         SortLengths(sf_tree *    tree)
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

void         ReadLengths(sf_tree *    tree)
{ 
   int          treeBytes;
   int          i;
   int          num, len;

  /* get number of bytes in compressed tree */
   READBIT(8,treeBytes);
   treeBytes++; 
   i = 0; 

   tree->MaxLength = 0;

 /* High 4 bits: Number of values at this bit length + 1. (1 - 16)
    Low  4 bits: Bit Length needed to represent value + 1. (1 - 16) */
   while (treeBytes > 0)
   {
      READBIT(4,len); len++;
      READBIT(4,num); num++;

      while (num > 0)
      {
         if (len > tree->MaxLength)
            tree->MaxLength = len;
         tree->entry[i].BitLength = len;
         tree->entry[i].Value = i;
         i++;
         num--;
      }

      treeBytes--;
   } 
} 


/* ----------------------------------------------------------- */ 

void         GenerateTrees(sf_tree *    tree)
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
      if (tree->entry[i].BitLength != LastBitLength) 
      { 
         LastBitLength = tree->entry[i].BitLength; 
         CodeIncrement = 1 << (16 - LastBitLength); 
      } 

      tree->entry[i].Code = Code; 
      i--; 
   } 
} 


/* ----------------------------------------------------------- */ 

void         ReverseBits(sf_tree *    tree)
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

void         LoadTree(sf_tree *    tree,
                      int          treesize)
     /* allocate and load a shannon-fano tree from the compressed file */ 
{ 
   tree->entries = treesize; 
   ReadLengths(tree); 
   SortLengths(tree); 
   GenerateTrees(tree); 
   ReverseBits(tree); 
} 


/* ----------------------------------------------------------- */ 

void         LoadTrees(void)
{ 
   eightK_dictionary = (lrec.general_purpose_bit_flag & 0x02) != 0;   /* bit 1 */
   lit_tree_present = (lrec.general_purpose_bit_flag & 0x04) != 0;   /* bit 2 */

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

void         ReadTree(sf_tree *    tree,
                      int     *    dest)
     /* read next byte using a shannon-fano tree */ 
{ 
   int          bits = 0;
   word         cv = 0;
   int          cur = 0;
   int          b;

   *dest = -1;   /* in case of error */ 

   for (;;)
   { 
      READBIT(1,b);
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

      while (tree->entry[cur].BitLength < bits) 
      { 
         cur++; 
         if (cur >= tree->entries) 
            return; /* data error */
      } 

      while (tree->entry[cur].BitLength == bits) 
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

void         unImplode(void)
     /* expand imploded data */ 

{ 
   int          lout;
   longint      op;
   int          Length;
   int          Distance;
   int          i;

   LoadTrees(); 

   while ((!zipeof) && ((outpos+outcnt) < lrec.uncompressed_size))
   { 
      READBIT(1,lout);

      if (lout != 0)   /* encoded data is literal data */ 
      { 
         if (lit_tree_present)  /* use Literal Shannon-Fano tree */
            ReadTree(&lit_tree,&lout);
         else 
            READBIT(8,lout);

         OUTB(lout);
      } 
      else             /* encoded data is sliding dictionary match */
      {                
         READBIT(dict_bits,lout);
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
            READBIT(8,lout);
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

void extract_member(void)
{
    word     b;
    bits_left = 0;
	bitbuf = 0;
	incnt = 0;
	outpos = 0L;
	outcnt = 0;
	outptr = outbuf;
	zipeof = 0;
	crc32val = 0xFFFFFFFFL;


	/* create the output file with READ and WRITE permissions */
    if (flag)
      if (create_output_file())
		exit(1);

        switch (lrec.compression_method) {

	case 0:		/* stored */
        {
            if (flag) printf(" Extracting: %-12s ", filename);
            else if (!flag) {
              printf("reading past file : %s",filename);
              printf(".\n");
            }
			while (ReadByte(&b))
				OUTB(b);
		}
		break;

        case 1: {
            if (flag) printf("UnShrinking: %-12s ", filename);
            else if (!flag) {
              printf("reading past file : %s",filename);
              printf(".\n");
            }
			unShrink();
		}
		break;

	case 2:
	case 3:
	case 4:
        case 5: {
            if (flag) printf("  Expanding: %-12s ", filename);
            else if (!flag) {
              printf("reading past file : %s",filename);
              printf(".\n");
            }
			unReduce();
		}
		break;

        case 6: {
            if (flag)
              printf("  Exploding: %s\n", filename);
            else if (!flag)
              printf("reading past file : %s\n",filename);
            unImplode();
		}
		break;

        default:
        printf("Unknown compression method.\n");
	}

    /* write the last partial buffer, if any */
	if (outcnt > 0) {
      UpdateCRC(outbuf, outcnt);
      if (flag)
        write(outfd, outbuf, outcnt);
	}
    /* set output file date and time */

    set_file_time();
    close(outfd);
    crc32val = -1 - crc32val;
      if (crc32val != lrec.crc32)
        printf(" Bad CRC %08lx  (should be %08lx)", lrec.crc32, crc32val);
}




/* ---------------------------------------------------------- */

void get_string (int len,
           char *s)
{
    int temp;
    temp=read(zipfd,s,len);             /**********/
    checkout(temp,len,s);
    s[len] = 0;                           /**********/
}                                         /**********/
int fd;
void struct_checkout(void)
{
  fd=creat("temp.bin",S_IREAD | S_IWRITE);
  close(fd);
  fd=open("temp.bin", O_RDWR | O_BINARY | O_TRUNC);
}



void open_new_disk(void)
{
  int t;
  close(zipfd);
  printf("I need the next disk please.\n");
  printf("When disk is in press <Enter> to continue.\n");
  wait();
  while (IsDrvRdy())
  {
      RsetFlppy();
      printf("The DRIVE is not ready.\n");
      printf("If you would close the DOOR on the DRIVE we could get busy,\n");
      printf("as it is kind of drafty in here.\n");
      wait();
  }
  t=strlen(zipfn);
  zipfn[t-1]=zipfn[t-1] + 1;
  while ((zipfd=open(zipfn,O_BINARY|O_RDONLY))<1)
  {
      printf("You have inserted the wrong disk, try again.\n");
      printf("Press <Enter> to continue.\n");
      wait();
  }
  printf("You have just opened - %s\n",zipfn);
  disk=disk-1;
  return;
}

int checkout(int got, int tot, byte *c)
{
  int readsize,temp;
  byte s;
  if (eof(zipfd) && (disk>0))
  {
    if (got<tot)
    {
        open_new_disk();
        readsize=tot-got;
        while (readsize!=0)
        {
          temp = read(zipfd,&s,sizeof(s));
          readsize=readsize-1;
          c[got]=s;
          got=got+temp;
        }
    }
    else
      open_new_disk();
  }
}


/* --------------------------------------------------------------- */

void process_local_file_header(void)                /*********/
{                                                   /*********/
    int t,temp,stemp;
    byte *ch;
    struct_checkout();
    temp=read(zipfd,ch,sizeof(lrec));
    checkout(temp,sizeof(lrec),ch);
    write(fd,ch,sizeof(lrec));
    lseek(fd,0L,0);
    read(fd,&lrec,sizeof(lrec));
    struct_checkout();
    close(fd);
#ifdef HIGH_LOW
	swap_bytes(&lrec.filename_length);
	swap_bytes(&lrec.extra_field_length);
	swap_lbytes(&lrec.compressed_size);
	swap_lbytes(&lrec.uncompressed_size);
	swap_bytes(&lrec.compression_method);
#endif
    get_string(lrec.filename_length, filename);
    setflag();
    get_string(lrec.extra_field_length, extra);
	extract_member();
}


/* ---------------------------------------------------------- */

void process_central_file_header(void)
{
    int t,temp;
    byte *ch;
      central_directory_file_header rec;
      char filename[STRSIZ];
      char extra[STRSIZ];
      char comment[STRSIZ];
    struct_checkout();
    temp=read(zipfd,ch,sizeof(rec));
    checkout(temp,sizeof(rec),ch);
    write(fd,ch,sizeof(rec));
    lseek(fd,0L,0);
    read(fd, &rec, sizeof(rec));
    close(fd);
#ifdef HIGH_LOW                               /***********/
    swap_bytes(&rec.filename_length);         /***********/
	swap_bytes(&rec.extra_field_length);
	swap_bytes(&rec.file_comment_length);
#endif
    get_string(rec.filename_length, filename);
    setflag();
    get_string(rec.extra_field_length, extra);
	get_string(rec.file_comment_length, comment);
}


/* ---------------------------------------------------------- */

void process_end_central_dir(void)
{
    int t,temp;
      end_central_dir_record rec;
    char comment[STRSIZ];                     /***********/
    byte *ch;
    struct_checkout();
    temp=read(zipfd,ch,sizeof(rec));
    checkout(temp,sizeof(rec),ch);
    write(fd,ch,sizeof(rec));
    lseek(fd,0L,0);
    read(fd, &rec, sizeof(rec));
    close(fd);
#ifdef HIGH_LOW
	swap_bytes(&rec.zipfile_comment_length);
#endif
    get_string(rec.zipfile_comment_length, comment);
}


/* ---------------------------------------------------------- */

void process_headers(void)
{
	longint sig;
    int temp;
    int temp2;
    byte *ch;
    while (1) {
        struct_checkout();
        temp=read(zipfd,ch,sizeof(sig));
        checkout(temp,sizeof(sig),ch);
        write(fd,ch,sizeof(sig));
        lseek(fd,0L,0);
        read(fd, &sig,sizeof(sig));
        close(fd);
#ifdef HIGH_LOW
		swap_lbytes(&sig);
#endif
        if (sig == LOCAL_FILE_HEADER_SIGNATURE)
          process_local_file_header();
        else if (sig == CENTRAL_FILE_HEADER_SIGNATURE)
          process_central_file_header();
        else if (sig == END_CENTRAL_DIR_SIGNATURE) {
          process_end_central_dir();
          return;
		}
        else {
          printf("Invalid Zipfile Header\n");
          return;
		}
	}
}


/* ---------------------------------------------------------- */

void extract_zipfile(void)
{
 /*
  * open the zipfile for reading and in BINARY mode to prevent cr/lf
  * translation, which would corrupt the bitstreams
  */
    if (open_input_file())
      exit(1);
    process_headers();
    close(zipfd);
}


/* ---------------------------------------------------------- */
/*
 * main program
 *
 */

char *drivepath;
void main(int argc, char **argv)
{
    char drive[15];
    drive[0]=0;
    strncat(drive,argv[0],2);
    printf("drive - %s\n",drive);
    flname = "*.001";
    filefind(&flname);
    strcat(drive,flname);
    printf("zipfile to extract %s\n",drive);
    zipfn=drive;
    if (argc==1)
      argv[1] = "*.*";
    strcpy(flname,argv[1]);
    printf("file series to look for - %s\n",flname);
  /* allocate i/o buffers */
	inbuf = (byte *) (malloc(INBUFSIZ));
	outbuf = (byte *) (malloc(OUTBUFSIZ));
	if ((inbuf == NULL) || (outbuf == NULL)) {
      printf("Can't allocate buffers!\n");
      exit(1);
	}
  /* do the job... */
    extract_zipfile();
    printf( "Thththththththththat's all folks!\n" );
    exit(0);
}

