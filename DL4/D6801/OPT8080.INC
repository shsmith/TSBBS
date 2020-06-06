

(*******************************************************
 *
 * Subsystem:   Opt8080 - Optimizer for 8080 target machine
 *
 * Overview
 * --------
 *
 *    Filters the output of the code generator and replaces
 *    some code sequences with smaller sequences that have
 *    the same effect.   Also translates some library calls
 *    into inline code to perform the same function.
 *
 *
 * Revision History
 * ----------------
 *
 *   09-dec-85 s.h.smith  initial coding
 *
 *)



(*      OptOutput outputs a string to the output file without any further
 *      processing.   *)

 procedure optoutput (object:       objectstr);
 var
   i:            integer;
   outline:      objectstr;
   fileok:       boolean;
   incomment:    boolean;

 begin

   if object = noobj then
      exit;                      { delete line when an optimization
                                   has taken place }

   outline := '';                { map spaces into fixed tab stops }
   incomment := false;

   for i := 1 to length (object) do
   begin                         { in the output line }

      outline := outline + object [i];
      if object [i]= op_comment then
         incomment := true;

      if (not incomment) and (object [i]= ' ') then
         while (length (outline) mod 8)<> 0 do
            outline := outline + ' ';
   end;

{$I-}
   writeln(outfile, outline);
{$I+}
   fileok :=(ioresult = 0);

   if not fileok then
      error(disk);

   outlines := outlines + 1;

 end;


(*      OptRemove removed the current and previous objects from the
 *      object stream; they are considered redundant.   *)

 procedure optremove;
 begin
   prevobject := noobj;
 end;


