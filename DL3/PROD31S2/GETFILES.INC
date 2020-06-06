
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)


(*
 * getfiles - file list processing library
 *
 * This module will change a wildcard list of files into a
 * sorted file name list.
 *
 *)

const
   maxnumfiles =  200;
   null =         #0;

type
   filestring =   string [64];
   filearray =    array [1.. maxnumfiles] of filestring;


var
   filetable:     filearray;
   filecount:     integer;


(*
 *
 * sort a portion of a file table
 *
 *)


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


(*
 *
 * expand a comma-seperated wildcard list into
 * a list of full pathnames.
 * sort files going with each wildcard, but otherwise
 * preserve file order
 *
 *)

procedure getfiles (patternlist:   filestring;
                    var fdir:      filearray;
                    var num:       integer);
var
   i:             integer;
   cf:            byte;
   onedir:        filestring;
   listpos:       integer;
   pattern:       filestring;
   curdir:        filestring;
   reg:           registers;
   dta:           string[255];
   c:             char;
   prevnum:       integer;

begin
   for i := 1 to length(patternlist) do
      patternlist[i] := upcase(patternlist[i]);

   if patternlist = '-F' then   {filter standard input?}
   begin
      num := 1;         {make a fixed filelist instead of searching}
      fdir[1] := '-F';
      exit;
   end;

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
         listpos := succ(listpos);
         c := patternlist [listpos];
      end;

      listpos := succ(listpos);
      curdir := pattern;

      while (length(curdir) > 0) and
            (curdir [length(curdir)] <> '\') and
            (curdir [length(curdir)] <> ':') do
               curdir[0] := pred(curdir[0]);

      pattern := pattern + null;
      reg.ax := $1a00;
      reg.ds := seg (dta [1]);
      reg.dx := ofs (dta [1]);
      msdos(reg);              {set dta address}

      reg.ax := $4e00;
      reg.cx := $21;  {match archive and read-only attributes}
      reg.ds := seg (pattern [1]);
      reg.dx := ofs (pattern [1]);
      msdos(reg);              {find first matching file}

      cf := reg.flags and 1;

      while ((cf <> 1) and (num < maxnumfiles)) do
      begin

         onedir := '';
         i := 0;

         repeat
            c := dta [31 + i];

            if c <> null then
               onedir := onedir + c;

            i := i + 1;
         until c = null;          {throw out the . and .. entries}


         if onedir [1]<> '.' then
         begin
            num := num + 1;
            fdir[num]:= curdir + onedir;
         end;

         reg.ax := $4f00;
         reg.ds := seg (dta [1]);
         reg.dx := ofs (dta [1]);
         msdos(reg);              {keep searching for next file}

         cf := reg.flags and 1;
      end;

      sorttable(fdir, prevnum, num);
                         {sort each part of list seperately}

      prevnum := num + 1;
   end;

   if num >= maxnumfiles then
   begin
      writeln(con,'warning:  files in excess of ', maxnumfiles, ' ignored');
   end;
end;                     {getfiles}


