#include <uzhdr.h>
#include <uzcursor.h>

extern byte *outbuf; /* buffer for rle look-back */
extern byte *outptr;
extern char filename[STRSIZ];
extern local_file_header lrec;
extern longint outpos; /* absolute position in outfile */
extern int outcnt; /* current position in outbuf */
extern unsigned bitbuf;
extern int incnt;
extern unsigned bits_left;
extern boolean zipeof;
extern boolean xflag;
extern boolean iflag;
extern boolean more;
extern boolean test; 
extern boolean nomore; 
extern boolean skip;
extern boolean cflag;
extern boolean pflag;
extern boolean def_pat;
extern char m_outbuf[hsize];
extern int outfd;
extern int linenum;
extern int i;
extern char uoutbuf[];
extern void memcpy();
extern char zipfn[13];
long outcount = 0L;
long printcount = 0L;

/*----------------------------------------------------------------------*/
int factor;
long crc32val;
byte followers[256][64];
byte Slen[256];

typedef int hsize_array_integer[hsize+1];
typedef byte hsize_array_byte[hsize+1];

hsize_array_integer prefix_of;
hsize_array_byte suffix_of;
hsize_array_byte stack;

int codesize;
int maxcode;
int free_ent;
int maxcodemax;
int offset;
int sizex;


/*----------------------------------------------------------*/
/*
 *  void UpdateCRC(s,len);
 *
 *  unsigned char  *s;
 *  register int   len;
 *
 */

/* update running CRC calculation with contents of a buffer */

/*----------------------------------------------------------------------*/

static unsigned mask_bits[] =
{
   0, 0x0001, 0x0003, 0x0007, 0x000f,
   0x001f, 0x003f, 0x007f, 0x00ff,
   0x01ff, 0x03ff, 0x07ff, 0x0fff,
   0x1fff, 0x3fff, 0x7fff, 0xffff
};


unsigned FillBitBuffer(bits)/*arthur*/
register unsigned bits; /*arthur*/
{
   /* get the bits that are left and read the next word */
   unsigned temp;
   register unsigned result = bitbuf;/*arthur*/
   unsigned sbits = bits_left; /*arthur*/
   bits -= bits_left;

   /* read next word of input */
   bits_left = ReadByte(&bitbuf);
   bits_left += ReadByte(&temp);
   bitbuf |= (temp << 8);
   if (bits_left == 0)
      zipeof = 1;

   /* get the remaining bits */
   result = result | (unsigned) ((bitbuf & mask_bits[bits]) << sbits);/*arthur*/
   bitbuf >>= bits;
   bits_left -= bits;
   return result;
}

/*----------------------------------------------------------------------*/


void LoadFollowers()
{
register int x;
register int i;

for (x = 255; x >= 0; x--) {
   READBIT(6,Slen[x]);
   for (i = 0; i < Slen[x]; i++) {
      READBIT(8,followers[x][i]);
   }
}
}


/*----------------------------------------------------------------------*/

/*
 * The Reducing algorithm is actually a combination of two
 * distinct algorithms.  The first algorithm compresses repeated
 * byte sequences, and the second algorithm takes the compressed
 * stream from the first algorithm and applies a probabilistic
 * compression method.
 */

int L_table[] = {
0, 0x7f, 0x3f, 0x1f, 0x0f};

int D_shift[] = {
0, 0x07, 0x06, 0x05, 0x04};
int D_mask[] = {
0, 0x01, 0x03, 0x07, 0x0f};

int B_table[] = {
8, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6,
6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7,
7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
8, 8, 8, 8};

/*----------------------------------------------------------------------*/


