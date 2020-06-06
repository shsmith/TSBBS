


(*******************************************************
 *
 * Description:
 *
 *    This file contains the main program of the 'D1' compiler.
 *    D1 is a small language which adopts much of the vocabulary
 *    of Pascal.  This language was inspired by the compiler
 *    construction articles in Nov'85 and Dec'85 issues of
 *    Computer Language magazine.
 *
 *
 * Revision History
 * ----------------
 *
 *   9-dec-85 s.h.smith initial coing
 *
 *
 *)



(*$V+       compiler option to not require string parameters
 *          to match declared length; default +  *)

(*$R-       compiler option to check ranges and subscripts; default -  *)

(*$D-       compiler option to allow file buffering to devices; default +  *)



program compiled1 (infile, outfile, display, keyboard);


{$I data.inc}      {data declarations}
{$I utility.inc}   {utility procedures}
{$I opc6801.inc}   {define opcodes for motorola 6801}
{$I opt6801.inc}   {code optimizer for 6801}
{$I codegen.inc}   {general code generator}
{$I scanner.inc}   {lexical scanner}
{$I symtable.inc}  {symbol table maintenance}
{$I parsexp.inc}   {parser for expressions}
{$I parsstmt.inc}  {parser for variables, statements and programs}


begin                        { main block }
   initialize;
   openfiles;
   parseprogram;
   closefiles;
end.

