#include <uzhdr.h>
#include <uzcursor.h>

extern int cp;
extern int cx;
extern boolean vflag;
extern boolean iflag;
extern boolean cflag;
extern int zipfd;
extern boolean more;
extern char zipfn[13]; 
/*-----------------------------------------------------------*/
static int TotalFiles;
static long TotalBytes;
static long TotalUnCompressedBytes;

char FileName [STRSIZ];
int count = 0;
int variable_size;
/*-----------------------------------------------------------*/
ListZipFile(fullname,ifilename)
char *fullname;
char *ifilename;
{
   long sig;
   struct local_file_header lrec;

   zipfd = open(fullname,O_RDONLY|O_BINARY);

   if(zipfd < 1) 
     {
      abort("could not open this file");
     }
 

   pos_zipfn();
   fprintf(stdout,"\033pZipfile: %s\033q\033B\033l",zipfn);
   rem_pos();
   if(iflag || cflag)
     {
       pos_three();
       fprintf(stdout,"----------------------------------------------------------------------------\n");
       fflush(stdout);
     }
   TotalFiles = 0;
   TotalBytes = 0L;
   TotalUnCompressedBytes = 0L;

   if(vflag){ 
      List_head();
   }

   while(1) {

      process_headers();
      if(more){
         return;
      }
      if(sig != END_CENTRAL_DIR_SIGNATURE) {
         break;
      }
      close(zipfd);
   }
   DisplayTotals();
   return 0;
}


DisplayHeaderRecord(Zipfn,lrec, FileName)
char *Zipfn;
struct local_file_header lrec;
char *FileName;
{
   int Month,
   Day,
   Year,
   Hour,
   Minutes,
   StowageFactor;
   char *NamePtr;
   long SizeReduction;
   char *mOnth,*comp_type;
   if(lrec.uncompressed_size == 0) {
      StowageFactor = 0;
   }
   else {
      if(lrec.compressed_size <= lrec.uncompressed_size) {
         SizeReduction = lrec.uncompressed_size - lrec.compressed_size;
         if(SizeReduction == 0L) {
            StowageFactor = 0;
         }
         else {
            SizeReduction = SizeReduction * 100L + 50;
            StowageFactor = (int)(SizeReduction/lrec.uncompressed_size);
         }
      }
      else {
         SizeReduction = lrec.compressed_size - lrec.uncompressed_size;
         SizeReduction = SizeReduction * 100L + 50;
         StowageFactor = (int)(SizeReduction/lrec.uncompressed_size);
         StowageFactor *= -1;
      }
   }
   if(StowageFactor >= 100) {
      StowageFactor = 0;
   }


   /* Convert the DOS internal date and time format to something we can
         use for output. */

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

   /* The ZIP documentation says that path names are stored with '/'s
         rather than '\'s.  Look for a '/' and if so point to the file
         name rather than the whole path name. */

   if((NamePtr = (char *)strrchr(FileName,'/')) == NULL) {
      NamePtr = FileName;
   }
   comp_type = DisplayCompressionType(lrec.compression_method);
   mOnth = DisplayMonthName(Month);
   if(count == 0){
      pos_five();
   }
   fprintf(stdout,"%-14s%8ld  %s   %2d%%  %8ld  %02d %s %2d  %02d:%02d   %08lX\n",
   NamePtr,
   lrec.uncompressed_size,
   comp_type,
   StowageFactor,
   lrec.compressed_size,
   Day,
   mOnth,
   Year,
   Hour,
   Minutes,
   lrec.crc32);
   fflush(stdout);
   count++;
   if(count == 18){
      int i;
      pos_prompt(Zipfn,"press any key for more files");
     /* fprintf(stdout,"\033ppress any key for more files\033q ");*/
      fflush(stdout);
      Bconin(2);
      /*clr_cmdline();*/
      clr_verbose();
      count = 0;
   }

   TotalFiles += 1;
   TotalBytes += lrec.compressed_size;
   TotalUnCompressedBytes += lrec.uncompressed_size;
   return 0;
}
/*---------------------------------------------------------*/
DisplayTotals()
{
   int StowageFactor;
   long SizeReduction;




   fprintf(stdout,"============  ========  ========  ====  ========  =========  ======  ========\n");
   fflush(stdout);
   if(TotalUnCompressedBytes == 0) {
      StowageFactor = 0;
   }
   else {
      if(TotalBytes <= TotalUnCompressedBytes) {
         SizeReduction = TotalUnCompressedBytes - TotalBytes;
         if(SizeReduction == 0L) {
            StowageFactor = 0;
         }
         else {
            SizeReduction = SizeReduction * 100L + 50;
            StowageFactor = (int)(SizeReduction/TotalUnCompressedBytes);
         }
      }
      else {
         SizeReduction = TotalBytes - TotalUnCompressedBytes;
         SizeReduction = SizeReduction * 100L + 50;
         StowageFactor = (int)(SizeReduction/TotalUnCompressedBytes);
         StowageFactor *= -1;
      }
   }
   if(StowageFactor >= 100) {
      StowageFactor = 0;
   }

   fprintf(stdout,"*total%6d  %8ld             %2d%%  %8ld\n\n",
   TotalFiles,
   TotalUnCompressedBytes,
   StowageFactor,
   TotalBytes);
   fflush(stdout);
   return 0;
}


char *DisplayCompressionType(Compression)
int Compression;
{
   switch (Compression) {
   case 0:
      return " Stored ";
      break;
   case 1:
      return " Shrunk ";
      break;
   case 2:
      return "Reduced1";
      break;
   case 3:
      return "Reduced2";
      break;
   case 4:
      return "Reduced3";
      break;
   case 5:
      return "Reduced4";
      break;
   case 6:
      return "Imploded";
      break; 
   default:
      return "Unknown ";
      break;
   }
}

char *DisplayMonthName(Month)
int Month;
{
   switch (Month) {
   case 1:
      return "Jan";
      break;
   case 2:
      return "Feb";
      break;
   case 3:
      return "Mar";
      break;
   case 4:
      return "Apr";
      break;
   case 5:
      return "May";
      break;
   case 6:
      return "Jun";
      break;
   case 7:
      return "Jul";
      break;
   case 8:
      return "Aug";
      break;
   case 9:
      return "Sep";
      break;
   case 10:
      return "Oct";
      break;
   case 11:
      return "Nov";
      break;
   case 12:
      return "Dec";
      break;
   }
}

