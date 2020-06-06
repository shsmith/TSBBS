/*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 */

/*
 * UnZip - A simple zipfile extract utility
 *
 *
 * 24-July-89 Modified for OS/2 support Malcolm Greenhalgh
 *            changes made to 'setftime' function.
 */ 

#define version  "UnZip:  Zipfile Extract v1.1á/ý of 24-07-89;  (C) 1989 S.H.Smith"

typedef unsigned char byte;
typedef long longint;
typedef unsigned word;
typedef char boolean;
#define STRSIZ  256

#include <fcntl.h>
#include <sys/types.h>      //...   MCG 24-07-89 for OS/2 version
#include <sys/stat.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>

#define INCL_DOSFILEMGR     //...   MCG 24-07-89 for OS/2 version
#define INCL_SUB            //...   MCG 24-07-89 for OS/2 version
#include <os2.h>            //...   MCG 24-07-89 for OS/2 version


/* ----------------------------------------------------------- */ 
/*
 * Zipfile layout declarations
 *
 */ 

   typedef longint       signature_type;


   #define local_file_header_signature  0x04034b50L


   typedef struct local_file_header { 
      word         version_needed_to_extract; 
      word         general_purpose_bit_flag; 
      word         compression_method; 
      word         last_mod_file_time; 
      word         last_mod_file_date; 
      longint      crc32; 
      longint      compressed_size; 
      longint      uncompressed_size; 
      word         filename_length; 
      word         extra_field_length; 
   } local_file_header; 


   #define cntrl_file_header_signature  0x02014b50L


   typedef struct cntrl_dir_file_header {
      word         version_made_by; 
      word         version_needed_to_extract; 
      word         general_purpose_bit_flag; 
      word         compression_method; 
      word         last_mod_file_time; 
      word         last_mod_file_date; 
      longint      crc32; 
      longint      compressed_size; 
      longint      uncompressed_size; 
      word         filename_length; 
      word         extra_field_length; 
      word         file_comment_length; 
      word         disk_number_start; 
      word         internal_file_attributes; 
      longint      external_file_attributes; 
      longint      relative_offset_local_header; 
   } cntrl_dir_file_header;


   #define end_cntrl_dir_signature  0x06054b50L


   typedef struct end_cntrl_dir_record {
      word         number_this_disk; 
      word         number_disk_with_strt_cntrl_dir;
      word         total_entries_cntrl_dir_on_disk;
      word         total_entries_cntrl_dir;
      longint      size_cntrl_dir;
      longint      offset_start_cntrl_dir;
      word         zipfile_comment_length; 
   } end_cntrl_dir_record;



/* ----------------------------------------------------------- */ 
/*
 * input file variables
 *
 */ 


   #define           uinbufsize    512L   /* input buffer size */
   byte              inbuf[uinbufsize];

   boolean           zipeof;
   longint           csize;
   longint           cusize;
   int               cmethod;
   int               inpos;
   int               incnt;
   int               pc;
   int               pcbits;
   int               pcbitv;
   
   int               zipfd;
   char              zipfn[STRSIZ];
   local_file_header lrec;
   FILESTATUS        fistat;
   USHORT            filevel;



/* ----------------------------------------------------------- */ 
/*
 * output stream variables
 *
 */ 


   byte     outbuf[4096];   /* for rle look-back */
   longint  outpos;         /* absolute position in outfile */
   int      outcnt;

   int      outfd;
   char     filename[STRSIZ];
   char     extra[STRSIZ];



/* ----------------------------------------------------------- */ 
/*
 * shrink/reduce working storage
 *
 */ 


   int      factor;
   byte     followers[256][64];
   byte     Slen[256];
   int      ExState;
   int      C;
   int      V;
   int      Len;

   #define max_bits      13
   #define init_bits     9
   #define hsize         8192
   #define first_ent     257
   #define clear         256

   typedef int  hsize_array_integer[hsize+1];
   typedef byte hsize_array_byte[hsize+1];

   hsize_array_integer prefix_of;
   hsize_array_byte    suffix_of;
   hsize_array_byte    stack;

   int      cbits;
   int      maxcode;
   int      free_ent;
   int      maxcodemax;
   int      offset;
   int      sizex;


