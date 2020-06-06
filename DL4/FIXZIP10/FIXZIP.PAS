
(*
 * FixZip - Attempt to repair truncated zipfiles by generating
 *          a central directory from the local directories
 *
 * Copyright 1989 Samuel H. Smith
 *
 *)

{$v-}
{$m 8000,0,0}
{$D+,L+}
{$r+,s+}

uses DosMem, MdosIO, Tools;

const
   whoami = 'FixZip v1.0 02-21-89 (C) 1989 S.H.Smith';
   bufsiz = $8000;

type
   signature_type = longint;
      
const
   local_file_header_signature = $04034b50;

type
   local_file_header = record
      version_needed_to_extract:    word;
      general_purpose_bit_flag:     word;
      compression_method:           word;
      last_mod_file_time:           word;
      last_mod_file_date:           word;
      crc32:                        longint;
      compressed_size:              longint;
      uncompressed_size:            longint;
      filename_length:              word;
      extra_field_length:           word;
   end;

const
   central_file_header_signature = $02014b50;

type
   central_directory_file_header = record
      version_made_by:                 word;
      version_needed_to_extract:       word;
      general_purpose_bit_flag:        word;
      compression_method:              word;
      last_mod_file_time:              word;
      last_mod_file_date:              word;
      crc32:                           longint;
      compressed_size:                 longint;
      uncompressed_size:               longint;
      filename_length:                 word;
      extra_field_length:              word;

      file_comment_length:             word;
      disk_number_start:               word;
      internal_file_attributes:        word;
      external_file_attributes:        longint;
      relative_offset_local_header:    longint;
   end;

   central_list_ptr = ^central_list;
   central_list = record
      dir:     central_directory_file_header;
      name:    string;
      extra:   string;
      comment: string;
      next:    central_list_ptr;
   end;

const
   end_central_dir_signature = $06054b50;

type
   end_central_dir_record = record
      number_this_disk:                         word;
      number_disk_with_start_central_directory: word;
      total_entries_central_dir_on_this_disk:   word;
      total_entries_central_dir:                word;
      size_central_directory:                   longint;
      offset_start_central_directory:           longint;
      zipfile_comment_length:                   word;
   end;


var
   inzip:         dos_filename;
   infd:          dos_handle;
   outzip:        dos_filename;
   ofd:           dos_handle;

   sig:           signature_type;

   crec:          central_directory_file_header;
   lrec:          local_file_header;

   cdir:          central_list_ptr;
   lcdir:         central_list_ptr;
   endrec:        end_central_dir_record;

   filename:      string;
   extra:         string;
   comment:       string;

   iobuf:         array[1..bufsiz] of byte;



(* ---------------------------------------------------------- *)
procedure get_string(fd: dos_handle; len: word; var s: string);
var
   n: word;
begin
   if len > 255 then
      len := 255;
   n := dos_read(fd,s[1],len);
   s[0] := chr(len);
end;


(* ------------------------------------------------------------- *)
procedure save_central_dir;
   (* write original central directory records *)
begin
   dos_lseek(ofd,0,seek_cur);
   endrec.offset_start_central_directory := dos_tell;

   lcdir := cdir;
   while lcdir <> nil do
   begin
      sig := central_file_header_signature;
      dos_write(ofd,sig,sizeof(sig));
      dos_write(ofd,lcdir^.dir,sizeof(lcdir^.dir));
      dos_write(ofd,lcdir^.name[1],lcdir^.dir.filename_length);
      dos_write(ofd,lcdir^.extra[1],lcdir^.dir.extra_field_length);
      dos_write(ofd,lcdir^.comment[1],lcdir^.dir.file_comment_length);

      cdir := lcdir;
      lcdir := lcdir^.next;
      dos_freemem(cdir);
   end;

end;


(* ------------------------------------------------------------- *)
procedure build_central_dir_entry;
   (* gather information to create new central directory record *)
begin
   dos_lseek(ofd,0,seek_cur);
   crec.relative_offset_local_header := dos_tell;
   crec.version_needed_to_extract := lrec.version_needed_to_extract;
   crec.general_purpose_bit_flag := lrec.general_purpose_bit_flag;
   crec.compression_method := lrec.compression_method;
   crec.last_mod_file_time := lrec.last_mod_file_time;
   crec.last_mod_file_date := lrec.last_mod_file_date;
   crec.crc32 := lrec.crc32;
   crec.compressed_size := lrec.compressed_size;
   crec.uncompressed_size := lrec.uncompressed_size;
   crec.filename_length := lrec.filename_length;
   crec.extra_field_length := lrec.extra_field_length;
   crec.file_comment_length := 0;
   crec.disk_number_start := 0;
   crec.internal_file_attributes := 0;
   crec.external_file_attributes := 0;

   (* allocate the central_directory record *)
   if cdir = nil then
   begin
      dos_getmem(cdir,sizeof(cdir^));
      lcdir := cdir;
   end
   else
   begin
      dos_getmem(lcdir^.next,sizeof(lcdir^));
      lcdir := lcdir^.next;
   end;

   lcdir^.next := nil;
   lcdir^.dir := crec;
   lcdir^.extra := extra;
   lcdir^.name := filename;
   lcdir^.comment := '';
