
(*
 * gmrep - global multiple replacement
 *
 * s.h.smith, 8-apr-87 (rev. 16-feb-88)
 *
 * This utility will perform multiple search/replace operations
 * globally on a group of files.
 *
 *)

{$m 20000,100000,100000}

uses Dos,mdosio,tools;

const
   whoami = 'GMREP 1.3 (2-26-94 S.H.Smith)';
   max_replace = 1000;
   bufsize = 10240;
   obufsize = 10240;

type
   replacement_rec = record
      old:  varstring;
      rep:  varstring;
   end;

var
   table:       array[1..max_replace] of replacement_rec;
   reps:        integer;
   query:       boolean;
   undo:        boolean;
   verbose:     boolean;
   buffer:      array[1..bufsize] of char;
   obuf:        array[1..obufsize] of char;


procedure error(message: string);
begin
   writeln('ERROR: ',message);
   halt;
end;

procedure load_replacement_list;
var
   p:       integer;
   old,rep: anystring;
   delim:   char;
   line:    anystring;
   infd:    text;

begin
   if not dos_exists(paramstr(1)) then
      error('Missing replacement list file: '+paramstr(1));

   fillchar(table,sizeof(table),0);

   assign(infd,paramstr(1));
   reset(infd);
   setTextBuf(infd,buffer);
   reps := 0;

   while not eof(infd) do
   begin
      readln(infd,line);
      while copy(line,1,1) = ' ' do
         delete(line,1,1);
      line := line + ';';

      delim := line[1];
      if delim <> ';' then
      begin
         inc(reps);
         delete(line,1,1);

         p := pos(delim,line);
         if p=0 then error('Missing delimiter: '+line);
         old := copy(line,1,p-1);

         line := copy(line,p+1,255);
         p := pos(delim,line);
         if p=0 then error('Missing delimiter: '+line);
         rep := copy(line,1,p-1);

         if undo then
         begin
            savestr(table[reps].old,rep);
            savestr(table[reps].rep,old);
         end
         else
         begin
            savestr(table[reps].old,old);
            savestr(table[reps].rep,rep);
         end;

         if verbose then
            writeln('Replace /',table[reps].old^,
                   '/ with /',table[reps].rep^,'/');
      end;
   end;

   close(infd);

   if verbose then
      writeln(reps,' replacement table entries');
   writeln;
end;


procedure perform_replacement(name: anystring);
var
   infd:  text;
   outfd: text;
   line:  anystring;
   i,p:   integer;
   hits:  integer;
   j:     integer;
   yn:    anystring;
   lnum:  integer;
   lhit:  boolean;
   lpass: integer;
const
   maxpass = 10;

begin
   write(name,':');

   if not dos_exists(name) then
      error('Missing input file: ' + name);

   backup_file(name);
   assign(infd,remove_ext(name)+'.bak');
   reset(infd);
   setTextBuf(infd,buffer);

   assign(outfd,name);
   rewrite(outfd);
   setTextBuf(outfd,obuf);

   hits := 0;
   lnum := 0;
   while not eof(infd) do
   begin
      readln(infd,line);
      lpass := 0;
      inc(lnum);

      repeat
         inc(lpass);
         lhit := false;

         for i := 1 to reps do
         with table[i] do
         begin
            p := pos(old^,line);

            if p <> 0 then
            begin
               if query then
               begin
                  writeln;
                  writeln;
                  writeln(lnum:5,': ',line);
                  for j := -5 to p do
                     write('-');
                  writeln('^');

                  write('Replace with /',rep^,'/ <yes> ');
                  yn := 'y';
                  readln(yn);

                  if upcase(yn[1]) <> 'N' then
                  begin
                     lhit := true;
                     inc(hits);
                     line := copy(line,1,p-1) + rep^ + copy(line,p+length(old^),255);
                  end;
               end
               else
                  begin
                     lhit := true;
                     inc(hits);
                     line := copy(line,1,p-1) + rep^ + copy(line,p+length(old^),255);
                  end;
            end;
         end;

         if verbose and lhit then
         begin
            writeln;
            write(lnum:5,': ',line);
         end;

      until (lhit = false) or (lpass >= maxpass);

      writeln(outfd,line);
   end;

   close(infd);
   close(outfd);

   if hits = 0 then
   begin
      writeln(^M,name,' unchanged');
      erase(outfd);
      rename(infd,name);
   end
   else
   begin
      if verbose then
         writeln;
      writeln(^M,hits:3,' changes in ',name);
   end;
end;


var
   i,j: integer;
   par: string;

begin
   if paramcount < 2 then
   begin
      writeln;
      writeln(whoami);
      writeln;
      writeln('Usage:  gmrep REPFILE [-q] [-u] [-v] FILE_LIST');
      writeln;
      writeln(' REPFILE    name of file containing replacement commands');
      writeln(' FILE_LIST  list of files to act upon (wildcards okay)');
      writeln('      -q    query before performing replacement');
      writeln('      -u    undo (reverse) replacements');
      writeln('      -v    verbose mode');
      writeln;
      writeln('REPFILE must contain lines of the format:');
      writeln('   /original/replacement/');
      writeln('Any non-blank character except ";" can be used instead of "/".');
      writeln;
      writeln('Example:');
      writeln('  gmrep nobios -q *.pas *.inc            ;apply nobios, ask');
      writeln('  gmrep nobios -u *.pas *.inc            ;undo nobios changes');
      halt;
   end;

   fillchar(filetable,sizeof(filetable),0);
   query := false;
   undo := false;
   verbose := false;

   for i := 2 to paramcount do
   begin
      par := paramstr(i);
      stoupper(par);

      if par = '-Q' then
         query := true
      else
      if par = '-U' then
         undo := true
      else
      if par = '-V' then
         verbose := true
      else
      if par[1] = '-' then
         writeln('Unknown option: ',par);
   end;

   load_replacement_list;

   for i := 2 to paramcount do
   begin
      par := paramstr(i);
      stoupper(par);
      if par[1] <> '-' then
      begin
         writeln('Checking ',par,' ...');
         getfiles(par,filetable,filecount);
         if filecount = 0 then
            writeln('Warning: no files matched "',par,'"');
         for j := 1 to filecount do
            perform_replacement(filetable[j]^);
      end;
   end;
end.
