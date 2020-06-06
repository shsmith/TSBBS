

(*******************************************************
 *
 * Subsystem:   runutil - interpreter utility and initialization procedures
 *
 * Overview
 * --------
 *
 *    Provides initialization, file handling and error
 *    reporting services.   contains symbol table maintenance
 *    and global data declarations.
 *
 *
 * Revision History
 * ----------------
 *
 *   18-dec-85 s.h.smith  initial coding
 *
 *
 *)




(*******************************************************
 *
 *   Global Constants
 *
 *)

 const

   interpreterversion = '6801 Interpreter X0.0 09-Jan-86 S.H.Smith';

   maxidentlen = 6;           { longest object code identifier }

   maxkeylen =   9;           { longest keyword }

   max_object = 2000;         { highest object memory location }

   libfunlen = 32;            { longest library function name }

   maxlibfun = 30;            { maximum number of library functions }



(**)
(*******************************************************
 *
 *   Global Data Types
 *
 *)

 type

   identstr =    string [maxidentlen];

   keystr =      string [maxkeylen];

   anystring =   string [132];

   libfunstr =   string [libfunlen];


   object_location = 0..max_object;



(*      Opcode lists all 6801 operation code tokens that can possibly be
 *      benerated by the D1 compiler.  *)


   opcode =      (empty,          {this object cell is empty}
                  variable,       {this object cell is a variable}
                  comment,

(* define assembler pseudo-ops *)
                  start_module,   {start new program module}
                  include_libs,   {include runtime libraries}
                  end_module,     {end program module}
                  equate,         {equate a label to current address}
                  define_bytes,   {define literal bytes of code}
                  reserve_bytes,  {reserve bytes with a label}

(* program flow control opcodes *)
                  libcall,        {runtime library call}
                  call,           {call subroutine}
                  return,         {return from subroutine}
                  jump,           {jump to label}
                  test_zero,      {test boolean and set zero flag}
                  jump_zero,      {jump if zero condition}
                  jump_not_zero,  {jump if notzero confition}

(* 'byte' and 'boolean' data type manipulation *)
                  push_byte,      {push current value}
                  pop_byte,       {pop value from stack}
                  load_byte,      {load from variable}
                  lit_byte,       {lit from variable}
                  store_byte,     {store into variable}

(* 'integer' data type manipulation *)
                  push_integer,
                  pop_integer,
                  lit_integer,
                  load_integer,
                  store_integer,

(* other "optimized" machine instructions *)
                  pshb,
                  pulb,
                  tab,
                  tba,
                  mul,
                  addb,
                  subb,
                  orab,
                  andb,
                  coma,

                  UNKNOWN);      {special end-list marker: must be last}



