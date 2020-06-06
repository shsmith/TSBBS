
(*
 * TPTCSYS.PAS - System unit for use with Turbo Pascal --> C Translator
 *
 * (C) 1988 S.H.Smith (rev. 07-Apr-88)
 *
 * This unit is compiled to create 'TPTCSYS.UNS' and 'TPTCSYS.UNH', which
 * are automatically loaded on each TPTC run.   It defines the predefined
 * environment from which programs are translated.
 *
 * Compile with:
 *    tptc tptcsys -L -NU
 *
 * Note: the special 'as replacement_name' clause used in some cases.
 * When present, this clause causes the replacement_name to be used in
 * place of the original name in the translated output.
 *
 * Note: the special 'symtype <typename>' clause forces the declared symbol 
 * type to the specified typename.  This is used when adding detail to 
 * standard builtin identifiers (such as text).
 *
 * Lines starting with "\" are passed directly to the C object file
 * without any translation.
 *
 *)

unit tptcsys;

interface

   const
      maxint = $7fff;


(*
 * C language declarations passed directly to TPTCSYS.UNH
 *
 *)

\  #undef extern

\  #include <stdio.h>

\  #ifdef IN_TPTCSYS
\  #define extern
\  #endif

\  #define chr(n)          ((char)(n))
\  #define integer         int
\  #define word            unsigned
\  #define longint         long
\  #define real            double
\  #define boolean         int
\  #define false           0
\  #define true            1
\  #define nil             NULL
\  #define STRSIZ 255      /* default string length */

\  /* set support */
\  #define __  -2    /* thru .. */
\  #define _E  -1    /* end of set marker */


   type
      byte = 0..$FF;
      shortint = byte;
      pointer = ^char;
      setrec = pointer;
\     typedef char *string;

      text = record    
         fname:   string[64];    (* the actual filename *)
\        FILE     *filevar;      /* C's file variable */
      end symtype text;

   var
      Output:     text;
      Input:      text;
      ParamCount: integer;
      IoResult:   word;
      tptc_argv:  ^pointer;
      dseg:       word;
      sseg:       word;
      cseg:       word;


   (* 
    * Standard procedures and functions
    *
    *)
   
   function Sin(n: real): real;
   function Cos(n: real): real;
   function Tan(n: real): real;
   function Sqr(n: real): real;
   function Sqrt(n: real): real;
   function Trunc(r: real): longint;
   function Round(r: real): real;
   function Int(r: real): real            as dint;

   function Pred(b: integer): integer;
   function Succ(b: integer): integer;
   function Ord(c: char): integer;
   function Hi(w: word): word;
   function Lo(w: word): word;
   procedure Inc(var b: byte);
   procedure Dec(var b: byte);

   function MemAvail: longint;
   function MaxAvail: longint;
   procedure Dispose(ptr: pointer);
   procedure FreeMem(ptr: pointer; size: integer) as PfreeMem;
      
   function ParamStr(n: integer): string;
   function UpCase(c: char): char;
   procedure Delete(s: string; posit,number: integer);
   function Copy(s: string; from,len: integer): string;
   procedure Val(s: string; var res: real; var code: integer);
   procedure Move(tomem, fmmem: pointer; bytes: word);
   procedure FillChar(dest: pointer; size: integer; value: char);
   function Length(s: string): integer;


   (*
    * These will probably change when binary file translation is implemented
    *
    *)

   function Eof(var fd: text): boolean;
   procedure Flush(var fd: text);
   procedure Close(var fd: text);
   procedure Assign(var fd: text; name: string);
   procedure Reset(var fd: text);
   procedure ReWrite(var fd: text);
   procedure Append(var fd: text);
   procedure SetTextBuf(var fd: text; buffer: pointer; size: word);
   procedure Seek(var fd: text; rec: word);
   function SeekEof(var fd: text): boolean;



   (* 
    * Additional procedures called by translated code 
    *
    *)
   
\  setrec setof(byte element,...);
      {construct a set; variable parameter list}

   function inset(item: byte; theset: setrec): boolean;
      {is an item a member of a set?}

   function spos(str1, str2: string): integer;
      {returns the position of a substring within a longer string}
      
   function cpos(c: char; str2: string): integer;
      {returns the position of a character within a string}
      
   function ctos(c: char): string;
      {convert a character into a string}

      
\  string scat(string control, ...);
      {concatenate strings according to printf style control and
       return pointer to the result}
       
\  void sbld(string dest,
\            string control, ...);
      {build a string according to a control string (works like sprintf
       with with special handling to allow source and destination
       variables to be the same)}
       