/* ------------------------------------------------------------- */ 

void         skip_csize(void)
{ 
   lseek(zipfd,csize,SEEK_CUR);
   zipeof = 1;
   csize = 0L; 
   incnt = 0; 
} 


/* ------------------------------------------------------------- */ 

void         ReadByte(int *       x)
{ 
   if (incnt == 0) 
   { 
      if (csize == 0L) 
      { 
         zipeof = 1;
         return;
      } 

      inpos = sizeof(inbuf);
      if (inpos > csize) 
         inpos = (int)csize;
      incnt = read(zipfd,inbuf,inpos);

      inpos = 1; 
      csize -= incnt; 
   } 

   *x = inbuf[inpos-1]; 
   inpos++; 
   incnt--; 
} 


/* ------------------------------------------------------------- */ 

void         ReadBits(int      bits,
                      int *    x)
     /* read the specified number of bits */ 
{ 
   int      bit;
   int      bitv;

   *x = 0;
   bitv = 1;

   for (bit = 0; bit <= bits-1; bit++)
   { 

      if (pcbits > 0) 
      { 
         pcbits--; 
         pcbitv = pcbitv << 1; 
      } 
      else 

      { 
         ReadByte(&pc); 
         pcbits = 7; 
         pcbitv = 1; 
      } 

      if ((pc & pcbitv) != 0) 
         *x = *x | bitv; 

      bitv = (int) (bitv << 1);
   } 

} 


/* ---------------------------------------------------------- */ 

void         get_string(int      len,
                        char *   s)
{ 
   read(zipfd,s,len);
   s[len] = 0;
} 


/* ------------------------------------------------------------- */ 

void         OutByte(int      c)
   /* output each character from archive to screen */ 
{ 
   outbuf[outcnt /* outpos % sizeof(outbuf) */] = c;
   outpos++; 
   outcnt++;
 
   if (outcnt == sizeof(outbuf)) 
   { 
      write(outfd,outbuf,outcnt);
      outcnt = 0; 
      printf("."); 
   } 
} 


/* ----------------------------------------------------------- */
   
int         reduce_L(int         x)
   { 
      switch (factor) {
         case 1:   return x & 0x7f; 
         case 2:   return x & 0x3f; 
         case 3:   return x & 0x1f; 
         case 4:   return x & 0x0f; 
      } 
    return 0; /* error */
   } 

   
int         reduce_F(int         x)
   { 
      switch (factor) {
         case 1:   if (x == 127) return 2;  else return 3;
         case 2:   if (x == 63) return 2;   else return 3;
         case 3:   if (x == 31) return 2;   else return 3;
         case 4:   if (x == 15) return 2;   else return 3;
      } 
    return 0; /* error */
   } 

   
int         reduce_D(int         x,
                     int         y)
   { 
      switch (factor) {
         case 1:   return ((x >> 7) & 0x01) * 256 + y + 1; 
         case 2:   return ((x >> 6) & 0x03) * 256 + y + 1; 
         case 3:   return ((x >> 5) & 0x07) * 256 + y + 1; 
         case 4:   return ((x >> 4) & 0x0f) * 256 + y + 1; 
      } 
    return 0; /* error */
   } 


