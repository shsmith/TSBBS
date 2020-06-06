
(*
 * tar - "tape" archive:  this program will maintain
 *       a sequential access archive file that can be
 *       used for library storage, tape storage or
 *       file transfer.  It is optimized to minimize writes to
 *       the archive file so that slow devices will have
 *       reduced seeking.
 *
 * Patterned after the unix "tar" utility.
 *
 * Author:  Samuel H. Smith,  3-jan-86 v1.0
 *
 *)


{$g512            Buffer standard input for -f option}
{$p128,d-         Buffer standard output for output redirection}

{$I\SHS\TOOLS\regpack.inc    DOS register package}
{$I\SHS\TOOLS\dosio.inc      DOS I/O function library}
{$I\SHS\TOOLS\getfiles.inc   Get file list from wildcard}
{$I\SHS\TOOLS\itou.inc       Integer to unsigned conversion}


const
   tarversion = 'TAR 1.1';
   tardate    = '(7/24/87)';

   buf_size   = $8000;

type
   file_header = record
      tarid:   string[10];
      name:    dos_filename;
      length:  real;
      time:    integer;
      date:    integer;
   end;

   ram_page = array [0..$7fff] of byte;

   anystring = string[80];


var
   hdr:       file_header;
   read_buf:  ^ram_page;
   write_buf: ^ram_page;
   write_pos: integer;
   infd:      dos_handle;
   outfd:     dos_handle;
   incnt:     integer;
   outcnt:    integer;
   total:     real;
   fun:       anystring;
   tarfile:   dos_filename;
   pattern:   dos_filename;
   free_space: real;


procedure error(s: anystring);
var
  j:  dos_handle;

begin
   if outfd <> 0 then
      j := dos_close(outfd);

   writeln('ERROR: ', s);
   writeln('Program aborted');
   halt;
end;


(*
 * display_header - display the current 'hdr' contents formatted
 *                  as: size date time filename
 *)

procedure display_header;
const
   months:  array[0..15] of string[3] = ('---',
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                '13?', '14?', '15?');

var
   year, month, day, hour, min:  integer;

begin

   year  := (hi(hdr.date) shr 1) + 80;
   month := (hdr.date shr 5) and 15;

   day   := hdr.date and 31;
   hour  := (hi(hdr.time) shr 3);
   min   := (hdr.time shr 5) and 63;

   writeln(hdr.length:8:0, '   ', day:2, '-', months[month], '-', year:2,
                           ' ', hour*100+min:4, '   ', hdr.name);

   flush(output);
end;


procedure banner;
begin
   writeln;
   writeln('   Size     Last updated      File name');
   writeln('  ------   --------------   -------------');
end;



(*
 * clear_buffer - clear any buffer to all zeros
 *
 *)

procedure clear_buffer(var    buffer;
                       size:  integer);
var
   i:   integer;
   b:   ram_page  absolute buffer;

begin
   for i := 0 to size do
      b[i] := 0;
end;



(*
 * tar_allocate - allocate all available space on output device
 *                if it is "D:" - this speeds up tape drives
 *
 *)

procedure tar_allocate;
var
   tardev:         char;

begin

   outfd := dos_create(tarfile, 0);
   if outfd = dos_error then
      error('can''t create tarfile '+tarfile);


(* allocate the entire output device in advance to prevent dos
   rewinding to update the FAT when we are in the middle of the backup.
   note that extra space will be released when the tarfile is closed *)

   tardev := upcase(tarfile[1]);
   if (tarfile[2] <> ':') then
      tardev := '@';

   with dos_regs do
   begin
      ax := $3600;
      dx := ord(tardev) - ord('@');
      msdos(dos_regs);
      free_space := i_to_ur(ax) * i_to_ur(bx) * i_to_ur(cx);

      if tarfile[2] <> ':' then
         exit;

      if dos_lseek(outfd, seek_start, free_space) <> free_space then
         error('alloc seek');

      if dos_write(outfd, outfd, 0) <> 0 then
         error('alloc truncate');

      if dos_close(outfd) = dos_error then
         error('alloc close');

      outfd := dos_open(tarfile, open_update);
      if outfd = dos_error then
         error('alloc reopen');
   end;

end;


procedure buffered_write(fd:       dos_handle;
                         var       buf;
                         size:     integer);
var
   data_buf:   ram_page  absolute buf;
   buf_space:  integer;
   move_size:  integer;

