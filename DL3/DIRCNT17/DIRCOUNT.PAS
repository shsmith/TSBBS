
(*
 * DirCount - Count file directory entries and insert headers with
 *            file information.
 *
 * Written by Samuel H. Smith, 12-30-88
 *
 *)

uses qread;

const
   version   = 'DirCount 1.8, 05-30-95';

var
   console:    text;
   ctlfd:      text;

   bbsname:    string;
   dirfile:    string;
   title:      string;
   subtitle:   string;
   dirnum:     integer;

   ibuf:       array[1..20480] of byte;
   obuf:       array[1..20480] of byte;
   line:       string;

   sizes:      real;
   tsizes:     real;
   files:      real;
   tfiles:     real;
   tdirs:      real;


(* --------------------------------------------------------- *)
function insert_commas(s: string): string;
var
   i: integer;
begin
   i := length(s);
   while i > 3 do
   begin
      dec(i,3);
      insert(',',s,i+1);
   end;

   insert_commas := s;
end;


(* --------------------------------------------------------- *)
function itoa (n: real): string;
var
   tstr:          string;

begin
   str(n:0:0, tstr);
   itoa := insert_commas(tstr);
end;


(* --------------------------------------------------------- *)
function itoan(n: real; width: integer): string;
var
   s: string;
begin
   s := itoa(n);
   while length(s) < width do
      s := ' ' + s;
   itoan := s;
end;


(* --------------------------------------------------------- *)
function ljust(s: string; width: integer): string;
begin
   s := copy(s,1,width);
   while length(s) < width do
      s := s + ' ';
   ljust := s;
end;


(* --------------------------------------------------------- *)
function center(s: string; width: integer): string;
var
   i: integer;
begin
   s := copy(s,1,width);
   i := (width - length(s)) div 2;
   while i > 0 do
   begin
      s := ' ' + s;
      dec(i);
   end;
   center := s;
end;


(* --------------------------------------------------------- *)
function cjust(s: string; width: integer): string;
var
   i: integer;
begin
   s := copy(s,1,width);
   i := (width - length(s)) div 2;
   while i > 0 do
   begin
      s := ' ' + s;
      dec(i);
   end;
   while length(s) < width do
      s := s + ' ';
   cjust := s;
end;


(* --------------------------------------------------------- *)
function isfile: boolean;
begin
   if length(line) < 35 then
      isfile := false
   else
   if (line[26] = '-')  and (line[29] = '-') and
      (line[21] >= '0') and (line[21] <= '9') and
      (line[24] >= '0') and (line[24] <= '9') then
      isfile := true
   else
   if (line[24] = 'D') and (line[25] = 'E') and
      (line[26] = 'L') and (line[27] = 'E') and
      (line[28] = 'T') and (line[29] = 'E') then
      isfile := true
   else
      isfile := false;
end;


(* --------------------------------------------------------- *)
procedure count_files;
var
   size: real;
   err:  integer;
   tmp:  string;
   ifd:  text;

begin
   files := 0;
   sizes := 0;

   assign(ifd,dirfile);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln(console,'Can''t open DIR file ',dirfile);
      exit;;
   end;

   setTextBuf(ifd,ibuf);
   write(console,'  Counting: ',dirfile,'':10,^M);

   while not eof(ifd) do
   begin
      qreadln(ifd,line,sizeof(line));
      if isfile then
      begin
         files := files + 1;
         tmp := copy(line,13,9);
         while tmp[1] = ' ' do
            delete(tmp,1,1);
         val(tmp,size,err);
         sizes := sizes + size;
      end;
   end;

   close(ifd);
end;


(* --------------------------------------------------------- *)
procedure update_dirfile;
var
   ifd:     text;
   ofd:     text;
   tmp:     string;