int         reduce_B(int         x)
        /* number of bits needed to encode the specified number */ 
   { 
      switch (x - 1) {
         
         case 0:   
         case 1:   return 1; 
         
         case 2:   
         case 3:   return 2; 
         
         case 4:
         case 5:   
         case 6:   
         case 7:   return 3; 
         
         case 8:   
         case 9:   
         case 10:   
         case 11:   
         case 12:   
         case 13:   
         case 14:   
         case 15:   return 4; 
        
         case 16:
         case 17:
         case 18:
         case 19:
         case 20:
         case 21:
         case 22:
         case 23:
         case 24:
         case 25:
         case 26:
         case 27:
         case 28:
         case 29:
         case 30:
         case 31:   return 5;
        
         case 32:
         case 33:
         case 34:
         case 35:
         case 36:
         case 37:
         case 38:
         case 39:
         case 40:
         case 41:
         case 42:
         case 43:
         case 44:
         case 45:
         case 46:
         case 47:
         case 48:
         case 49:
         case 50:
         case 51:
         case 52:
         case 53:
         case 54:
         case 55:
         case 56:
         case 57:
         case 58:
         case 59:
         case 60:
         case 61:
         case 62:
         case 63:   return 6;

         case 64:
         case 65:
         case 66:
         case 67:
         case 68:
         case 69:
         case 70:
         case 71:
         case 72:
         case 73:
         case 74:
         case 75:
         case 76:
         case 77:
         case 78:
         case 79:
         case 80:
         case 81:
         case 82:
         case 83:
         case 84:
         case 85:
         case 86:
         case 87:
         case 88:
         case 89:
         case 90:
         case 91:
         case 92:
         case 93:
         case 94:
         case 95:
         case 96:
         case 97:
         case 98:
         case 99:
         case 100:
         case 101:
         case 102:
         case 103:
         case 104:
         case 105:
         case 106:
         case 107:
         case 108:
         case 109:
         case 110:
         case 111:
         case 112:
         case 113:
         case 114:
         case 115:
         case 116:
         case 117:
         case 118:
         case 119:
         case 120:
         case 121:
         case 122:
         case 123:
         case 124:
         case 125:
         case 126:
         case 127:   return 7;
      
      default:       return 8;
      } 
   } 



/* ----------------------------------------------------------- */

void         Expand(int      c)
   { 
      #define DLE           144
   
      switch (ExState) {
           
           case 0:
               if (c != DLE)
                   OutByte(c);
               else 
                   ExState = 1; 
           break; 
           
           case 1:
               if (c != 0)
               { 
                   V = c; 
                   Len = reduce_L(V);
                   ExState = reduce_F(Len);
               } 
               else 
               { 
                   OutByte(DLE); 
                   ExState = 0; 
               } 
           break; 
           
           case 2:   { 
                  Len = Len + c; 
                  ExState = 3; 
               } 
           break; 
           
           case 3:   { 
                  int i;
                  longint offset = reduce_D(V,c);
                  longint op = outpos - offset;

                  for (i = 0; i <= Len + 2; i++) 
                  { 
                     if (op < 0L) 
                        OutByte(0);
                     else 
                        OutByte(outbuf[(int)(op % sizeof(outbuf))]);
                     op++; 
                  } 

                  ExState = 0; 
               } 
         break;
      } 
   } 


/* ----------------------------------------------------------- */
   
