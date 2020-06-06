
const tshint_tag: string[90]
   = #0'@(#)CURRENT_FILE LAST_UPDATE Interrupt/trace turbo 1.1'#0;
#log Interrupt/trace package 1.1


(*
 * tshint - execute turbo pascal; setup interrupts on each
 *          breakpoint.  decode and each of the turbo interrupts
 *          this module detects and process all details of
 *          low-level interface to the turbo compiler.
 *)

const
   heapstack: integer = $0400;         {size of heap/stack area in paragraphs}

   our_ds: integer =  0;               {must be in cseg}

   xsaveint10: array [0..1] of integer = (0, 0);

   turbintno: integer = $65;           {interrupt no. used for breaks
                                         in turbo.com}


var
   maxmem:     integer absolute cseg : 2;

   turbo_cs:           integer;
   turbo_ss:           integer;
   turbo_sp:           integer;

   our_ss:             integer;
   our_sp:             integer;

   location:           array[1..maxturbbrk] of integer;
   instruction:        array[1..maxturbbrk] of integer;


type
   intpointer = ^integer;

var
   oldint10:           intpointer absolute xsaveint10;
   oldtracevect:       intpointer;


#include "tshpatch.inc"  {turbo code patches}


(*------------------------------------------
 *
 * turbo_int_process
 *    Process the INT's which occur during compilation.
 *    Sort out which break occurred and call the
 *    proper procedure to process it
 *
 *)

procedure turbo_int_process (breakip:    integer);
var
   break: integer;

begin
   break := 1;
   while (location[break] <> breakip) and
         (break <= maxturbbrk) do
      INCR(break);      {find out which break it is}

   case break of

      before_line_compile:   line_no_process;

      include_open:          push_include_state;

      include_eof:           pop_include_state;

      end_compile:           end_compile_process;

      else writeln(con,#13,whoami,': Unhandled break #',break,
                                  ' IP=',breakip);
   end;
end;



(*------------------------------------------
 *
 * putvector - Change interrupt vector
 *
 *)

procedure putvector(n : byte; p : intpointer);
var
   regs: regpack;
begin
    regs.ax := $2500+n;
    regs.ds := seg(p^);
    regs.dx := ofs(p^);
    msdos(regs);
end;


(*------------------------------------------
 *
 * savevector
 *
 *)

procedure savevector(n : byte; var p : intpointer);
var
   regs: regpack;
begin
    regs.ax := $3500+n;
    msdos(regs);
    p := ptr(regs.es, regs.bx);
end;


(*------------------------------------------
 *
 * install_turbo_breaks
 *    patch in 'INT xx' instructions in Turbo.com.
 *    no need to save the contents, as they are already known
 *       *** this proc takes about 6% of total time
 *)

procedure install_turbo_breaks;
var
   i:                  integer;
begin

   for i := 1 to maxturbbrk do
      memw[turbo_cs : location[i]] := $cd + (turbintno shl 8);
                                     {int xx}
end;


(*------------------------------------------
 *
 * remove_turbo_breaks
 *    remove the 'INT xx' instructions and restore
 *    the original word to Turbo.com
 *       *** this proc takes about 5% of total time
 *
 *)

procedure remove_turbo_breaks;
var
   i:                  integer;
begin

   for i := 1 to maxturbbrk do
      memw[turbo_cs : location[i]] := instruction[i];
                              {replace proper instruction}
end;


(*------------------------------------------
 *
 * turbo_trace
 *    control comes here after the CPU executes one
 *    instruction in 'trace' mode.  after tracing one
 *    instruction, install the break points
 *
 *)

procedure turbo_trace (flags,
                       callers_cs:         integer);
