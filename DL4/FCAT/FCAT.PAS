

(*
 * fcat - concatenate a list of text files into standard output
 * add filenames to start of each line
 *
 * shs 8/24/85
 *
 *)

{$p20480,d-,c-,r-}

var
   linecount:     integer;


#include <anystring.inc>
#include <regpack.inc>
#include <getfiles.inc>


procedure cpfile (filename:      filestring);
   var
      infile:        text [2048];
      line:          string [255];
      c:             char;
      p:             integer;
      l:             integer;

   begin
      write(con, filename);
      assign(infile, filename);
      reset(infile);

      p := pos('.',filename);
      if p > 0 then
         filename := copy(filename,1,p-1);

      while not eof (infile) do
      begin
         linecount := linecount + 1;
         readln(infile, line);

{        l := length(line);
         if l > 70 then
         begin
            line[0] := chr(70);
            l := 70;
         end;

         for p := 1 to l do
            line[p] := upcase(line[p]);

         writeln(line,'':70-l,';',filename);
}
         writeln(line,'':(80-length(line)),' ',filename);

         if keypressed then
         begin
            read(kbd, c);

            if c =^C then
            begin
               writeln(con, '** ^C');
               halt;
            end;
         end;
      end;

      close(infile);
      writeln;
      linecount := linecount + 1;
      flush(output);
      writeln(con);
   end;

procedure catfiles (pattern:       filestring);
   var
      i: integer;

   begin
      linecount := 0;
      getfiles(pattern, filetable, filecount);

      for i := 1 to filecount do
         cpfile(filetable [i]);

      write(con,filecount,' files concatenated, ');
      writeln(con,linecount,' output lines');
   end;



begin

   if paramcount <> 1 then
   begin
      writeln(con);
      writeln(con, 'usage: fcat SOURCE-FILE-LIST >OUTFILE');
      writeln(con);
      writeln(con, 'example: fcat *.pas,*.doc | find "MISC" >prn');
      writeln(con);
      writeln(con,' action: concatenates specified files to stdout,');
      writeln(con,'         prefixes each line with base filename of');
      writeln(con,'         original input file.  all lines are mapped to');
      writeln(con,'         upper case.  output is suitable for use with');
      writeln(con,'         DOS "find" utility.');
      halt;
   end;

   catfiles(paramstr (1));

end.
