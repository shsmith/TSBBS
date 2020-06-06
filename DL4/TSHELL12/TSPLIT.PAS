
(*
 * TSPLIT - divide a single large file into many smaller files
 *
 * Used primarily with the output of TPP when all includes combined
 * are too large for turbo pascal to handle.
 *
 * S.H.Smith, 27-Mar-87
 *
 *)


const
   lines_per_file = 500;
   max_lines      = 2000;

type
   anystring = string[128];

var
   line:    anystring;
   base:    anystring;
   source:  anystring;
   infd:    text[20480];
   lineno:  integer;
   fileno:  integer;
   outfile: anystring;
   outfd:   text[2048];
   mainfd:  text[2048];

#include <strutil.inc>   {string utilities}
#include <incdec.inc>    {increment and decrement scalars}


procedure start_next_file;
begin
   str(fileno,outfile);
   INCR(fileno);
   if LEN(outfile) = 1 then
      outfile := '0' + outfile;

   outfile := base + '.P' + outfile;
   assign(outfd,outfile);
   rewrite(outfd);

   writeln(mainfd,'{$I ',outfile,'}');
   writeln(outfile);
   lineno := 0;
end;


begin
   if paramcount <> 2 then
   begin
      writeln;
      writeln('TSPLIT - Split up TPP output files, Compiled: SYSTEM_DATE');
      writeln;
      writeln('Usage:  TSPLIT sourcename outname');
      halt;
   end;

   source := paramstr(1);
   base := paramstr(2);

   assign(infd,source);
   {$i-} reset(infd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Cant open input file: ',source);
      halt;
   end;

   assign(mainfd,base+'.PAS');
   rewrite(mainfd);
   writeln(base + '.PAS');
   fileno := 0;
   lineno := 0;

   while not eof(infd) do
   begin
      readln(infd,line);

      INCR(lineno);

      if (lineno > lines_per_file) then
      begin
         if (copy(line,1,9) = '{#line 1 ') then
         begin
            if fileno <> 0 then
               close(outfd);
            start_next_file;
         end
         else

         if (lineno > max_lines) then
         begin
            if fileno <> 0 then
               close(outfd);
            writeln('Warning: too many lines for a normal split');
            start_next_file;
         end;
      end;

      if fileno = 0 then
         writeln(mainfd,line)
      else
         writeln(outfd,line);
   end;

   close(outfd);
   close(mainfd);
   close(infd);
end.
