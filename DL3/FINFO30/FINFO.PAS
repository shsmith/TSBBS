
(*
 * finfo - dos filter update file size/date info in a file
 *         directory listing.
 *
 * 26-feb-87 s.h.smith (7-4-89 shs)
 *
 *)

uses DOS;

const
   version = 'Finfo v3.0 03-11-92 S.H.Smith';

var
   dir:     string;
   line:    string;
   infd:    text;
   outfd:   text;
   ibuf:    array[1..10240] of char;
   obuf:    array[1..10240] of char;


procedure upd2(i: integer; pos: integer);
var
   s: string;
begin
   str(i:2,s);
   if s[1] = ' ' then s[1] := '0';
   line[pos] := s[1];
   line[pos+1] := s[2];
end;

procedure get_file_info;
var
   DirInfo:    SearchRec;
   Stamp:      DateTime;
   name:       string;
   i,j:        integer;
   s:          string;

begin
   i := pos(' ',line);
   if i = 0 then exit;

   name := copy(line,1,i-1);
   FindFirst(dir+name,$21,DirInfo);
   if DosError <> 0 then exit;

   UnpackTime(DirInfo.time, Stamp);

(****        xxxxxxxx
PROBB091.ZIP    34609  04-29-89  (hh:mm) Official list of boards running ProDoor
         1         2         3         4         5
123456789012345678901234567890123456789012345678901234567890
****)
   if (Stamp.year < 1981) or (Stamp.year > 1995) then exit;
   if (length(line) < 34) or (line[26] <> '-') or (line[29] <> '-') then exit;
   if DirInfo.size < 1 then exit;

   str(DirInfo.size:8,s); for i := 1 to 8 do line[i+13] := s[i];
   upd2(Stamp.year-1900,30);
   upd2(Stamp.month,24);
   upd2(Stamp.day,27);

   if (line[34] = '(') and (line[37] = ':') and (line[40] = ')') then
   begin
      upd2(Stamp.hour,35);
      upd2(Stamp.min,38);
   end;
end;

begin
   if paramcount <> 3 then
   begin
      writeln('Usage: finfo DIRECTORY INFILE OUTFILE');
      halt(99);
   end;

   dir := paramstr(1);
   if dir[length(dir)] <> '\' then
      dir := dir + '\';

   assign(infd,paramstr(2));
   reset(infd);
   setTextBuf(input,ibuf);

   assign(outfd,paramstr(3));
   rewrite(outfd);
   setTextBuf(output,obuf);

   while not eof(infd) do
   begin
      readln(infd,line);
      get_file_info;
      writeln(outfd,line);
   end;

   close(infd);
   close(outfd);
end.

