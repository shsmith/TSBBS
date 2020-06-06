/* LOCAL.H    All CPU and compiler specific stuff should
 *            be listed here.
 */

#ifdef   ANSI             /* portable way to prototype functions */
#define  PARAM(a)     a   /* from Thomas Plum */
#endif
#ifdef   APW              /* Apple compiler is NOT ANSI compatable */
#define  PARAM(a)
#endif

static char   *make_legal( PARAM(( char *)) );
extern char   *malloc( PARAM(( size_t)) );