begin

   inline($fb /               {sti}
    $50 / $53 / $51 / $52 /
    $56 / $57 / $1E / $06 /   {push ax,bx,cx,dx,si,di,ds,es}
    $2e / $8e / $1E / our_ds);{mov ds,cs:[our_ds] ;restore this ds}

   {Switch to local stack}

   inline($8C / $D0           {mov ax,ss        ;save the present SP}
    / $A3 /> turbo_ss         {mov [>Turbo_ss],ax}
    / $89 / $26 /> turbo_sp   {mov [>Turbo_sp],sp}
    / $A1 /> our_ss           {mov ax,[>our_ss] ;switch to our stack}
    / $FA                     {cli}
    / $8e / $D0               {mov ss,ax}
    / $8B / $26 /> our_sp     {mov sp,[>our_sp]}
    / $fb);                   {STI}


   {Install this breakpoint for next time around}
   install_turbo_breaks;

   inline($A1 /> turbo_ss     {mov ax,[>Turbo_ss] ;restore put's stack}
    / $FA                     {cli}
    / $8e / $D0               {mov ss,ax}
    / $8B / $26 /> turbo_sp   {mov sp,[>Turbo_sp]}
    / $fb);                   {sti}

   flags := flags and $feff;  {remove the trace bit}

   inline($07 / $1F / $5f / $5E /
    $5a / $59 / $5b / $58 /   {pop registers}
    $89 / $ec /               {mov sp,bp}
    $5d /                     {pop bp}
    $cf);                     {iret}

end;


(*------------------------------------------
 *
 * turbo_int
 *    the interrupt instructions patched in Turbo.com come here
 *
 *)

procedure turbo_int (flags,
                     callers_cs:         integer);
const
   breakip : integer = 0;

begin
   inline($fb /               {sti}
    $50 / $53 / $51 / $52 /
    $56 / $57 / $1E / $06 /        {push ax,bx,cx,dx,si,di,ds,es}
    $2e / $8C / $1E / turbo_ds /   {mov cs:[Turbo_ds],ds }
    $2e / $8e / $1E / our_ds);     {mov ds,cs:[our_ds] ;restore this ds}

{Back up the instruction ptr to the start of the instruction to be replaced}

   inline($FF / $4E / $02 /        {dec word ptr [bp+2]}
    $FF / $4E / $02 /              {dec word ptr [bp+2]}
    $8B / $46 / $02 /              {mov ax,[bp+2]       ;save the ip}
    $2e / $89 / $06 / breakip);    {cs:mov [breakip],ax}

{Switch to local stack}

   inline($8C / $D0           {mov ax,ss        ;save the present SP}
    / $A3 /> turbo_ss         {mov [>Turbo_ss],ax}
    / $89 / $26 /> turbo_sp   {mov [>Turbo_sp],sp}
    / $A1 /> our_ss           {mov ax,[>our_ss] ;switch to our stack}
    / $FA                     {cli}
    / $8e / $D0               {mov ss,ax}
    / $8B / $26 /> our_sp     {mov sp,[>our_sp]}
    / $fb);                   {STI}


{process the interrupt function}
   turbo_int_process(breakip);


{Replace breakpoint with proper instruction}
   remove_turbo_breaks;


   inline($A1 /> turbo_ss     {mov ax,[>Turbo_ss] ;restore put's stack}
    / $FA                     {cli}
    / $8e / $D0               {mov ss,ax}
    / $8B / $26 /> turbo_sp   {mov sp,[>Turbo_sp]}
    / $fb                     {sti}
   );


{Set trace bit to trace one instruction
 before reinstalling break points}

   flags := flags or $100;
   putvector(1, ptr (cseg, ofs (turbo_trace)));   {set up trace interrupts}

   inline($07 / $1F / $5f / $5E /
    $5a / $59 / $5b / $58 /   {pop registers}
    $89 / $ec /               {mov sp,bp}
    $5d /                     {pop bp}
    $cf);                     {iret}

end;


(*------------------------------------------
 *
 * int10
 *    come here at first int 10 call after loading
 *    Turbo.com. install the required patches
 *
 *)

procedure int10 (callers_cs:         integer);
var
   i:       integer;
   regs:    regpack;
   wrong:   boolean;

begin
   inline($fb /               {sti}
    $50 / $53 / $51 / $52 /
    $56 / $57 / $1E / $06 /   {push ax,bx,cx,dx,si,di,ds,es}
    $2e / $8e / $1E / our_ds);{mov ds,cs:[our_ds] ;restore this ds}

   turbo_cs := callers_cs;
   putvector($10, oldint10); {restore old int 10 so we won't come here again}

   {Check to see that the contents at the break point locations correspond
     with the predicted values for one of the allowable Turbo versions}

   version := v301a;

   repeat
      i := 1;
      wrong := false;

      while (i <= maxturbbrk) and not wrong do
      begin
         wrong := memw [turbo_cs : turb_brk [version, i].ofst]<>
                        turb_brk [version, i].contents;
         i := i + 1;
      end;

      INCR(version);
   until not wrong or (version = toofar);

   DECR(version);

   if wrong then
   begin
      writeln(con,whoami,': Incorrect Version of TURBO.COM!');
      regs.ax := $4c00;          {terminate process}
      msdos(regs);
   end;


{copy the matching breakpoint table into a simpler array for faster access}
   for i := 1 to maxturbbrk do
   begin
      location[i]    := turb_brk[version,i].ofst;
      instruction[i] := turb_brk[version,i].contents;
   end;


{install and speed-up patches in the turbo code segment}
   install_turbo_patches;


{install handler for the turbo breakpoints}
   install_turbo_breaks;
   putvector(turbintno, ptr (cseg, ofs (turbo_int)));


{now that we're done, pass control to the real int10 handler}
   inline($07 / $1F / $5f / $5E /
    $5a / $59 / $5b / $58 /        {pop registers}
    $89 / $ec /                    {mov sp,bp}
    $5d /                          {pop bp}
    $2e / $FF / $2e / oldint10);   {jmp far cs:[oldint10] }

end;


(*------------------------------------------
 *
 * execturbo
 *    load and execute turbo pascal
 *    arrange for interrupts to be inserted at key places
 *
 *)

procedure execturbo;
const
   comline : integer = $d00;  {actually a null string followed by cr}
   savesp : integer =  0;     {must be in cseg}
   savess : integer =  0;

type
   parblockrec =       record
      envsegm : integer;      {paragraph of environment}
      comlineptr : intpointer;   {pts to command line for child}
      fcb1, fcb2 : intpointer;   {pts to file control blks}
   end;

var
   parblock:           parblockrec;
   some_flag_bits:     integer;
   turbo1_cs:          integer absolute dseg : turbom_cs;
   dsp,
   esp:                intpointer;
   membase,
   axr,
   flagr:              integer;
   regs:               regpack;

begin                         {Find the base of our memory block. It differs
                                if we a compiling in memory mode or have
                                already been compiled.}

   some_flag_bits := memw [dseg : flag_bits];
   if (some_flag_bits and 1)<> 0 then
      membase := turbo1_cs       {in memory}
   else
      membase := cseg;        {compiled}

   regs.es := membase;
   regs.bx :=(sseg + $1000 - membase)+ 1;  {block size we want to retain}
   regs.ax := $4a00;
   msdos(regs);               {free up memory for child}

   if (regs.flags and 1)<> 0 then
   begin
      writeln(con,'Allocation error ', regs.ax);
      halt(1);
   end;                       {set up the parameter block for $4b call}

   with parblock do
   begin
      envsegm := 0;              {use present environment}
      fcb1 := ptr (cseg, $5c);   {copy present default fcb'S}
      fcb2 := ptr (cseg, $6c);
      comlineptr := ptr (seg (comline), ofs (comline));
   end;

{set up interrupt 10 for immediate break in loaded Turbo.com}
   savevector($10, oldint10);
   putvector($10, ptr (cseg, ofs (int10)));

{set the future SP down the stack a safe distance}
   inline($89 / $26 / our_sp);{mov [our_sp],sp}
   our_sp := our_sp - 200;

{Now make the $4b call. Unfortunately can't
 use 'msdos' call because DOS 2 requires
 that the sp and ss registers be saved also.}

   dsp := ptr (seg (progname), ofs (progname [1]));
   esp := ptr (seg (parblock), ofs (parblock));

   inline($1E / $55 /         {push ds,push bp    ;save ds and bp}
    $C4 / $9e / esp /         {les bx,[bp+esp]    ;load regs for call}
    $C5 / $96 / dsp /         {lds dx,[bp+dsp]}
    $2e / $89 / $26 / savesp /{mov cs:[savesp],sp ;save sp and ss}
    $2e / $8C / $16 / savess /{mov cs:[savess],ss}
    $FC /                     {cld                ;to fix DOS bug}
    $b8 / $4b00 /             {mov ax,$4b00}
    $cd / $21 /               {int 21}

    $FA /                     {cli}
    $2e / $8e / $16 / savess /{mov ss,cs:[savess] ;restore stack}
    $2e / $8B / $26 / savesp /{mov sp,cs:[savesp]}
    $fb /                     {sti}

    $5d / $1F /               {pop bp, pop ds     ;restore bp,ds}
    $89 / $86 / axr /         {mov [bp+axr],ax    ;save any error code}
    $9C / $58 /               {pushf, pop ax      ;save flags too}
    $89 / $86 / flagr);       {mov [bp+flagr],ax}

   putvector($10, oldint10);  {restore old value in case of calling error}

   if some_flag_bits and 1 <> 0 then
   begin
      regs.ax := $4a00;       {memory mode}
      regs.es := membase;
      regs.bx := $ffff;       {ask for too much to find out what's left}
      msdos(regs);            {produces error}

      regs.ax := $4a00;       {regs.bx now has what we can get}
      msdos(regs);
   end;

   if flagr and 1 <> 0 then
   begin
      if (axr = 2) or (axr = 3) then
         writeln(con,'Can''t find ', progname)
      else
      if axr = 8 then
         writeln(con,'Insufficient Memory or Missing COMMAND.COM')
      else
         writeln(con,'Load error ', axr);

      halt(1);
   end;

   putvector(1, oldtracevect);     {put back the previous trace handler}
end;



(*------------------------------------------
 *
 * callturbo
 *    release unused stack
 *    load and execute turbo pascal
 *    (must not return!)
 *)

procedure callturbo;
begin

{initialize interrupt system}
   checkwhichcompiler;        {Info on the compiler used}
   our_ds := dseg;
   savevector(1, oldtracevect);

 {calculate a new sseg to leave HeapStack paragraphs available}
   our_ss := seg (heapptr^)+(ofs (heapptr^) shr 4)- $1000 + heapstack;

   if (our_ss + $1000 - $8000) > (maxmem - $8000) then
   begin
      writeln(con,'Insufficient Memory');
      halt(1);
   end;

{Now change the ss register accordingly.
 By doing this in 'MAIN' there is nothing
 of importance on the stack to destroy}

   inline($FA /               {cli}
    $8e / $16 / our_ss /      {mov ss,[our_ss]}
    $bc / $FE / $FF /         {mov sp,$fffe}
    $fb);                     {sti}


{Execute turbo with interrupt trapping}
   execturbo;

{Because SS:SP has been changed, we MUST exit now}
   halt(0);
end;

