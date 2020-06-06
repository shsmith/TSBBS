
(*
 * file formats for archives created by pkzip
 * s.smith, 2-2-89
 *
 *)

{$m 6000,0,0}
{$s-,r-}
{$d+,l+}
{$v-}

uses MdosIO, DOS;

const
   version = 'ZipV 1.3  -  Verbose ZIP directory listing  -  S.H.Smith, 7-14-89';

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

const
   compression_methods: array[0..7] of string[8] =
      (' Stored ', ' Shrunk ',
       'Reduce-1', 'Reduce-2', 'Reduce-3', 'Reduce-4',
       'Implode', '?');

var
   zipfd:   dos_handle;
   zipfn:   dos_filename;


type
   string8 = string[8];



(* ---------------------------------------------------------- *)
procedure get_string(len: word; var s: string);
var
   n: word;
begin
   if len > 255 then
      len := 255;
   n := dos_read(zipfd,s[1],len);
   s[0] := chr(len);
end;


(* ---------------------------------------------------------- *)
procedure itoa2(i: integer; var sp);
var
   s: array[1..2] of char absolute sp;
begin
   s[1] := chr( (i div 10) + ord('0'));
   s[2] := chr( (i mod 10) + ord('0'));
end;

function format_date(date: word): string8;
const
   s:       string8 = 'mm-dd-yy';
begin
   itoa2(((date shr 9) and 127)+80, s[7]);
   itoa2( (date shr 5) and 15,  s[1]);
   itoa2( (date      ) and 31,  s[4]);
   format_date := s;
end;

function format_time(time: word): string8;
const
   s:       string8 = 'hh:mm:ss';
begin
   itoa2( (time shr 11) and 31, s[1]);
   itoa2( (time shr  5) and 63, s[4]);
   itoa2( (time shl  1) and 63, s[7]);
   format_time := s;
end;


(* ---------------------------------------------------------- *)
procedure process_local_file_header;
var
   n:             word;
   rec:           local_file_header;
   filename:      string;
   extra:         string;

begin
   n := dos_read(zipfd,rec,sizeof(rec));
   get_string(rec.filename_length,filename);
   get_string(rec.extra_field_length,extra);
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
   get_string(rec.filename_length,filename);
   get_string(rec.extra_field_length,extra);
   get_string(rec.file_comment_length,comment);

   write(rec.uncompressed_size:7,'  ',
           compression_methods[rec.compression_method]:8,' ',
           rec.compressed_size:7,'   ',
           format_date(rec.last_mod_file_date),'  ',
           format_time(rec.last_mod_file_time));

   if (rec.internal_file_attributes and 1) <> 0 then
      write('   Ascii  ')
   else
      write('  Binary  ');

   writeln(filename);

(**************
   writeln;
   writeln('central file header');
   writeln('   filename = ',filename);
   writeln('   extra = ',extra);
   writeln('   file comment = ',comment);
   writeln('   version_made_by = ',rec.version_made_by);
   writeln('   version_needed_to_extract = ',rec.version_needed_to_extract);
   writeln('   general_purpose_bit_flag = ',rec.general_purpose_bit_flag);
   writeln('   compression_method = ',rec.compression_method);
   writeln('   last_mod_file_time = ',rec.last_mod_file_time);
   writeln('   last_mod_file_date = ',rec.last_mod_file_date);
   writeln('   crc32 = ',rec.crc32);
   writeln('   compressed_size = ',rec.compressed_size);
   writeln('   uncompressed_size = ',rec.uncompressed_size);
   writeln('   disk_number_start = ',rec.disk_number_start);
   writeln('   internal_file_attributes = ',rec.internal_file_attributes);
   writeln('   external_file_attributes = ',rec.external_file_attributes);
   writeln('   relative_offset_local_header = ',rec.relative_offset_local_header);
***********)

end;


(* ---------------------------------------------------------- *)
procedure process_end_central_dir;
var
   n:             word;
   rec:           end_central_dir_record;
   comment:       string;

begin
   n := dos_read(zipfd,rec,sizeof(rec));
   get_string(rec.zipfile_comment_length,comment);

(*******
   writeln;
   writeln('end central dir');
   writeln('   zipfile comment = ',comment);
   writeln('   number_this_disk = ',rec.number_this_disk);
   writeln('   number_disk_with_start_central_directory = ',rec.number_disk_with_start_central_directory);
   writeln('   total_entries_central_dir_on_this_disk = ',rec.total_entries_central_dir_on_this_disk);
   writeln('   total_entries_central_dir = ',rec.total_entries_central_dir);
   writeln('   size_central_directory = ',rec.size_central_directory);
   writeln('   offset_start_central_directory = ',rec.offset_start_central_directory);
********)

end;


(* ---------------------------------------------------------- *)
procedure process_headers;
var
   sig:  longint;
   fail: integer;

begin
   fail := 0;

   while true do
   begin

      if dos_read(zipfd,sig,sizeof(sig)) <> sizeof(sig) then
         exit
      else

      if sig = local_file_header_signature then
         process_local_file_header
      else

      if sig = central_file_header_signature then
         process_central_file_header
      else

      if sig = end_central_dir_signature then
      begin
         process_end_central_dir;
         exit;
      end
      else

      begin
         inc(fail);
         if fail > 100 then
         begin
            writeln('invalid zipfile header');
            exit;
         end;
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure list_zip(name: dos_filename);
begin
   zipfd := dos_open(name,open_read);
   if zipfd = dos_error then
   begin
      writeln('Can''t open: ',name);
      halt(1);
   end;

   writeln;
   if (pos('?',zipfn)+pos('*',zipfn)) > 0 then
   begin
      writeln('Zipfile: '+name);
      writeln;
   end;
   writeln('  Size    Method   Zipped     Date      Time     Type     File Name');
   writeln('-------- -------- --------  --------  --------  ------  -------------');

   process_headers;

   dos_close(zipfd);
end;


(* ---------------------------------------------------------- *)
var
   DirInfo:       SearchRec;
   Dir,Nam,Ext:   dos_filename;

begin
   if paramcount <> 1 then
   begin
      writeln(version);
      writeln('Usage: ZipV [directory\]zipfile[.zip]');
      halt(1);
   end;

   zipfn := paramstr(1);
   if pos('.',zipfn) = 0 then
      zipfn := zipfn + '.zip';

   FSplit(zipfn,Dir,Nam,Ext);
   FindFirst(zipfn,$21,DirInfo);
   while (DosError = 0) do
   begin
      list_zip(Dir+DirInfo.name);
      FindNext(DirInfo);
   end;
   halt(0);
end.

