
{$m 10000,0,0}

uses mdosio,bindex;

var
   ix:   bindex_handle;

begin
   if paramcount <> 1 then
   begin
      writeln('usage:  dumpix INDEXFILE');
      writeln('example: dumpix NAMES.IX');
      halt(1);
   end;

   OpenIndex(ix,paramstr(1));

   ix.match := #0;
   FindKey(ix);
   while ix.ixpos <> indexNotFound do
   begin
      writeln(ix.rec.key,'':ix.hdr.recsize-length(ix.rec.key),' ',
              ix.rec.fid:8,' ',
              ix.rec.fpos:8);
      FindNext(ix);
   end;

   CloseIndex(ix);
end.

