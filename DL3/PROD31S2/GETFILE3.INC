
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
 * getfile2 - file list processing library (simplified version)
 *
 * This module will change a wildcard list of files into a
 * sorted file name list.
 *
 * Samuel H. Smith, rev. 25-oct-87
 *
 *)

procedure getfiles (pattern:       string65;
                    var fdir:      filearray;
                    var num:       integer);
var
   i:             integer;
   curdir:        string65;
   keyword:       string13;
   doscan:        boolean;    {can dos do this wildcard?}
   DirInfo:       SearchRec;

begin
   stoupper(pattern);

   curdir := path_only(pattern);
   if curdir = '' then
      curdir := '@:';

   if (length(curdir) = 2) and (curdir[2] = ':') then
      getdir(ord(curdir[1])-ord('@'),curdir);

   if (curdir[length(curdir)] <> '\') then
   begin
      inc(curdir[0]);
      curdir[length(curdir)] := '\';
   end;

   keyword := remove_path(pattern);

   doscan := true;
   i := pos('*',keyword);
   if i > 0 then
      if (keyword[i+1] <> '.') and (i < length(keyword)) then
         doscan := false;

   if doscan = false then
      pattern := curdir + '*.*';

   num := 0;
   FindFirst(pattern,$21,DirInfo);

   while (DosError = 0) and (num < maxnumfiles) do
   begin
         {best if $B-}
      if doscan or wildcard_match(keyword, DirInfo.name) then
      begin
         inc(num);
         savestr(fdir[num],curdir + DirInfo.name);
      end;

      FindNext(DirInfo);
   end;

{  if num >= maxnumfiles then
      writeln('Warning:  Files in excess of ', maxnumfiles, ' ignored.');
}
{writeln('getfile3 par=',pattern,
                 ' cd=',curdir,
                ' key=',keyword,
                ' can=',doscan,
                ' n=',num);}

end;                     {getfiles}

