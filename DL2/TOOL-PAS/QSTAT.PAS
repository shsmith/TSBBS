
program demo;

uses dos;

function ltos(l: longint): string;
var
   b:    string[20];
   b1:   string[20];
   i:    integer;
begin
   str(l:20,b);

   b1 := '';
   for i := 1 to 20 do         {insert commas}
   begin
      if b[i] <> ' ' then
      begin
         if (b1 <> '') and ((i mod 3) = 0) then
            b1 := b1 + ',';
         b1 := b1 + b[i];
      end;
   end;

   ltos := b1;
end;

type
   asciiz_type =       string [255];
   cardinal =          integer;

{$i cache.inc}
   
var
   reg:                registers;
   system_info:        system_status_type;
   drive_info:         all_drive_status_type;
   drive_index:        drive_index_type;
   
{==============================================================================}

procedure fetch_cache_status;
begin
   reg.ax := $3000;
   reg.ds := dseg;
   reg.dx := ofs (system_info);
   intr($13, reg);

   reg.ax := $3001;
   reg.dx := ofs (drive_info);
   intr($13, reg);
end;



{==============================================================================}

procedure show_status_line;
var
   n: integer;

begin
   fetch_cache_status;

   writeln;
   writeln('         Active   Dirty    Errors       Read      Reads       Write    Delayed');
   writeln(' Drive   Blocks  Blocks    R    W       I/Os      Saved       I/Os     Writes');
   writeln(' -----  ------- -------  ---- ----  ----------- --------  ----------- --------');

   for n := 0 to 15 do
   with drive_info[n] do
   if in_use or (rio_count > 0) then
   begin
      write('   ',
            chr(dos_drive+ord('A')),':',
            ltos(sectors_assigned):9,
            ltos(dirty_sectors):8,
            ltos(read_error_count):6,
            ltos(write_error_count):5,
            ltos(rio_count):13);

      if rio_count = 0 then
         write('0 %':9)
      else
         write(int(rio_count-miss_count)/int(rio_count)*100:7:0,' %');

      write(ltos(wio_count):13);
      if wio_count = 0 then
         write('0 %':9)
      else
         write(int(dio_count)/int(wio_count)*100:7:0,' %');

      writeln;
   end;
end;


{==============================================================================}
begin
   reg.ax := 39 * 256;
   reg.bx := 0;
   reg.cx := 0;
   reg.dx := 0;
   intr($13, reg);
   
   if reg.bx = 0 then
   begin
      writeln('QUICKCACHE not installed.');
      halt;
   end;

   {==============================================================================}
   { Set up initial configuration }
   {==============================================================================}

(*******
    enable_cache;
    enable_bufferedwrite;
    enable_bufferedread;
    set_flush_interval(0);
    set_flush_count(0);
    set_sectors(200);
*******)

   show_status_line;
end.