begin
   free_space := free_space - i_to_ur(size);
   buf_space := buf_size - write_pos;

   if (i_to_ur(size) > i_to_ur(buf_space)) and (write_pos <> 0) then
   begin
      move(data_buf, write_buf^[write_pos], buf_space);
      write_pos := write_pos + buf_space;

      if dos_write(fd, write_buf^, write_pos) <> write_pos then
         error('can''t write tarfile '+tarfile);

      move_size := size - buf_space;
      move(data_buf[buf_space], write_buf^, move_size);
      write_pos := move_size;
   end
   else

   begin
      move(data_buf, write_buf^[write_pos], size);
      write_pos := write_pos + size;
   end;

end;


procedure make_new_tarfile;
var
   fd:    file;
   c:     char;

begin
{$I-}
   assign(fd, tarfile);
   reset(fd);
{$I+}
   if ioresult = 0 then
   begin
      close(fd);
      flush(output);
      write(con,'WARNING: tarfile '+tarfile+
                ' exists.  Overwrite? (Y/N) '^G^G^G);
      read(kbd, c);
      c := upcase(c);
      writeln(c);
      flush(output);
      if c <> 'Y' then
         halt;
   end;

   tar_allocate;      {open and allocate tarfile}
   write_pos := 0;
end;



procedure close_tarfile;
begin
   if dos_write(outfd, write_buf^, write_pos) <> write_pos then
      error('can''t write tarfile '+tarfile);

   if dos_write(outfd, write_buf^, 0) <> 0 then
      error('tarfile truncate');

   if dos_close(outfd) = dos_error then
      error('tarfile close');
end;


procedure swap_disks;
var
   c: char;
begin
   close_tarfile;

   flush(output);
   write(con,'WARNING: No space on output device;  place next disk in drive');
   write(con,' and press ENTER: '^G^G^G);

   repeat
      read(kbd, c);
      c := upcase(c);
   until c = #13;
   writeln;
   flush(output);

   make_new_tarfile;
end;


procedure tar_write;
var
   fd:  file;
   pos: integer;

begin

{$I-}
   assign(fd, hdr.name);
   reset(fd);
{$I+}
   if ioresult <> 0 then
      exit;

   close(fd);

   infd := dos_open(hdr.name, open_read);

   dos_file_times(infd, time_get, hdr.time, hdr.date);
   hdr.length := dos_lseek(infd, seek_end, 0);


   display_header;
   if free_space < (hdr.length+2000) then
   begin
      repeat
         swap_disks;
      until free_space >= (hdr.length+2000);
      display_header;
   end;


   if dos_lseek(infd, seek_start, 0) <> 0 then
      error('seek infd');

   buffered_write(outfd, hdr, sizeof(hdr));

   total := 0;
   repeat
      incnt := dos_read(infd, read_buf^, buf_size);

      if incnt <> 0 then
      begin
         total := total + i_to_ur(incnt);
         buffered_write(outfd, read_buf^, incnt);
      end;

   until (incnt <> buf_size);

   if total <> hdr.length then
      error('size');

   if dos_close(infd) = dos_error then
      error('close infd');
end;


procedure create_tar;
var
   i:     integer;
   line:  string[80];
   buf:   string[80];

