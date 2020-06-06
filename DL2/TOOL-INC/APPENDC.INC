
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

(***
procedure appendc(var line: string; c: char);
begin
   inc(line[0]);
   line[length(line)] := c;
end;

procedure appends(var line: string; s: anystring);
begin
   line := line + s;
end;
***)

procedure vappends(var line: varstring; s: anystring);
begin
   savestr(line,line^ + s);
end;


