

(*******************************************************
 *
 * Subsystem:   runload - interpreter pass 1 - load emulation memory
 *
 * Overview
 * --------
 *
 *    Reads input file and loads it into the object memory.
 *    decodes all instructions and allocates all variables.
 *
 *
 * Revision History
 * ----------------
 *
 *   18-dec-85 s.h.smith  initial coding
 *
 *
 *)





(**)
(*******************************************************
 *
 * Function:     strip(str);
 *
 * Description:  remove trailing spaces from a string
 *
 * Example:      s := strip(s);
 *
 *)

function strip(s: anystring): anystring;
begin
   while (length(s) > 0) and (s[length(s)] = ' ') do
      s[0] := pred(s[0]);

   strip := s;
end;



(**)
(*******************************************************
 *
 * Procedure:    scanline
 *
 * Description:  looks at sourceline and scans it into three
 *               fields:  label, opcode and paremeter.
 *               the opcode is tokenized.  strips off comments.
 *
 * Example:      scanline; decodeline;
 *
 * input:        sourceline
 *
 * outputs:      scanlabel  is the label field scanned
 *               scanopcode is the opcode field scanned
 *               scanparam  is the parameter field scanned
 *
 *)

procedure scanline;
var
   i:      integer;
   opstr:  anystring;
   op:     opcode;


begin

(* strip off any comments *)
   for i := length(sourceline) downto 1 do
      if sourceline[i] = '*' then
         sourceline[0] := chr(i-1);

(* add spaces so that all fields will exist *)
   sourceline := sourceline + '                        ';

(* decode the three fields *)
   scanlabel  := strip(copy(sourceline,1,8));
   opstr      := strip(copy(sourceline,9,8));
   scanparam  := strip(copy(sourceline,17,9));

(* tokenize the opcode string *)
   scanopcode := empty;
   for op := empty to UNKNOWN do
      if opstr = keywords[op] then
         scanopcode := op;

   if scanopcode = empty then
      error('Unknown opcode');
end;





(**)
(*******************************************************
 *
 * function:     library_call_number
 *
 * Description:  looks up the current JSR parameter in the
 *               runtime library function list and returns
 *               the index into the table.
 *
 * Example:      parameter := library_call_number;
 *
 * Inputs:       sourceline
 *
 * Outputs:      index into library table
 *
 *)

function library_call_number:  integer;
var
   i:   integer;
   fun: libfunstr;

begin
   fun := strip(copy(sourceline,20,99));

   for i := 1 to libfuncnt do
      if libfun[i] = fun then
      begin
         library_call_number := i;
         exit;
      end;

   libfuncnt := libfuncnt + 1;
   libfun[libfuncnt] := fun;
   library_call_number := libfuncnt;
end;




(**)
(*******************************************************
 *
 * Procedure:    decodeline
 *
 * Description:  decodes the data left by the line scanner and
 *               possibly fills in one or more object cells.
 *
 * Example:      scanline; decodeline;
 *
 * Inputs:       scanlabel  is the label field scanned
 *               scanopcode is the opcode field scanned
 *               scanparam  is the parameter field scanned
 *
 * Outputs:      modified object cells
 *               entrypoint symbol may be modified
 *
 *)

procedure decodeline;
var
   i:  integer;
   c:  integer;
   s:  anystring;

begin
   with objectmem[regs.pc] do
   begin
     ident := scanlabel;
     instruction := scanopcode;
     paramident := scanparam;

     case scanopcode of

      variable..include_libs:      {these don't take a cell}
         ;

      end_module:                  {end module specifies entry point}
         entry_point := scanparam;

      define_bytes:                {generate literal bytes of data}
         begin
            val(scanparam,i,c);
            if c <> 0 then                     { numeric literal }
               error('Invalid define-bytes constant');

            parameter := i;
            regs.pc := regs.pc + 1;
         end;

      reserve_bytes:               {allocate variables}
         begin
            val(scanparam,i,c);
            if c <> 0 then
               error('Invalid reserve count');

            while i > 0 do         {reserve locations that are needed}
            begin
               with objectmem[regs.pc] do
               begin
                  ident := scanlabel;
                  instruction := variable;
               end;
               regs.pc := regs.pc + 1;
               i := i - 1;
            end;
         end;

      load_byte:
         begin
            if scanparam[1] = '#' then
            begin
               instruction := lit_byte;
               paramident := copy(scanparam,2,8);
            end;
            regs.pc := regs.pc + 1;
         end;

      load_integer:
         begin
            if scanparam[1] = '#' then
            begin
               instruction := lit_integer;
               paramident := copy(scanparam,2,8);
            end;
            regs.pc := regs.pc + 1;
         end;

      call:
         begin
            if copy(scanparam,1,3) = 'OP_' then
            begin
               instruction := libcall;
               paramident := '';
               parameter := library_call_number;
               regs.pc := regs.pc + 1;
            end
            else
               regs.pc := regs.pc + 1;
         end;

      equate,libcall..UNKNOWN:
         regs.pc := regs.pc + 1;

      else
         error('decodeline:  unknown opcode');
   end;
 end;

end;





(**)
(*******************************************************
 *
 * Procedure:    loadmem;
 *
 * Description:  Reads input file and loads it into the object memory.
 *               decodes all instructions and allocates all variables.
 *
 * Example:      loadmem;
 *
 *)

procedure loadmem;
begin

   writeln;
   writeln('Loading object code into emulation memory:');
   flush(output);

   while not eof(infile) do
   begin
      readln(infile,sourceline);
      linecount := linecount + 1;
      scanline;
      decodeline;
   end;

   writeln('  ',regs.pc,' emulation cells allocated');
   writeln('  Entry point: ',entry_point);
   flush(output);

   if option_dump then
      dump_memory;

end;
