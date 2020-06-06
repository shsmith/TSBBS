
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

(*-----------------------------------------------------------------*)
function stof(B: single): real;
   {convert 4 byte single to real}
var
   PasReal:  real;
   R: array [0..5] of byte absolute PasReal;
begin
   R[0] := B[3];
   R[1] := 0;
   R[2] := 0;
   move(B[0],R[3],3);
   stof := PasReal;
end;


(*-----------------------------------------------------------------*)
procedure ftos(PasReal: real; var B: single);
   {convert real to 4 byte single}
var
   R: array [0..5] of byte absolute PasReal;
begin
   B[3] := R[0];
   move(R[3],B[0],3);
end;


(*-----------------------------------------------------------------*)
function stol(s: single): longint;
var
   f: real;
begin
{writeln('stol = (',s[0]:3,s[1]:4,s[2]:4,s[3]:4,')');}

   f := int(stof(s));
   if (f < -$7FFFFFFE) or (f > $7FFFFFFF) then
   begin
      {writeln(' f=',f:0:10);}
      f := 0;
   end;

   stol := trunc( f );
end;


(*-----------------------------------------------------------------*)
procedure ltos(l: longint; var B: single);
begin
   ftos(l,B);
end;


(*-----------------------------------------------------------------*)
procedure incs(var s: single; n: real);
begin
   ftos( trunc(stof(s)) + n, s );
end;


(*-----------------------------------------------------------------*)
procedure zeros(var B: single);
begin
   ltos(0, B);
end;

