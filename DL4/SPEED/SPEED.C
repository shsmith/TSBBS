
/*
 * cpuspeed - general system performance benchmark
 *
 * S.H.Smith, 26-Sep-86
 *
 */


#include <stdio.h>
#include <dos.h>
#include <assert.h>
#include <ctype.h>

void   dispspeed();
void   memspeed();
void   cpuspeed();
void   mathspeed();
void   filespeed();
void   bufspeed();
long   get_time();
char   *malloc();
FILE   *output;
long   start;
long   stop;
double elapsed;
double index;
double total;
int    count;
int    pass;
int    iterations = 1;

#define round(d) ((d) + 0.004995)


main(argc,argv)
int argc;
char *argv[];
{
   char *tests = "ABCDEF";   /* default test list */
   char *arg;

   count = 0;
   total = 0;
   output = fopen( "CON","w" );

   while ( argc-- > 1 ) {
      arg = argv[argc];

      if ( isdigit( *arg ) )
         iterations = atoi( arg );
      else
         tests = arg;
   }

   scrollscreen();

   while ( *tests )
   {
      switch ( toupper( *tests++ ) )
      {
         case 'A':  bench( dispspeed, "A - BIOS display updates" );   break;
         case 'B':  bench( memspeed,  "B - Heavy memory access" );    break;
         case 'C':  bench( cpuspeed,  "C - Minimal memory access" );  break;
         case 'D':  bench( mathspeed, "D - Floating point" );         break;
         case 'E':  bench( bufspeed,  "E - Buffered file access" );   break;
         case 'F':  bench( filespeed, "F - General file access" );    break;

         default:   fprintf( output,"Invalid test: %c\n",*(tests-1) );
                    usage();
      }
   }

   total /= (double)count;
   index = (iterations*10) / total;

   fprintf( output,"%28s  --------       --------\n"," ");
   fprintf( output,"  %25s %8.1f       %8.2f\n\n",
                   "Average performance",round(total),round(index) );

   fflush( output );
   fclose( output );
}


usage()
{
   fprintf( output,"Usage: SPEED           ;1 iteration, all tests\n" );
   fprintf( output,"       SPEED N         ;N iterations, all tests\n" );
   fprintf( output,"       SPEED N ABCDEF  ;N iterations, specified tests\n\n" );
   fprintf( output,"Tests: A - BIOS display updates\n" );
   fprintf( output,"       B - Heavy memory access\n" );
   fprintf( output,"       C - Minimal memory access\n" );
   fprintf( output,"       D - Floating point\n" );
   fprintf( output,"       E - Buffered file access\n" );
   fprintf( output,"       F - General (unbuffered) file access\n" );

   fflush( output );
   fclose( output );
   exit(1);
}


bench( procedure, description )
void (*procedure)();
char *description;
{
   fprintf( output, "   %-25s",description );
   fflush( output );

   (*procedure)();

   elapsed = (double)(stop-start) / 100.0;
   total += elapsed;
   count++;

   if (elapsed == 0.0)
      index = 9999.0;
   else
      index = (iterations*10) / elapsed;

   if (count == 1) {
      scrollscreen();
      fprintf( output,"\n                  System performance test\n\n" );
      fprintf( output,"All tests run in %4.1f seconds on a standard 8088 IBM PC with\n",10.0*iterations);
      fprintf( output,"4.77 MHz clock, 640k ram, 360k floppy disk, no math processor.\n\n");
      fprintf( output,"           Test                 Time     Performance index\n" );
      fprintf( output,"----------------------------  --------  -------------------\n");
      fprintf( output, "   %-25s",description );
   }

   fprintf( output,"%8.1f       %8.2f \n",round(elapsed),round(index) );
   fflush( output );
}


/*
 * benchmark procedures
 *
 * each procedure should run for exactly 10.0 seconds per call on
 * a standard IBM-PC.
 *
 */

