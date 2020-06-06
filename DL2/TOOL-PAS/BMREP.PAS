
(*
 * Bmrep - multiple replacement of exact length strings in multiple binary files
 *
 * from gmrep s.h.smith, 8-apr-87 (21-may-91)
 *
 *)

uses mdosio,tools;

const
   version = '2.0 (5-21-91)';

type
   replacement_rec = record
      old:     ^string;
      rep:     ^string;
   end;

const
   max_replace = 100;

var
   table:  array[1..max_replace] of replacement_rec;
   reps:   integer;

const
   nblocks = 150;


procedure error(why: string);
begin
   writeln;
   writeln('FATAL ERROR: ',why);
   halt(1);
end;

procedure load_replacement_list;
var
   p:       integer;
   old,rep: string;
   delim:   char;
   line:    string;
   infd:    text;

begin
   if not dos_exists(paramstr(1)) then
      error('missing replacement list file: '+paramstr(1));

   assign(infd,paramstr(1));
   reset(infd);
   reps := 0;

   while not eof(infd) do
   begin
      readln(infd,line);
      line := line + ';';

      delim := line[1];
      if delim <> ';' then
      begin
         inc(reps);
         delete(line,1,1);

         p := pos(delim,line);
         if p=0 then error('missing delimiter: '+line);
         old := copy(line,1,p-1);
         getmem(table[reps].old,length(old)+1);
         table[reps].old^ := old;

         line := copy(line,p+1,255);
         p := pos(delim,line);
         if p=0 then error('missing delimiter: '+line);
         rep := copy(line,1,p-1);
         getmem(table[reps].rep,length(rep)+1);
         table[reps].rep^ := rep;

{         writeln(' replace [',old,'] with [',rep,']'); }

         if length(old) <> length(rep) then
            error('Old and new lengths must be the same ('+old+'/'+rep+')');
      end;
   end;

   close(infd);
   writeln(reps,' replacement table entries');
   writeln;
end;


procedure perform_replacement(name: string);
type
   buffer = array[1..maxint] of char;
   bufptr = ^buffer;
var
   buf:     bufptr;
   count:   word;
   infd:    dos_handle;
   outfd:   dos_handle;
   i,j,p:   integer;
   hits:    integer;
   bak:     string;

begin
   write(name:15);

   if not dos_exists(name) then
      error('missing input file: ' + name);

   backup_file(name);

   bak := remove_ext(name)+'.bak';
   infd := dos_open(bak,open_read);
   outfd := dos_create(name);

   new(buf);
   hits := 0;
   count := dos_read(infd,buf^,sizeof(buf^));

   if count = sizeof(buf^) then
      error('File too large!');

   for i := 1 to reps do
   with table[i] do
   begin
      for j := 1 to count-length(old^) do
      begin
         p := 1;
         repeat
            inc(p);
         until (p = length(old^)) or (buf^[j+p-1] <> old^[p]);

         if buf^[j+p-1] = old^[p] then
         begin
            inc(hits);
            for p := 1 to length(old^) do
               buf^[j+p-1] := rep^[p];
         end;
      end;
   end;

   dos_write(outfd,buf^,count);

   dos_close(infd);
   dos_close(outfd);
   writeln('   ',hits,' replacements');

   dispose(buf);
end;


var
   i,j: integer;

begin
   if paramcount < 2 then
   begin
      writeln('BMREP ',version,' (C) 1991 Samuel H. Smith');
      writeln('Usage:  BMREP replacement_list file_list');
      writeln;
      writeln('Replacement list file may contain any number lines with the format:');
      writeln('<delimiter>old string<delimiter>new string<delimiter>');
      halt;
   end;

   load_replacement_list;

   for i := 2 to paramcount do
   begin
      getfiles(paramstr(i),filetable,filecount);
      for j := 1 to filecount do
         perform_replacement(filetable[j]^);
   end;
end.