/* expand probablisticly reduced data */
void unReduce()
{
register int lchar;
int nchar;
int ExState;
int V;
int Len;

factor = lrec.compression_method - 1;
ExState = 0;
lchar = 0;
LoadFollowers();

while (((outpos + outcnt) < lrec.uncompressed_size) && (!zipeof)) {
   if (Slen[lchar] == 0)
      READBIT(8,nchar) /* ; */
else
{
   READBIT(1,nchar);
   if (nchar != 0)
      READBIT(8,nchar) /* ; */
else
{
   int follower;
   int bitsneeded = B_table[Slen[lchar]];
   READBIT(bitsneeded,follower);
   nchar = followers[lchar][follower];
}
}


/* expand the resulting byte */
switch (ExState) {

case 0:
if (nchar != DLE){
   if(more){
      OutByte(nchar);
   }
   else
      OUTB(nchar) /*;*/
   }
else
   ExState = 1;
break;

case 1:
if (nchar != 0) {
   V = nchar;
   Len = V & L_table[factor];
   if (Len == L_table[factor])
      ExState = 2;
   else
      ExState = 3;
}
else{ 
   if(more){
      OutByte(DLE);
   }
   else{
      OUTB(DLE);
   }
   ExState = 0;
}
break;

case 2:
{
   Len += nchar;
   ExState = 3;
}
break;

case 3:
{
   long op;
   register int i;
   int offset;
   if(more){
      offset = (((V >> D_shift[factor]) &
         D_mask[factor]) << 8) + nchar + 1;
      op = outpos + outcnt - offset;

      for(i = 0; i <= Len + 2; i++) 
      { 
         if (op < 0L)
            OutByte(0); 
         else{ 
            OutByte(m_outbuf[op % sizeof(m_outbuf)]); 
         }
         if(nomore)
            return;
         op++;
      }
   }
   else{ 
      i = Len + 3;
      offset = (((V >> D_shift[factor]) &
         D_mask[factor]) << 8) + nchar + 1;
      op = outpos + outcnt - offset;

      /* special case- before start of file */
      while ((op < 0L) && (i > 0)) {
         OUTB(0);
         op++;
         i--;
      }

      /* normal copy of data from output buffer */
      {
         register int ix = (int) (op %
            OUTBUFSIZ);
         /* do a block memory copy if possible */
         if ( ((ix +i) < OUTBUFSIZ) &&
            ((outcnt+i) < OUTBUFSIZ) ) {
            memcpy(outptr,&outbuf[ix],i);
            outptr += i;
            outcnt += i;


            /* otherwise copy byte by byte */
         }
         else while (i--) {
            OUTB(outbuf[ix]);
            if (++ix >= OUTBUFSIZ)
               ix = 0;
         }
      }
   }/* end of else */
   ExState = 0;
}
break;
}

/* store character for next iteration */
lchar = nchar;
}
}


/*----------------------------------------------------------------------*/

/*
 * Shrinking is a Dynamic Ziv-Lempel-Welch compression algorithm
 * with partial clearing.
 *
 */

void partial_clear()
{
register int pr;
register int cd;

/* mark all nodes as potentially unused */
for (cd = first_ent; cd < free_ent; cd++)
prefix_of[cd] |= 0x8000;

/* unmark those that are used by other nodes */
for (cd = first_ent; cd < free_ent; cd++) {
pr = prefix_of[cd] & 0x7fff; /* reference to another node? */
if (pr >= first_ent) /* flag node as referenced */
prefix_of[pr] &= 0x7fff;
}

/* clear the ones that are still marked */
for (cd = first_ent; cd < free_ent; cd++)
if ((prefix_of[cd] & 0x8000) != 0)
prefix_of[cd] = -1;

/* find first cleared node as next free_ent */
cd = first_ent;
while ((cd < maxcodemax) && (prefix_of[cd] != -1))
cd++;
free_ent = cd;
}


/*----------------------------------------------------------------------*/


void unShrink()
{
#define  GetCode(dest) READBIT(codesize,dest)

register int code;
register int stackp;
int finchar;
int oldcode;
int incode;


/* decompress the file */
maxcodemax = 1 << max_bits;
codesize = init_bits;
maxcode = (1 << codesize) - 1;
free_ent = first_ent;
offset = 0;
sizex = 0;

for (code = maxcodemax; code > 255; code--)
prefix_of[code] = -1;

for (code = 255; code >= 0; code--) {
prefix_of[code] = 0;
suffix_of[code] = code;
}

GetCode(oldcode);
if (zipeof)
return;
finchar = oldcode;

if(more){
OutByte(finchar); 
}
else
OUTB(finchar);

stackp = hsize;

while (!zipeof) {
GetCode(code);
if (zipeof)
return;

while (code == clear) {
GetCode(code);
switch (code) {

case 1:
   {
      codesize++;
      if (codesize == max_bits)
         maxcode = maxcodemax;
      else
         maxcode = (1 << codesize) - 1;
   }
   break;

case 2:
   partial_clear();
   break;
}

GetCode(code);
if (zipeof)
return;
}


/* special case for KwKwK string */
incode = code;
if (prefix_of[code] == -1) {
stack[--stackp] = finchar;
code = oldcode;
}


/* generate output characters in reverse order */
while (code >= first_ent) {
stack[--stackp] = suffix_of[code];
code = prefix_of[code];
}

finchar = suffix_of[code];
stack[--stackp] = finchar;


/* and put them out in forward order, block copy */

if(more){
while ((stackp < hsize)) 
{ 
   outpos = stackp; /* required to preserve shared buffer/stack */


   OutByte(stack[stackp++]); 
   if(nomore)
      return;
}
}
if ((hsize-stackp+outcnt) < OUTBUFSIZ) {
memcpy(outptr,&stack[stackp],hsize-stackp);
outptr += hsize-stackp;
outcnt += hsize-stackp;
stackp = hsize;
}
/* output byte by byte if we can't go by blocks */
else while (stackp < hsize){
if(more){
   OutByte(stack[stackp++]); 
}
OUTB(stack[stackp++]);
}

/* generate new entry */
code = free_ent;
if (code < maxcodemax) {
prefix_of[code] = oldcode;
suffix_of[code] = finchar;

do
code++;
while ((code < maxcodemax) && (prefix_of[code] != -1));

free_ent = code;
}

/* remember previous code */
oldcode = incode;
}

}