\  int tscanf(text *fd,
\             string control, ...);
      {functions like fscanf but allows whole-line reads into
       string variables}
       
\  void tprintf(text *fd,
\               string control, ...);
      {functions like fprintf}
       


   (* The following identfiers are 'builtin' to the translator and
      should not be defined here.  If any of these are redefined, the
      corresponding special translation will be disabled. *)
      
   (* 
    *   function Pos(key: string; line: string): integer;
    *   procedure Chr(i: integer): char;
    *   procedure Str(v: real; dest: string);
    *   procedure Exit;
    *
    *   var 
    *      Mem:    array[0..$FFFF:0..$FFFF] of byte;
    *      MemW:   array[0..$FFFF:0..$FFFF] of word;
    *      Port:   array[0..$1000] of byte; {i/o ports}
    *      PortW:  array[0..$1000] of word;
    *   type
    *      string = array[1..255] of char;
    *
    *)


\  /*
\   * rename some tp4 identifiers that conflict with tc1.0 identifiers
\   */
\  #define intr    Pintr
\  #define getdate Pgetdate
\  #define gettime Pgettime
\  #define setdate Psetdate
\  #define settime Psettime
\  #define keep    Pkeep

      
(*
 * Implementation of support procedures
 *
 *)

implementation

\  #include <stdlib.h>
\  #include <string.h>
\  #include <stdarg.h>
\  #include <dos.h>
\  #include <conio.h>
\  #include <ctype.h>
\  #include <alloc.h>


   (*
    * String/character concatenation function
    *
    * This function takes a sprintf-like control string, a variable number of
    * parameters, and returns a pointer a static location where the processed
    * string is to be stored.
    *
    *)

\  string scat(string control, ...)
\  {
\     static char buf[STRSIZ];
\     char buf2[STRSIZ];
\     va_list args;
\
\     va_start(args, control);     /* get variable arg pointer */
\     vsprintf(buf2,control,args); /* format into buf with variable args */
\     va_end(args);                /* finish the arglist */
\
\     strcpy(buf,buf2);
\     return buf;                  /* return a pointer to the string */
\  }


   (*
    * string build - like scat, sprintf, but will not over-write any
    *                input parameters
    *)
\  void sbld(string dest,
\            string control, ...)
\  {
\     char buf[STRSIZ];
\     va_list args;
\
\     va_start(args, control);     /* get variable arg pointer */
\     vsprintf(buf,control,args);  /* format into buf with variable args */
\     va_end(args);                /* finish the arglist */
\
\     strcpy(dest,buf);            /* copy result */
\  }



   (*
    * spos(str1,str2) - returns index of first occurence of str1 within str2;
    *    1=first char of str2
    *    0=nomatch
    *)
   function spos(str1, str2: string): integer;
      {returns the position of a substring within a longer string}
   begin
\     string res;
\     res = strstr(str2,str1);
\     if (res == NULL)
\        return 0;
\     else
\        return res - str2 + 1;
   end;


   (*
    * cpos(str1,str2) - returns index of first occurence of c within str2;
    *    1=first char of str2
    *    0=nomatch
    *)
   function cpos(c: char; str2: string): integer;
      {returns the position of a character within a string}
   begin
\     string res;
\     res = strchr(str2,c);
\     if (res == NULL)
\        return 0;
\     else
\        return res - str2 + 1;
   end;


   function Copy(s: string; from,len: integer): string;
      {copy len bytes from the dynamic string dstr starting at position from}
   begin
\     static char buf[STRSIZ];
\     buf[0]=0;
\     if (from>strlen(s))       /* copy past end gives null string */
\        return buf;
\
\     strcpy(buf,s+from-1);    /* skip over first part of string */
\     buf[len] = 0;            /* truncate after len characters */
\     return buf;
   end;

   procedure Move(tomem, fmmem: pointer; bytes: word);
   begin
\     while (bytes--)
\        *tomem++ = *fmmem++;
   end;

   procedure FillChar(dest: pointer; size: integer; value: char);
   begin
\     while (size--)
\        *dest++ = value;
   end;

   function Length(s: string): integer;
   begin
\     return strlen(s);
   end;

   function ctos(c: char): string;
      {convert a character into a string}
   begin
\     static char s[2];
\     s[0] = c;
\     s[1] = 0;
\     return s;
   end;
   
   function UpCase(c: char): char;
   begin
\     if (islower(c))
\        c = toupper(c);
      UpCase := c;
   end;


   (*
    * This function operate like fscanf except for an added control
    * code used for full-line reads.
    *
    *)
