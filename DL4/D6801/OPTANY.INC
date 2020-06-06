



(*******************************************************
 *
 * Subsystem:   OptAny - Optimizer for Any target machine
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
 *         integer lib calls take parameters in X and stack-top and
 *         leave return values in X.

 *         boolean lib calls take parameters in A and stack-top
 *         and leave return values in A.  *)

 procedure optlibcall (object:       objectstr);
 var
   func:         objectstr;

 begin
   func := copy (object, 9, 99);


(**** example of library opt format:

   if func = 'BYTE_ADD' then
   begin
      optoutput(' PULB  *byte add');
      optoutput(' ADDB');
   end
   else

****)

      prevobject := object;   { else can't optimize this call right now,
                                leave it for further checking when more code
                                is generated }

 end;


(*      Optimize and output a single line of object code.   The object
 *      code must be with fixed tabstops output from Gen.  *)

 procedure optimize (object:       objectstr);
 begin

   if (object[1] = op_comment) then  { just output the object when
                                       the optimizer is turned off or
                                       when the object is a comment }
   begin
      optoutput(object);
      exit;
   end;


   if (prevobject = op_push_byte) and      { get rid of redundant boolean }
      (object     = op_pop_byte) then      { stack operations }

      optremove
   else

   if (prevobject = op_push_integer) and   { get rid of redundant integer }
      (object     = op_pop_integer) then   { stack operations }

      optremove
   else

   if nooptimize or
      (object[1] = op_comment) then  { just output the object when
                                       the optimizer is turned off or
                                       when the object is a comment }
   begin
      optoutput(object);
   end
   else

   if (not nooptimize) and (copy (object, 1, 8)= (op_call + 'OP_')) then
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