void         LoadFollowers(void)
   { 
      int      x;
      int      i;
      int      b;

      for (x = 255; x >= 0; x--) 
      { 
         ReadBits(6,&b); 
         Slen[x] = b;

         for (i = 0; i < Slen[x]; i++)
         { 
            ReadBits(8,&b); 
            followers[x][i] = b;
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
 *
 */ 

void         unReduce(void)
     /* expand probablisticly reduced data */ 

   { 

   int    lchar;
   int    lout;
   int    I;

   factor = cmethod - 1; 
   if ((factor < 1) || (factor > 4)) 
   { 
      skip_csize(); 
      return;
   } 

   ExState = 0; 
   LoadFollowers(); 
   lchar =  0;

   while ((!zipeof) && (outpos < cusize))
   { 

      if (Slen[lchar] == 0)
         ReadBits(8,&lout);
      else 

      { 
         ReadBits(1,&lout); 
         if (lout != 0) 
            ReadBits(8,&lout);
         else 
         { 
            ReadBits(reduce_B(Slen[lchar]),&I);
            lout = followers[lchar][I];
         } 
      } 

      Expand(lout); 
      lchar = lout; 
   } 
} 


/* ------------------------------------------------------------- */
/*
 * Shrinking is a Dynamic Ziv-Lempel-Welch compression algorithm
 * with partial clearing.
 *
 */ 

void         partial_clear(void)
{ 
   int      pr;
   int      cd;


   /* mark all nodes as potentially unused */
   for (cd = first_ent; cd < free_ent; cd++)
      prefix_of[cd] |= 0x8000;


   /* unmark those that are used by other nodes */
   for (cd = first_ent; cd < free_ent; cd++)
   { 
      pr = prefix_of[cd] & 0x7fff;   /* reference to another node? */ 
      if (pr >= first_ent)           /* flag node as referenced */
         prefix_of[pr] &= 0x7fff;
   } 


   /* clear the ones that are still marked */ 
   for (cd = first_ent; cd < free_ent; cd++)
      if ((prefix_of[cd] & 0x8000) != 0) 
         prefix_of[cd] = -1;


   /* find first cleared node as next free_ent */ 
   free_ent = first_ent; 
   while ((free_ent < maxcodemax) && (prefix_of[free_ent] != -1)) 
      free_ent++; 
} 


/* ------------------------------------------------------------- */

void         unShrink(void)

{ 
   int      stackp;
   int      finchar;
   int      code;
   int      oldcode;
   int      incode;


   /* decompress the file */ 
   maxcodemax = 1 << max_bits; 
   cbits = init_bits; 
   maxcode = (1 << cbits) - 1; 
   free_ent = first_ent; 
   offset = 0; 
   sizex = 0; 

   for (code = maxcodemax; code > 255; code--)
      prefix_of[code] = -1;

   for (code = 255; code >= 0; code--) 
   { 
      prefix_of[code] = 0;
      suffix_of[code] = code;
   } 

   ReadBits(cbits,&oldcode); 
   if (zipeof) return;
   finchar = oldcode; 

   OutByte(finchar); 

   stackp = 0; 

   while ((!zipeof)) 
   { 
      ReadBits(cbits,&code); 
      if (zipeof) return;

      while (code == clear)
      { 
         ReadBits(cbits,&code); 

         switch (code) {
            
            case 1:   { 
                  cbits++; 
                  if (cbits == max_bits) 
                     maxcode = maxcodemax;
                  else 
                     maxcode = (1 << cbits) - 1; 
               } 
            break;

            case 2:
                  partial_clear();
            break;
         } 

         ReadBits(cbits,&code); 
         if (zipeof) return;
      } 

   
      /* special case for KwKwK string */
      incode = code;
      if (prefix_of[code] == -1)
      { 
         stack[stackp] = finchar;
         stackp++; 
         code = oldcode; 
      } 


      /* generate output characters in reverse order */
      while (code >= first_ent)
      { 
         stack[stackp] = suffix_of[code];
         stackp++; 
         code = prefix_of[code];
      } 

      finchar = suffix_of[code];
      stack[stackp] = finchar;
      stackp++; 


      /* and put them out in forward order */
      while (stackp > 0)
      { 
         stackp--; 
         OutByte(stack[stackp]);
      } 


      /* generate new entry */
      code = free_ent;
      if (code < maxcodemax) 
      { 
         prefix_of[code] = oldcode;
         suffix_of[code] = finchar;
         while ((free_ent < maxcodemax) && (prefix_of[free_ent] != -1))
            free_ent++;
      } 


      /* remember previous code */
      oldcode = incode; 
   } 

} 

/* ---------------------------------------------------------- */
//...   MCG 24-07-89 for OS/2 version

static int setftime(fn, fd, ft)
   char *fn;
   unsigned fd, ft;
{
   USHORT   eact;
   HDIR     ehand;
   unsigned eflag = 0x01, emode = 0x42;

   if (DosOpen(fn, &ehand, &eact, 0L, 0, eflag, emode, 0L))
      return (1);

   /* set output file date and time ; modified MCG OS/2 */
   filevel = 1;
   DosQFileInfo (ehand,filevel,&fistat,sizeof(fistat));
   fistat.fdateLastWrite.day   = (fd & 0x1F);
   fistat.fdateLastWrite.month = ((fd >> 5) & 0xF);
   fistat.fdateLastWrite.year  = (fd >> 9);
   fistat.ftimeLastWrite.twosecs = (ft & 0x1F);
   fistat.ftimeLastWrite.minutes = ((ft >> 5) & 0x2F);
   fistat.ftimeLastWrite.hours   = (ft >> 11);
   if (DosSetFileInfo (ehand,filevel,&fistat,sizeof(fistat)))
      return(2);
   return(0);
}

/* ---------------------------------------------------------- */ 

void         extract_member(void)
{ 
   int    b;

   union {
        // struct ftime ft;
        struct {
            word ztime;
            word zdate;
        } zt;
    } td;

for (b=0; b<sizeof(outbuf); b++) outbuf[b]=0;
   pcbits = 0; 
   incnt = 0; 
   outpos = 0L; 
   outcnt = 0; 
   zipeof = 0;

   outfd = creat(filename,S_IWRITE|S_IREAD);
   if (outfd < 1)
   { 
      printf("Can't create output: %s\n",filename); 
      exit(0);
   } 

   close(outfd);
   outfd = open(filename,O_RDWR|O_BINARY);


   switch (cmethod) {
      
      case 0:     /* stored */ 
            { 
               printf(" Extract: %s ...",filename); 
               while ((!zipeof)) 
               { 
                  ReadByte(&b); 
                  OutByte(b); 
               } 
            } 
      break; 
      
      case 1:   { 
               printf("UnShrink: %s ...",filename); 
               unShrink(); 
            } 
      break; 
      
      case 2:   
      case 3:   
      case 4:   
      case 5:   { 
               printf("  Expand: %s ...",filename); 
               unReduce(); 
            } 
      break; 
      
      default: printf("Unknown compression method."); 
   } 

   if (outcnt > 0) 
      write(outfd,outbuf,outcnt);
   close(outfd);
   setftime(filename,lrec.last_mod_file_date,lrec.last_mod_file_time);
   printf("  done.\n"); 
} 


/* ---------------------------------------------------------- */ 

void         process_local_file_header(void)
{ 
   read(zipfd,&lrec,sizeof(lrec));
   get_string(lrec.filename_length,filename);
   get_string(lrec.extra_field_length,extra);
   csize = lrec.compressed_size;
   cusize = lrec.uncompressed_size;
   cmethod = lrec.compression_method;
   extract_member(); 
} 


/* ---------------------------------------------------------- */ 

void         process_cntrl_file_header(void)
{ 
   cntrl_dir_file_header rec;
   char filename[STRSIZ];
   char extra[STRSIZ];
   char comment[STRSIZ];

   read(zipfd,&rec,sizeof(rec));
   get_string(rec.filename_length,filename); 
   get_string(rec.extra_field_length,extra); 
   get_string(rec.file_comment_length,comment); 
} 


/* ---------------------------------------------------------- */ 

void         process_end_cntrl_dir(void)
{ 
   end_cntrl_dir_record rec;
   char comment[STRSIZ];

   read(zipfd,&rec,sizeof(rec));
   get_string(rec.zipfile_comment_length,comment); 
} 


/* ---------------------------------------------------------- */ 

void         process_headers(void)
{ 
   longint sig;

   while (1)
   { 
      if (read(zipfd,&sig,sizeof(sig)) != sizeof(sig))
         return;
      else 

      if (sig == local_file_header_signature) 
         process_local_file_header();
      else 

      if (sig == cntrl_file_header_signature)
         process_cntrl_file_header();
      else 

      if (sig == end_cntrl_dir_signature)
      { 
         process_end_cntrl_dir();
         return;
      } 

      else 
      { 
         printf("Invalid Zipfile Header\n"); 
         return;
      } 
   } 

} 


/* ---------------------------------------------------------- */ 

void         extract_zipfile(void)
{ 
   zipfd = open(zipfn,O_RDONLY|O_BINARY);
   if (zipfd < 1) {
      printf("Can't open input file: %s\n",zipfn);
      return;
   }

   process_headers();
 
   close(zipfd);
} 


/* ---------------------------------------------------------- */
/*
 * main program
 *
 */ 

void main(int argc, char **argv)
{
   char *courtesy = "Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.\n\n";
   VioWrtTTy(version, strlen(version), 0);
   VioWrtTTy(courtesy, strlen(courtesy), 0);
 
   if (argc != 2)
   { 
      VioWrtTTy("Usage:  UnZip FILE[.zip]\n", 25, 0);
      DosExit(0,1);
   } 

   strcpy(zipfn,argv[1]);
   if (strchr(zipfn,'.') == NULL)
      strcat(zipfn,".ZIP");

   extract_zipfile(); 
   DosExit(0,1);
}