(*      OptLibCall will replace some support library calls by inline
 *      code to perform the same function.

 *      integer lib calls take parameters in X and stack-top and
 *      leave return values in X.

 *      boolean lib calls take parameters in A and stack-top
 *      and leave return values in A.  *)

 procedure optlibcall (object:       objectstr);
 var
   func:         objectstr;

 begin
   func := copy (object, 10, 99);

   if (func = 'BYTE_STORE_BYTE_INDEX') and optspeed then
   begin
      optoutput(op_pop_byte+' ;byte store using byte index');
      optoutput(' MOV B,A');
      optoutput(' XRA A');
      optoutput(' MOV E,A');
      optoutput(op_pop_byte);
      optoutput(' MOV D,A');
      optoutput(' DAD D');
      optoutput(' MOV M,B');
   end
   else

   if (func = 'BYTE_STORE_INTEGER_INDEX') and optspeed then
   begin
      optoutput(op_pop_byte+' ;byte store using integer index');
      optoutput(' MOV B,A');
      optoutput(' POP D');
      optoutput(' DAD D');
      optoutput(' MOV M,B');
   end
   else

   if (func = 'BYTE_LOAD_BYTE_INDEX') and optspeed then
   begin
      optoutput(' XRA A ;byte load using byte index');
      optoutput(' MOV E,A');
      optoutput(op_pop_byte);
      optoutput(' MOV D,A');
      optoutput(' DAD D');
      optoutput(' MOV A,M');
   end
   else

   if (func = 'BYTE_LOAD_INTEGER_INDEX') and optspeed then
   begin
      optoutput(' POP D ;byte load using integer index');
      optoutput(' DAD D');
      optoutput(' MOV A,M');
   end
   else

   if (func = 'INTEGER_STORE_BYTE_INDEX') and optspeed then
   begin
      optoutput(' POP B ;integer store using integer index');
      optoutput(' XRA A');
      optoutput(' MOV E,A');
      optoutput(op_pop_byte);
      optoutput(' MOV D,A');
      optoutput(' DAD D');
      optoutput(' MOV M,B');
      optoutput(' INX H');
      optoutput(' MOV M,C');
   end
   else

   if (func = 'INTEGER_STORE_INTEGER_INDEX') and optspeed then
   begin
      optoutput(' POP B ;integer store using integer index');
      optoutput(' POP D');
      optoutput(' DAD D');
      optoutput(' MOV M,B');
      optoutput(' INX H');
      optoutput(' MOV M,C');
   end
   else

   if (func = 'INTEGER_LOAD_BYTE_INDEX') and optspeed then
   begin
      optoutput(' XRA A ;integer load using byte index');
      optoutput(' MOV E,A');
      optoutput(op_pop_byte);
      optoutput(' MOV D,A');
      optoutput(' DAD D');
      optoutput(' MOV D,M');
      optoutput(' INX H');
      optoutput(' MOV E,M');
      optoutput(' XCHG');
   end
   else

   if (func = 'INTEGER_LOAD_INTEGER_INDEX') and optspeed then
   begin
      optoutput(' POP D ;integer load using integer index');
      optoutput(' DAD D');
      optoutput(' MOV D,M');
      optoutput(' INX H');
      optoutput(' MOV E,M');
      optoutput(' XCHG');
   end
   else

   if func = 'INTEGER_ADD' then
   begin
      optoutput(' POP D ;integer add');
      optoutput(' DAD D');
   end
   else

   if func = 'BYTE_ADD' then
   begin
      optoutput(' MOV B,A ;byte add');
      optoutput(op_pop_byte);
      optoutput(' ADD B');
   end
   else

   if func = 'BYTE_SUB' then
   begin
      optoutput(' MOV B,A ;byte subtract');
      optoutput(op_pop_byte);
      optoutput(' SUB B');
   end
   else

   if (func = 'BYTE_OR') or (func = 'BOOLEAN_OR') then
   begin
      optoutput(' MOV B,A ;byte OR');
      optoutput(op_pop_byte);
      optoutput(' ORA B');
   end
   else

   if (func = 'BYTE_AND') or (func = 'BOOLEAN_OR') then
   begin
      optoutput(' MOV B,A ;byte AND');
      optoutput(op_pop_byte);
      optoutput(' ANA B');
   end
   else

   if ((func = 'BYTE_EQ') or (func = 'BOOLEAN_EQ')) and optspeed then
   begin
      optoutput(' MOV B,A ;byte EQ test');
      optoutput(op_pop_byte);
      optoutput(' CMP B');
      optoutput(' MVI A,0');
      optoutput(' JNZ *+2');
      optoutput(' XRA A');
   end
   else

   if ((func = 'BYTE_NE') or (func = 'BOOLEAN_NE')) and optspeed then
   begin
      optoutput(' MOV B,A ;byte NE test');
      optoutput(op_pop_byte);
      optoutput(' CMP B');
      optoutput(' MVI A,0');
      optoutput(' JZ *+2');
      optoutput(' XRA A');
   end
   else

   if func = 'BOOLEAN_NOT' then
   begin
      optoutput(' CMA  ;byte NOT');
   end
   else

      prevobject := object;   { else can't optimize this call right now,
                                leave it for further checking when more code
                                is generated }

 end;


(*      Optimize and output a single line of object code.   The object
 *      code must be with fixed tabstops output from Gen.  *)

 procedure optimize (object:       objectstr);
 begin

   if nooptimize then         { just output the object when the optimizer
                                is turned off }

   begin
      optoutput(object);
      exit;
   end;


   if (prevobject = op_push_byte) and   { get rid of redundant boolean }
      (object     = op_pop_byte)  then  { stack operations }

      optremove
   else

   if (prevobject = op_push_integer) and   { get rid of redundant integer }
      (object     = op_pop_integer)  then  { stack operations }

      optremove
   else

   if (copy (object, 1, 9)= (op_call + 'OP_')) then
   begin
      optoutput(prevobject);     { check for and optimize calls to }
      prevobject := noobj;       { the runtime support library }

      optlibcall(object);
   end

   else
   begin                         { no optimization for this instruction }
      optoutput(prevobject);     { so keep it and output the prevous one }
      prevobject := object;
   end;
 end;



(*      OptFlush flushes out any pending object instructions that have
 *      been stored for later.   *)

 procedure optflush;
 begin
    optoutput(prevobject);
    prevobject := noobj;
    flush(outfile);
 end;

