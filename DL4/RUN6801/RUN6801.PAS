

(*******************************************************
 *
 * Description:
 *
 *    This file contains the main program of a simple 6801
 *    interpreter.  This program will be used to test the
 *    operation of the 'D1' compiler.
 *
 *
 * Revision History
 * ----------------
 *
 *   18-dec-85 s.h.smith initial coing
 *
 *
 *)



(*$V+       compiler option to not require string parameters
 *          to match declared length; default +  *)

(*$R+       compiler option to check ranges and subscripts; default -  *)

(*$D-       compiler option to allow file buffering to devices; default +  *)

(*$C-       compiler option to disable ^C and ^S checks  *)

(*$P512     compiler option to buffer output to stdout *)


program run6801 (objfile, display, keyboard);


{$I runutil.inc}   {interpreter utilities}
{$I runload.inc}   {pass 1 to load emulation memory}
{$I runexec.inc}   {pass 2 to execute the program}

begin                        { main block }

   initialize;   { do basic inits}
   loadmem;      { make the first pass to build symbol tables }
   runexecprog;  { execute the program }

end.

