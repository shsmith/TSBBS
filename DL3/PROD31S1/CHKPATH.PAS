
(*
 * Copyright 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)


(*
 * chkpath - check for a program in the current PATH list;
 *           report to stdout if the program is not present
 *
 *)

{$m 8000,0,0}
{$s-,r-,v-}

program check_path;

uses dos;

const
   version = 'ChkPath v2.0 07-09-89 (C) 1989 S.H.Smith';

var
   found:   boolean;
   command: string;
   path:    string;


procedure displn(what: string);
begin
   writeln(what);
end;

procedure report(what: string);
begin
   displn(paramstr(2)+': '+what);
end;


procedure lookfor(ext: string);
var
   fname:   string;
   result:  string;
begin
   if not found then
   begin
      fname := command+ext;
      result := fsearch(fname,path);
      if result <> '' then
      begin
         found := true;
         if GetEnv('PRODEBUG') = 'ON' then
            displn('ProDebug: Program='+result);
      end;
   end;
end;


function name_only(name: string): string;
var
   d,n,e:  string;
begin
   FSplit(name,d,n,e);
   name_only := n;
end;


var
   i:       integer;
begin
   path := GetEnv('PATH');
   command := paramstr(1);
   for i := 1 to length(command) do
      command[i] := upcase(command[i]);
   found := false;

   if paramcount = 0 then
   begin
      displn(version);
      displn('Usage: chkpath COMMAND [MESSAGE_PREFIX]');
      displn('          ;set errorlevel if command not in path');
      displn('  or   chkpath -N FILE1 FILE2');
      displn('          ;set errorlevel if FILE1 and FILE2 have different names');
      halt(1);
   end;

   if path = '' then
      report('WARNING: There is no "PATH" variable in the environment!');

   if paramstr(1) = '-N' then
   begin
      if name_only(paramstr(2)) = name_only(paramstr(3)) then
         halt(0)
      else
         halt(1);
   end;

   lookfor('.EXE');
   lookfor('.COM');
   lookfor('.BAT');
   if not found then
   begin
      report('Can''t locate program: '+command);
      report('Current PATH is: "'+path+'"');
      writeln('['+command+'] must be in one of these directories: ['+path+']');
      halt(1);
   end;

   halt(0);
end.