/* ------------------------------------------------------------- */ 
/*
 * Imploding
 * ---------
 *
 * The Imploding algorithm is actually a combination of two distinct
 * algorithms.  The first algorithm compresses repeated byte sequences
 * using a sliding dictionary.  The second algorithm is used to compress
 * the encoding of the sliding dictionary ouput, using multiple
 * Shannon-Fano trees.
 *
 */ 

enum { maxSF = 256 };

typedef struct sf_entry { 
    word Code; 
    byte Value; 
    byte BitLength; 
}
sf_entry; 

typedef struct sf_tree { /* a shannon-fano tree */
    sf_entry entry[maxSF];
    int entries;
    int MaxLength;
}
sf_tree; 

typedef sf_tree *sf_treep; 

sf_tree lit_tree; 
sf_tree length_tree; 
sf_tree distance_tree; 
boolean lit_tree_present; 
boolean eightK_dictionary; 
int minimum_match_length;
int dict_bits;


void SortLengths(tree)
sf_tree *tree;
/* Sort the Bit Lengths in ascending order, while retaining the order
    of the original lengths stored in the file */ 
{ 
    int x;
    int gap;
    sf_entry t; 
    boolean noswaps;
    int a, b;

    gap = tree->entries /2; 

    do { 
        do { 
            noswaps = 1;
            for (x = 0; x <= (tree->entries - 1) - gap; x++) 
            { 
                a = tree->entry[x].BitLength; 
                b = tree->entry[x + gap].BitLength; 
                if ((a > b) || ((a == b) && (tree->entry[x].Value > tree->entry[x + gap].Value))) 
                { 
                    t = tree->entry[x]; 
                    tree->entry[x] = tree->entry[x + gap]; 
                    tree->entry[x + gap] = t; 
                    noswaps = 0;
                }
            }
        }
        while (!noswaps);
        gap = gap /2; 
    }
    while (gap > 0);
}


/* ----------------------------------------------------------- */ 

void ReadLengths(tree)
sf_tree *tree;
{ 
    int treeBytes;
    int i;
    int num, len;

    /* get number of bytes in compressed tree */
    READBIT(8,treeBytes);
    treeBytes++; 
    i = 0; 

    tree->MaxLength = 0;

    /* High 4 bits: Number of values at this bit length + 1. (1 - 16)
        Low  4 bits: Bit Length needed to represent value + 1. (1 - 16) */
    while (treeBytes > 0)
    {
        READBIT(4,len); 
        len++;
        READBIT(4,num); 
        num++;

        while (num > 0)
        {
            if (len > tree->MaxLength)
                tree->MaxLength = len;
            tree->entry[i].BitLength = len;
            tree->entry[i].Value = i;
            i++;
            num--;
        }

        treeBytes--;
    }
}


/* ----------------------------------------------------------- */ 

void GenerateTrees(tree)
sf_tree *tree;
/* Generate the Shannon-Fano trees */ 
{ 
    word Code;
    int CodeIncrement;
    int LastBitLength;
    int i;


    Code = 0;
    CodeIncrement = 0; 
    LastBitLength = 0; 

    i = tree->entries - 1; /* either 255 or 63 */

    while (i >= 0) 
    { 
        Code += CodeIncrement; 
        if (tree->entry[i].BitLength != LastBitLength) 
        { 
            LastBitLength = tree->entry[i].BitLength; 
            CodeIncrement = 1 << (16 - LastBitLength); 
        }

        tree->entry[i].Code = Code; 
        i--; 
    }
}


