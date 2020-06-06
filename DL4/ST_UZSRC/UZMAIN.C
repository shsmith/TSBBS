#include <uzhdr.h>
#include <uzcursor.h>
char *list_head[] = {
   "Name           Length   Stowage    SF   Size now    Date      Time     CRC      ",
   "============  ========  ========  ====  ========  =========  ======  ========   "};


char *Disclaimer[] = {
   "                                                                              ",
   "   IN NO EVENT WILL I BE LIABLE TO YOU FOR ANY DAMAGES, INCLUDING ANY LOST    ",
   "      PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES      ",
   "     ARISING OUT OF YOUR USE OR INABILITY TO USE THE PROGRAM, OR FOR ANY      ",
   "                          CLAIM BY ANY OTHER PARTY.                           ",
   "       Continuing development by.........................Arthur Cravener      ",
   "                                                                              ", 
   "      \033p Please contribute to the continuing development of this program. \033q      ",
   "                                                                              ", 
   "            The suggested contribution is the equivalent of $10.00            ",
   "              (US dollars).  Deutsch marks, francs, roubles, and              ",
   "                       other monetary units are welcome.                      ",
   "                                  Send to:                                    ",
   "                               Arthur Cravener                                ",
   "                             1256 Church Street                               ",
   "                             Reading, PA  19601                               ",
   "                                   U.S.A.                                     ",
   "               Thank-you and I hope you find this program useful.             ",
   "             =====================================================            "};





char *instructions[] = {
   "                                                                              ",
   "    \033qUsage: st_unzip {command[option]} <zipfile[.zip]> [<file>] [<to path>]\033p    ",
   "                                                                              ",
   "  <to path> must contain trailing back (or forward) slash. ex: c:\\, c:\\foo\\   ",
   "                                Commands:                                     ",
   "  -------------------------------------------------------------------------   ",
   " | \033qc[m]= extract text file to screen\033p \033qp   = extract text file to printer   \033p |  ",
   " | \033qx[o]= extract all files          \033p \033qi[o]= extract individual file to disk\033p |  ",
   " | \033qv   = verbose list to screen     \033p \033qt   = test zipfile crc integrity     \033p |  ",
   "  -------------------------------------------------------------------------   ",
   "          Commands contained in [brackets] are optional...examples:           ",
   "   xo foo.zip         = extracts all from foo.zip and overwrites any files    ",
   "                        with same name that are already on disk.              ",
   "   cm foo.zip         = displays all files available in foo.zip then steps    ",
   "                        to each file and prompts:                             ",
   "                        (N)ext (V)iew (R)elist/(O)ne (Q)uit:                  ",
   "                        The <m> option will also display a sorted filename    ", 
   "                        list, do an individual verbose of a file record, and  ",
   "                        more!                                                 ",
   "   i  foo.zip fee.prg = extracts file  fee.prg from foo.zip and warns if      ",
   "                        file with same name already exists.                   ", 
   "             Read documentation for detailed usage instructions.              ",
   "                                                                              "};

/*
 * input file variables
 *
 */
#
byte *inbuf; /* input file buffer - any size is legal */
byte *inptr;

int incnt;
unsigned bitbuf;
unsigned bits_left;/*arthur*/
boolean zipeof;

int zipfd;
char zipfn[13];
local_file_header lrec;
central_directory_file_header rec;
struct display_save *start;
struct display_save *last;

/*----------------------------------------------------------------------*/

/*
 * output stream variables
 *
 */

byte *outbuf; /* buffer for rle look-back */
byte *outptr;

longint outpos; /* absolute position in outfile */
int outcnt; /* current position in outbuf */
int ispath;

char *path;
int outfd;
char filename[STRSIZ];
char ifilename[STRSIZ];
char extra[STRSIZ];
boolean more = 0;
boolean cflag = 0;
boolean pflag = 0;
boolean iflag = 0;
boolean vflag = 0;
boolean xflag = 0;
boolean test = 0;
boolean find_file_fail = 0;
boolean overwrite = 0;
boolean skip = 0;
boolean header_present = 0;
boolean expand_files = 0;
boolean def_pat = 0;
boolean nomore = 0;
extern boolean flist;
extern boolean verbose;
int cw = 15; /* cw-cp-cy-cx--these are cursor positions */
int cp = 24;
int cy = 23;
int cx = 0;
char *splitpat();
/*----------------------------------------------------------------------*/

/*
 * main program
 *
 */

