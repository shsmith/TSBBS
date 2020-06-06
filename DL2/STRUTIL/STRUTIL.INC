
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

function len(var s: longstring): integer; 
begin
   len := ord(s[0]); 
end;

(**
procedure concat_char(var s: longstring; c: char);
begin
   inc(s[0]);
   s[ord(s[0])] := c;
end;
procedure concat_str(var s: longstring; var s2: longstring);
begin
   s := s + s2;
end;
***)

function lastchar(var s: longstring): char;
begin
   lastchar := s[ord(s[0])];
end;

procedure copy_str(var s: longstring; var s2: longstring);
begin
   s := s2;
end;

