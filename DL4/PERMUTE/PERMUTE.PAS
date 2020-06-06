
(*
 * permute - permute all combinations of entries in a list
 *           form command lines for each
 *
 * s.h.smith, 20-aug087
 *
 *)

type
   anystring = string[80];

const
   listsize = 100;

var
   list:    array[0..listsize] of anystring;
   count:   integer;

   prefix:  anystring;
   i,j:     integer;
   n:       integer;

   fd:      text;


begin
   if paramcount <> 3 then
   begin
      writeln('usage:    permute LISTFILE BATCHOUT command prefix...');
      writeln('example:  permute NAMES.DAT FCALL.BAT fc');
      halt;
   end;

   assign(fd,paramstr(1));
   reset(fd);
   count := 0;
   while not eof(fd) do
   begin
      count := count + 1;
      readln(fd,list[count]);
   end;
   close(fd);

   assign(fd,paramstr(2));
   rewrite(fd);

   prefix := '';
   for i := 3 to paramcount do
      prefix := prefix + paramstr(i) + ' ';

   n := 0;
   for i := 1 to count do
      for j := 1 to count do
         if i <> j then
         begin
            n := n + 1;
            writeln(fd,prefix,list[i],' ',list[j]);
         end;

   close(fd);
   writeln(n,' permutations');

end.


