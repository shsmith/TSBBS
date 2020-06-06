
#include <stdio.h>   /*  your standard header for all C compiles */
#include <osbind.h>
#include <malloc.h>
#include <ctype.h>
#include <strings.h> /* this include defines strcpy, strcmp, etc. */
#include <fcntl.h>
#include <define.h> 
#include <stat.h>
#define ATARI_ST
#define strchr index

#define VERSION          \
"      ST_UNZIP: Zipfile Extract v2.70 of 11-22-89; by Arthur N. Cravener"
/* NOTE: ANSI C is supposed to concatinate adjacent string literals.    */
/* See "The C Programming Language (Second Edition)" section A2.6 pg194 */
/* by Brian W. Kernighan, Dennis M. Ritchie                             */
/* Prentice Hall Software Series                                        */
/* ISBN 0-13-110362-8, 0-13-110370-9                                    */
typedef unsigned char byte; /* code assumes UNSIGNED bytes */
typedef long longint;
#ifdef  ATARI_ST
typedef unsigned short word;
#else
typedef unsigned word;
#endif
typedef char boolean;

#define STRSIZ 256
#define MAXFILES 40
#define PATHSIZE 31
#define set_file_time() ;

/*
 * SEE HOST OPERATING SYSTEM SPECIFICS SECTION STARTING NEAR LINE 180
 *
 */


/*----------------------------------------------------------------------*/

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
}
local_file_header;


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
}
central_directory_file_header;


#define END_CENTRAL_DIR_SIGNATURE  0x06054b50L


typedef struct end_central_dir_record {
  word number_this_disk;
  word number_disk_with_start_central_directory;
  word total_entries_central_dir_on_this_disk;
  word total_entries_central_dir;
  longint size_central_directory;
  longint offset_start_central_directory;
  word zipfile_comment_length;
}
end_central_dir_record;



typedef struct _dt { /* My creation! DAW */
  unsigned realdate;
  unsigned realtime;
}
dt;

struct display_save {
         char                  Nameptr[14];
         long            unCompressed_size;  
         int            Compression_method; 
         char                 Comp_type[9];
         int                 stowageFactor;
         long              Compressed_size;
         int                           day;
         char                     month[4];
         int                          year;
         int                          hour;
         int                       minutes;    
         long                        CRC32;
         long                 total_offset;
         int               version_made_by;
         int     version_needed_to_extract;
         int      general_purpose_bit_flag;
         int            extra_field_length;
         int           file_comment_length;
         int               filename_length;
         int             disk_number_start;
         int      internal_file_attributes;
         long     external_file_attributes;
         int                 mod_file_time;
         int                 mod_file_date;
         struct display_save         *next;
         struct display_save        *prior;
         } list_entry;


/*----------------------------------------------------------------------*/
#define OUTBUFSIZ 0x2000                /* must be at least 2000 for unImplode */

#define INBUFSIZ 0xFFFE
 #define DLE 144


/*----------------------------------------------------------------------*/

/*
 * shrink/reduce working storage
 *
 */



#define max_bits 13
#define init_bits 9
#define hsize 8192
#define first_ent 257
#define clear 256



/*---------------------------------------------------------*/
      #define pagelen 22
      #define CONSOLE 2
      #define keypressed     Bconstat(CONSOLE)



      #define fun_arcview  'V'         
      #define enter_eq     "(Enter)="  
      #define option       ""          
      #define expert       TRUE        
      #define readkey      Cconin()
   /*   typedef struct { 
    *       int          pagelen;
    *  }  user_rec;
    */
/* ----------------------------------------------------------- */ 

/*
 * output stream variables for uzmore.c
 *
 */ 
   #define max_binary   50            /* non-printing count before binary file trigger */ 
   #define max_linelen  200          /* line length before binary file triggered */ 
/* ----------------------------------------------------------- */ 
/*
 * Host operating system details
 *
 */

#ifdef MSDOS
#include <io.h> 
#include <stdlib.h>    /* defines various standard library prototypes */ 
#endif
#ifdef AMIGA
struct ftime {
  unsigned ft_tsec : 5;
  unsigned ft_min : 6;
  unsigned ft_hour : 5;
  unsigned ft_day : 5;
  unsigned ft_month : 4;
  unsigned ft_year : 7;
};
#define setftime(a,b)
#endif
/*
  * this include file defines
  *             struct ftime ...        (* file time/date stamp info *)
  *             int setftime (int handle, struct ftime *ftimep);
  *             #define SEEK_CUR  1     (* lseek() modes *)
  *             #define SEEK_END  2
  *             #define SEEK_SET  0
  */

#ifdef AMIGA
#define O_BINARY 0x0000
#endif

#ifdef  ATARI_ST

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

/*#define O_BINARY   O_RAW*/

#define HIGH_LOW

struct ftime {
  unsigned ft_tsec : 5;
  unsigned ft_min : 6;
  unsigned ft_hour : 5;
  unsigned ft_day : 5;
  unsigned ft_month : 4;
  unsigned ft_year : 7;
};

#endif

/*
  * this include file defines
  *             #define O_BINARY 0x8000  (* no cr-lf translation *)
  * as used in the open() standard function
  */


#ifndef AMIGA
/* #include <sys/stat.h> */
#endif
/*
  * this include file defines
  *             #define S_IREAD 0x0100  (* owner may read *)
  *             #define S_IWRITE 0x0080 (* owner may write *)
  * as used in the creat() standard function
  */

#ifdef AMIGA
#define HIGH_LOW
#endif
/*
  * change 'undef' to 'define' if your machine stores high order bytes in
  * lower addresses.
  */

/*------------------------------------------------------------*/

/* macros to read bit buffer and output translated character */

#define OUTB(intc) {             \
        *outptr++=intc;          \
         if(++outcnt==OUTBUFSIZ) \
           FlushOutput();}

#define READBIT(nbits,zdest) {                       \
         if(nbits <= bits_left) {                    \
           zdest = (unsigned)(bitbuf & mask_bits[nbits]); \
           bitbuf >>= nbits;                         \
           bits_left -= nbits;                       \
         }else                                       \
           zdest = FillBitBuffer(nbits);}

/*----------------------------------------------------*/
extern int Nomore(),strpos();
extern void newline(),process_zipfile(),memcpy();
extern void List_head(),Action(),Verbose();
extern void flushbuf(),addchar(),not_text(),OutByte(); 
extern struct display_save *find_names();
extern unsigned ReadByte(), FillBitBuffer(), FillBuffer();
extern int create_output_file(), open_input_file();
extern void swap_bytes(), swap_lbytes(), usage(), print(),disclaimer();
extern void extract_zipfile(), FlushOutput(), LoadFollowers();
extern void unReduce(), unShrink(), partial_clear(), extract_members();
extern void process_local_file_header(), process_central_file_header();
extern void get_string(), process_end_central_dir(), process_headers();
extern int ListZipFile();
extern int DisplayHeaderRecord();
extern int DisplayTotals();
extern char *DisplayCompressionType(), *strupr();
extern char *DisplayMonthName(), *strrchr(), *strlwr(), *strpbrk();
