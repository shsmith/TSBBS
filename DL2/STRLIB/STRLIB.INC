
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

{--
 -- Long string package
 --
 -- Author: S.H.Smith, 25-apr-86
 --
 --}


{--
 -- Package specification
 --
 --}

type
   string_buffer_pointer = ^string_buffer;
   string_buffer = array[1..maxint] of char;

   long_string_record = record
      length:      integer;
      max_length:  integer;
      value:       string_buffer_pointer;
   end;

   long_string_pointer = ^long_string_record;
   short_string = string[255];


function new_long_string(max: integer): long_string_pointer;
var
   str: long_string_pointer;

begin
   new(str);
   with str^ do
   begin
      length := 0;
      max_length := max;
      getmem(value,str^.max_length);
   end;
   new_long_string := str;
end;


function copy_long_string(old: long_string_pointer): long_string_pointer;
var
   str: long_string_pointer;
   i:   integer;
begin
   str := new_long_string(old^.max_length);
   str^.length := old^.length
   str^.value^ := old^.value;
   copy_long_string := str;
end;


