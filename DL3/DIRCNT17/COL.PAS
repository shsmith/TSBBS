
(*
 * col - filter to put lines into multiple columns
 *
 * s.h.smith, ?, rev(7-sep-87)
 *
 *)

type
   anystring = string[80];

function atoi (asc:  string): integer;
var
   i:             integer;
   value:         integer;
begin
   val(asc, value, i);
   atoi := value;
end;

const
   mcol = 6;
   mlin = 50;

var
   ncol:  integer;
   nlin:  integer;

   page:  array[1..mlin,1..mcol] of anystring;
   l,c:   integer;

begin
   if paramcount = 0 then
   begin
      nlin := mlin;
      ncol := mcol;
   end
   else

   if paramcount = 2 then
   begin
      nlin := atoi(paramstr(1));
      ncol := atoi(paramstr(2));
   end
   else

   begin
      writeln('usage:  col <infile >outfile');
      writeln(' or     col LINES COLUMNS <infile >outfile');
      halt(2);
   end;

   while not eof do
   begin

      for l := 1 to nlin do
         for c := 1 to ncol do
            page[l,c] := '';
      c := 1;
      l := 1;

      while (c <= ncol) and (not eof) do
      begin
         readln(page[l,c]);
         if l < nlin then
            l := l + 1
         else
         begin
            c := c + 1;
            l := 1;
         end;
      end;

      for l := 1 to nlin do
      begin
         for c := 1 to ncol do
         begin
            write(page[l,c]);
            if c < ncol then
               write('':(80 div ncol)-length(page[l,c]));
         end;
         writeln;
      end;

      if not eof then
         writeln(^L);

   end;
end.
