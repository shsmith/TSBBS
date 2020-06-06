#include <uzhdr.h>
#include <uzcursor.h>

extern byte *inbuf; /* input file buffer - any size is legal */
extern byte *inptr;
extern int incnt;
extern byte *outbuf; /* buffer for rle look-back */
extern byte *outptr;
extern unsigned bitbuf;
extern int bits_left;
extern char uoutbuf[];
extern long crc32val;
extern int i;
extern int linenum;
extern longint outpos; /* absolute position in outfile */
extern int outcnt; /* current position in outbuf */
extern int cp;
extern int cx;
extern char *path;
extern int outfd;
extern int zipfd;
extern int ispath;
extern char zipfn[13];
extern char filename[STRSIZ];
extern char ifilename[STRSIZ];
char temp[STRSIZ];
int linecount = 2;   
extern local_file_header lrec;
extern boolean xflag;
extern boolean find_file_fail;
extern boolean skip;
extern boolean overwrite;
extern boolean more; 
extern boolean cflag;
extern boolean pflag;
extern boolean iflag;
extern boolean vflag;
extern boolean def_pat;
extern boolean nomore;
extern boolean test;
extern boolean zipeof;
extern int cy;
extern int cx;
char *stradj();
char *strstr();
/*----------------------------------------------------------------------*/

void extract_zipfile(fullname)
char *fullname;
{
   /*
              * open the zipfile for reading and in BINARY mode to prevent cr/lf
              * translation, which would corrupt the bitstreams
              */

   if (open_input_file(fullname))
      abort("Could not open zipfile %s!",zipfn);

   process_headers(fullname);

   close(zipfd);
}

/*----------------------------------------------------------------------*/

/* return non-0 if creat failed */
int open_input_file(fullname)
char *fullname;
{
   /*
              * open the zipfile for reading and in BINARY mode to prevent cr/lf
              * translation, which would corrupt the bitstreams
              */

   zipfd = open(fullname, O_RDONLY | O_BINARY);
   if (zipfd < 1) {
      abort("Can't find: %s", fullname);
   }
   return 0;
}

/*----------------------------------------------------------------------*/

void process_headers(fullname)
char *fullname;
{
   long FileOffset;
   longint sig;

   while (1) {

      if (read(zipfd, (char *)&sig, sizeof(sig)) != sizeof(sig))
         return;

#ifdef HIGH_LOW
      swap_lbytes(&sig);
#endif

      if (sig == LOCAL_FILE_HEADER_SIGNATURE) {
         process_local_file_header(fullname);

         if(!xflag && strcmp(ifilename,filename) != 0){
            FileOffset = lrec.compressed_size;
            /* Jump to the next local file header */

            if(lseek(zipfd,FileOffset,SEEK_CUR) == -1){ 
               close(zipfd);
               abort("Invalid ZIP file format");
            }
         }

      }
      else if (sig == CENTRAL_FILE_HEADER_SIGNATURE) {
         if(test)
           abort("No more files in Zipfile ");
         else 
           process_central_file_header();
      }
      else if (sig == END_CENTRAL_DIR_SIGNATURE) {
         process_end_central_dir();
         if(find_file_fail){
            if(more){
               abort("No more files in Zipfile ");
            }
            else
               abort("Could not find : %s in Zipfile: %s ",ifilename,zipfn);
         }
         return;
      }
      else {
         abort("*Invalid Zipfile Header ");
      }
   }

}


/*----------------------------------------------------------------------*/

#ifndef ATARI_ST
/*
  * set the output file date/time stamp according to information from the
  * zipfile directory record for this file
  */

void set_file_time()
{
   union {
      long filetime;
      struct ftime ft; /* system file time record */
      struct {
         word ztime; /* date and time words */
         word zdate; /* .. same format as in .ZIP file */
      }
      zt;
   }
   td;

   /*
              * set output file date and time - this is optional and can be
              * deleted if your compiler does not easily support setftime()
              */

   td.zt.ztime = lrec.last_mod_file_time;
   td.zt.zdate = lrec.last_mod_file_date;

   /*#ifdef  ATARI_ST           */
   /*      chgft(outfd,td.filetime);*/
   /*#else                                          */
   /*        setftime(outfd, &td.ft);*/
   /*#endif                                                  */
}

#endif
/*----------------------------------------------------------------------*/
/* return non-0 if creat failed */

