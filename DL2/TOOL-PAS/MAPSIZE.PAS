
(*
 * mapsize - filter to append sizes to lines of LINK .MAP files
 *
 * shs 19-mar-86 (rev. 15-may-87)
 *
 *)

type
   anystring = string[128];

var
   fd:         text;
   CurLine:    anystring;
   NextLine:   anystring;
   CurSeg:     string[20];

type
   segment_info = record
      para: word;
      name: string[20];
   end;

const
   maxseg = 200;

var
   segment:    array[1..maxseg] of segment_info;
   segments:   integer;


function hex_to_long(hex: anystring): longint;
var
   i:   integer;
   c:   char;
   r:   longint;

begin
   r := 0;
   for i := 1 to length(hex) do
   begin
      r := r * 16 + ord(hex[i]) - ord('0');
      if hex[i] > '9' then
         r := r - 7;
   end;

   hex_to_long := r;
end;


procedure process_segment;
begin
   inc(segments);
   segment[segments].para := hex_to_long(copy(CurLine,2,4));
   segment[segments].name := copy(CurLine,23,19);
end;


procedure determine_segment(para: word);
var
   i: integer;
begin
   for i := 1 to segments do
      if segment[i].para = para then
      begin
         CurSeg := segment[i].name;
         exit;
      end;
end;


procedure process_item;
var
   CurAddr:    longint;
   NextAddr:   longint;
   NewSegment: boolean;
   Overhead:   longint;

begin
   CurAddr := hex_to_long(copy(CurLine,2,4))*16 +
              hex_to_long(copy(CurLine,7,4));

   NewSegment := copy(CurLine,2,4) <> copy(NextLine,2,4);
   if NewSegment then
      NextAddr := hex_to_long(copy(NextLine,2,4))*16
   else
      NextAddr := hex_to_long(copy(NextLine,2,4))*16 +
                  hex_to_long(copy(NextLine,7,4));

   writeln(CurSeg:20,'  ',copy(CurLine,1,13),NextAddr-CurAddr:7,' ',copy(CurLine,15,99));

   if NewSegment then
   begin
      writeln;
      writeln;
      writeln(' Segment               Location       Size    Symbol');
      writeln;
      determine_segment(hex_to_long(copy(NextLine,2,4)));
      Overhead := hex_to_long(copy(NextLine,7,4));
      if Overhead > 0 then
         writeln(CurSeg:20,'  ',copy(NextLine,1,5),':0000   ',Overhead:7,'    <overhead>');
   end;
end;


begin
   if paramcount <> 1 then
   begin
      writeln('Usage: mapsize {file}.MAP [>outfile]');
      halt;
   end;

   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('Can''t open: ',paramstr(1));
      halt;
   end;

   repeat
      readln(fd,CurLine);
   until CurLine = ' Start  Stop   Length Name               Class';
   readln(fd);

   segments := 0;
   readln(fd,CurLine);
   while length(CurLine) > 40 do
   begin
      process_segment;
      readln(fd,CurLine);
   end;

   curseg := '';
   writeln;
   writeln(' Segment               Location       Size    Symbol');
   writeln;

   repeat
      readln(fd,CurLine);
   until CurLine = '  Address         Publics by Value';
   readln(fd);

   readln(fd,CurLine);
   determine_segment(hex_to_long(copy(CurLine,2,4)));

   readln(fd,NextLine);

   repeat
      process_item;
      CurLine := NextLine;
      readln(fd,NextLine);
   until NextLine = '';

   close(fd);
end.


