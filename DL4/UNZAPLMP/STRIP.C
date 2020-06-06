
#include <stdio.h>
#include <types.h>
#include <string.h>
#include <fcntl.h>
#include <prodos.h>

/* STRIP.C    Strips crtn/linefeed, tabs, and Ctrl-Z's from files.
 *
 *  Written by Martin E. Peckham and donated to the public domain.
 */

extern char   *p2cstr();
extern char   *c2pstr();
extern int    atoi();

#define  WORK      "tmpfilezzz.000"
#define  TEXT      0x04           /* filetype */
#define  BINARY    0x06           /* filetype */
#define  SRC       0xB0           /* filetype */
#define  MSDOS_EOF 0x1A           /* Ctrl-Z */
#define  TAB       9

int      tabLen = 4;      /* default: expand tabs to every 4th column */

main( argc, argv )
unsigned argc;
char     **argv;
{
    unsigned  i;
    FILE      *ifd, *ofd;
    FileRec   fileInfo;      /* get file type */
    Word      ftype;

    setargv( &argc, &argv );  /* expand wild cards */

    if( argc < 2 )
         usage( argv[0] );

    for( i = 1; i < argc; i++ )
    {
         if( *argv[i] == '-' )
         {
              if( *(argv[i]+1) == 't' )
                   tabLen = atoi( argv[i] + 2 );  /* new tab stop */
              else
                   usage( argv[0] );
         }
    }
    for( i = 1; i < argc; i++ )
    {
         fileInfo.pathname = c2pstr( argv[i] );
         GET_FILE_INFO( &fileInfo );
         p2cstr( argv[i] );
         ftype = fileInfo.fileType;
         if( ftype != TEXT && ftype != BINARY && ftype != SRC )
              continue;      /* skip this one */

         if( (ifd = fopen(argv[i], "rb")) == NULL )
         {
              perror( argv[i] );
              continue;      /* do next file */
         }

         ofd = fopen( WORK, "w" );

         fprintf( stderr, "%s: %s\n", argv[0], argv[i] );
         process( ifd, ofd );
         fclose( ifd );
         fclose( ofd );
         unlink( argv[i] );                   /* delete source file */
         faccess( WORK, F_RENAME, argv[i] );  /* rename WORK to source name */
         faccess( argv[i], F_TYPE, TEXT );    /* assume it's a text file */
    }
}

process( in, out )
FILE     *in, *out;
{
    int       c;
    unsigned  column = 0;

    while( (c = fgetc( in )) != EOF && c != MSDOS_EOF )
    {
         if( (c &= 0x7F) == TAB )
         {
              do{
                   fputc( ' ', out );
              }while( ++column % tabLen );
         }
         else if( c == '\r' )
         {
              if( ((c = fgetc( in )) & 0x7F) != '\n' )
                   ungetc( c, in );
              fputc( '\n', out );
              column = 0;
         }
         else
         {
              fputc( c, out );
              ++column;
         }
    }
}

usage( fname )
char     *fname;
{
    fprintf( stderr, "USAGE: %s [-t<n>] file0 file1 ...\n", fname );
    exit( 1 );
}

perror( str )
char     *str;
{
    extern int    errno;
    fprintf( stderr, "%s: 0x%X\n", str, errno );
}