begin
   assign(ifd,dirfile);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      exit;
   end;

   assign(ofd,dirfile+'$');
   {$i-} rewrite(ofd); {$i+}
   if ioresult <> 0 then
   begin
      writeln(console,'Can''t create tempfile ',dirfile,'$');
      halt(99);
   end;

   setTextBuf(ifd,ibuf);
   setTextBuf(ofd,obuf);
   write(console,'Formatting: ',dirfile,'':10,^M);

   repeat
      qreadln(ifd,line,sizeof(line));
   until isfile or eof(ifd);

   writeln(ofd);
   writeln(ofd,center(bbsname,79));
   writeln(ofd);
   writeln(ofd,center(title,79));

   tmp := itoa(files) + ' files using ' + itoa(sizes) + ' bytes';
   writeln(ofd,center(tmp,79));

   writeln(ofd);
   writeln(ofd,' File Name      Size     Date                  File Description');
   writeln(ofd,'============  =======  ========  =============================================');
   writeln(ofd);

   writeln(ofd,line);
   while not eof(ifd) do
   begin
      qreadln(ifd,line,sizeof(line));
      writeln(ofd,line);
   end;

   close(ofd);
   close(ifd);

   {$i-} erase(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln(console,'Can''t erase old dirfile ',dirfile);
      halt(99);
   end;

   {$i-} rename(ofd,dirfile); {$i+}
   if ioresult <> 0 then
   begin
      writeln(console,'Can''t rename new dirfile ',dirfile,'$ to ',dirfile);
      halt(99);
   end;

end;


(* --------------------------------------------------------- *)
var
   temp: string;
   i:    integer;
begin
   assign(console,'CON');
   rewrite(console);
   writeln(console);
   writeln(console,version);
   writeln(console,'Public Domain Material by Samuel H. Smith');
   writeln(console);

   if paramcount <> 1 then
   begin
      writeln(console,'Usage:    DirCount configfile [>summary]');
      writeln(console,'Example:  DirCount COUNT.CNF >\PCB\GEN\BLT16');
      halt(99);
   end;

   assign(ctlfd,paramstr(1));
   {$i-} reset(ctlfd); {$i+}
   if ioresult <> 0 then
   begin
      writeln(console,'Can''t open configuration file ',paramstr(1));
      halt(99);
   end;

   readln(ctlfd,bbsname);
   readln(ctlfd,subtitle);
   dirnum := 0;
   tfiles := 0;
   tsizes := 0;
   tdirs := 0;

   writeln;
   writeln(center(bbsname,79));
   writeln(center(subtitle,79));
   writeln;

   writeln('  ',
           cjust('Area',6),'   ',
           cjust('Description',36),'  ',
           cjust('Files',9),' ',
           center('File Sizes',16));
   writeln('  ',
           cjust('------',6),'  ',
           cjust('-------------------------------------',36),'   ',
           cjust('--------',9),
           center('---------------',18));

   while not eof(ctlfd) do
   begin
      readln(ctlfd,dirfile);
      readln(ctlfd,title);
      dirnum := dirnum + 1;

      count_files;

      if files > 0 then
      begin
         temp := '  ' +
                 itoan(dirnum,4)+'     '+
                 ljust(title,36)+
                 itoan(files,9)+
                 itoan(sizes,17);

         if odd(trunc(tdirs)) then
         begin
            for i := 8 to length(temp) do
               if (not odd(i)) and (temp[i] = ' ') then
                  temp[i] := 'ú';
         end;

         writeln(temp);
         tdirs := tdirs + 1;
      end;

      tfiles := tfiles + files;
      tsizes := tsizes + sizes;

      update_dirfile;
   end;

   write(console,'':60,^M);
   close(ctlfd);

   writeln('  ',
           cjust('',6),'  ',
           cjust('                                     ',36),'   ',
           cjust('--------',9),
           center('---------------',18));
   writeln('  ',
           '':6,
           'Overall Totals':38,' ',
           itoan(tfiles,9),
           itoan(tsizes,17));
end.

