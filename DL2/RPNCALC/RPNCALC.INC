
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * MISC_rpn_calc - post-fix calculator
 *
 * This is a utility library to implement a simple post-fix (rpn)
 * calculator that can be used when runtime defined calculations
 * need to be made.
 *
 *)

function MISC_rpn_calc (initial_value:      real;
                        formula:            anystring): real;
                           {apply RPN calculator to formula with initial_value
                             on top of stack. returns final top of stack}

const
   stack_limit =       10;    {maximum stack depth}


var
   stack:              array [1.. stack_limit] of real;
   top:                integer;
   word:               anystring;
   c:                  char;
   i:                  integer;
   code:               integer;
   v1,
   v2:                 real;


   procedure push (v:                  real);
                              {push v on top of the stack}
   begin
      top := top + 1;

      if top > stack_limit then
      begin
         MISC_fatal_error('RPN Stack overflow, formula: ' + formula);
         top := top -1;
      end;

      stack[top]:= v;
   end;


   function pop: real;        {pop a value off the top of stack}
   begin

      if top < 1 then
      begin
         MISC_fatal_error('RPN Stack underflow, formula: ' + formula);
         top := top + 1;
      end;

      pop := stack [top];
      top := top - 1;
   end;

   function scannum(word: anystring; radix: integer): real;
   var
      i:  integer;
      n:  real;
      d:  integer;

   begin
      n := 0.0;
      for i := 2 to length(word) do
      begin
         d := ord(upcase(word[i])) - ord('0');
         if d > 9 then
            d := d - 7;
         n := n * int(radix) + int(d);
      end;

      scannum := n;
   end;

   function binval(word: anystring): real;
   begin
      binval := scannum(word,2);
   end;

   function hexval(word: anystring): real;
   begin
      hexval := scannum(word,16);
   end;

   function tan(r: real): real;
   begin
      tan := sin(r) / cos(r);
   end;

begin                         {MISC_rpn_calc}

   top := 0;
   push(initial_value);
   word := '';

   for i := 1 to length (formula) do
                              {scan the formula string}
   begin
      c := formula [i];

      if c <> ' ' then
         word := word + upcase(c);

      if (c = ' ') or (i = length (formula)) then
                                 {if at the end of a word or at the end
                                   of the formula}
      begin

         case word [1] of       {check for and process each operator}

            '+':  push(pop + pop);

            '*':  push(pop * pop);

            '-':  begin
                     if (length(word) > 1) and (word[2] in ['0'..'9']) then
                     begin
                        val(word, v1, code);
                        push(v1);
                     end
                     else
                     begin
                        v1 := pop;
                        v2 := pop;
                        push(v2 - v1);
                     end;
                  end;

            '/':  begin
                     v1 := pop;
                     v2 := pop;
                     push(v2 / v1);
                  end;

            '\':  begin
                     v1 := pop;
                     if v1 <> 0.0 then
                        push(1.0 / v1)
                     else
                        push(0.0);
                  end;

            'H':  push(hexval(word));

            'B':  push(binval(word));

            '.','0'..'9':              {numbers are pushed on the stack}
                  begin
                     val(word, v1, code);
                     push(v1);
                  end;

            else
               if word = 'PI'   then push(pi)        else
               if word = 'SIN'  then push(sin(pop))  else
               if word = 'COS'  then push(cos(pop))  else
               if word = 'TAN'  then push(tan(pop))  else
               if word = 'EXP'  then push(exp(pop))  else
               if word = 'INT'  then push(int(pop))  else
               if word = 'SQRT' then push(sqrt(pop)) else
               if word = 'LN'   then push(ln(pop))   else
               if word = 'E'    then push(exp(1.0))
               else
                  MISC_fatal_error('Unknown RPN word: ' + word +
                                   ' in formula: ' + formula);
         end;

         word := '';                {consume the word and scan for more
                                      words}

      end;
   end;

   MISC_rpn_calc := pop;

end;                       {MISC_rpn_calc}