begin

   make_new_tarfile;

   getfiles(pattern, filetable, filecount);
                      {get full list of files}

   banner;

   clear_buffer(hdr, sizeof(hdr));
   hdr.tarid := tarversion;

   if (filecount = 0) or (pattern = '') or (filetable[1] = '-F') then
   begin
      {if file list comes from stdin then
       read stdin and process each line as a filename}

      while not seekeof do
      begin
         readln(input, buf);

         line := '';
         for i := 1 to length(buf) do
            if buf[i] in [#33..'~'] then
               line := line + buf[i];

         hdr.name := line;
         tar_write;
      end;
   end
   else

   for i := 1 to filecount do
   begin
      hdr.name := filetable[i];
      tar_write;
   end;

   close_tarfile;
end;



procedure table_tar;
var
   code:  integer;

begin

   infd := dos_open(tarfile, open_read);
   if infd = dos_error then
      halt;


   banner;

   repeat
      incnt := dos_read(infd, hdr, sizeof(hdr));
      if incnt <> sizeof(hdr) then
         halt;

      if hdr.tarid <> tarversion then
      begin
         writeln('id = ', hdr.tarid);
         error('bad header (file may not be TAR format)');
      end;

      display_header;

      if dos_lseek(infd, seek_cur, hdr.length) = dos_error then
         error('seek infd');

   until true=false;

end;


procedure make_directory_for(name:  anystring);
var
   i:     integer;
   dir:   anystring;

begin
   dir := '';

   for i := 1 to length(name) do
   begin
      if name[i] = '\' then
      begin
{$I-}
        mkdir(dir);
{$I-}
        if ioresult = 0 then
           writeln(con,dir,': created');
      end;

      dir := dir + name[i];
   end;
end;


procedure extract_tar(force_overwrite: boolean);
var
   code:  integer;
   fd:    file;
   c:     char;

begin

   infd := dos_open(tarfile, open_read);
   if infd = dos_error then
      halt;


   banner;

   repeat
      incnt := dos_read(infd, hdr, sizeof(hdr));
      if incnt <> sizeof(hdr) then
         halt;

      if hdr.tarid <> tarversion then
      begin
         writeln('id = ', hdr.tarid);
         error('bad header (file may not be TAR format)');
      end;

      display_header;

{$I-}
      assign(fd, hdr.name);
      reset(fd);
{$I+}
      if ioresult = 0 then
      begin
         close(fd);
         if not force_overwrite then
         begin
            write('WARNING: file '+hdr.name+' exists.  Overwrite? (Y/N) ');
            flush(output);
            read(kbd, c);
            c := upcase(c);
            writeln(c);
            flush(output);
            if c <> 'Y' then
               hdr.name := 'nul';   {output to null file if no overwrite}
         end;
      end;


{$I-}
      assign(fd, hdr.name);
      rewrite(fd);
{$I+}
      if ioresult <> 0 then
         make_directory_for( hdr.name )
      else
         close(fd);


      outfd := dos_create(hdr.name, 0);

      repeat
         if hdr.length > i_to_ur(buf_size) then
            incnt := buf_size
         else
            incnt := ur_to_i(hdr.length);

         if dos_read(infd, read_buf^, incnt) <> incnt then
            error('unexpected end of tarfile '+tarfile);

         outcnt := dos_write(outfd, read_buf^, incnt);
         if outcnt <> incnt then
            error('can''t extract '+hdr.name);

         hdr.length := hdr.length - i_to_ur(incnt);
      until hdr.length = 0;

      dos_file_times(outfd, time_set, hdr.time, hdr.date);
      if dos_close(outfd) = dos_error then
         error('close outfd');

   until true=false;
end;


var
   i:  integer;

begin  {main}
   writeln;
   write(tarversion, ' ', tardate, ',  ');
   flush(output);

   if (paramcount < 2) then
   begin
      writeln('Missing command line parameters');
      writeln;
      writeln('TAR:  Tape Archive Manager              S.H.Smith');
      writeln;
      writeln('Usage:  tar FUNCTION TARFILE FILE ... FILE');
      writeln;
      writeln('FUNCTION is one of:');
      writeln('      C       to create an archive file');
      writeln('      T       to list table of contents');
      writeln('      X       to extract from an archive file');
      writeln('      XF      to extract and force overwriting existing files');
      writeln;
      writeln('TARFILE is the filename of the of the TAR archive file to use');
      writeln('FILE is one or more wildcard file specifications. ');
      writeln('"-f" will cause file list to be piped from standard input.');
      writeln;
      writeln('Examples:  tar c paslib *.pas *.inc');
      writeln('           chkdsk/v c: | tar c d:backup -f');
      halt;
   end;


   new(read_buf);
   new(write_buf);

   fun := paramstr(1);
   tarfile := paramstr(2);

   if pos('.', tarfile) = 0 then
      tarfile := tarfile + '.tar';

   for i := 1 to length(tarfile) do
      tarfile[i] := upcase(tarfile[i]);


   pattern := paramstr(3);     {build patternlist from remaining params}

   for i := 4 to paramcount do
      pattern := pattern + ',' + paramstr(i);

   for i := 1 to length(pattern) do
      pattern[i] := upcase(pattern[i]);


   case upcase(fun[1]) of
      'U',
      'C':   begin
                writeln('Create new TAR file');
                flush(output);
                create_tar;
             end;

      'X':   begin
                if upcase(fun[2]) = 'F' then
                   write('Force ');
                writeln('Extract files');
                flush(output);
                extract_tar(upcase(fun[2]) = 'F');
             end;

      'T':   begin
                writeln('Table of contents');
                flush(output);
                table_tar;
             end;

      else   begin
                writeln('Invalid function');
             end;

   end;

end.

