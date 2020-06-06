/* LOCAL.H    All CPU and compiler specific stuff should
 *            be listed here.
 */

#ifdef   __STDC__         /* portable way to prototype functions */
#define  PARAM(a)     a   /* from Thomas Plum */
#endif

#ifdef   APW              /* Apple compiler is NOT ANSI compatable */
#define  PARAM(a)

#define S_IREAD   0x0100      /* owner may read */
#define S_IWRITE  0x0080      /* owner may write */
#define SEEK_CUR  1           /* lseek() modes */
#define SEEK_END  2
#define SEEK_SET  0

#endif

static char   *make_legal( PARAM(( char * )) );
extern char   *malloc( PARAM(( size_t )) );
