
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
 * pattern match function - matches a unix-style filename pattern.
 *      this recursive definition will accept *key* forms.
 *
 * S.H.Smith, rev. 04-Oct-87 (rev. 12-01-88)
 *
 *)

{$DEFINE PATTERN_MATCH}

(* these static variables are part of a hack to speed up the recursive
   pattern matching operation.  *)

var
   PAT_pattern:        string13;
   PAT_pc:             integer;
   PAT_line:           string13;
   PAT_lc:             integer;


(* matching engine - uses pointers into static pattern and line strings *)

function PAT_match (patpos,
                    linpos:             integer): boolean;
const
   QUESTION =          63;    {ord('?')}
   STAR =              42;    {ord('*')}
   ENDSTR =            32;    {ord(' ')}
   
label 
   continue;

begin
   PAT_match := false;

(* do a "wildcard" filename scan *)
   
   repeat
continue :
      PAT_pc := ord (PAT_pattern [patpos]);  {get next pattern character}
      PAT_lc := ord (PAT_line [linpos]);     {get next line character}

(* end of pattern?  we might have a match if so *)
      
      if patpos > length(PAT_pattern) then
      begin
         PAT_match := PAT_lc = ENDSTR;
         exit;
      end
      else

(* does line match pattern?  step forward if so *)
      
      if (PAT_pc = PAT_lc) then
      begin
         inc(patpos);
         inc(linpos);
         goto continue;
      end
      else

(* end of line?  we missed a match if so *)
      
      if PAT_lc = ENDSTR then
         exit
      else

(* ? matches anything *)
      
      if (PAT_pc = QUESTION) then
      begin
         inc(patpos);
         inc(linpos);
         goto continue;
      end
      else

(* '*' matches 0 or more characters, anywhere in string *)
      
      if PAT_pc = STAR then
      begin
         
         if patpos = length(PAT_pattern) then
         begin
            PAT_match := true;
            exit;
         end;
         
         inc(patpos);
         
         repeat
            
            if PAT_match (patpos, linpos) then
            begin
               PAT_match := true;
               exit;
            end;
            
            inc(linpos);
            PAT_lc := ord (PAT_line [linpos]);
         until PAT_lc = ENDSTR;
         
         exit;
      end
      else
(* else no match is possible; terminate scan *)
         exit;

   until false;
end;

function wildcard_match (var pattern,
                         line:               string65): boolean;
                           {pattern must be upper case; line is not case 
                             sensitive}
var
   p: integer;
begin

(* test for special case that matches all filenames *)
   
   if pattern[1] = '*' then
   begin
      p := cpos('.',line);
      if (pattern = '*.*') or
        ((pattern = '*.') and ((p=0) or (p > 9))) then
      begin
         wildcard_match := true;
         exit;
      end;
   end;

   PAT_pattern := pattern;
   PAT_line := line;

(* force a space as end-of-string character to simplify *)
   
   if length(PAT_line) > 12 then
      PAT_line[0]:= chr (12);
   
   if PAT_line[length(PAT_line)] <> ' ' then
      PAT_line := PAT_line + ' ';

(* perform the match test *)
   
   stoupper(PAT_line);
   wildcard_match := PAT_match (1, 1);
end;

