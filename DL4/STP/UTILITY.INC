

(*******************************************************
 *
 * Subsystem:   Utility - utility and initialization procedures
 *
 * Overview
 * --------
 *
 *    Provides initialization, file handling and error
 *    reporting services for the rest of the compiler.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 shs  initial coding
 *   09-mar-86 shs  made smalltalk-80 version
 *
 *)



(*******************************************************
 *
 * Procedure:     closefiles
 *
 * Description:   flush and close all files in preparation
 *                for termination of the compiler.  also prints
 *                final compile statistics.
 *
 * Example:       closefiles;
 *
 *)

 procedure gen_finis;  forward;

 procedure closefiles;
 begin
   writeln(#13,linecount:4);

   gen_finis;


{$I-}
   close(infile);
   close(outfile);
   close(dclfile);
{$I+}
   if ioresult <> 0 then
      writeln('<output file lost>');

   writeln;
 end;



(**)
(*******************************************************
 *
 * Procedure:     error(message)
 *
 * Description:   display an error message, display
 *                the source line being processed and the current
 *                token type.   a better version of this procedure
 *                might also report what tokens were expected at
 *                the time of the error.
 *
 * Example:       error('bad character');
 *
 * Inputs:        error message
 *
 * Outputs:       compile is aborted
 *
 *)

 procedure error (problem:      anystring);
 begin
   closefiles;

   writeln('Error in line ', linecount, ':  ', problem);

   writeln('Source: ', sourceline);

   write  ('Token:  ',tk.name);
   if tk.name <> keywords[tk.code] then
      write('  (', keywords[tk.code], ')');
   writeln;

   halt;
 end;



(**)
(*******************************************************
 *
 * Procedure:     openfiles
 *
 * Description:   decode command line parameters and determine
 *                input and output file names.   opens these
 *                files if they are valid.   also decodes any
 *                command line options.
 *
 * Example:       openfiles;
 *
 *)

 procedure openfiles;
 var
   fileok:       boolean;
   infilename:   string [65];
   outfilename:  string [65];
   dclfilename:  string [65];
   i:            integer;
   param:        string [80];

 begin

   if paramcount = 0 then
   begin
      writeln('Usage: TRANSLATE source [object] [options]');
      writeln('options:  -C     ;Copy source to object as comments');
      halt;
   end;


   infilename := paramstr(1);
   if pos('.', infilename) = 0 then
      infilename := infilename + '.S';

   assign(infile, infilename);
{$I-}
   reset(infile);
{$I+}

   if ioresult <> 0 then
   begin
      writeln('Can''t open input file: '+infilename);
      halt;
   end;


   outfilename := copy(infilename,1,pos('.',infilename)-1);

   for i := 2 to paramcount do
   begin
      param := paramstr(i);
      if param[1] <> '-' then
         outfilename := param
      else

      case upcase(param[2]) of
         'C':  copysource := true;

         else
            writeln('Invalid parameter: ',param);
            halt;
      end;
   end;



   if pos('.', outfilename) = 0 then
      outfilename := outfilename + '.PAS';

   dclfilename := copy(outfilename,1,pos('.',outfilename)-1) + '.DCL';


   assign(outfile, outfilename);
{$I-}
   rewrite(outfile);
{$I+}

   if ioresult <> 0 then
   begin
      writeln('Can''t open output file: '+outfilename);
      halt;
   end;

   writeln(outfile);
   writeln(outfile,'{ '+outfilename+' - Made by ',compilerversion,' }');
   writeln(outfile);
   writeln(outfile,'{$I stplib.inc - STP library}');
   writeln(outfile,'{$I '+dclfilename+' - global declarations}');


   assign(dclfile, dclfilename);
{$I-}
   rewrite(dclfile);
{$I+}

   if ioresult <> 0 then
   begin
      writeln('Can''t open declare output file: '+dclfilename);
      halt;
   end;

   writeln(dclfile);
   writeln(dclfile,'{ '+dclfilename+' - Made by ',compilerversion,' }');
   writeln(dclfile);

   include := false;
   write('   1 source lines');
 end;




(**)
(*******************************************************
 *
 * Function:     itoa(integer): identstr
 *
 * Description:  function to convert an integer into an
 *               ascii string
 *
 * Example:      write('L' + itoa(labelnum));
 *
 * Inputs:       the integer to convert
 *
 * Outputs:      the converted string
 *
 *)

function itoa(i: integer): identstr;
var
   a:  identstr;

begin
   str(i:0, a);
   itoa := a;
end;

