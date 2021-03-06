/*
 *	arcmatch.c	1.1
 *
 *	Author: Thom Henderson
 *	Original System V port: Mike Stump
 *
 * REVISION HISTORY
 *
 * 03/22/87  C. Seaman		enhancements, bug fixes, cleanup
 * 11/13/89  C. Mascott		adapt for use with unzip
 *
 */

/*
 * ARC - Archive utility - ARCMATCH
 * 
 * Version 2.17, created on 12/17/85) at 20:32:18
 * 
 * (C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED
 * 
 *     Description:
 *          This file contains service routines needed to maintain an archive.
 */

#include <sys/types.h>
#include <sys/dir.h>

#define ASTERISK '*'		/* The '*' metacharacter */
#define QUESTION '?'		/* The '?' metacharacter */
#define BACK_SLASH '\\'         /* The '\' metacharacter */
#define LEFT_BRACKET '['	/* The '[' metacharacter */
#define RIGHT_BRACKET ']'	/* The ']' metacharacter */

#define IS_OCTAL(ch) (ch >= '0' && ch <= '7')

typedef short INT;
typedef short BOOLEAN;
#define TRUE 1
#define FALSE 0
#define EOS '\000'

static BOOLEAN do_list();
static char nextch();
static void list_parse();

int match(string, pattern)
char *string;
char *pattern;
{
    register int ismatch;

    ismatch = FALSE;
    switch (*pattern)
    {
    case ASTERISK:
        pattern++;
        do
        {
            ismatch = match (string, pattern);
        }
        while (!ismatch && *string++ != EOS);
        break;
    case QUESTION:
        if (*string != EOS)
            ismatch = match (++string, ++pattern);
        break;
    case EOS:
        if (*string == EOS)
            ismatch = TRUE;
        break;
    case LEFT_BRACKET:
        if (*string != EOS)
            ismatch = do_list (string, pattern);
        break;
    case BACK_SLASH:
        pattern++;
    default:
        if (*string == *pattern)
        {
            string++;
            pattern++;
            ismatch = match (string, pattern);
        }
        else
            ismatch = FALSE;
        break;
    }
    return(ismatch);
}

static BOOLEAN do_list (string, pattern)
register char *string;
char *pattern;
{
    register BOOLEAN ismatch;
    register BOOLEAN if_found;
    register BOOLEAN if_not_found;
    auto char lower;
    auto char upper;

    pattern++;
    if (*pattern == '!')
    {
        if_found = FALSE;
        if_not_found = TRUE;
        pattern++;
    }
    else
    {
        if_found = TRUE;
        if_not_found = FALSE;
    }
    ismatch = if_not_found;
    while (*pattern != ']' && *pattern != EOS)
    {
        list_parse(&pattern, &lower, &upper);
        if (*string >= lower && *string <= upper)
        {
            ismatch = if_found;
            while (*pattern != ']' && *pattern != EOS) pattern++;
        }
    }

    if (*pattern++ != ']')
    {
        printf("Character class error\n");
        exit(1);
    }
    else
        if (ismatch)
            ismatch = match (++string, pattern);

    return(ismatch);
}

static void list_parse (patp, lowp, highp)
char **patp;
char *lowp;
char *highp;
{
    *lowp = nextch (patp);
    if (**patp == '-')
    {
        (*patp)++;
        *highp = nextch(patp);
    }
    else
        *highp = *lowp;
}

static char nextch (patp)
char **patp;
{
    register char ch;
    register char chsum;
    register INT count;

    ch = *(*patp)++;
    if (ch == '\\')
    {
        ch = *(*patp)++;
        if (IS_OCTAL (ch))
        {
            chsum = 0;
            for (count = 0; count < 3 && IS_OCTAL (ch); count++)
            {
                chsum *= 8;
                chsum += ch - '0';
                ch = *(*patp)++;
            }
            (*patp)--;
            ch = chsum;
        }
    }
    return(ch);
}
