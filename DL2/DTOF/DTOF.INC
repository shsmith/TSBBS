
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

function dtof(B: double): real;
   {convert 8 byte double to real}
var
   PasReal:  real;
   R:        array [0..5] of byte absolute PasReal;
begin
   PasReal := 0;
   move(B[2],R[1],5);
   R[0] := B[7];
   dtof := PasReal;
end;

function dtol(B: double): longint;
   {convert 8 byte double to long integer}
begin
   dtol := trunc(dtof(B));
end;

procedure ftod(PasReal: real; var B: double);
   {convert real to 8 byte double}
var
   R: array [0..5] of byte absolute PasReal;
begin
   fillchar(B[0],8,0);
   B[7] := R[0];
   move(R[1],B[2],5);
end;


(*-----------------------------------------------------------------*)
procedure incd(var d: double; n: real);
begin
   ftod( int(dtof(d)) + n, d );
end;

