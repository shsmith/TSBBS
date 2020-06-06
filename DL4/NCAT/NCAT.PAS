

(*
 * cat - concatenate a list of text files into standard output
 *
 * shs 8/24/85
 *
 *)

{$p5120,d-,c-}

const
   maxnumfiles =  100;
   null =         #0;

type
   filestring =   string [132];
   anystring =    string [132];
   filearray =    array [1.. maxnumfiles] of filestring;
   regpack =      record
         ax,
         bx,
         cx,
         dx,
         bp,
         si,
         di,
         ds,
         es,
         flags:         Integer;
      end;

var
   filelist:      filestring;
   destdir:       filestring;
   reg:           regpack;
   dta:           anystring;
   filepat:       filestring;
   filetable:     filearray;
   filecount:     integer;
   i:             integer;
   linecount:     integer;


procedure sorttable (var fdir:      filearray;
                     first:         integer;
                     last:          integer);
   var
      i:             integer;
      swapped:       boolean;
      temp:          filestring;
      
   begin
      
      repeat
         swapped := false;
         
         for i := first to last - 1 do
         begin
            
            if fdir [i]> fdir [i + 1] then
            begin
               temp := fdir [i];
               fdir[i]:= fdir [i + 1];
               fdir[i + 1]:= temp;
               swapped := true;
            end;
         end;
      until swapped = false;
   end;

procedure getfiles (patternlist:   filestring;
                           {comma seperated list of patterns to match}

                    fattr:         integer;
                           {attribute to match}

                    var fdir:      filearray;
                           {output filename list}

                    var num:       integer);
                              {output number of files}
   
   {-find files matching specified characteristics}
   
   var
      i,
      cf:            byte;
      onedir:        filestring;
      listpos:       integer;
      pattern:       filestring;
      curdir:        filestring;
      c:             char;
      prevnum:       integer;
      
   begin
      num := 0;
      prevnum := 1;
      listpos := 1;
      
      while listpos <= length (patternlist) do
      begin
         pattern := '';
         c := patternlist [listpos];
         
         while (c <> ',') and (listpos <= length (patternlist)) do
         begin
            pattern := pattern + c;
            listpos := listpos + 1;
            c := patternlist [listpos];
         end;
         
         listpos := listpos + 1;
         curdir := pattern;
         
         while (curdir [length (curdir)]<> '\')
               and (curdir [length (curdir)]<> ':')
               and (length (curdir)> 0) do
            curdir[0]:= pred (curdir [0]);
         
         pattern := pattern + null;
         reg.ax := $1a00;
         reg.ds := seg (dta [1]);
         reg.dx := ofs (dta [1]);
         msdos(reg);                {set dta address}
         
         reg.cx := fattr;
         reg.ax := $4e00;
         reg.ds := seg (pattern [1]);
         reg.dx := ofs (pattern [1]);
         msdos(reg);                {find first matching file}
         
         cf := reg.flags and 1;
         
         while ((cf <> 1) and (num < maxnumfiles)) do
         begin
            i := ord (dta [22]);
            
            if (i = fattr) or ((fattr <> 16)
                  and (i < fattr)) then
            begin                         {get subdir or file name}
               
               onedir := '';
               i := 0;
               
               repeat
                  c := dta [31 + i];
                  
                  if c <> null then
                     onedir := onedir + c;
                  
                  i := i + 1;
               until c = null;            {throw out the . and .. entries}
               
               
               if onedir [1]<> '.' then
               begin
                  num := num + 1;
                  fdir[num]:= curdir + onedir;
               end;
            end;
            
            reg.ax := $4f00;
            reg.ds := seg (dta [1]);
            reg.dx := ofs (dta [1]);
            msdos(reg);                {keep searching for next file}
            
            cf := reg.flags and 1;
         end;
         
         sorttable(fdir, prevnum, num);
                                    {sort each part of list seperately}
         
         prevnum := num + 1;
      end;
      
      if num >= maxnumfiles then
      begin
         writeln('warning: files in excess of ', maxnumfiles, ' ignored');
      end;
   end;                       {getfiles}
   

procedure cpfile (filename:      filestring);
   var
      infile:        text [512];
      line:          string [255];
      c:             char;
      
   begin
      write(con, filename);
      assign(infile, filename);
      reset(infile);

      writeln('---------- ',filename,' --------------');

      while not eof (infile) do
      begin
         readln(infile, line);
         writeln(line);
         linecount := linecount + 1;

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
      writeln(^L);
      linecount := linecount + 1;
      flush(output);
      write(con, #13, '' : 40, #13);
   end;

procedure catfiles (pattern:       filestring);
   begin
      linecount := 0;
      getfiles(pattern, 39, filetable, filecount);

      for i := 1 to filecount do
         cpfile(filetable [i]);

      write(con,filecount,' files concatenated, ');
      writeln(con,linecount,' output lines');
   end;



begin

   if paramcount <> 1 then
   begin
      writeln(con, 'usage: cat SOURCE-FILE-LIST >OUTFILE');
      writeln(con, 'example: cat *.pas,*.doc | find "MISC" >prn');
      halt;
   end;

   catfiles(paramstr (1));

end.