int create_output_file()
{
   skip = 0;
   strcpy(temp,filename);
   temp[(strlen(temp) + 1)] ='\0';
   if(ispath == 4){ /* if redirecting output with pathspec */
      char fix[STRSIZ];
      char *i,*rindex();
      strupr(strcpy(fix,path)); /* note path name template */
      if(!(i=rindex(fix,'\\'))) /* find start of name */
         if(!(i=rindex(fix,'/')))
            if(!(i=rindex(fix,':')))
               i = fix-1;
      strcpy(i+1,filename); /* replace template with name */
      if(!overwrite){
         FILE *f, *fopen();
         if(f=fopen(fix,"r")){ /* see if it exists */
            int c;
            fclose(f);
            clr_twentythree();
            pos_twentythree();
            fprintf(stdout,"\033pWARNING:\033q File %s exists!\07",fix);
            clr_cmdline();
            fflush(stdout);
            do{
               pos_twentyfour();
               fprintf(stdout,"Overwrite (y/n/q-uit)? \033e");
               fflush(stdout);
               c = toupper(Cconin());
               if(c == 81){
                  close(zipfd);
                  clr_cmdline();
                  clr_twentythree();
                  abort("Extraction aborted by user.");
               }
            }while(c != 89 && c != 78 && c !=81);
            clr_cmdline();
            clr_twentythree();
            cursor_off();
            if(c == 78){
               display_line("   Skipping: ",temp,linecount); 
               lseek(zipfd, lrec.compressed_size , SEEK_CUR);
               skip = 1;
               return (0);
            }
         }
      }
      outfd = open(fix, O_CREAT | O_RDWR | O_BINARY);
      if(outfd < 1) {
         abort("Check your path specification: %s\n", temp);
      }

                      /*
                       * close the newly created file and reopen it in BINARY mode to
                       * disable all CR/LF translations
                       */
      close(outfd);
      outfd = open(fix, O_RDWR | O_BINARY);
   }
   else{ /* else no pathspec given */
      if(!overwrite){
         FILE *f, *fopen();
         if(f=fopen(filename,"r")){ /* see if it exists */
            int c; 
            fclose(f);
            clr_twentythree();
            pos_twentythree();
            fprintf(stdout,"\033pWARNING:\033q File %s exists!\07",filename);
            clr_cmdline();
            fflush(stdout);
            do{
               pos_twentyfour(); 
               fprintf(stdout,"Overwrite (y/n/q-uit)? \033e");
               fflush(stdout);
               c = toupper(Cconin());
               if(c == 81){
                  close(zipfd);
                  clr_cmdline();
                  clr_twentythree();
                  abort("Extraction aborted by user.");
               }
            }while(c != 89 && c != 78 && c != 81);
             cursor_off();
             clr_cmdline();
             clr_twentythree();
             if(c == 78){
               display_line("   Skipping: ",filename,linecount); 
               lseek(zipfd, lrec.compressed_size, SEEK_CUR);
               skip = 1;
               return(0);
            }
         }
      }

      /* create the output file minus pathspec with READ and WRITE permissions */
      outfd = open(filename, O_CREAT | O_RDWR| O_BINARY);
      if (outfd < 1) {
         abort("Can't create output: %s\n", filename);
      }
                      /*
                       * close the newly created file and reopen it in BINARY mode to
                       * disable all CR/LF translations
                       */
      close(outfd);
      outfd = open(filename, O_RDWR | O_BINARY);
   }/* write a single byte at EOF to pre-allocate the file */

   lseek(outfd, lrec.uncompressed_size - 1L, SEEK_SET);
   write(outfd, "?", 1);
   lseek(outfd, 0L, SEEK_SET);
   return 0;

}

/*----------------------------------------------------------------------*/


