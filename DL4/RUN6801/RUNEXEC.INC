

(*******************************************************
 *
 * Subsystem:   runexec - interpreter pass 2 - execute instructions
 *
 * Overview
 * --------
 *
 *    Interprets the instructions in object memory.  this
 *    is the main runtime subsystem.
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
 * Function:      determine_param(identstr)
 *
 * Description:   determines the value of a symbolic parameter
 *                and returns it as an integer value.
 *
 * Example:       regs.pc := determine_param(entry_point);
 *
 * Inputs:        the symbolic parameter to process
 *                format:    number   - value of number is returned
 *                           symbol   - the objectlocation of the symbol
 *
 * Outputs:       integer value or object location
 *                error raised if undefined symbol
 *
 *)

function determine_param(id:  identstr): integer;
var
   i:  integer;
   c:  integer;

begin

   if id = '' then
      error('determine_param: blank id');

   if id[1] in ['0'..'9'] then
   begin
      val(id,i,c);
      if c <> 0 then
         error('determine_param: invalid number');

      determine_param := i;
      exit;
   end;

   i := 0;
   for i := 0 to max_object do
   with objectmem[i] do
   begin
      if ident = id then
      begin
         determine_param := i;
         exit;
      end;

(* could not find this identifier - check for some pre-defined identifiers *)
      if instruction = empty then
      begin
         if id = 'TRUE' then
            determine_param := 1
         else
         if id = 'FALSE' then
            determine_param := 0
         else
            error('undefined parameter symbol: '+id);
         exit;
      end;
   end;

   error('internal error in determine_param');
end;




(**)
(*******************************************************
 *
 * Function:     object_param
 *
 * Description:  returns 16 bit value of parameter in
 *               current objectmem (pointed to by regs.pc).
 *               does a determine param on the first call for
 *               a given location.
 *
 * Example:      regs.a := object_param;
 *
 * Inputs:       regs.pc
 *               objectmem[regs.pc].parameter
 *               objectmem[regs.pc].paramident
 *
 * Outputs:      the parameter value
 *               paramident cleared
 *
 *)

function object_param: integer;
begin
   with objectmem[regs.pc] do
   begin
      if paramident = '' then         {if parameter is known, use it}
         object_param := parameter
      else
      begin                           {otherwise look it up and mark it known}
         parameter := determine_param(paramident);
         paramident := '';
         object_param := parameter;
      end;
   end;
end;



(**)
(*******************************************************
 *
 * Procedure:    push(byte)
 *
 * Description:  push a byte on the top of the data stack
 *
 * Example:      push(lo(regs.x));
 *
 * Inputs:       byte to push
 *               regs.sp
 *
 * Outputs:      objectmem[regs.sp].parameter
 *               regs.sp decremented
 *
 *)

procedure push(b: byte);
begin
   if objectmem[regs.sp].instruction <> empty then
      error('push:  stack crashed into code');

   objectmem[regs.sp].parameter := b;
   regs.sp := regs.sp - 1;
end;

procedure pushint(i:  integer);
begin
   push(lo(i));
   push(hi(i));
end;


(**)
(*******************************************************
 *
 * Function:     pop
 *
 * Description:  pop a byte from the top of the data stack
 *
 * Example:      regs.a := pop;
 *
 * Inputs:       regs.sp
 *               objectmem[regs.sp].parameter
 *
 * Outputs:      the popped byte
 *               regs.sp incremented
 *
 *)

function pop: byte;
begin
   if regs.sp >= max_object then
      error('pop:  stack underflow');

   regs.sp := regs.sp + 1;
   pop := objectmem[regs.sp].parameter;
end;

function popint: integer;
var
   i:  integer;
begin
   i := pop;
   popint := i*$100 + pop;
end;



(**)
(*******************************************************
 *
 * Procedure:    runtimecall
 *
 * Description:  call a runtime library function
 *
 * Example:      runtimecall
 *
 * Inputs:       objectmem[regs.pc].paramident is function name
 *
 *)

procedure runtimecall;
var
   fun:  libfunstr;
   i:    integer;
   c:    char;

begin
   fun := libfun[objectmem[regs.pc].parameter];

(* byte data library functions *)
   if fun = 'BYTE_ADD' then
      regs.a := pop+regs.a
   else
   if fun = 'BYTE_SUB' then
      regs.a := pop-regs.a
   else
   if fun = 'BYTE_MUL' then
      regs.a := pop*regs.a
   else
   if fun = 'BYTE_DIV' then
      regs.a := pop div regs.a
   else
   if fun = 'BYTE_MOD' then
      regs.a := pop mod regs.a
   else
   if fun = 'BYTE_EQ' then
      if pop=regs.a then regs.a := 1 else regs.a := 0
   else
   if fun = 'BYTE_NE' then
      if pop<>regs.a then regs.a := 1 else regs.a := 0
   else
   if fun = 'BYTE_GT' then
      if pop>regs.a then regs.a := 1 else regs.a := 0
   else
   if fun = 'BYTE_LT' then
      if pop<regs.a then regs.a := 1 else regs.a := 0
   else
   if fun = 'BYTE_LE' then
      if pop<=regs.a then regs.a := 1 else regs.a := 0
   else
   if fun = 'BYTE_GE' then
      if pop>=regs.a then regs.a := 1 else regs.a := 0
   else

