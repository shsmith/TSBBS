
(*
 * (C) 1989 Samuel H. Smith, 15-feb-89
 *
 * This program is provided courtesy of:
 *         The Tool Shop
 *         Samuel H. Smith
 *         P. O. Box 4808
 *         Panorama City, CA 91412-4808
 *         (818) 891-6780
 *
 * Disclaimer
 * ----------
 *
 * If you modify this program, I would appreciate a copy of the new 
 * source code.   Please don't delete my name from the program.
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (818) 891-6780
 *
 * Enjoy!     Samuel H. Smith
 *
 *)


{$r-,s-}            (* enable range checking *)
{$v-}               (* allow variable length string params *)
{$D+,L+}

uses
   Dos,Tools,MDosIO;

const
   whoami   = 'ZIPDS: Zipfile Date Stamper  v1.2 01-03-91;  (C) 1991 S.H.Smith';

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

var
   zipfd:      dos_handle;
   zipfn:      dos_filename;
   newdate:    word;
   newtime:    word;
   err:        integer;


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

   (* track newest member *)
   if dos_jdate(rec.last_mod_file_time, rec.last_mod_file_date) >
      dos_jdate(newtime,newdate) then
   begin
      newdate := rec.last_mod_file_date;
      newtime := rec.last_mod_file_time;
   end;

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
end;


(* ---------------------------------------------------------- *)
procedure process_headers(name: dos_filename);
var
   sig:  longint;

begin
   newdate := 0;
   newtime := 0;

   while true do
   begin

      if dos_read(zipfd,sig,sizeof(sig)) <> sizeof(sig) then
      begin
         write('has errors!  Truncated!  '^G);
         inc(err);
         exit;
      end
      else

      if sig = local_file_header_signature then
         process_local_file_header
      else

      if sig = central_file_header_signature then
      begin
         process_central_file_header;
         write('Okay.  ');
         exit;
      end
      else

      if sig = end_central_dir_signature then
      begin
         process_end_central_dir;
         write('Okay..  ');
         exit;
      end
      else

      begin
         write('has errors!  Bad header!  sig='^g,sig);
         inc(err);
         exit;
      end;
   end;
end;


(* ---------------------------------------------------------- *)
procedure process_zip(dir,name: dos_filename);
var
   time,date:  word;
begin
   write(dir,name,' ');
   zipfd := dos_open(dir+name,open_update);
   if zipfd = dos_error then
   begin
      writeln(' Can''t open!');
      exit;
   end;

   process_headers(dir+name);

   dos_file_times(zipfd,time_get,time,date);
   if dos_jdate(time,date) <> dos_jdate(newtime,newdate) then
   if (newdate <> 0) and (newtime <> 0) then
   begin
      write('Stamping date.');
      dos_file_times(zipfd,time_set,newtime,newdate);
   end;

   dos_close(zipfd);
   writeln;
end;


(* ---------------------------------------------------------- *)
var
   DirInfo:       SearchRec;
   Dir,Nam,Ext:   dos_filename;

begin
   writeln;
   writeln(whoami);
   writeln;

   if paramcount = 0 then
   begin
      writeln('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (818) 891-6780.');
      writeln;
      writeln('Usage:  ZipDS *.zip [>OUT]');
      writeln;
      writeln('Sets non-0 errorlevel on truncated zipfiles.');
      writeln('Stamps all zipfiles with date of newest member file.');
      writeln('Also produces the proper error message for use with PROUTEST.');
      writeln;
      halt(99);
   end;

   err := 0;

   zipfn := paramstr(1);
   if pos('.',zipfn) = 0 then
      zipfn := zipfn + '.zip';

   FSplit(zipfn,Dir,Nam,Ext);
   FindFirst(zipfn,$21,DirInfo);
   while (DosError = 0) do
   begin
      process_zip(Dir,DirInfo.name);
      FindNext(DirInfo);
   end;

   writeln(err,' errors detected.');;
   halt(err);
end.

