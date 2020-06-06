
(*
 * fpr - print file with page formatting
 *
 * version 2
 * shs 8/3/85
 * removed blank pages, 24-jul-86 shs
 * changed name, now uses getfiles.inc, 13-nov-86 shs
 *
 *)

{$r-,s-}
{$m 20000,40000,40000}

uses dos, tools, bufio;

const
   version =      'FPR (6/6/92) - File Print Utility - (C)1985-1992 Samuel H. Smith';
   formfeed =     ^L;
   return =       ^M;
   linesperpage = 60;
   titlelen =     65;

type
   anystring =    string [128];
   intext =       buffered_file;

var
   pattern:       anystring;
   defdir:        anystring;
   rawtitle:      anystring;
   outfile:       text;
   outname:       anystring;
   totpage:       integer;

(*
 *
 * return the string equivelant of an integer value
 * with leading zeroes for a minimum width of 2
 *
 *)

function strval (int:           integer): anystring;
var
   tstr:          anystring;

begin
   str(int, tstr);

   if length (tstr)= 1 then
      strval := '0' + tstr
   else
      strval := tstr;
end;


(**)

(*
 *
 * given a valid filename, returns modification date and time
 *
 *)

procedure filedate (filename:      anystring;
                    var info:      anystring);
const
   month : array [1..12] of string[3]
           = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
              'Sep', 'Oct', 'Nov', 'Dec');

var
   cf, b1, b2,
   hr, mn,
   m, d, y:       integer;
   dta:           array [1..512] of byte;
   sval:          string [2];
   reg:           registers;

begin                       {set up disk transfer area}

   reg.ax := $1a00;
   reg.ds := seg (dta [1]);
   reg.dx := ofs (dta [1]);
   msdos(reg);              {fill up dta}

   filename := filename + null;
   reg.ax := $4e00;
   reg.cx := 39;
   reg.ds := seg (filename [1]);
   reg.dx := ofs (filename [1]);
   msdos(reg);
   cf := reg.flags and 1;

   if cf = 1 then
      info := '00-000-00 00:00'
   else
   begin
      b1 := ord (dta [25]);
      b2 := ord (dta [26]);
      d := b1 and 31;
      m :=(b1 shr 5)+ 8 *(b2 and 1);
      y :=(b2 shr 1)+ 80;

      b1 := ord (dta [23]);
      b2 := ord (dta [24]);
      mn :=(b1 shr 5)+ 8 *(b2 and 7);
      hr := b2 shr 3;
      info := strval (d)+ '-' + month [m]+ '-' + strval (y)+ ' ' +
              strval (hr)+ ':' + strval (mn);
   end;
end;


(*
 *
 * converts ascii string to an integer value
 *
 *)

function atoi (asc:           anystring): integer;
var
   code:          integer;
   value:         integer;

begin
   val(asc, value, code);
   atoi := value;
end;


(*
 *
 * centers a string around a given width
 *
 *)

procedure center (var str:       anystring;
                  width:         integer);
var
   front:         integer;
   back:          integer;

begin
   
   if length (str)> width then
      str[0]:= chr (width);
   
   back := width - length (str);
   front := back div 2;
   back := back - front;

   while front > 0 do
   begin
      str := ' ' + str;
      front := front - 1;
   end;

   while back > 0 do
   begin
      str := str + ' ';
      back := back - 1;
   end;
end;


(*
 *
 * decode command line and get options and title
 *
 *)

procedure getoptions;
var
   param:         integer;

begin
   rawtitle := '';
   outname := 'prn';        {default output file name}
   pattern := paramstr(1);  {file list pattern for input files}

   param := 2;

   while param <= paramcount do
   begin                       {check for page number option}

      
      if (paramstr (param)= '-O') or (paramstr (param)= '-o') then
      begin                       {check for output file option}
         
         outname := paramstr (param + 1);
         param := param + 1;
      end
      else                     {otherwise this is part of title}

         rawtitle := rawtitle + ' ' + paramstr (param);

      param := param + 1;
   end;
end;


(*
 *
 * print a single file
 * displays status on standard output while printing
 *
 *)