(* integer data library functions *)
   if fun = 'INTEGER_ADD' then
      regs.x := popint+regs.x
   else
   if fun = 'INTEGER_SUB' then
      regs.x := popint-regs.x
   else
   if fun = 'INTEGER_MUL' then
      regs.x := popint*regs.x
   else
   if fun = 'INTEGER_DIV' then
      regs.x := popint div regs.x
   else
   if fun = 'INTEGER_MOD' then
      regs.x := popint mod regs.x
   else
   if fun = 'INTEGER_EQ' then
      if popint=regs.x then regs.a := 1 else regs.a := 0
   else
   if fun = 'INTEGER_NE' then
      if popint<>regs.x then regs.a := 1 else regs.a := 0
   else
   if fun = 'INTEGER_GT' then
      if popint>regs.x then regs.a := 1 else regs.a := 0
   else
   if fun = 'INTEGER_LT' then
      if popint<regs.x then regs.a := 1 else regs.a := 0
   else
   if fun = 'INTEGER_LE' then
      if popint<=regs.x then regs.a := 1 else regs.a := 0
   else
   if fun = 'INTEGER_GE' then
      if popint>=regs.x then regs.a := 1 else regs.a := 0
   else

(* input/output library functions *)
   if fun = 'INTEGER_WRITELN' then
   begin
      writeln(regs.x);
      flush_output;
   end
   else

   if fun = 'BYTE_WRITELN' then
   begin
      writeln(regs.a);
      flush_output;
   end
   else

   if fun = 'CHAR_WRITELN' then
   begin
      regs.a := objectmem[regs.x].parameter;
      for i := 1 to regs.a do
      begin
         regs.x := regs.x + 1;
         write(chr(objectmem[regs.x].parameter));
      end;
      writeln;
      flush_output;
   end
   else

   if fun = 'INTEGER_READLN' then
   begin
      write('? ');
      flush(output);
      i := regs.x;
      readln(i);
      regs.x := i;
   end

   else
      error('runtimecall: '+ fun + ' missing');

end;




(**)
(*******************************************************
 *
 * Procedure:    execute
 *
 * Description:  executes the instruction at the current regs.pc value
 *
 * Example:      executes
 *
 *)

procedure execute;
begin

   with regs, objectmem[pc] do
      case instruction of

(* program control instructions *)
         libcall:      runtimecall;

         call:         begin
                          pushint(pc);   {push return address
                                          and set new PC}
                          pc := object_param -1;
                       end;

         return:       pc := popint;

         jump:         pc := object_param -1;

         test_zero:    flag.zero := (a = 0);

         jump_zero:    if flag.zero then
                          pc := object_param -1;

         jump_not_zero:
                       if not flag.zero then
                          pc := object_param -1;


(* 'byte' data type manipulation instructions *)
         push_byte:    push(a);

         pop_byte:     a := pop;

         lit_byte:     a := lo(object_param);

         load_byte:    a := lo(objectmem[object_param].parameter);

         store_byte:   if objectmem[object_param].instruction = variable then
                       begin
                          if option_trace then
                             writeln('Byte store of ', regs.a,
                                     ' into location ', object_param);

                          objectmem[object_param].parameter := a;
                       end
                       else
                          error('run: store into non-variable');


(* 'integer' data type manipulation instructions *)
         push_integer:   pushint(x);

         pop_integer:    x := popint;

         lit_integer:    x := object_param;

         load_integer:   x := (objectmem[object_param  ].parameter)*$100+
                              (objectmem[object_param+1].parameter);

         store_integer:  if objectmem[object_param].instruction = variable then
                         begin
                            if option_trace then
                               writeln('Integer store of ', x,
                                       ' into location ', object_param);

                            objectmem[object_param  ].parameter := hi(x);
                            objectmem[object_param+1].parameter := lo(x);
                         end
                         else
                             error('run: store into non-variable');

(* other "optimized" machine instructions *)
         pshb:   push(b);

         pulb:   b := pop;

         tab:    b := a;

         tba:    a := b;

         mul:    a := a * b;

         addb:   a := a + b;

         subb:   a := a - b;

         orab:   a := a or b;

         andb:   a := a and b;

         coma:   if a = 0 then a := 1 else a := 0;


(* check for execution errors *)
         equate:    ;

         empty..reserve_bytes:
            error('run: attempt to run non-instruction');

         else
            error('run: invalid instruction');
      end;

end;


(**)
(*******************************************************
 *
 * Procedure:    runexecprog;
 *
 * Description:  run the object coad loaded into object memory
 *
 * Example:      runexecprog;
 *
 *)

procedure runexecprog;
begin

   writeln;
   writeln('Starting execution:');
   flush(output);
   linecount := 0;

   pushint(9999);   {push the normal-exit address}

   regs.pc := determine_param(entry_point);
                    {set the initial pc to the entry point}


   repeat

      execute;                  {execute the current instruction}

      regs.pc := regs.pc + 1;   {increment the pc for the next fetch}

      if option_trace then
         dump_regs;             {display registers if in trace more}

   until regs.pc = 9999+1;


   writeln('Normal program termination');
   flush(output);

end;

