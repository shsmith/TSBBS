
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
 * get the value of an environment variable
 *
 * example:  path := get_environment_var('PATH=');
 *
 *)

function get_environment_var(id: string20): anystring;


{$IFDEF TP40}
var
   envseg:  integer;
   i:       integer;
   env:     anystring;

begin
   envseg := memw[PrefixSeg:$2c];
   i := 0;

   repeat
      env := '';
      while mem[envseg:i] <> 0 do
      begin
         env := env + chr(mem[envseg:i]);
         inc(i);
      end;

      if copy(env,1,length(id)) = id then
      begin
         get_environment_var := copy(env,length(id)+1,255);
         exit;
      end;

      inc(i);
   until mem[envseg:i] = 0;

(* not found *)
   get_environment_var := '';
end;

{$ELSE}  {TP 5.0}

begin
   dec(id[0]);    {delete trailing =}
   get_environment_var := GetEnv(id);
end;

{$ENDIF}


function environment_on(id: string20): boolean;
var
   value:   string20;
begin
   value := GetEnv(id);
   stoupper(value);
   environment_on := (value = 'ON');
end;

