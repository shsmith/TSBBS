
{$m 10000,0,0}

uses mdosio,bindex;

const
   recs = 100;


function generate_string: string;
var
   s: string;
   i: integer;
   l: integer;
begin
   l := 20 {random(10)+10};
   s := '';
   for i := 1 to l do
      s := s + chr(random(10)+ord('0'));
   generate_string := s;
end;

var
   ix:      bindex_handle;
   fd:      dos_handle;
   key:     string;
   keylen:  byte;
   fpos:    longint;
   i,n:     integer;
   crlf:    array[1..2] of char;

begin
   crlf := ^M^J;
   randomize;

   writeln('Create index');
   ix.hdr.keysize := 23;
   ix.hdr.keytype := StringKey;
   CreateIndex(ix,'TEST.IX');

   OpenIndex(ix,'TEST.IX');
   fd := dos_create('TEST.DAT');
   for i := 1 to recs do
   begin
      key := generate_string;
      writeln('   ',key);

      dos_lseek(fd,0,seek_cur);
      fillchar(ix.rec,sizeof(ix.rec),0);
      ix.rec.fpos := dos_tell;
      ix.rec.fid := 0;
      ix.rec.key := key;
      AddKey(ix);

      dos_write(fd,key,length(key)+1);
      dos_write(fd,crlf,sizeof(crlf));
   end;
   dos_close(fd);
   CloseIndex(ix);

   writeln('Read index');
   OpenIndex(ix,'TEST.IX');
   fd := dos_open('TEST.DAT',open_read);
   ix.match := '';
   FindKey(ix);
   while ix.ixpos <> indexNotFound do
   begin
      dos_lseek(fd,ix.rec.fpos,seek_start);
      n := dos_read(fd,key[0],1);
      n := dos_read(fd,key[1],length(key));
      writeln('  found [',key,']');
      FindNext(ix);
   end;
   dos_close(fd);
   CloseIndex(ix);
end.