end;


(* ---------------------------------------------------------- *)
procedure process_local_file_header;
var
   n,w:     word;
   fsize:   longint;

begin
   n := dos_read(infd,lrec,sizeof(lrec));
   get_string(infd,lrec.filename_length,filename);
   get_string(infd,lrec.extra_field_length,extra);


   (* gather information to create new central directory record *)
   build_central_dir_entry;


   (* update the end_directory record for a new entry *)
   inc(endrec.total_entries_central_dir_on_this_disk);
   inc(endrec.total_entries_central_dir);
   inc(endrec.size_central_directory,
         sizeof(sig)+sizeof(crec)+
         crec.filename_length+crec.extra_field_length);


   (* write the local header for this new member *)
   sig := local_file_header_signature;
   dos_write(ofd,sig,sizeof(sig));
   dos_write(ofd,lrec,sizeof(lrec));
   dos_write(ofd,filename[1],lrec.filename_length);
   dos_write(ofd,extra[1],lrec.extra_field_length);


   writeln('Recovering member file: ',filename);

   (* copy the member file to the scratchfile *)
   fsize := lrec.compressed_size;

   repeat
      if fsize > bufsiz then
         n := bufsiz
      else
         n := fsize;
      fsize := fsize - n;

      w := dos_read(infd,iobuf,n);
      if w <> n then
      begin
         writeln('--- file truncated, will zero remainder of file');
         while w < n do
         begin
            inc(w);
            iobuf[w] := 0;
         end;
      end;

      dos_write(ofd,iobuf,n);
      w := dos_regs.ax;
      if n <> w then
      begin
         writeln('Disk write error!');
         halt;
      end;
   until fsize = 0;

end;


(* ---------------------------------------------------------- *)
procedure process_central_file_header;
var
   n:             word;
   rec:           central_directory_file_header;
   filename:      string;
   extra:         string;
   comment:       string;

begin
   n := dos_read(infd,rec,sizeof(rec));
   get_string(infd,rec.filename_length,filename);
   get_string(infd,rec.extra_field_length,extra);
   get_string(infd,rec.file_comment_length,comment);
end;


(* ---------------------------------------------------------- *)
procedure process_end_central_dir;
var
   n:             word;
   rec:           end_central_dir_record;
   comment:       string;

begin
   n := dos_read(infd,rec,sizeof(rec));
   get_string(infd,rec.zipfile_comment_length,comment);
end;


(* ------------------------------------------------------------- *)
   { extract and view text files in the zipfile - main entry }
procedure repair_zipfile;
begin
   while true do
   begin
      if dos_read(infd,sig,sizeof(sig)) <> sizeof(sig) then
      begin
         writeln('Unexpected end-of-file.');
         exit;
      end;

      if sig = local_file_header_signature then
         process_local_file_header
      else

      if sig = central_file_header_signature then
         process_central_file_header
      else

      if sig = end_central_dir_signature then
         process_end_central_dir
      else

      begin
         writeln('Invalid Zipfile header');
         exit;
      end;
   end;

end;




(* ------------------------------------------------------------- *)
begin
   writeln;
   writeln(whoami);
   writeln;

   if paramcount <> 2 then
   begin
      writeln('Usage: FixZip INFILE[.zip] OUTFILE[.zip]');
      halt;
   end;

   inzip := paramstr(1);
   if pos('.',inzip) = 0 then
      inzip := inzip + '.zip';
   stoupper(inzip);

   infd := dos_open(inzip,open_read);
   if infd = dos_error then
   begin
      writeln('Can''t open input: ',inzip);
      halt;
   end;

   outzip := paramstr(2);
   if pos('.',outzip) = 0 then
      outzip := outzip + '.zip';
   stoupper(outzip);

   ofd := dos_create(outzip);
   if ofd = dos_error then
   begin
      writeln('Can''t create output: ',outzip);
      halt;
   end;

   cdir := nil;
   lcdir := nil;
   fillchar(endrec,sizeof(endrec),0);

   writeln('Scanning original zipfile.');
   repair_zipfile;

   (* write all central directory records *)
   writeln('Writing new central directory.');
   save_central_dir;

   (* write the end-central-directory-header for the file *)
   sig := end_central_dir_signature;
   dos_write(ofd,sig,sizeof(sig));
   dos_write(ofd,endrec,sizeof(endrec));

   dos_close(infd);
   dos_close(ofd);
end.

