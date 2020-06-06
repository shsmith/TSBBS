
{$m 10000,0,0}

uses dos,tools,mdosio,bindex,openshare,qread;

var
   ixname:  bindex_handle;
   ixdate:  bindex_handle;
   fd:      text;
   fid:     longint;
   fpos:    longint;
   line:    string;

begin
   if paramcount <> 3 then
   begin
      writeln('usage:  ixdir DIRFILE CONF# DIR#');
      writeln('example: ixdir L:\PCB\GEN\DIR1 0 1');
      halt(1);
   end;

   fid := atoi(paramstr(2))*256 + atoi(paramstr(3));

   if not dos_exists(paramstr(1)) then
   begin
      writeln('Can''t open dirfile');
      halt;
   end;

   assign(fd,paramstr(1));
   reset(fd);

   if not dos_exists('NAMES.IX') then
   begin
      ixname.hdr.keysize := 12;
      ixname.hdr.keytype := StringKey;
      CreateIndex(ixname,'NAMES.IX');
   end;

   if not dos_exists('DATES.IX') then
   begin
      ixdate.hdr.keysize := 6;
      ixdate.hdr.keytype := DateKey;
      CreateIndex(ixdate,'DATES.IX');
   end;

   OpenIndex(ixname,'NAMES.IX');
   OpenIndex(ixdate,'DATES.IX');

   while not eof(fd) do
   begin
      qReadLn(fd,line,255);
      {PROBB10.ZIP     46620  12-24-89  Official list }
      {123456789012345678901234567890123456}
      {         1         2         3      }
      if (length(line) > 33) and (line[26] = '-') and (line[23] = ' ') then
      with TextRec(fd) do
      begin
         dos_lseek(Handle,0,seek_cur);
         fpos := dos_tell-BufEnd+BufPos-length(line)-2;

         ixname.rec.key := copy(line,1,12);
         ixname.rec.fid := fid;
         ixname.rec.fpos := fpos;
         write(ixname.rec.key:12,' ');
         AddKey(ixname);

         ixdate.rec.key := line[30]+line[31] +
                           line[24]+line[25] +
                           line[27]+line[28];
         ixdate.rec.fid := fid;
         ixdate.rec.fpos := fpos;
         writeln(ixdate.rec.key);
         AddKey(ixdate);
      end;

   end;

   CloseIndex(ixdate);
   CloseIndex(ixname);
   close(fd);
end.