procedure printfd (var infile:    intext;
                   name:          anystring;
                   date:          anystring);
var
   linecount:     integer;
   linenum:       integer;
   pageno:        integer;
   line:          anystring;
   title:         anystring;
   i:             integer;
   c:             char;

begin

   title := rawtitle;
   center(title, titlelen - length (name) - length (date));
   title := name + ' ' + title;

   if name <> '' then
      name := name + ',  ';

   linenum := 0;
   pageno := 0;
   linecount := 0;

   while not berr do
   begin

      if linenum = 0 then
      begin
         write(#13,name,linecount,' lines,  ',pageno,' pages');
         pageno := pageno + 1;
         flush(outfile);
         write(outfile, title, ' ', date, ' Page ', pageno);

         if totpage >= 0 then
         begin
            totpage := totpage + 1;
            write(outfile,' [',totpage,']');
         end;
         writeln(outfile);
         writeln(outfile);
         linenum := 2;
      end;

      line := '';
      bread(infile,c);
      while (c <> #10) and (not berr) do
      begin
           if (c <> #13) and (c <> #26) then
              line := line + c;
           bread(infile,c);
      end;

      {readln(infile, line);}
      writeln(outfile, line);
      linenum := linenum + 1;
      linecount := linecount + 1;

      for i := 1 to length(line) do
         if line [i] = formfeed then
            linenum := 0;
            
      if linenum >= linesperpage then
      begin
         writeln(outfile, formfeed);
         linenum := 0;
      end;

   end;

   if linenum > 0 then      {final formfeed}
      writeln(outfile, formfeed);

   flush(outfile);
   writeln(#13,name, linecount, ' lines,  ', pageno, ' pages');
end;


procedure printfile (name:          anystring);
var
   infile:        intext;
   date:          anystring;

begin
{
   if name = '-F' then
   begin
      printfd(input,'','');
      exit;
   end;
}

   bopen(infile, name,10000,1);
   if berr then
   begin
      writeln('???? CANT RESET FILE: ',name);
      halt;
   end;

   filedate(name, date);
   printfd(infile,name,date);
   bclose(infile);
end;


(*
 *
 * if there are many files to print, outputs a banner page that
 * summarizes the file names and modification dates
 *
 *)

procedure printfilelist;
var
   date:          anystring;
   title:         anystring;
   i:             integer;

begin

   if filecount > 2 then
   begin
      totpage := 0;

      writeln(outfile);
      title := rawtitle;
      center(title, titlelen);
      writeln(outfile, title);

      writeln(outfile);
      writeln(outfile);
      writeln(outfile, ' ' : 10, '  Last Update         Path Name');
      writeln(outfile, ' ' : 10, '===============    ===============');
      writeln(outfile);

      for i := 1 to filecount do
      begin
         filedate(filetable [i]^, date);
         writeln(outfile, ' ' : 10, date, '    ', filetable [i]^);

         if filecount < 20 then
            writeln(outfile);
      end;

      writeln(outfile, formfeed);
   end
   else
      totpage := -1;

end;


(*
 *
 * main program
 *
 *)

var
   i: integer;

begin                       {main}

   if paramcount = 0 then
   begin
      writeln(version);
      writeln;
      writeln('usage:    fpr FILENAME-LIST [OPTIONS] [TITLE]');
      writeln('options:  -o FILENAME  to specify alternate output');
      writeln('          -f           to act as a filter on standard input');
      writeln;
      writeln('example:  fpr file.doc,*.pas,*.bat  System Source Files');
      writeln('          fpr *.pas,*.inc -o files.prn');
      writeln('          loc *.PAS proc | fpr -f');
      halt;
   end;

   getoptions;              {decode options and title from command line}

   getfiles(pattern, filetable, filecount);
                            {get full list of files}

   assign(outfile, outname);
   rewrite(outfile);        {setup output file}

   printfilelist;           {print a summary of files printed}

   for i := 1 to filecount do  {print each file}
      printfile(filetable [i]^);

   flush(outfile);
   close(outfile);          {finish output file}

   halt(0);                 {return to dos}
end.

