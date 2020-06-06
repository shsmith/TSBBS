
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
 * Wildcard match function
 *
 * S.H.Smith, rev. 04-Oct-87
 *
 *)

function wildcard_match(keyword,line:  anystring): boolean;
var
   keypos,linpos:  integer;

begin
   if keyword = '*.*' then
   begin
      wildcard_match := true;
      exit;
   end;

(**
if setdebug then
writeln(dbfd,'match key=',keyword,' line=',line);
**)
   keypos := 1;
   linpos := 1;

   (* do a "wildcard" filename scan *)
   while true do
   begin

      (* end of keyword?  we might have a match if so *)
      if keypos > length(keyword) then
      begin
         wildcard_match := (linpos >= length(line)) or (line[linpos] = ' ');
(**
if setdebug then
writeln(dbfd,'match=',(linpos >= length(line)) or (line[linpos] = ' '));
**)
         exit;
      end
      else

      (* end of line?  we missed a match if so *)
      if linpos > length(line) then
      begin
         wildcard_match := false;
(**
if setdebug then
writeln(dbfd,'no1');
**)
         exit;
      end
      else

      (* does line match keyword? (? matches anything); step forward if so *)
      if (keyword[keypos] = upcase(line[linpos])) or 
         (keyword[keypos] = '?') then
      begin
         inc(keypos);
         inc(linpos);
      end
      else

      (* is keyword a *?  skip to . or end if so *)
      if keyword[keypos] = '*' then
      begin
         while (line[linpos]<>' ') and (line[linpos]<>'.') and
               (linpos < length(line)) do
            inc(linpos);

         inc(keypos);
      end
      else

      (* else no match is possible; terminate scan *)
      begin
         wildcard_match := false;
(**
if setdebug then
writeln(dbfd,'no1');
**)
         exit;
      end;
   end;

end;


