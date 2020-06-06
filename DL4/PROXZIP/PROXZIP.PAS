
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * ProXzip - Extract files from one ZIP zipfile to another
 *
 *)

{$v-}
{$m 10000,0,500000}
{$D+,L+}
{$r+,s+}

uses DosMem, MdosIO, Tools;

const
   whoami = 'ProExZip v3.3 04-12-90 (C) 1990 S.H.Smith';
   maxfiles = 10;

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
   zipname:       dos_filename;
   scratchzip:    dos_filename;
   pattern:       dos_filename;
   zipfd:         dos_handle;
   extcount:      integer;

   xrec:          central_directory_file_header;
   rec:           local_file_header;

   ofd:           dos_handle;
   sig:           signature_type;
   cdir:          central_list_ptr;
   lcdir:         central_list_ptr;
   endrec:        end_central_dir_record;

   filename:      string;
   extra:         string;
   dups:          boolean;



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
   procedure load_central_dir;
      (* load existing central directory *)
   var
      n,w:     word;
   begin
      dups := false;

      dos_lseek(ofd,-sizeof(endrec),seek_end);
      n := dos_read(ofd,endrec,sizeof(endrec));
      dos_lseek(ofd,endrec.offset_start_central_directory,seek_start);

      for w := 1 to endrec.total_entries_central_dir_on_this_disk do
      begin

         (* allocate the central_directory record *)
         if cdir = nil then
         begin
            new(cdir);
            lcdir := cdir;
         end
         else
         begin
            new(lcdir^.next);
            lcdir := lcdir^.next;
         end;
         lcdir^.next := nil;

         n := dos_read(ofd,sig,sizeof(sig));
         if sig <> central_file_header_signature then
         begin
            writeln('load_central_dir: incorrect signature');
         end;

         n := dos_read(ofd,lcdir^.dir,sizeof(lcdir^.dir));
         get_string(ofd,lcdir^.dir.filename_length,lcdir^.name);
         get_string(ofd,lcdir^.dir.extra_field_length,lcdir^.extra);
         get_string(ofd,lcdir^.dir.file_comment_length,lcdir^.comment);

         if filename = lcdir^.name then
            dups := true;
      end;

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
         dispose(cdir);
      end;

   end;


   (* ------------------------------------------------------------- *)
   procedure dispose_central_dir;
   begin
      lcdir := cdir;
      while lcdir <> nil do
      begin
         cdir := lcdir;
         lcdir := lcdir^.next;
         dispose(cdir);
      end;
   end;


   (* ------------------------------------------------------------- *)
   procedure build_central_dir_entry;
   begin
      (* gather information to create new central directory record *)
      dos_lseek(ofd,0,seek_cur);
      xrec.relative_offset_local_header := dos_tell;
      xrec.version_needed_to_extract := rec.version_needed_to_extract;
      xrec.general_purpose_bit_flag := rec.general_purpose_bit_flag;
      xrec.compression_method := rec.compression_method;
      xrec.last_mod_file_time := rec.last_mod_file_time;
      xrec.last_mod_file_date := rec.last_mod_file_date;
      xrec.crc32 := rec.crc32;
      xrec.compressed_size := rec.compressed_size;
      xrec.uncompressed_size := rec.uncompressed_size;
      xrec.filename_length := rec.filename_length;
      xrec.extra_field_length := rec.extra_field_length;
      xrec.file_comment_length := 0;
      xrec.disk_number_start := 0;
      xrec.internal_file_attributes := 0;
      xrec.external_file_attributes := 0;
   end;


   (* ------------------------------------------------------------- *)
   procedure xtract_member;
      (* extract the current member into a scratch file *)

   const
      bufmax = $1000;  {maximum buffer size in bytes}
   var
      buf:     ^byte;
      n,w:     word;
      fsize:   longint;

   begin
      cdir := nil;
      lcdir := nil;
      fillchar(endrec,sizeof(endrec),0);

      (* check for existing scratch zipfile *)
      if dos_exists(scratchzip) then
      begin
         ofd := dos_open(scratchzip,open_update);
         if ofd = dos_error then
         begin
            writeln('?Can''t reopen scratchzip');
            halt;
         end;

         (* load existing central directory *)
         load_central_dir;

         (* position for appending new entries *)
         dos_lseek(ofd,endrec.offset_start_central_directory,seek_start);
      end
      else

      (* new scratch zipfile created *)
      begin
         {$i-} writeln('Created: ',remove_path(scratchzip)); {$i+}
         ofd := dos_create(scratchzip);
         if ofd = dos_error then
         begin
            writeln('?Can''t create scratchzip');
            halt;
         end;
         dups := false;
      end;

      if dups then
      begin
         {$i-} writeln(filename:12,' is already present in ',
               remove_path(scratchzip),'!'); {$i+}
         dos_close(ofd);
         dispose_central_dir;
         dos_lseek(zipfd,rec.compressed_size,seek_cur);
         exit;
      end;

      if endrec.total_entries_central_dir_on_this_disk >= maxfiles then
      begin
         {$i-} writeln('Please download ',remove_path(scratchzip),' before extracting any more files!');
         {$i+}
         dos_close(ofd);
         dispose_central_dir;
         dos_lseek(zipfd,rec.compressed_size,seek_cur);
         exit;
      end;



      {$i-} writeln(filename:12,' extracted from ',
            remove_path(zipname),' to ',remove_path(scratchzip),'.'); {$i+}
      inc(extcount);

      (* gather information to create new central directory record *)
      build_central_dir_entry;


      (* write the local header for this new member *)
      sig := local_file_header_signature;
      dos_write(ofd,sig,sizeof(sig));
      dos_write(ofd,rec,sizeof(rec));
      dos_write(ofd,filename[1],rec.filename_length);
      dos_write(ofd,extra[1],rec.extra_field_length);


      (* copy the member file to the scratchfile *)
      fsize := rec.compressed_size;
      getmem(buf,bufmax);

      repeat
         if fsize > bufmax then
            n := bufmax
         else
            n := fsize;
         fsize := fsize - n;
         n := dos_read(zipfd,buf^,n);
         dos_write(ofd,buf^,n);
         w := dos_regs.ax;
      until w < bufmax;

      if n <> w then
      begin
         dos_unlink(scratchzip);
         {$i-} writeln('Disk write error!'); {$i+}
         halt;
      end;

      freemem(buf,bufmax);


      (* write original central directory records *)
      save_central_dir;


      (* write new central directory record *)
      sig := central_file_header_signature;
      dos_write(ofd,sig,sizeof(sig));
      dos_write(ofd,xrec,sizeof(xrec));
      dos_write(ofd,filename[1],xrec.filename_length);
      dos_write(ofd,extra[1],xrec.extra_field_length);


      (* update the end_directory record for a new entry *)
      inc(endrec.total_entries_central_dir_on_this_disk);
      inc(endrec.total_entries_central_dir);
      inc(endrec.size_central_directory,
            sizeof(sig)+sizeof(xrec)+
            xrec.filename_length+xrec.extra_field_length);


      (* write the end-central-directory-header for the file *)
      sig := end_central_dir_signature;
      dos_write(ofd,sig,sizeof(sig));
      dos_write(ofd,endrec,sizeof(endrec));

      dos_close(ofd);
   end;


   (* ---------------------------------------------------------- *)
   procedure process_local_file_header;
   var
      n:             word;
      name:          dos_filename;

   begin
      n := dos_read(zipfd,rec,sizeof(rec));
      get_string(zipfd,rec.filename_length,filename);
      get_string(zipfd,rec.extra_field_length,extra);
      name := remove_path(filename);
      stoupper(name);

      (* skip the file if it does not match the selection wildcard *)
      if wildcard_match(pattern,name) then
         xtract_member
      else
         dos_lseek(zipfd,rec.compressed_size,seek_cur);
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
      n := dos_read(zipfd,rec,sizeof(rec));
      get_string(zipfd,rec.filename_length,filename);
      get_string(zipfd,rec.extra_field_length,extra);
      get_string(zipfd,rec.file_comment_length,comment);
   end;


   (* ---------------------------------------------------------- *)
   procedure process_end_central_dir;
   var
      n:             word;
      rec:           end_central_dir_record;
      comment:       string;

   begin
      n := dos_read(zipfd,rec,sizeof(rec));
      get_string(zipfd,rec.zipfile_comment_length,comment);
   end;


   (* ------------------------------------------------------------- *)
      { extract and view text files in the zipfile - main entry }
   procedure process_pattern;
   var
      fail: integer;

   begin
      zipfd := dos_open(zipname,open_read);
      if zipfd = dos_error then
         exit;

      fail := 0;

      while true do
      begin

         if dos_read(zipfd,sig,sizeof(sig)) <> sizeof(sig) then
            exit;

{writeln('sig = ',sig);}

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
            inc(fail);
            if fail > 100 then
            begin
               writeln('Invalid Zipfile header');
               exit;
            end;
         end;
      end;

      dos_close(zipfd);
   end;



(* ------------------------------------------------------------- *)
var
   i: integer;
begin
   assign(output,'');
   rewrite(output);

{$i-}
   writeln;
   writeln(whoami);

   if paramcount < 3 then
   begin
      writeln;
      writeln('Usage: proxzip INFILE.zip OUTFILE.zip MEMBER ... MEMBER');
      halt;
   end;

   zipname := paramstr(1);
   stoupper(zipname);

   scratchzip := paramstr(2);
   stoupper(scratchzip);

   extcount := 0;

   if zipname = scratchzip then
   begin
      writeln('Input and output zipfiles must be different!');
      halt;
   end;

   for i := 3 to paramcount do
   begin
      pattern := paramstr(i);
      stoupper(pattern);
      process_pattern;
   end;

   writeln(extcount,' file(s) extracted.');
end.