(*   Objectcell is a cell in the object memory.   All instructions
     are stored in a single object cell.   Variables will be
     stored in several object cells (1 cell per byte).   *)

   objectcell = record

      ident:        identstr;      {the identifier of this cell's label, if any}

      instruction:  opcode;        {the opcode to be performed by this cell}

      parameter:    integer;       {the 16 bit argument to the instruction,
                                    if any.  8 bits of data when this is
                                    a variable location}

      paramident:   identstr;      {the identifier string for the parameter.
                                    this is converted into the real parameter
                                    the first time it is needed.  the
                                    conversion involves a symbol (object
                                    memory) search for a label. }
   end;




(*   Registers is a record describing all of the target machine
     registers that will be emulated.   *)

   registers = record

      a:        byte;               {accumulator a}

      b:        byte;               {accumulator b}

      x:        integer;            {index register}

      pc:       integer;            {program counter}

      sp:       integer;            {stack pointer}

      flag:     record              {status flags}
         zero:  boolean;                {zero/equal condition}
      end;

   end;


(**)
(*******************************************************
 *
 *   Global Variables
 *
 *)

 var

   infile:       text[2048];  { input object code }

   ch:           char;        { current scanner input }

   linecount:    integer;     { number of lines in source text }

   sourceline:   string[128]; { the current source line }


   keywords:     array [opcode] of keystr;
                              { list of all instruction keywords }

   objectmem:    array [object_location] of objectcell;
                              { the object code memory }

   regs:         registers;   { the processor registers }

   scanlabel:    identstr;    { the line scanner label field}

   scanopcode:   opcode;      { the scanner opcode field }

   scanparam:    anystring;   { the scanner parameter field }

   entry_point:  identstr;    { the program entry point label }

   libfuncnt:   integer;     { number of runtime library call functions }

   libfun:       array [1..maxlibfun] of
                 libfunstr;   { table of runtime library calls }


   option_dump:  boolean;

   option_trace: boolean;





(**)
(*******************************************************
 *
 * Procedure:    initkeywords
 *
 * Description:  provides initial values for all keywords
 *               in the opcode keyword array.
 *
 * Example:      initkeywords;
 *
 *)

 procedure initkeywords;
 begin

   keywords[empty        ] := '<stack>';  {this object cell is empty}
   keywords[variable     ] := '<data>';   {this object cell is a variable}
   keywords[comment      ] := '';         {comment; does not use object space}

(* define assembler pseudo-ops *)
   keywords[start_module ] := 'NAM';  {start new program module}
   keywords[include_libs ] := 'INC';  {include runtime libraries}
   keywords[end_module   ] := 'END';  {end program module}
   keywords[equate       ] := 'EQU';  {equate a label to current address}
   keywords[define_bytes ] := 'FCB';  {define literal bytes of code}
   keywords[reserve_bytes] := 'RMB';  {reserve bytes with a label}

(* program flow control opcodes *)
   keywords[call         ] := 'JSR';  {call subroutine}
   keywords[libcall      ] := '<lib>';{call runtime library}
   keywords[return       ] := 'RTS';  {return from subroutine}
   keywords[jump         ] := 'JMP';  {jump to label}
   keywords[test_zero    ] := 'TSTA'; {test boolean and set zero flag}
   keywords[jump_zero    ] := 'BEQ';  {jump if zero condition}
   keywords[jump_not_zero] := 'BNE';  {jump if notzero confition}

(* 'byte' and 'boolean' data type manipulation *)
   keywords[push_byte    ] := 'PSHA';  {push current value}
   keywords[pop_byte     ] := 'PULA';  {pop value from stack}
   keywords[load_byte    ] := 'LDAA';  {load from variable}
   keywords[lit_byte     ] := 'LDAA#'; {literal byte}
   keywords[store_byte   ] := 'STAA';  {store into variable}

(* 'integer' data type manipulation *)
   keywords[push_integer ] := 'PSHX';
   keywords[pop_integer  ] := 'PULX';
   keywords[load_integer ] := 'LDX';
   keywords[lit_integer  ] := 'LDX#';
   keywords[store_integer] := 'STX';

(* other "optimized" machine instructions *)
   keywords[pshb         ] := 'PSHB';
   keywords[pulb         ] := 'PULB';
   keywords[tab          ] := 'TAB';
   keywords[tba          ] := 'TBA';
   keywords[mul          ] := 'MUL';
   keywords[addb         ] := 'ADDB';
   keywords[subb         ] := 'SUBB';
   keywords[orab         ] := 'ORAB';
   keywords[andb         ] := 'ANDB';
   keywords[coma         ] := 'COMA';

   keywords[UNKNOWN      ] := '?';
 end;



(**)
(*******************************************************
 *
 * Procedure:     initmemory
 *
 * Description:   initialize all object code memory
 *
 * Example:       initmemory;
 *
 *)

procedure initmemory;
var
   loc:   object_location;

begin

   for loc := 0 to max_object do
      with objectmem[loc] do
      begin
         ident := '';
         instruction := empty;
         parameter := 0;
         paramident := '';
      end;

end;



(**)
(*******************************************************
 *
 * Procedure:     initregs
 *
 * Description:   initialize all processor registers
 *
 * Example:       initregs;
 *
 *)

procedure initregs;
begin
   with regs do
   begin
      a := 0;
      b := 0;
      x := 0;
      pc := 0;
      sp := max_object;
      flag.zero := false;
   end;

   entry_point := '?NONE?';
end;




(**)
(*******************************************************
 *
 * Function:     itoal(i, len): anystring
 *
 * Description:  convert an integer to an ascii string of a
 *               specified length.   the string will contain
 *               trailing spaces so that it is left justified.
 *
 * Example:      write(itoal(i,5));
 *
 * Inputs:       the integer to convert
 *               the length of the result
 *
 * Outputs:      the string result
 *
 *)

function itoal(i:  integer;
               l:  integer): anystring;
var
   a:  anystring;

begin
   str(i:0, a);
   while length(a) < l do
      a := a + ' ';

   itoal := a;
end;



(**)
(*******************************************************
 *
 * Procedure:   dump_regs;
 *
 * Description: dump all register contents and current
 *              objectmem contents
 *
 * Example:     dump_regs;
 *
 * Inputs:      regs
 *
 *)

procedure dump_regs;
begin

   with regs, objectmem[regs.pc] do
   begin
      write  ('pc=',itoal(pc,5),
              'a=', itoal(a,4),
              'b=', itoal(b,4),
              'x=', itoal(x,6),
              's=', itoal(sp,5),
              'z=', flag.zero:5,' ',
              ident,'':8-length(ident),
              keywords[instruction],
              '':8-length(keywords[instruction]));

      if instruction = libcall then
         writeln(libfun[parameter])
      else
         writeln(paramident,'(',parameter,')');
   end;

   flush(output);
end;



(**)
(*******************************************************
 *
 * Procedure:    dump_memory
 *
 * Description:  display contents of object memory
 *
 * Example:      dump_memory;
 *
 *)

procedure dump_memory;
var
   i:  integer;
   fd: text;

begin

   writeln;
   writeln('Dumping emulation memory to "core":');
   flush(output);

   assign(fd,'core');
   rewrite(fd);

   writeln(fd);
   writeln(fd,'Emulation memory dump:');

   writeln(fd);
   writeln(fd,'ADDR   LABEL   OPCODE  PARAMSYM (PARAMVAL)');

   for i := 0 to max_object do
      with objectmem[i] do
         if (instruction <> empty) or (parameter <> 0) then
         begin
            write(fd,i:4,'   ',ident,'':8-length(ident),
                               keywords[instruction],
                               '':8-length(keywords[instruction]));

            if instruction = libcall then
               writeln(fd,libfun[parameter])
            else
               writeln(fd,paramident,'(',parameter,')');
         end;

   writeln(fd);
   close(fd);

end;


(**)
(*******************************************************
 *
 * Procedure:     error(anystring)
 *
 * Description:   display an error message and terminate program
 *                execution.
 *
 * Example:       error('stack underflow');
 *
 * Inputs:        error message string
 *
 * Outputs:       interpretation is aborted
 *
 *)

 procedure error (problem:      anystring);
 begin
   writeln;

   if linecount > 0 then
   begin
      writeln('Error in line ', linecount, ':  ', problem);
      writeln('Source: ', sourceline);
   end
   else
      writeln('Runtime error:  ',problem);

   dump_regs;
   dump_memory;
   writeln;
   writeln('EXECUTION ABORTED');
   flush(output);
   halt;
 end;




(**)
(*******************************************************
 *
 * Procedure:     openfiles
 *
 * Description:   decode command line parameters and determine
 *                input file name.  leaves input file open.
 *
 * Example:       openfiles;
 *
 *)

 procedure openfiles;
 var
   fileok:       boolean;
   infilename:   string [65];
   i:            integer;

 begin

   if paramcount < 1 then
   begin
      writeln('Usage: RUN6801 objectfile [options]');
      writeln('options:  -d    ;dump emulation memory');
      writeln('          -t    ;trace execution');
      halt;
   end;


   infilename := paramstr(1);
   if pos('.', infilename) = 0 then
      infilename := infilename + '.DO';

   assign(infile, infilename);
{$I-}
   reset(infile);
{$I+}

   fileok :=(ioresult = 0);

   if not fileok then
      error('Can''t open input file');

   for i := 2 to paramcount do
      if paramstr(i) = '-t' then
         option_trace := true
      else
      if paramstr(i) = '-d' then
         option_dump := true
      else
      begin
         writeln('invalid command line options');
         halt;
      end;
 end;



(**)
(*******************************************************
 *
 * Procedure:     initialize
 *
 * Description:   perform all initializations to prepare the
 *                compiler for operation.
 *
 * Example:       initialize;
 *
 *)

 procedure initialize;
 begin
   initkeywords;                 { init keyword list }
   initregs;                     { initialize processor registers }
   initmemory;                   { initialize object code memory }

   linecount := 0;               { start on first source line }
   sourceline := '';             { no current source line }
   libfuncnt := 0;               { number of runtime library functions }

   writeln;
   writeln(interpreterversion);  { sign on with compiler version banner }

   option_dump := false;
   option_trace := false;

   openfiles;                    { decode command line and open input file }
 end;



procedure flush_output;
var
   c: char;

begin

   flush(output);

   if keypressed then
   begin

      read(kbd,c);
      if c in [^C,#27] then
      begin
         writeln('**Execution aborted**');
         regs.pc := 9999;
      end;

   end;

end;
