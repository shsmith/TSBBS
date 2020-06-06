
(*
 * bIndex - Simple binary index lookup unit
 *
 * Samuel H. Smith, 5/17/90
 *
 *)

unit bIndex;

interface

   uses mdosio,dosmem;

   const
      indexNotFound = -1;        {value of fpos when match fails}

   type
      (* custom key compare function *)
      compare_function = function (k1,k2: string): integer;

      (* file/key type codes *)
      key_types = (StringKey, DateKey);

      (* index file header record *)
      bindex_header = record
         keysize: byte;          {actual key size in the file}
         keytype: key_types;     {the type of key/special processing codes}
         recsize: word;          {total record size within bindex file}
      end;

      (* this record is passed/returned to process an entry in a bIndex file *)
      bindex_rec = record
         fpos:    longint;       {data file position of this key}
         fid:     longint;       {file identifier of this key (conf/dir, etc.)}
         key:     string;        {the actual key string, fixed size in file}
      end;

      (* this record describes an open bIndex file *)
      bindex_handle = record
         dosfd:   dos_handle;    {the dos handle for this file}
         compf:   compare_function;
         hdr:     bindex_header; {the file header record}
         rec:     bindex_rec;    {current index position/record}
         ixpos:   longint;       {current file position in index file}
         ixend:   longint;       {eof position of index file}
         match:   string;        {current key value to match}
         cmp:     integer;       {comparison of current key -1,0,1}
         exact:   boolean;       {require exact matches?}
      end;


   procedure CreateIndex(  var fd:  bindex_handle;
                           fname:   dos_filename );

   procedure OpenIndex(    var fd:  bindex_handle;
                           fname:   dos_filename );

   procedure CloseIndex(   var fd:  bindex_handle );

   procedure FindKey(      var fd:  bindex_handle );

   procedure FindExactKey( var fd:  bindex_handle );

   procedure FindNext(     var fd:  bindex_handle );

   procedure AddKey(       var fd:  bindex_handle );

   procedure DeleteKey(    var fd:  bindex_handle );

   function StringCompare (k1,k2: string): integer;


implementation
function ixn(var fd: bindex_handle): word;
begin
   ixn := (fd.ixpos-sizeof(bindex_header)) div fd.hdr.recsize;
end;

   (* -------------------------------------------------------- *)
   procedure CreateIndex(  var fd:  bindex_handle;
                           fname:   dos_filename );
   begin
      fd.dosfd := dos_create(fname);
      fd.hdr.recsize := sizeof(bindex_rec)-sizeof(string)+fd.hdr.keysize+1;
      dos_write(fd.dosfd,fd.hdr,sizeof(bindex_header));
      dos_close(fd.dosfd);
   end;


   (* -------------------------------------------------------- *)
   procedure OpenIndex(    var fd:  bindex_handle;
                           fname:   dos_filename );
   var
      n: integer;

   begin
      fd.dosfd := dos_open(fname,open_update);
      n := dos_read(fd.dosfd,fd.hdr,sizeof(bindex_header));
      dos_lseek(fd.dosfd,0,seek_end);
      fd.ixend := dos_tell;
      fd.compf := StringCompare;
      fillchar(fd.rec,sizeof(fd.rec),0);
   end;


   (* -------------------------------------------------------- *)
   procedure CloseIndex(   var fd:  bindex_handle );
   begin
      dos_close(fd.dosfd);
   end;


   (* -------------------------------------------------------- *)
   procedure FindKey(      var fd:  bindex_handle );
   var
      fcur:    longint;
      fmin:    longint;
      fmax:    longint;
      recn:    word;
      n:       integer;

   begin
      fd.exact := false;
      fmin := sizeof(bindex_header);
      fmax := fd.ixend-fd.hdr.recsize;
      fd.ixpos := fmax;

      while fmax >= fmin do
      begin
         {compute next position to try}
         recn := (fmax-fmin) div fd.hdr.recsize;
         fd.ixpos := fmin + (recn div 2)*fd.hdr.recsize;

         {read the selected index record}
         dos_lseek(fd.dosfd,fd.ixpos,seek_start);
         n := dos_read(fd.dosfd,fd.rec,fd.hdr.recsize);

         {decide action based on comparison result}
         fd.cmp := fd.compf(fd.rec.key,fd.match);
         if (fd.cmp <> 0) and (fmax=fmin) then
            exit;

         case fd.cmp of
            1:    fmax := fd.ixpos-fd.hdr.recsize;

            0:    exit;

           -1:    fmin := fd.ixpos+fd.hdr.recsize;
         end;
      end;

      {not found when we use what was last seen}
   end;


   (* -------------------------------------------------------- *)
   procedure FindExactKey( var fd:  bindex_handle );
   begin
      FindKey(fd);

      {not found when we cancel current position}
      fd.exact := true;
      if fd.cmp <> 0 then
         fd.ixpos := indexNotFound;
   end;


   (* -------------------------------------------------------- *)
   procedure FindNext(     var fd:  bindex_handle );
   var
      n: integer;
   begin
      if fd.ixpos = indexNotFound then exit;

      inc(fd.ixpos,fd.hdr.recsize);
      dos_lseek(fd.dosfd,fd.ixpos,seek_start);
      n := dos_read(fd.dosfd,fd.rec,fd.hdr.recsize);

      fd.cmp := fd.compf(fd.rec.key,fd.match);
      if (n = 0) or (fd.exact and (fd.cmp <> 0)) then
         fd.ixpos := indexNotFound;
   end;


   (* -------------------------------------------------------- *)
   procedure AddKey(       var fd:  bindex_handle );
   const
      bufsize = $F000;
   var
      copysize:   longint;
      copypos:    longint;
      cursize:    word;
      buf:        ^char;
      n:          word;
      rec:        bindex_rec;

   begin
      rec := fd.rec;
      if fd.ixend = sizeof(bindex_header) then
         fd.ixpos := fd.ixend
      else
      begin
         fd.match := fd.rec.key;
         FindKey(fd);
         if fd.cmp = -1 then
            inc(fd.ixpos,fd.hdr.recsize);
      end;

      copysize := fd.ixend-fd.ixpos{-fd.hdr.recsize};
      if copysize > 0 then
      begin
         dos_getmem(buf,bufsize);

         repeat
            if copysize > bufsize then
               cursize := bufsize
            else
               cursize := copysize;
            copypos := fd.ixpos+copysize-cursize;

            dos_lseek(fd.dosfd,copypos,seek_start);
            n := dos_read(fd.dosfd,buf^,cursize);

            dos_lseek(fd.dosfd,copypos+fd.hdr.recsize,seek_start);
            dos_write(fd.dosfd,buf^,cursize);
            dec(copysize,cursize);
         until copysize = 0;

         dos_freemem(buf);
      end;

      dos_lseek(fd.dosfd,fd.ixpos,seek_start);
      dos_write(fd.dosfd,rec,fd.hdr.recsize);
      inc(fd.ixend,fd.hdr.recsize);
   end;


   (* -------------------------------------------------------- *)
   procedure DeleteKey(    var fd:  bindex_handle );
   begin
   end;


   (* -------------------------------------------------------- *)
   function StringCompare (k1,k2: string): integer;
   begin
      if k1 > k2 then
         StringCompare := 1
      else
      if k1 < k2 then
         StringCompare := -1
      else
         StringCompare := 0;
   end;
end.