/* ----------------------------------------------------------- */ 

void ReverseBits(tree)
sf_tree *tree;
/* Reverse the order of all the bits in the above ShannonCode[]
    vector, so that the most significant bit becomes the least
    significant bit. For example, the value 0x1234 (hex) would become
    0x2C48 (hex). */ 
{ 
    int i;
    word mask;
    word revb;
    word v;
    word o;
    int b;


    for (i = 0; i <= tree->entries - 1; i++) 
    { 
        /* get original code */ 
        o = tree->entry[i].Code; 

        /* reverse each bit */ 
        mask = 0x0001;
        revb = 0x8000;
        v = 0;
        for (b = 0; b <= 15; b++) 
        { 
            /* if bit set in mask, then substitute reversed bit */ 
            if ((o & mask) != 0) 
                v = v | revb; 

            /* advance to next bit */ 
            revb = (revb >> 1);
            mask = (mask << 1);
        }

        /* store reversed bits */ 
        tree->entry[i].Code = v; 
    }
}


/* ----------------------------------------------------------- */ 

void LoadTree(tree, treesize)
sf_tree *tree;
int treesize;
/* allocate and load a shannon-fano tree from the compressed file */ 
{ 

    tree->entries = treesize; 
    ReadLengths(tree); 
    SortLengths(tree); 
    GenerateTrees(tree); 
    ReverseBits(tree); 
}


/* ----------------------------------------------------------- */ 

void LoadTrees()
{ 
    eightK_dictionary = (lrec.general_purpose_bit_flag & 0x02) != 0; /* bit 1 */
    lit_tree_present = (lrec.general_purpose_bit_flag & 0x04) != 0; /* bit 2 */

    if (eightK_dictionary) 
        dict_bits = 7;
    else 
        dict_bits = 6; 

    if (lit_tree_present) 
    { 
        minimum_match_length = 3; 
        LoadTree(&lit_tree,256); 
    }
    else 
        minimum_match_length = 2; 

    LoadTree(&length_tree,64); 
    LoadTree(&distance_tree,64); 
}


/* ----------------------------------------------------------- */ 

void ReadTree(tree, dest)
sf_tree *tree;
int *dest;
/* read next byte using a shannon-fano tree */ 
{ 
    int bits = 0;
    word cv = 0;
    int cur = 0;
    int b;

    *dest = -1; /* in case of error */


    for (;;)
    {
     /*   if(xflag || test || iflag)
        {
            outcount++;
            if (outcount >= printcount) 
            {
                print_count(zipfn, outcount,lrec.uncompressed_size);
                printcount += 1024L;
            }
        }
       */


        READBIT(1,b);
        cv = cv | (b << bits);
        bits++; 

        /* this is a very poor way of decoding shannon-fano.  two quicker
            methods come to mind:
               a) arrange the tree as a huffman-style binary tree with
                  a "leaf" indicator at each node,
            and
               b) take advantage of the fact that s-f codes are at most 8
                  bits long and alias unused codes for all bits following
                  the "leaf" bit.
         */

        while (tree->entry[cur].BitLength < bits) 
        { 
            cur++; 
            if (cur >= tree->entries) 
                return; /* data error */
        }

        while (tree->entry[cur].BitLength == bits) 
        { 
            if (tree->entry[cur].Code == cv) 
            { 
                *dest = tree->entry[cur].Value; 
                return; 
            }

            cur++; 
            if (cur >= tree->entries) 
                return; /* data error */
        }
    }
}


/* ----------------------------------------------------------- */ 

void unImplode()
/* expand imploded data */ 