void dispspeed()   /* BIOS display updates */
{
   const int DISPSIZE = 5328;
   char *buf,*p;
   int fd;
   int i;

   assert( (p = buf = malloc(DISPSIZE)) != 0 );

   for (i=0; i<DISPSIZE; i++)
      *p++ = (i & 0x3f) + ' ';

   for (i=1000; i<1050; i++)
      buf[i] = '\n';

   for (i=2000; i<2050; i++)
      buf[i] = '\t';

   start = get_time();

   fd = open( "con",1 );
   for (pass=0; pass<iterations; pass++)
      write( fd,buf,DISPSIZE );
   close( fd );

   stop = get_time();
   free( buf );
}


void memspeed()   /* heavy memory access bench */
{
   const int LOOPS = 100;
   const int MEMSIZ = 26350;
   char *buf1,*buf2;
   int i;

   assert( (buf1 = malloc( MEMSIZ )) != 0 );
   assert( (buf2 = malloc( MEMSIZ )) != 0 );

   start = get_time();

   for (pass=0; pass<iterations; pass++)
      for (i=0; i<LOOPS; i++)
         memcpy( buf2,buf1,MEMSIZ );

   stop = get_time();
   free( buf1 );
   free( buf2 );
}


void cpuspeed()   /* minimal memory access */
{
   const int LOOPS = 100;
   register int i,j;

   start = get_time();

   for (pass=0; pass<iterations; pass++)
      for (i=0; i<LOOPS; i++)
         for (j=0; j<4956; j++);

   stop = get_time();
}


void mathspeed()   /* floating point */
{
   const int LOOPS = 770;
   double a,b,c;
   int i;

   a = 123.45;
   b = 111.12;
   c = 1.7;
   start = get_time();

   for (pass=0; pass<iterations; pass++)
      for (i=0; i<LOOPS; i++)
         c = c + (a*b) + (a/b) - (b/a)*c;

   stop = get_time();
}


void bufspeed()   /* (large) buffered file access */
{
   const int LOOPS = 12;
   const int IOBSIZE = 4096;
   int fd,i;
   char *buf;
   char *name = "$$$$$$$$.$$$";

   assert( (buf = malloc( IOBSIZE )) != 0 );

   newfile( name,IOBSIZE,LOOPS );
   start = get_time();

   for (pass=0; pass<iterations; pass++) {
      assert( (fd = open( name,2 )) > 0);
      for (i=0; i<LOOPS; i++)
         assert( write( fd,buf,IOBSIZE ) == IOBSIZE );
      close( fd );

      assert( (fd = open( name,2 )) > 0);
      for (i=0; i<LOOPS; i++)
         assert( read( fd,buf,IOBSIZE ) == IOBSIZE );
      close( fd );
   }

   stop = get_time();
   unlink( name );
   free( buf );
}


void filespeed()   /* general (small buffer) file access */
{
   const int LOOPS = 349; /*262*/
   int fd,i;
   char buf[30];
   char *name = "$$$$$$$$.$$$";

   newfile( name,sizeof(buf),LOOPS );
   start = get_time();

   for (pass=0; pass<iterations; pass++) {
      assert( (fd = open( name,2 )) > 0);
      for (i=0; i<LOOPS; i++)
         assert( write( fd,buf,sizeof(buf) ) == sizeof(buf) );
      close( fd );

      assert( (fd = open( name,2 )) > 0);
      for (i=0; i<LOOPS; i++)
         assert( read( fd,buf,sizeof(buf) ) == sizeof(buf) );
      close( fd );
   }

   stop = get_time();
   unlink( name );
}



/* scroll cursor to erase screen and leave cursor at the LAST line */
scrollscreen()
{
   fprintf( output,"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" );
   fflush( output );
}



/* gets the time since midnight in seconds*100 */
long get_time()
{
   union REGS in, out;
   #define hi(vv) ((out.x.vv>>8) & 0xff)
   #define lo(vv) (out.x.vv & 0xff)

   in.x.ax = 0x2c00;          /* DOS get time function code */
   intdos( &in, &out );

   return lo(dx) + 100L*(hi(dx) + 60L*(lo(cx) + 24L*(hi(cx))));
}



/* create a new (empty) file with a given initial size */
newfile(name,elements,size)
char *name;
unsigned elements,size;
{
   int fd;
   unsigned size;

   assert( (fd = creat(name,0)) > 0);
   assert( write( fd,&fd,elements*size ) == elements*size );
   close( fd );
}
