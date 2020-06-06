
static char pedigree_tag[]
   = "\0@(#)pedigree.c 23-Mar-87 Pedigree report generator 1.0";

/*
 * pedigree - report on the pedigree of an object/exe file
 *
 * This program searches a command file for timestamps or "SCCS tags"
 * that identify the component modules or source files.  These tags can
 * be inserted automatically by the TSHELL program (turbo pascal preprocessor
 * shell).
 *
 * Written by Samuel H. Smith, 20-Mar-87
 *
 */

#include <stdio.h>

#define repeat for(;;)

#define BUFSIZ   0x7000      /* size of file buffer (must be < 0x8000) */
#define MAXIDLEN 90          /* longest identifier line */

char *file_name;
char *file_buf;
int buf_count;
int fd;

int strip_directory = 0;
int report_offset = 0;
int prefix_name = 0;

extern long lseek();


main(argc,argv)
int argc;
char *argv[];
{
   int i;

   if (argc < 2) 
   {
      fprintf(stderr,"usage:     pedigree [options] FILE ... FILE >REPORTFILE\n");
      fprintf(stderr,"options:   -d    ;strip directory from tag filenames\n");
      fprintf(stderr,"           -o    ;report file offsets\n");
      fprintf(stderr,"           -n    ;prefix lines with FILE name\n");
      exit(1);
   }

   file_buf = (char *)malloc(BUFSIZ);
   if (file_buf == 0) 
   {
      fprintf(stderr,"can't allocate %u bytes for buffer\n",BUFSIZ);
      exit(1);
   }

   for (i=1; i<argc; i++) 
   {
      if (argv[i][0] == '-')
      {
         switch (toupper(argv[i][1])) {
            case 'D': strip_directory = 1;  
                      break;

            case 'O': report_offset = 1;    
                      break;

            case 'N': prefix_name = 1;
                      break;

            default:  fprintf(stderr,"Invalid option: %s\n",argv[1]);
         }
      }
      else
      {
         file_name = argv[i];
         fd = open(file_name,0);

         if (fd < 1) 
            fprintf(stderr,"can't open %s\n",file_name);
         else
         {
            if (!prefix_name)
               printf("\n%s:\n",file_name);

            scan_file();
            close(fd);
         }
      }
   }
}


/*
 * read_buffer - read next bufferful of text
 * returns 0 on end of file
 *
 */

read_buffer()
{
   memset(file_buf,0,BUFSIZ);
   buf_count = read(fd,file_buf,BUFSIZ);
   return buf_count != 0;
}


/*
 * locate_tag - search the current buffer for a timestamp tag
 *              and return the index to where it was found.
 *              start search at specified position.
 *              return actual position if found
 *              return -1 if not found
 */

locate_tag(pos)
int pos;
{
   char *loc;
   int npos;
   extern char *memchr();

   repeat 
   {
      loc = memchr(&file_buf[pos],'@',buf_count-pos);

      if (*loc != '@')
         return -1;

      npos = loc - file_buf;
      if ((loc[1] == '(') && (loc[2] == '#') && (loc[3] == ')'))
         return npos+4;

      pos = npos + 1;
   }
}

/*
 * scan_file - read and scan the file, reporting taglines
 *             as they are found.  
 *
 */

scan_file()
{
   int pos;

   repeat 
   {
      if (!read_buffer())                 /* get a buffer full of text */
         break;

      pos = 0;

      repeat 
      {
         pos = locate_tag(pos);           /* search for a tag in the buffer */

         if (pos < 1)                     /* no tag found, get next buffer */
            break;

         /* if there is not enough room for the whole tag, 
            align the file so it will be at the start of the
            next buffer full */

         if (pos >= buf_count-MAXIDLEN) 
         {
            lseek(fd,(long)-MAXIDLEN,1);
            read_buffer();
            pos = locate_tag(0);
         }

         /* we have a valid tag, format and report it */

         pos = format_tag(pos);
      }
   }
}


/*
 * format_tag - format the timestamp tag at the specified position;
 *              return position past end of tag.
 */

format_tag(pos)
int pos;
{
   char c;
   int q;
   char name[MAXIDLEN];
   long offset;

/* print input filename prefix when needed */
   if (prefix_name)
      print_filename(file_name);
   else
      printf("  ");

/* print file offset when needed */
   if (report_offset)
   {
      offset = lseek(fd,0L,1);
      offset = offset - buf_count + pos;
      printf("%06lx  ",offset);
   }

/* extract filename from tag */
   q = 0;
   c = file_buf[pos++];
   while (c > ' ')
   {
      name[q++] = c;
      c = file_buf[pos++];
   }
   name[q] = 0;

/* report the filename */
   print_filename(name);

/* extract and report the remainder of the tag (date and comment) */
   if (c != 0) 
   {
      c = file_buf[pos++];
      while (c != 0 && c != '\r' && c != '\n')
      {
         putchar(c);
         c = file_buf[pos++];
      }
   }

   printf("\n");

/* return index to next buffer position to scan */
   return pos-1;
}


/*
 * print a filename with directory stripping.  pads spaces to align
 * files with the same directory prefix.
 *
 */

print_filename(s)
char *s;
{
   char name[80];
   int name_length;
   int full_length;
   char c;

/* copy the name, keeping track of directory and basename locations */
   full_length = name_length = 0;
   c = *s++;
   while (c)
   {
      name[full_length++] = c;
      name[full_length] = 0;

      if (c == '\\' || c == '/')
      {
         name_length = 0;        /* count chars past last prefix */

         if (strip_directory)    /* delete prefix if needed */
            full_length = 0;
      }
      else
         name_length ++;

      c = *s++;
   }

/* print the formatted name */
   printf("%s",name);

/* print needed spaces to align filenames */
   do
      putchar(' ');
   while (name_length++ < 13);
}

