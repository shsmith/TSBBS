
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
 * gettime - get time of day from system clock
 *
 *)

function get_time: real;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   get_time := int(s1)/ 100.0 +   {seconds/100}
               int(s) +           {seconds}
               int(m) * 60.0 +    {minutes}
               int(h) * 3600.0;   {hours}
end;

function lget_time: longint;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   lget_time := longint(s) +                  {seconds}
                longint(m) * longint(60) +    {minutes}
                longint(h) * longint(3600);   {hours}
end;

function lget_ms: longint;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   lget_ms  := longint(s1)* longint(10) +      {seconds/100}
               longint(s) * longint(1000) +    {seconds}
               longint(m) * longint(60000) +   {minutes}
               longint(h) * longint(3600000);  {hours}
end;

function get_mins: integer;
var
   h,m,s,s1: word;
begin
   GetTime(h,m,s,s1);
   get_mins := m + 60 * h;
end;