void extract_member()
{
unsigned b;
int c;
char *firstchar;
bits_left = 0;
bitbuf = 0;
incnt = 0;
outpos = 0L;
outcnt = 0;
outptr = outbuf;
zipeof = 0;
crc32val = 0xFFFFFFFFL;

if(more && !def_pat){
  clr_view();
  pos_two();
  strcpy(uoutbuf, "\0"); 
  linenum = 1;
}

if(xflag || iflag){
  linecount++;
  if(linecount >= 23){
    pos_prompt(zipfn,"press any key for more files\07");
    fflush(stdout);
    Bconin(2);
    clr_display();
    linecount = 3;
  }
if(!test)  
 create_output_file(); /* create the output file with READ and WRITE permissions */
}
if(!skip){
  switch (lrec.compression_method) {
case 0:/* stored */
{
   if(xflag || iflag)
   {
     if(test)
     {
       display_line("    \033pTesting:\033q ",filename,linecount);
     }
     else
       display_line(" \033pExtracting:\033q ",temp,linecount);
   }
   while (ReadByte(&b))
      OUTB(b);
}
break;
 
case 1:
{
   if(xflag || iflag)
   {
     if(test)
     {
       display_line("    \033pTesting:\033q ",filename,linecount);
     }
     else
       display_line("\r\033pUnShrinking:\033q ",temp,linecount);
   }
   unShrink();
}
break;

case 2:
case 3:
case 4:
case 5:
{
   if(xflag || iflag)
   {
     if(test)
     {
       display_line("    \033pTesting:\033q ",filename,linecount);
     }
     else
       display_line("  \033pExpanding:\033q ",temp,linecount);
   }
   unReduce();
}
break;
case 6:
{
   if(xflag || iflag)
   {
     if(test)
     {
       display_line("    \033pTesting:\033q ",filename,linecount);
     }
     else
       display_line("  \033pExploding:\033q ",temp,linecount);
   }
   unImplode();
}
break;

default:
abort("Unknown compression method.\r");
}

if(more && !def_pat){
  return;
}

if(nomore)
  return;
/* write the last partial buffer, if any */
if (outcnt > 0) 
   {
     UpdateCRC(outbuf, outcnt);
     if(cflag)
       {
         write(fileno(stdout),outbuf,outcnt);
       }
     if(pflag)
       {
         write(STDPRT,outbuf,outcnt);
       }
    else
       {
         if(!test)
         write(outfd, outbuf, outcnt);
       }
   }

/* set output file date and time */
set_file_time();

close(outfd);
crc32val = -1 - crc32val;
if(test)
  {
    if (crc32val == lrec.crc32)
       {
         display_crc(" Actual: CRC",crc32val,"  OK!",linecount );
       }
    if (crc32val != lrec.crc32)
       {
         display_badcrc(" Actual: CRC",crc32val,"  \033pshould be:\033q",
                             lrec.crc32,linecount ); 
       }
  }
  else
     {
       if (crc32val != lrec.crc32)
          display_badcrc(" Actual: CRC",crc32val,"  \033pshould be:\033q",lrec.crc32,linecount );
     }                      

  }
}




/*----------------------------------------------------------------------*/

#ifdef HIGH_LOW

/* convert intel style 'short int' variable to host format */
void swap_bytes(wordp)
word *wordp;
{
   char *charp = (char *) wordp;
   char temp;

   temp = charp[0];
   charp[0] = charp[1];
   charp[1] = temp;
}

/*----------------------------------------------------------------------*/

/* convert intel style 'long' variable to host format */
void swap_lbytes(longp)
longint *longp;
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



/*----------------------------------------------------------------------*/

/* fill input buffer if possible */
unsigned FillBuffer()
{
   unsigned readsize;

   if (lrec.compressed_size <= 0)
      return incnt = 0;

   if (lrec.compressed_size > INBUFSIZ)
      readsize = INBUFSIZ;
   else
      readsize = (unsigned) lrec.compressed_size;
   incnt = (unsigned)read(zipfd, inbuf, readsize);

   lrec.compressed_size -= incnt;
   inptr = inbuf;
   return incnt--;
}

/*----------------------------------------------------------------------*/

/* read a byte; return 8 if byte available, 0 if not */
unsigned ReadByte(x)/*arthur*/
unsigned *x;
{
   if (incnt-- == 0)
      if (FillBuffer() == 0)
         return 0;

   *x = *inptr++;
   return 8;
}

/*----------------------------------------------------------------------*/


/* flush contents of output buffer */
void FlushOutput()
{
   int c;
   char *firstchar;
   UpdateCRC(outbuf, outcnt);
   if(cflag){
      write(fileno(stdout),outbuf,outcnt);
   }
   if(pflag){
      write(STDPRT,outbuf,outcnt);
   }
   else{
      if(!test)
      write(outfd, outbuf, outcnt);
   }

   outpos += outcnt;
   outcnt = 0;
   outptr = outbuf;
}

void skip_rest() 
{ 
   lseek(zipfd, lrec.compressed_size - outcnt, SEEK_CUR); 
   zipeof = 1;
   lrec.compressed_size = 0; 
   incnt = 0;
   outcnt = 0; 
}

void skip_csize() 
{ 
   outcnt = 0;
   incnt = 0; 
   skip_rest(); 
}