{ 
    int lout;
    longint op;
    int Length;
    int Distance;
    int i;
    int c = 0;

    LoadTrees(); 

    while ((!zipeof) && ((outpos+outcnt) < lrec.uncompressed_size))
    { 


        READBIT(1,lout);

        if (lout != 0) /* encoded data is literal data */
        { 
            if (lit_tree_present){ /* use Literal Shannon-Fano tree */
                ReadTree(&lit_tree,&lout);
c++;
              if (lit_tree_present && eightK_dictionary)
              {
                switch (lout) {

                case 1:
                    { /* check-mark */
                        lout = 195;
                    }
                    break;

                case 2:
                    { /* check-mark */
                        lout = 196;
                    }
                    break;

                case 3:/* ^Z */
                    {
                        lout = 197;
                    }
                    break;

                case 4:
                    { /* % */

                        lout = 198;
                    }
                    break;

                case 5:
                    { /* % */

                        lout = 199;
                    }
                    break;

                case 6:
                    { /**/
                        lout = 200;
                    }
                    break;

                case 7:/* ^L  */
                    {
                        lout = 201;
                    }
                    break;

                case 8:
                    { /**/
                        lout = 202;
                    }
                    break;

                case 11:/* ^Z */
                    {
                        lout = 203;
                    }
                    break;

                case 12:/* ^Z */
                    {
                        lout = 204;/*arthur 37 */
                    }
                    break;

                case 14:/* ^Z */
                    {
                        lout = 205;/*arthur 37 */
                    }
                    break;

                case 15:
                    { /* check-mark */
                        lout = 206;
                    }
                    break;

                case 16:/* ^Z */
                    {
                        lout = 207;
                    }
                    break;

                case 17:/* ^Z */
                    {
                        lout = 208;
                    }
                    break;

                case 18:/* ^Z */
                    {
                        lout = 209;
                    }
                    break;

                case 19:/* ^Z */
                    {
                        lout = 210;
                    }
                    break;

                case 20:/* ^Z */
                    {
                        lout = 211;
                    }
                    break;

                case 21:/* ^Z */
                    {
                        lout = 212;
                    }
                    break;

                case 22:/* ^Z */
                    {
                        lout = 213;
                    }
                    break;

                case 23:/* ^Z */
                    {
                        lout = 214;
                    }
                    break;

                case 24:/* ^Z */
                    {
                        lout = 215;
                    }
                    break;

                case 25:/* ^Z */
                    {
                        lout = 216;
                    }
                    break;

               case 26:
                    { /* ~ */
                        lout = 255;
                    }
                    break;

                case 27:/**/
                    {
                        lout = 217;
                    }
                    break;

                case 28:
                    { /* @ */
                        lout = 218;
                    }
                    break;


                case 29:/* # */
                    {
                        lout = 219;
                    }
                    break;

               case 30:
                    { /* ~ */
                        lout = 220;
                    }
                    break;
 
               case 31:
                    { /* ~ */
                        lout = 221;
                    }
                    break;

                case 35:/* ^Z */
                    {
                        lout = 222;
                    }
                    break;

                case 37:/* ^Z */
                    {
                        lout = 223;
                    }
                    break;

                case 59:/* ^Z */
                    {
                        lout = 225;
                    }
                    break;

                case 64:
                    { /* % */

                        lout = 229;
                    }
                    break;

                case 94:
                    { /* % */

                        lout = 233;
                    }
                    break;

                case 96:/* ^Z */
                    {
                        lout = 238;
                    }
                    break;

                case 125:
                    { /* ; */
                        lout = 242;
                    }
                    break;


                case 126:
                    { /* ; */
                        lout = 243;
                    }
                    break;

                case 127:
                    { /* @ */
                        lout = 244;
                    }
                    break;

                case 128:
                    { /* @ */
                        lout = 26;
                    }
                    break;

                case 129:
                    { /* @ */
                        lout = 128;
                    }
                    break;

                case 130:
                    { /* ^ */
                        lout = 129;
                    }
                    break; 

                case 131:
                    { /* ^ */
                        lout = 130;
                    }
                    break; 

                case 132:
                    { /**/
                        lout = 131;
                    }
                    break; 

                case 133:
                    { /* % */

                        lout = 132;
                    }
                    break;

                case 134:/* ^Z */
                    {
                        lout = 133;
                    }
                    break;

                case 135:
                    {
                        lout = 134;/*136*/
                    }
                    break;

                case 136:
                    {
                        lout = 135;
                    }
                    break;

               case 137:
                    { /* ~ */
                        lout = 136;
                    }
                    break;

                case 138:
                    { /**/
                        lout = 137;
                    }
                    break; 

                case 139:
                    { /* ` */
                        lout = 138;/*242*/
                    }
                    break;

               case 140:
                    { 
                        lout = 139;
                    }
                    break;

                case 141:
                    { /**/
                        lout = 140;
                    }
                    break; 

               case 142:
                    { /* ~ */
                        lout = 141;
                    }
                    break;

               case 143:
                    { /* ~ */
                        lout = 142;
                    }
                    break;
 
                case 144:
                    { /**/
                        lout = 143;
                    }
                    break; 

                case 145:/* ^Z */
                    {
                        lout = 144;
                    }
                    break;

                case 146:/* ^Z */
                    {
                        lout = 145;
                    }
                    break;

               case 147:
                    { /* ~ */
                        lout = 146;
                    }
                    break;
 
               case 148:
                    { /* ~ */
                        lout = 147;
                    }
                    break;

                case 149:
                    { /* ^ */
                        lout = 148;
                    }
                    break; 

                case 150:
                    { /* ^ */
                        lout = 149;
                    }
                    break; 

               case 151:
                    { /* ~ */
                        lout = 150;
                    }
                    break;

               case 152:
                    { /* ~ */
                        lout = 151;
                    }
                    break;

                case 153:
                    { /**/
                        lout = 152;
                    }
                    break; 

                case 154:
                    { /* % */

                        lout = 153;
                    }
                    break;

               case 155:
                    { /* ~ */
                        lout = 154;
                    }
                    break;

               case 156:
                    { /* ~ */
                        lout = 155;
                    }
                    break;

                case 157:
                    { /**/
                        lout = 156;
                    }
                    break; 

               case 158:
                    { /* ~ */
                        lout = 157;
                    }
                    break;

                case 159:/* ^Z */
                    {
                        lout = 158;
                    }
                    break;

                case 160:/* ^Z */
                    {
                        lout = 159;
                    }
                    break;

                case 161:
                    { /**/
                        lout = 160;
                    }
                    break; 

                case 162:
                    { /* % */

                        lout = 161;
                    }
                    break;

               case 163:
                    { /* ~ */
                        lout = 162;
                    }
                    break;
 
               case 164:
                    { /* ~ */
                        lout = 163;
                    }
                    break;
 
               case 165:
                    { /* ~ */
                        lout = 164;
                    }
                    break;

                case 166:
                    { /**/
                        lout = 165;
                    }
                    break; 

                case 167:
                    { /**/
                        lout = 166;
                    }
                    break; 

                case 168:
                    { /**/
                        lout = 167;
                    }
                    break; 

                case 169:
                    { /**/
                        lout = 168;
                    }
                    break; 

                case 170:
                    { /* ~ */
                        lout = 169;
                    }
                    break;

               case 171:
                    { /* ~ */
                        lout = 170;/*arthur*/
                    }
                    break;

                case 172:/* ^Z */
                    {
                        lout = 171;
                    }
                    break;

               case 173:
                    { /* ~ */
                        lout = 172;
                    }
                    break;
 
                case 174:
                    { /**/
                        lout = 173;
                    }
                    break; 

               case 175:
                    { /* ~ */
                        lout = 174;
                    }
                    break;
 
               case 176:
                    { /* ~ */
                        lout = 1;
                    }
                    break;

                case 177:
                    { /* % */

                        lout = 2;
                    }
                    break;

                case 178:
                    { /* ~ */
                        lout = 3;
                    }
                    break;

                case 179:
                    { /* ~ */
                        lout = 4;
                    }
                    break;

                case 180:
                    { /* % */

                        lout = 5;
                    }
                    break;

                case 181:
                    { /* ~ */
                        lout = 6;
                    }
                    break;

               case 182:
                    { /* ~ */
                        lout = 7;
                    }
                    break;

                case 183:
                    { /* % */

                        lout = 8;
                    }
                    break;

                case 184:/* ^Z */
                    {
                        lout = 11;/*arthur 37 */
                    }
                    break;

               case 185:
                    { /* ~ */
                        lout = 12;
                    }
                    break;

                case 186:
                    { /* ~ */
                        lout = 14;
                    }
                    break;

                case 187:/* ^Z */
                    {
                        lout = 15;
                    }
                    break;

                case 188:/* ^Z */
                    {
                        lout = 16;/*arthur 225*/
                    }
                    break;

               case 189:
                    { /* ~ */
                        lout = 17;
                    }
                    break;

                case 190:/* ^Z */
                    {
                        lout = 18;
                    }
                    break;

                case 191:
                    { /* % */

                        lout = 19;
                    }
                    break;

                case 192:/* ^Z */
                    {
                        lout = 20;
                    }
                    break;

                case 193:
                    { /* % */

                        lout = 21;/*252*/
                    }
                    break;

               case 194:
                    { /* ~ */
                        lout = 22;
                    }
                    break;

               case 195:
                    { /* ~ */
                        lout = 23;
                    }
                    break;

                case 196:/* ^Z */
                    {
                        lout = 24;
                    }
                    break;

                case 197:/* ^Z */
                    {
                        lout = 25;
                    }
                    break;

                case 198:/* ^Z */
                    {
                        lout = 27;
                    }
                    break;

                case 199:/* ^Z */
                    {
                        lout = 28;
                    }
                    break;

                case 200:
                    { /* % */

                        lout = 29;
                    }
                    break;

                case 201:
                    { /* ~ */
                        lout = 30;
                    }
                    break;

                case 202:
                    { /* % */

                        lout = 31;
                    }
                    break;

                case 203:/* ^Z */
                    {
                        lout = 35;
                    }
                    break;

               case 204:
                    { /* ~ */
                        lout = 37;
                    }
                    break;

               case 205:
                    { /* ~ */
                        lout = 59;
                    }
                    break;

                case 206:
                    { /* % */

                        lout = 64;
                    }
                    break;

               case 207:
                    { /* ~ */
                        lout = 94;
                    }
                    break;

                case 208:
                    { /* % */

                        lout = 96;
                    }
                    break;

                case 209:
                    { /* ^ */
                        lout = 125;
                    }
                    break; 

                case 210:
                    { /* ~ */
                        lout = 126;/*139*/
                    }
                    break;

                case 211:
                    { /* % */

                        lout = 127;
                    }
                    break;

                case 212:
                    { /* ^ */
                        lout = 176;
                    }
                    break; 

               case 213:
                    { /* ~ */
                        lout = 177;
                    }
                    break;

               case 214:
                    { /* ~ */
                        lout = 178;/*252*/
                    }
                    break;
 
               case 215:
                    { /* ~ */
                        lout = 179;
                    }
                    break;

                case 216:/**/
                    {
                        lout = 180;
                    }
                    break;

               case 217:
                    { /* ~ */
                        lout = 181;/*arthur171*/
                    }
                    break;

                case 218:/**/
                    {
                        lout = 182;
                    }
                    break;

                case 219:
                    { /* ^ */
                        lout = 183;
                    }
                    break; 

               case 220:
                    { /* ~ */
                        lout = 184;
                    }
                    break;

               case 221:
                    { /* ~ */
                        lout = 185;
                    }
                    break;

               case 222:
                    { /* ~ */
                        lout = 186;
                    }
                    break;

                case 223:/* ^Z */
                    {
                        lout = 187;
                    }
                    break;

                case 224:/* ^Z */
                    {
                        lout = 175;
                    }
                    break;

               case 225:
                    { /* ~ */
                        lout = 188;
                    }
                    break;

                case 226:
                    { /* % */

                        lout =224;
                    }
                    break;

                case 227:
                    { /* % */

                        lout = 226;
                    }
                    break;

                case 228:
                    { /* ~ */
                        lout = 227;
                    }
                    break;

                case 229:/**/
                    {
                        lout = 189;
                    }
                    break;

                case 230:
                    { /* ^ */
                        lout = 228;
                    }
                    break; 

                case 231:
                    { /* ^ */
                        lout = 230;
                    }
                    break; 

               case 232:
                    { /* ~ */
                        lout = 231;
                    }
                    break;

                case 233:
                    { /* ~ */
                        lout =190;
                    }
                    break;

                case 234:
                    { /* ~ */
                        lout = 232;
                    }
                    break;

               case 235:
                    { /* ~ */
                        lout = 234;
                    }
                    break;

                case 236:/* ^Z */
                    {
                        lout = 235;
                    }
                    break;

                case 237:
                    { /* ~ */
                        lout = 236;
                    }
                    break;

                case 238:
                    { /* ~ */
                        lout = 191;
                    }
                    break;

               case 239:
                    { /* ~ */
                        lout = 237;
                    }
                    break;

                case 240:
                    { /* % */

                        lout = 239;
                    }
                    break;

                case 241:
                    { /* % */

                        lout = 240;
                    }
                    break;

               case 242:
                    { /* ~ */
                        lout = 192;
                    }
                    break;

                case 243:
                    { /* % */

                        lout = 193;/*242*/
                    }
                    break;

                case 244:
                    { /* ^ */
                        lout = 194;
                    }
                    break; 

                case 245:
                    { /* ~ */
                        lout = 241;/*arthur*/
                    }
                    break;

                case 246:
                    { /* ~ */
                        lout = 245;
                    }
                    break;

                case 247:
                    { /* ~ */
                        lout = 246;
                    }
                    break;

                case 248:
                    { /* ~ */
                        lout = 247;
                    }
                    break;

                case 249:
                    { /* ~ */
                        lout = 248;
                    }
                    break;

                case 250:
                    { /* ~ */
                        lout = 249;
                    }
                    break;

               case 251:
                    { /* ~ */
                        lout = 250;
                    }
                    break;
 
                case 252:
                    { /* ~ */
                        lout = 251;
                    }
                    break;

                case 253:
                    { /* ~ */
                        lout = 252;/*193*/
                    }
                    break;

                case 254:
                    { /* ~ */
                        lout = 253;
                    }
                    break;
                case 255:
                    { /* ~ */
                        lout = 254;
                    }
                    break;
                }
              }  
              else
              {
                switch (lout) {


                case 128:/* ^Z */
                    {
                        lout = 26;
                    }
                    break;

                case 183:
                    { /* check-mark */
                        lout = 8;
                    }
                    break;

                case 185:/* ^L  */
                    {
                        lout = 12;
                    }
                    break;

                case 203:/* # */
                    {
                        lout = 35;
                    }
                    break;

                case 204:
                    { 

                        lout = 37;
                    }
                    break;

                case 205:
                    { /* ; */
                        lout = 59;
                    }
                    break;

                case 206:
                    { /* @ */
                        lout = 64;
                    }
                    break;

                case 207:
                    { /* ^ */
                        lout = 94;
                    }
                    break; 

                case 208:
                    { /* ` */
                        lout = 96;
                    }
                    break;

                case 209:
                    { /* } */
                        lout = 125;
                    }
                    break;
                case 210:
                    { /* ~ */
                        lout = 126;
                    }
                    break;

                case 227:
                    { /* % */

                        lout = 3;
                    }
                    break;
                }
             }

            }
            else 
                READBIT(8,lout);


            if(more)
            {
                OutByte(lout);
            }
            else 
                OUTB(lout);
        }
        else /* encoded data is sliding dictionary match */
        { 
            READBIT(dict_bits,lout);
            Distance = lout; 

            ReadTree(&distance_tree,&lout); 
            Distance |= (lout << dict_bits);
            /* using the Distance Shannon-Fano tree, read and decode the
                            upper 6 bits of the Distance value */ 

            ReadTree(&length_tree,&Length); 
            /* using the Length Shannon-Fano tree, read and decode the
                            Length value */

            Length += minimum_match_length; 
            if (Length == (63 + minimum_match_length)) 
            { 
                READBIT(8,lout);
                Length += lout; 
            }

            /* move backwards Distance+1 bytes in the output stream, and copy
               Length characters from this position to the output stream.
              (if this position is before the start of the output stream,
              then assume that all the data before the start of the output
                stream is filled with zeros) */ 
            if(more)
            {
                op = (outpos - Distance) - 1L; 
                for (i = 1; i <= Length; i++) 
                { 
                    if (op < 0L) 
                        OutByte(0); 
                    else 
                        OutByte(m_outbuf[op % sizeof(m_outbuf)]); 
                    if(nomore)
                        return;
                    op++; 
                }
            }
            else{ 

                op = (outpos+outcnt) - Distance - 1L;

                /* special case- before start of file */
                while ((op < 0L) && (Length > 0))
                { 
                    OUTB(0);
                    op++;
                    Length--;
                }

                /* normal copy of data from output buffer */
                {
                    register int ix = (int) (op % OUTBUFSIZ);

                    /* do a block memory copy if possible */
                    if ( ((ix +Length) < OUTBUFSIZ) &&
                        ((outcnt+Length) < OUTBUFSIZ) ) {
                        memcpy(outptr,&outbuf[ix],Length);
                        outptr += Length;
                        outcnt += Length;
                    }

                    /* otherwise copy byte by byte */
                    else while (Length--)
                    { 
                        OUTB(outbuf[ix]);
                        if (++ix >= OUTBUFSIZ)
                            ix = 0;
                    }
                }
            }
        }
    }
   /* outcount = 0L;
    printcount = 0L;
    */
}
