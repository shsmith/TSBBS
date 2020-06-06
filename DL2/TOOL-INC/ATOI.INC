
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
 * converts ascii string to an integer value
 * (tp3 dies on leading spaces but likes trailing.
 *  tp4 likes leading spaces but dies on trailing!!)
 *
 *)

function atol (asc:  anystring): longint;
var
   i:             integer;
   value:         longint;
   num:           anystring;

begin
   num := '';
   for i := 1 to length(asc) do
      if (asc[i] >= '0') and (asc[i] <= '9') then
         num := num + asc[i];

   if length(num) = 0 then
      value := 0
   else
      val(num, value, i);

   atol := value;
end;


function hatoi (asc:  anystring): word;
var
   i:          integer;
   num:        word;
   radix:      word;

begin
   num := 0;
   radix := 10;

   for i := 1 to length(asc) do
      case asc[i] of
         '0'..'9':
            num := num*radix + ord(asc[i])-ord('0');

         'a'..'f','A'..'F':
            begin
               radix := 16;
               num := num*radix + ord(asc[i])-ord('0')-7;
            end;

         '$','x','X':
            radix := 16;
      end;

   hatoi := num;
end;


function atoi (asc:  anystring): integer;
begin
   atoi := integer(atol(asc));
end;

function atow (asc:  anystring): word;
begin
   atow := word(atol(asc) and $FFFF);
end;

function insert_commas(s: anystring): anystring;
var
   i: integer;
begin
   i := length(s);
   if s[i] = 'k' then
      dec(i);

   while i > 3 do
   begin
      dec(i,3);
      insert(',',s,i+1);
   end;

   insert_commas := s;
end;

