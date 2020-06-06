
(*
 * prop - filters plain text.  outputs codes for proportional spacing
 *        to IBM graphics printers.
 *
 * author:  samuel h. smith, 01-Nov-86
 *
 *)

program proportional_spacing;

type
   anystring = string [200];  {general character strings}


(* font information about a single character *)
   font_char = record
         table1: array [1..9] of byte;
                                    {pixels for first print pass}

         table2: array [1..9] of byte;
                                    {pixels for second print pass}

         f:      byte;
         g:      byte;
         h:      byte;              {spacing information}

   end;


(* the layout of the font file *)
   font_rec = array [#32.. #126] of font_char;


(* register package for bios interface *)
   regpack = record
         ax, bx, cx, dx,
         bp, si, di, ds,
         es, flags:  integer;
   end;

const
   maxbuf = 3000;             {maximum columns to buffer at a time. must
                                be able to hold the longest line processed}

   space_width = 10;          {print columns for each space character}

   char_space = 4;            {print columns of space after each char}

   fontfile : anystring = 'prop.fnt';
                              {default font filename}

   quality : boolean = true;  {quality printing mode?}

   bold : boolean = false;    {bold (doublestrike)?}

   underline : boolean = false;
                              {add underline? }

   underline_bit = $100;      {bit corresponding to printer underline}


var
   font:   font_rec;          {the currently loaded font}

   col_buffer: array [1.. maxbuf] of integer;
   col_count: integer;        {buffer holding pixels for the current line.
                                the lo byte is the first pass bitmap,
                                hi byte is for the second pass}

   reg:    regpack;
   partial: boolean;          {have we done a partial linefeed already?}



(*
 * get the value of an environment variable
 *
 *)


function get_environment_var (id:                 anystring): anystring;
var
   envseg:             integer absolute cseg : $2c;
   i:                  integer;
   env:                anystring;

begin
   i := 0;

   repeat
      env := '';

      while mem [envseg : i]<> 0 do
      begin
         env := env + chr (mem [envseg : i]);
         i := i + 1;
      end;

      if copy (env, 1, length (id))= id then
      begin
         get_environment_var := copy (env, length (id)+ 1, 255);
         exit;
      end;

      i := i + 1;
   until mem [envseg : i]= 0;


(* not found *)

   get_environment_var := '';
end;


(*
 * locate a file.  search paths if needed.  returns
 * the full pathname of the located file.
 * returns only the original name if not found.
 *
 *)

function locate_file (name:               anystring): anystring;
var
   paths:              anystring;
   dir:                anystring;
   i:                  integer;
   fd:                 file;

begin


(* get the paths and start searching them.  arrange for current directory
   to be scanned first.  add trailing ; to handle special case for last path *)
   paths := ';' + get_environment_var ('PATH=')+ ';';
   dir := '';

   for i := 1 to length (paths) do
   begin


(* if a full directory has been collected, then try this path *)

      if (paths [i]= ';') or (i = length (paths)) then
      begin

         if (length (dir)> 1) and (dir [length (dir)]<> '\') then
            dir := dir + '\';

{$I-}
         assign(fd, dir + name);
         reset(fd);
{$I+}
         if ioresult = 0 then
         begin
            close(fd);
            locate_file := dir + name;
            exit;
         end;

         dir := '';
      end
      else
         dir := dir + paths [i];
   end;


(* couldn't find it.  return the original name *)

   locate_file := name;
end;

(*
 * printc - print a single character on the standard line printer.
 *          this procedure used the BIOS to drive the printer.
 *          it works 2-3 times faster than calling DOS or writing to LST.
 *
 *)

procedure printc (ch:     char);
begin
   reg.ax := ord (ch);
   reg.dx := 0;
   intr(23, reg);
end;


(*
 * print_quality - print out the current column buffer in two-pass quality
 *                 printing mode.  this print style leaves the printer with
 *                 a partial linefeed of 1/217".  this condition is flagged
 *                 so that it can be corrected later on.
 *)

procedure print_quality;
var
   i:      integer;

begin

   printc(#27);
   printc(#85);
   printc(#1);   {select unidirectional printing}

(* print first strike of the line *)
   printc(#27);
   printc('L');
   printc(chr (lo (col_count)));
   printc(chr (hi (col_count)));
   for i := 1 to col_count do
      printc(chr (lo (col_buffer [i])));

   if bold then
   begin
      printc(#13);
      printc(#27);
      printc('L');
      printc(chr (lo (col_count)));
      printc(chr (hi (col_count)));
      for i := 1 to col_count do
         printc(chr( lo (col_buffer [i])));
   end;


(* advance paper by one half pixel *)

   printc(#27);
   printc('3');
   printc(#2);
   printc(#13);
   printc(#10);


(* print second strike of the line *)
   printc(#27);
   printc('L');
   printc(chr (lo (col_count)));
   printc(chr (hi (col_count)));
   for i := 1 to col_count do
      printc(chr (hi (col_buffer [i])));

   if bold then
   begin
      printc(#13);
      printc(#27);
      printc('L');
      printc(chr (lo (col_count)));
      printc(chr (hi (col_count)));
      for i := 1 to col_count do
         printc(chr( hi (col_buffer [i])));
   end;


(* restore line spacing to normal-1 pixel *)

   col_count := 0;
   printc(#27);
   printc('3');
   printc(#34);
   partial := true;

   printc(#27);
   printc(#85);
   printc(#0);   {select bidirectional printing}
end;


(*
 * print_draft - print out the current column buffer in one-pass draft
 *               printing mode.  this is done by overlapping the pixels
 *               that would be printed in each of the two quality passes.
 *               this goes twice as fast and still looks pretty good.
 *)

procedure print_draft;
var
   i:      integer;

begin


(* print combined first and second strikes of the line *)
   printc(#27);
   printc('L');
   printc(chr (lo (col_count)));
   printc(chr (hi (col_count)));
   for i := 1 to col_count do
      printc(chr (lo (col_buffer [i]) or hi (col_buffer [i])));

   if bold then
   begin
      printc(#13);
      printc(#27);
      printc('L');
      printc(chr (lo (col_count)));
      printc(chr (hi (col_count)));
      for i := 1 to col_count do
         printc(chr (lo (col_buffer [i]) or hi (col_buffer [i])));
   end;

   col_count := 0;
end;


(*
 * flush_cols - flush out any columns still in the column buffer.  this
 *              should be called before printing any non-text character.
 *)

procedure flush_cols;
begin

   if col_count > 0 then

      if quality then
         print_quality
      else
         print_draft;
end;


(*
 * buffer_cols - add a column of pixels to the column buffer
 *
 *)

procedure buffer_cols (cols:   integer);
begin

   if col_count > maxbuf then
      flush_cols;

   if underline then
      cols := cols or underline_bit;

   col_count := col_count + 1;
   col_buffer[col_count] := cols;
end;


(*
 * load_font - load the current font from the selected font file
 *
 *)

procedure load_font (name:   anystring);
var
   ffd:    file of font_rec;

begin
   name := locate_file(name);   {use PATH= to find the file}

   assign(ffd, name);
{$i-}
   reset(ffd);
{$i+}

   if ioresult <> 0 then
   begin
      writeln('?cant open font file: ', name);
      halt(1);
   end;
   
   read(ffd, font);
   close(ffd);
end;


(*
 * process_char - process each text character.  get the pixel map for
 *                the character and add the pixels and spaces to the
 *                column buffer for later printing.
 *)

procedure process_char (ch:     char);
var
   first:  integer;
   last:   integer;
   map:    array [1..9] of integer;
   bits:   integer;
   i:      integer;

begin


(* process characters that aren't in the font *)

   if (ch < ' ') and (ch >= #127) then
      ch := '!';


(* build the character map and find the edges *)

   first := 0;
   last := 0;

   with font [ch] do

   for i := 1 to 9 do
   begin
      bits := table1[i] + (table2 [i] shl 8);
      map[i] := bits;

      if (first = 0) and (bits <> 0) then
         first := i;
   end;

   for i := 9 downto 1 do
      if last = 0 then
         if map [i]<> 0 then
            last := i;


(* output the character *)

   for i := first to last do
      buffer_cols(map [i]);


(* output spacing for next char *)

   for i := 1 to char_space do
      buffer_cols(0);
end;


(*
 * process_file - process an entire test file.  reads the file and sends
 *                it to the printer with the currently selected font.
 *)

procedure process_file (name:   anystring);
var
   fd:     text;
   ch:     char;
   i:      integer;

begin
   load_font(fontfile);

   writeln;
   name := locate_file(name);   {use PATH= to find the file}
   writeln('Printing: ', name);

   assign(fd, name);
{$I-}
   reset(fd);
{$i+}

   if ioresult <> 0 then
   begin
      writeln('?cant open input file: ', name);
      halt(1);
   end;

   while not eof (fd) do
   begin
      read(fd, ch);

      case ch of
         #10:  begin
                  flush_cols;
                  bold := false;
                  underline := false;
                  printc(ch);

                  if partial then
                  begin                         {finish up partial linefeeds}
                     printc(#27);
                     printc('3');
                     printc(#36);
                     partial := false;
                  end;
               end;

         #32:
               for i := 1 to space_width do
                  buffer_cols(0);

         #33.. #255:
               process_char(ch);

         ^B:      bold := not bold;

         ^U,^W:   underline := not underline;

         else  begin
                  flush_cols;
                  printc(ch);
               end;
      end;

      if keypressed then
      begin
         read(kbd, ch);
         write('Abort printing? (Y/N) ');
         read(kbd, ch);

         if upcase (ch)= 'Y' then
            exit
         else
            writeln('No');
      end;
   end;

   close(fd);
   printc(^L);
end;


(*
 * handle invalid command line - print command usage instructions
 *
 *)

procedure usage;
const
   author: anystring = ' Written by Samuel H. Smith '#0;
begin
   writeln;
   writeln('This program prints a text file with proportional spacing.');
   writeln;
   writeln('Usage:  prop OPTIONS ... FILE ... FILE');
   writeln;
   writeln('Options are:');
   writeln('   -Q        ;print in Quality mode');
   writeln('   -D        ;print in Draft mode');
   writeln('   -Fname    ;load Font (typeface) from ''name''');
   writeln;
   writeln('Examples:');
   writeln('   prop prop.doc');
   writeln('      Print prop.doc in Quality mode with PROP.FNT font.');
   writeln;
   writeln('   prop -D prop.doc');
   writeln('      Print prop.doc using the faster "draft" style.');
   writeln;
   writeln('   prop -D -F\DOS\PROP7.FNT prop.doc');
   writeln('      Print PROP.DOC in Draft mode with a Font controlled by');
   writeln('      the file \DOS\PROP7.FNT.');
   halt(1);
end;


(*
 * top level program - process command line parameters
 *
 *)

procedure main;
var
   i:      integer;
   par:    anystring;

begin
   writeln;
   writeln('PROP 1.1 (13-Nov-86 SHS)');

   if (paramcount = 0) then
      usage;

   partial := false;
   col_count := 0;


(* handle each command parameter *)

   for i := 1 to paramcount do
   begin
      par := paramstr (i);

      if par [1] <> '-' then
         process_file(par)          {anything without a "-" is a filename}

      else

         case upcase (par [2]) of
            'F':  fontfile := copy (par, 3, 99);   {set font file}

            'Q':  quality := true;                 {quality printing mode}

            'D':  quality := false;                {draft mode}

            else  usage;
         end;
   end;


(* restore line spacing to normal 1/6' *)

   flush_cols;
   printc(#27);
   printc('3');
   printc(#36);


   writeln('End run.');
end;


(* the "main" block *)
begin
   main;
end.

