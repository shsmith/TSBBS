
{sizes - filter to print sizes of files listed in standard input}

{$p80,g1024,d-}

#include <anystring.inc>
#include <regpack.inc>
#include <filesize.inc>
#include <getfdate.inc>


var
   name:  anystring;
   line:  anystring;
   total: real;
   size:  real;
   dates: anystring;
   n:     integer;
   i:     integer;

begin
   writeln;
   writeln('  Date     Time    Size      Path');
   writeln('-------- --------  ----  -----------');

   total := 0.0;
   n := 0;

   while not eof do
   begin
      readln(line);

      name := '';
      for i := 1 to length(line) do
         if line[i] in [#33..'~'] then
            name := name + upcase(line[i]);

      size := file_size(name);
      total := total + size;

      dates := get_file_date(name);
      n := n + 1;

      writeln(dates,'  ',size/1024.0:4:0,'  ',name);
   end;

   writeln;
   writeln('Total of ',total/1024.0:0:0,' K bytes used by ',n,' files');
   flush(output);
end.