void main(argc,argv)
int argc;
char *argv[];
{
   char *a; 
   char *index();
   char *substr();
   int n;
   char fullname[STRSIZ];
   char temp[STRSIZ];
   char opt = 0; /* selected action */   

#ifdef ATARI_ST
   int buffer_fail = 0;
#endif 
   start = last = NULL;

   pos_home();
   fprintf(stdout,"%s",VERSION); 
   fflush(stdout);
   overwrite = 0;
   if (argc < 3) {
      disclaimer();
      fprintf(stdout,"\033p");
      usage();
      fprintf(stdout,"\033q");
      fflush(stdout);
      abort("\033pThanks Sam Smith for getting me going \033q");
   }
   fprintf(stdout,"\033e");

   /* .ZIP default if none provided by user */
   strcpy(fullname,strupr(argv[2]));
   if (strchr(fullname, '.') == NULL)
      strcat(fullname, ".ZIP");

   n = strrpos(fullname,'\\');
   substr(zipfn,fullname,n+1,strlen(fullname));

   /* allocate i/o buffers */
   inbuf = (byte *) (malloc(INBUFSIZ));
   outbuf = (byte *) (malloc(OUTBUFSIZ));
   if ((inbuf == NULL) || (outbuf == NULL)) {
      abort("Can't allocate buffers!");
   }
   strupr(argv[1]);
   for(a=argv[1]; *a; a++) /* scan the option flags */
   { 
      if(index("XPCVIT",*a)) /* if a known command */
      { 
         if(opt) /* do we have one yet? */
            abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,*a);
         opt = *a; /* else remember it */
      }
      else if(*a=='O') /* overwrite existing files */
         overwrite = 1;

      else if(*a=='M')/* output to screen with prompt for more */
         more = 1;

      else if (*a=='-') /* UNIX option marker */
         ;

      else abort("\033p %c \033q is an unknown command",*a);
   }
   if(!opt){
      abort(" I have nothing to do!");
   }
   switch(opt){
   case 'T':
     if(more){
       char a;
       a = 'M';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      if(overwrite){
       char b;
       b = 'O';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,b);
      }else
       xflag = 1;
       test = 1;
       pos_zipfn();
       fprintf(stdout,"\033pZipfile: %s\033q\033B\033l",zipfn);
       fflush(stdout);
       pos_three();
       fprintf(stdout,"----------------------------------------------------------------------------\n");
       fflush(stdout);
       extract_zipfile(fullname);
       break;  
   case 'V':/* verbose list of files within zipfile */
     if(more){
       char a;
       a = 'M';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      find_file_fail = 0;
      vflag = 1;
      ListZipFile(fullname);
      abort("Verbose listing complete. ");
      break;
   case 'C':/*list a file within a zipfile to stdout */
      if(overwrite){
       char a;
       a = 'O';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      if(more){
         process_zipfile(fullname);
         abort("More complete. ");
      }
      find_file_fail = 1;
      cflag = 1;
      if(argc < 4)
         abort("\033pname\033q missing, ex: {c zipfile \033p foo.txt \033q}");
      strupr(strcpy(ifilename, argv[3]));
      clr_cmdline();
      fprintf(stdout,"Searching for %s in",ifilename);
      ListZipFile(zipfn);
      abort("End of text file ");
      break; 
   case 'P':/*list a file within a zipfile to printer */
      if(more){
       char a;
       a = 'M';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      if(argc < 4)
         abort("\033pname\033q missing, ex: {p zipfile \033p foo.doc \033q}");
      strupr(strcpy(ifilename, argv[3]));
      fprintf(stdout,"Searching for \033p %s \033q in\n",ifilename);
      find_file_fail = 1;
      pflag = 1;
      ListZipFile(zipfn);
      abort("Printing complete.");
      break; 
   case 'I':/*extract individual file within zipfile to disk */
      if(more){
       char a;
       a = 'M';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      if(argc < 4){
         abort("\033pname\033q missing, ex: {i zipfile \033p foo.com \033q}");
      }
      strupr(strcpy(ifilename, argv[3]));
      if(argc == 5){
         ispath = (argc -1);
         path = argv[4];
      }
      clr_cmdline();
      fprintf(stdout,"Looking for \033p %s \033q in %s",ifilename,zipfn);
      fflush(stdout);
      find_file_fail = 1;
      iflag = 1;
      ListZipFile(zipfn);
      abort("File extracted. ");
      break;
   case 'X':/*extract _all_ files within zipfile to disk */
      if(more){
       char a;
       a = 'M';
       abort("Cannot mix \033p %c \033 and \033p %c \033q",opt,a);
      }else
      if(argc == 4){
         ispath = argc;
         path = argv[3];
      }
      find_file_fail = 0;
      xflag = 1;
      pos_zipfn();
      fprintf(stdout,"\033pZipfile: %s\033q\033B\033l",zipfn);
      fflush(stdout);
      pos_three();
      fprintf(stdout,"----------------------------------------------------------------------------\n");
      fflush(stdout);
      extract_zipfile(fullname);
      break;
   default:
      abort("I don't know how to do \033p %c \033q yet!",opt);
   }
   abort("Extraction completed. ");
}



/*----------------------------------------------------------------------*/


void get_string(len,s)
int len;
char *s;
{
   read(zipfd, s, len);
   s[len] = 0;
}


/*----------------------------------------------------------------------*/


void process_local_file_header(fullname)
char *fullname;
{
   read(zipfd, (char *)&lrec, sizeof(lrec));

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
#endif
   get_string(lrec.filename_length, filename);
   if(xflag){
      get_string(lrec.extra_field_length, extra);
      extract_member(fullname);
   }
   if(vflag){
      DisplayHeaderRecord(zipfn,lrec,filename);
   }
   if(more && def_pat){
      find_names();
   }

   if((!xflag || !vflag) && strcmp(ifilename,filename) == 0){
      extract_member(fullname);
      if(more){
         def_pat = 1;
         flist = 1;
         return; 
      }
      if(cflag && !more)
        abort("End of file ");
      if(iflag)
        abort("File extracted ");
   }



}


/*----------------------------------------------------------------------*/


void process_central_file_header()
{
   central_directory_file_header rec;
   struct display_save *info,*sl_store();
   int Month,
   Day,
   Year,
   Hour,
   Minutes,
   StowageFactor;
   long SizeReduction;
   char filename[STRSIZ];
   char extra[STRSIZ];
   char comment[STRSIZ];
   char *mOnth,*comp_type;

   info = (struct display_save *)malloc(sizeof(list_entry));
   if(!info){
      abort("Out of memory! ");
   }

   read(zipfd, (char *)&rec, sizeof(rec));

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
#endif

   get_string(rec.filename_length, filename);
   get_string(rec.extra_field_length, extra);
   get_string(rec.file_comment_length, comment);



   if(more){ 

      if(rec.uncompressed_size == 0) {
         StowageFactor = 0;
      }
      else {
         if(rec.compressed_size <= rec.uncompressed_size) {
            SizeReduction = rec.uncompressed_size - rec.compressed_size;
            if(SizeReduction == 0L) {
               StowageFactor = 0;
            }
            else {
               SizeReduction = SizeReduction * 100L + 50;
               StowageFactor = (int)(SizeReduction/rec.uncompressed_size);
            }
         }
         else {
            SizeReduction = rec.compressed_size - rec.uncompressed_size;
            SizeReduction = SizeReduction * 100L + 50;
            StowageFactor = (int)(SizeReduction/rec.uncompressed_size);
            StowageFactor *= -1;
         }
      }
      if(StowageFactor >= 100) {
         StowageFactor = 0;
      }

      Month = (lrec.last_mod_file_date >> 5) & 0x0f;
      Day = lrec.last_mod_file_date & 0x1f;
      Year = ((lrec.last_mod_file_date >> 9) & 0x7f) + 80;

      if(lrec.last_mod_file_time > 0) {
         Hour = (lrec.last_mod_file_time >> 11) & 0x1f;
         Minutes = (lrec.last_mod_file_time >> 5) & 0x3f;
      }
      else {
         Hour = 0;
         Minutes = 0;
      }
      info->version_made_by = rec. version_made_by;
      info->version_needed_to_extract = rec.version_needed_to_extract;
      info->general_purpose_bit_flag = rec.general_purpose_bit_flag;
      info->extra_field_length = rec.extra_field_length;
      info->file_comment_length = rec.file_comment_length;
      info->disk_number_start = rec.disk_number_start;
      info->internal_file_attributes = rec.internal_file_attributes;
      info->external_file_attributes = rec.external_file_attributes;
      info->filename_length = rec.filename_length;
      mOnth = DisplayMonthName(Month);
      comp_type = DisplayCompressionType(rec.compression_method);
      strcpy(info->Nameptr,filename);
      strcpy(info->Comp_type,comp_type);
      info->Compression_method = rec.compression_method;
      info->stowageFactor = StowageFactor;
      info->day = Day;
      strcpy(info->month,mOnth);
      info->year = Year;
      info->hour = Hour;
      info->minutes = Minutes;
      info->CRC32 = rec.crc32;
      info->Compressed_size = rec.compressed_size;
      info->unCompressed_size = rec.uncompressed_size;
      info->mod_file_time = rec.last_mod_file_time;
      info->total_offset = rec.relative_offset_local_header;
      info->mod_file_time = rec.last_mod_file_time;
      info->mod_file_date = rec.last_mod_file_date;

      start = sl_store(info,start);

   }
}


/*----------------------------------------------------------------------*/


void process_end_central_dir()
{
   end_central_dir_record rec;
   char comment[STRSIZ];

   read(zipfd, (char *)&rec, sizeof(rec));

#ifdef HIGH_LOW
   swap_bytes(&rec.number_this_disk);
   swap_bytes(&rec.number_disk_with_start_central_directory);
   swap_bytes(&rec.total_entries_central_dir_on_this_disk);
   swap_bytes(&rec.total_entries_central_dir);
   swap_lbytes(&rec.size_central_directory);
   swap_lbytes(&rec.offset_start_central_directory);
   swap_bytes(&rec.zipfile_comment_length);
#endif

   /*get_string(rec.zipfile_comment_length, comment);*/
}


/*----------------------------------------------------------------------*/

/* print usage message if insufficient args entered */
void usage()
{
   int i, size;
   pos_two();
   fprintf(stdout,"\033f");
   size = ((sizeof instructions) /sizeof(char *));
   for(i = 0; i < size; i++){
      fprintf(stdout,"%s\n",instructions[i]);
      fflush(stdout);
   }
   fprintf(stdout,"\033q\033e");
}

void disclaimer()
{
   int i, size,x,y;
   x = 4;
   y = 0;
   pos_three();
   size = ((sizeof Disclaimer) /sizeof(char *));
   for(i = 0; i < size; i++){
      fprintf(stdout,"%s\n",Disclaimer[i]);
   }
   fprintf(stdout,"\n\n\n\t\t\t\033pPress any key for help screen\033q");
   fflush(stdout);
   Bconin(2);
   clr_view();
   fprintf(stdout,"\033Y%c%c\033e\033J\033q", x + ' ', y + ' ');
}

void List_head()
{
   int i,size;
   size = ((sizeof list_head) /sizeof(char *));
   if(verbose){
      pos_twenty();
   }
   else
      pos_three(); 
   for(i = 0; i < size; i++){
      fprintf(stdout,"\033f%s",list_head[i]);
      fflush(stdout); 
   }
}
/*---------------------------------------------------------*/
void memcpy(to,from,count)
register unsigned char *to,*from;
register unsigned int count;
{
   for(;count>0;--count,++to,++from)
      *to=*from;
}


char *strupr(string)
register char *string;
/*
 *      Convert all alphabetic characters in <string> to upper case.
 */
{
   register char *p = string;

   while(*string) {
      if(islower(*string))
         *string ^= 0x20;
      ++string;
   }
   return(p);
}

/*----------------------------------------------------------------------*/

prg_exit(value)
int value;
{
   fprintf(stdout,"\033f\033p (Press any key) \033q\07\07");
   fflush(stdout);
   Bconin(2); /* wait for keypress before exiting */
   fprintf(stdout,"\033e\033q"); /* activates cursor and disables reversed video */           
   close(zipfd);
   exit(value);
}
 
abort(s,arg1,arg2,arg3)
char *s;
{
   pos_abort(zipfn,"EXIT: "); 
   fprintf(stdout,s,arg1,arg2,arg3);
   prg_exit(1);
}

/*--------------------------------------------------------------------*/

/* store the info from headers to linked list structure: display_save
   also sorts in ascending order as info is stored
 */
struct display_save *sl_store(i,top)
struct display_save *i;
struct display_save *top;
{
   struct display_save *old,*p;
   if(last == NULL){
      i->next = NULL;
      i->prior = NULL;
      last = i;
      return i;
   }
   p = top; /* start at top of list */


   old = NULL;
   while(p){
      if(strcmp(p->Nameptr,i->Nameptr) < 0){   /* criteria for sort = file name: Nameptr */
         old = p;
         p = p->next;
      }
      else{
         if(p->prior){
            p->prior->next = i;
            i->next = p;
            i->prior = p->prior;
            p->prior = i;
            return top;
         }
         i->next = p;
         i->prior = NULL;
         p->prior = i;
         return i;
      }
   }
   old->next = i;
   i->next = NULL;
   i->prior = old;
   last = i;
   return start;
}

int strrpos(string, symbol)
register char *string;
register char symbol;
/*
 *	Return the index of the last occurance of <symbol> in <string>.
 *	-1 is returned if <symbol> is not found.
 */
{
	register int i = 0;
	register char *p = string;

	while(*string++)
		++i;
	do {
		if(*--string == symbol)
			return(i);
		--i;
	} while(string != p);
	return(-1);
}

char *substr(dest, source, start, end)
register char *dest;
register char *source;
register int start;
register int end;
/*
 *	Copy characters from <source> to <dest> starting with character
 *	<start> and ending with <end>.  A pointer to <dest>, which will
 *	be '\0' terminated, is returned.
 */
{
	register char *p = dest;
	register int n;

	n = strlen(source);
	if(start > n)
		start = n - 1;
	if(end > n)
		end = n - 1;
	source += start;
	while(start++ <= end)
		*p++ = *source++;
	*p = '\0';
	return(dest);
}

