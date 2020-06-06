
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

procedure iadd(var a: integer; b: integer);
begin
  a := a + b;
end;
procedure isub(var a: integer; b: integer);
begin
  a := a - b;
end;
procedure imult(var a: integer; b: integer);
begin
  a := a * b;
end;
procedure idiv(var a: integer; b: integer);
begin
  a := a div b;
end;

procedure radd(var a: real; b: real);
begin
  a := a + b;
end;
procedure rsub(var a: real; b: real);
begin
  a := a - b;
end;
procedure rmult(var a: real; b: real);
begin
  a := a * b;
end;
procedure rdiv(var a: real; b: real);
begin
  a := a / b;
end;

procedure rrange(var a: real; b,c: real);
begin
   if a < b then a := b else
   if a > c then a := c;
end;

procedure irange(var a: integer; b,c: integer);
begin
   if a < b then a := b else
   if a > c then a := c;
end;


