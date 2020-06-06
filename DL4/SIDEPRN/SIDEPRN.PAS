

(*
 * sideprn - This program will print a text file sideways on
 *           an IBM compatible graphics printer.  It does this
 *           by looking up the pixels for each character in the
 *           graphics character set rom.
 *
 * author:  Samuel H. Smith, 01-Jan-85
 *
 *)

{$d-}
{$i regpack.inc}   {register package declaration}
{$i anystring.inc} {general string declaration}
{$i charbit.inc}   {library to get character pixel bits}
{$i printc.inc}    {print through bios}


const
   max_line_length = 500;      {longest input line length}
   max_line_count  = 103;      {max number of input lines}

   whoami =          'SidePrn';
   version =         'Version 1.2, LAST_UPDATE';

type
   linebuf = array [1..max_line_length] of char;
   printpos = array[1..8] of char;

var
   textlines:  integer;
   maxlen:     integer;
   textline:   integer;
   line:       array[1..max_line_count] of linebuf;
   buf:        linebuf;
   emptybuf:   linebuf;

   scanline:   integer;
   scancol:    integer;
   linechar:   integer;
   scanbits:   integer;
   ch:         char;

   prnline:    array[1..max_line_count] of printpos;
   grafcols:   integer;
   fd:         text;


(*
 * Procedure:    selectfile
 *
 * Description:  select and open the input file
 *
 * Inputs:       input file (from command line)
 *
 *)

procedure selectfile;
var
   name:          string[64];

begin

   case paramcount of
      0:  begin
             writeln(con);
             writeln(con,whoami,'  ',version);
             writeln(con);
             writeln(con,'Usage:  ',whoami,' filename');
             writeln(con);
             writeln(con,'This program will print the contents of a text file');
             writeln(con,'sideways on your graphics printer.');
             writeln(con);
             write(con,'Enter filename to print: ');
             readln(con,name);
          end;

      1:   name := paramstr(1);

      else begin
              writeln(con,'Too many parameters');
              writeln(con,'Usage:  ',whoami,' filename');
              halt;
           end;
   end;


   writeln(con);
   writeln(con,'Reading ',name,':');

{$I-}
   assign(fd,name);
   reset(fd);
{I+}
   if ioresult <> 0 then
   begin
      writeln(con,' -- Can''t open (file not found)');
      halt;
   end;

end;


(*
 * Procedure:    readfile
 *
 * Description:  read the input file and setup the related
 *               variables.  stops reading at form-feed or end-of-file
 *
 * Outputs:      line[..]      the lines of text, tabs expanded
 *               textlines     the number of lines read
 *               maxlen        the length of the longest line
 *
 *)

procedure readfile;
var
   len:           integer;
   i:             integer;
   num:           integer;
   minpos:        integer;

begin

   for i := 1 to max_line_length do
      emptybuf[i] := ' ';

   for i := 1 to max_line_count do
      line[i] := emptybuf;

   minpos := 1;
   num := 1;
   maxlen := 0;
   len := 0;
   textlines := 0;

   while (not eof(fd)) and (num < max_line_count) do
   begin
      read(fd,ch);

      case ch of
         ^L:   begin       { append next page }
                  if num > textlines then
                     textlines := num;

                  num := 1;
                  minpos := maxlen;
                  len := minpos;
               end;

         ^J:   begin       { end of line }
                  num := num + 1;
                  if len > maxlen then
                     maxlen := len;   { keep track of the longest line }

                  len := minpos;
               end;

          ^M:  ;

          ^I:  begin      { expand tabs }
                  len := len + 1;
                  while (len mod 8) <> 0 do
                     len := len + 1;
               end;

          else begin
                  len := len + 1;
                  line[num][len] := ch;
               end;

       end;  {case ch}

       if len >= max_line_length then
       begin
          writeln(con,'Line ',num,' is too long; will wrap');
          len := 1;
       end;

       if num >= max_line_count then
          writeln(con,'Too many input lines; file truncated');

    end;  {while not eof}


   if num > textlines then
      textlines := num;

   writeln(con,textlines:5,' lines to print');

end;  {readfile}


(*
 * Procedure:    prepare_printer_line
 *
 * Description:  format data for next printer line to output
 *
 *)

procedure prepare_printer_line;
begin

   for textline := 1 to textlines do
   begin

      ch := line[textline][linechar];   { get the next char to output }

      for scanline := 1 to 8 do
      begin

         scanbits := 0;                   { collect the pixel bits for
                                            each scancol of this char in
                                            the current scanline }

         if ch <> ' ' then
            for scancol := 8 downto 1 do
            begin

               scanbits := scanbits shl 1;

               if char_bit(ch, scanline, scancol) then
                  scanbits := scanbits + 1;

         end;  {next scancol}

         prnline[textline][scanline] := chr(scanbits);
                                      { print the bits for this scanline }

      end;  {next scanline}

   end;  {next textline}

end;


(*
 * Procedure:    output_printer_line
 *
 * Description:  outputs current prepared line of data to printer.
 *               optimizes leading and trailing spaces.
 *
 *)

procedure output_printer_line;
var
   i:         integer;
   lastline:  integer;

begin


(* scan for the last non-blank at the end of the line.
   This prevents printing spaces beyond the end of the print line. *)

   lastline := textlines;
   for i := 1 to textlines do
   begin
      for scanline := 1 to 8 do
      begin
         if prnline[i][scanline] <> #0 then
            lastline := i;
      end;
   end;


   grafcols := lastline * 8;


(* leading spaces have been printed, non-blank graphics cols have been found,
   now do the real printing of the main text *)

   printc(#27+'K'+chr(lo(grafcols))+chr(hi(grafcols)));
                                    { select single density graphics on an
                                      IBM compatible printer, and reserve
                                      graph columns for one line of print }

   for i := 1 to lastline do
      for scanline := 1 to 8 do
         printc(prnline[i][scanline]);
                                    { output all of the print locations on
                                      this print line }

   printc(#27+'1');   {set line spacing so lines will touch}
   printc(^M^J);
   printc(#27+'2');   {restore to default line spacing}

   flush(output);
end;


begin  {main}

   writeln(con);
   writeln(con,'Sideways file printer               S.H.Smith, 06-Jan-86');

   selectfile;            {select and open the input file}

   readfile;

(* output the text in sideways characters *)

   for linechar := maxlen downto 1 do
   begin

      write(con,#13,linechar:5,' columns to print');
      clreol;

      prepare_printer_line;
      output_printer_line;

   end;  {next linechar}


   printc(^L);        {formfeed the printer}

   write(con,#13);   {remove status display from screen}
   clreol;

   close(fd);
end.