\  int tscanf(text *fd,
\             string control, ...)
\  {
\     va_list args;
\     string arg1;
\     int     i;
\
\     va_start(args, control);     /* get variable arg pointer */
\
\     /* process special case for full-line reads (why doesn't scanf allow
\        full-line string reads?  why don't gets and fgets work the same?) */
\     if (*control == '#') {
\        arg1 = va_arg(args,string);
\        fgets(arg1,STRSIZ,fd->filevar);
\        arg1[strlen(arg1)-1] = 0;
\        return 1;
\     }
\
\     /* pass the request on to fscanf */
\     i = vfscanf(fd->filevar,control,args);    /* scan with variable args */
\     va_end(args);                             /* finish the arglist */
\
\     return i;                        /* return a pointer to the string */
\  }


\  void tprintf(text *fd,
\               string control, ...)
\  {
\     va_list args;
\     va_start(args, control);               /* get variable arg pointer */
\     vfprintf(fd->filevar,control,args);    /* scan with variable args */
\     va_end(args);                          /* finish the arglist */
\  }
 
      

   (* 
    * Standard procedures and functions
    *
    *)
   
   function Sqr(n: real): real;
   begin
      Sqr := n * n;
   end;

   function Trunc(r: real): longint;
   begin
      Trunc := longint(r);
   end;

   function Round(r: real): real;
   begin
      Round := real(longint(r + 0.5));
   end;

   function Pred(b: integer): integer;
   begin
      Pred := b - 1;
   end;

   function Succ(b: integer): integer;
   begin
      Succ := b + 1;
   end;

   function Ord(c: char): integer;
   begin
      Ord := integer(c);
   end;

   function Hi(w: word): word;
   begin
      Hi := w shr 8;
   end;

   function Lo(w: word): word;
   begin
      Lo := w and $FF;
   end;

   procedure Inc(var b: byte);
   begin
      b := b + 1;
   end;

   procedure Dec(var b: byte);
   begin
      b := b - 1;
   end;

   function MemAvail: longint;
   begin
\     return coreleft();
   end;

   function MaxAvail: longint;
   begin
\     return coreleft();
   end;

   procedure Dispose(ptr: pointer);
   begin
\     free(ptr);
   end;

   procedure FreeMem(ptr: pointer; size: integer) as PfreeMem;
   begin
\     free(ptr);     
   end;

   function ParamStr(n: integer): string;
   begin
\     return tptc_argv[n];
   end;
   
   procedure Delete(s: string; posit,number: integer);
   begin
\     strcpy(s+posit-1,s+posit+number-2);
   end;

   procedure Val(s: string; var res: real; var code: integer);
   begin
      res := atof(s);
      code := 0;
   end;

   function Int(r: real): real            as dint;
   begin
      Int := real(longint(r));
   end;


   (*
    * These will probably change when binary file translation is implemented
    *
    *)

   function Eof(var fd: text): boolean;
   begin
\     return feof(fd->filevar);
   end;

   procedure Flush(var fd: text);
   begin
\     fflush(fd->filevar);
   end;

   procedure Close(var fd: text);
   begin
\     fclose(fd->filevar);
   end;

   procedure Assign(var fd: text; name: string);
   begin
      fd.fname := name;
   end;

   procedure Reset(var fd: text);
   begin
\     fd->filevar = fopen(fd->fname,"r");
\     ioresult = (fd->filevar) == NULL;
   end;

   procedure ReWrite(var fd: text);
   begin
\     fd->filevar = fopen(fd->fname,"w");
\     ioresult = (fd->filevar) == NULL;
   end;
   
   procedure Append(var fd: text);
   begin
\     fd->filevar = fopen(fd->fname,"a");
\     ioresult = (fd->filevar) == NULL;
   end;

   procedure SetTextBuf(var fd: text; buffer: pointer; size: word);
   begin
\     setvbuf(fd->filevar,buffer,_IOFBF,size);
   end;

   procedure Seek(var fd: text; rec: word);
   begin
      {stubbed}
   end;

   function SeekEof(var fd: text): boolean;
   begin
      {stubbed}
   end;



   (* 
    * Additional procedures called by translated code 
    *
    *)
   
\  setrec setof(byte element,...)
\  {
\     /* stubbed */
\  }

   function inset(item: byte; theset: setrec): boolean;
   begin
      {stubbed}
   end;


(*
 * Top-level initialization
 *
 *)
begin
\  tptc_argv = argv;
\  paramcount = argc;
\  cseg = _CS;
\  sseg = _SS;
\  dseg = _DS;
\ /* input.filevar = stdin; */
\ /* output.filevar = stdout; */
end.

