
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
 * remove_path - remove pathname prefix from a filename
 *
 *)

function remove_path(name: filenames): filenames;

{$IFDEF TP40}

var
   n: filenames;
   i: integer;

begin
   if (length(name) > 2) then
   begin
      if (name[2] <> ':') then
      begin
         remove_path := name;
         exit;
      end
      else
      if name[1] > '@' then
         delete(name,1,2);
   end;

   n := '';
   for i := 1 to length(name) do
      if name[i] = '\' then
         n := ''
      else
      begin
         inc(n[0]);
         n[length(n)] := name[i];
      end;

   remove_path := n;
end;

{$ELSE}

var
   d,n,e:   filenames;
begin
   if ((length(name) > 2) and (name[2] <> ':') and (name[1] <> '\')) or (name[1] < 'A') then
      remove_path := name
   else
   begin
      FSplit(name,d,n,e);
      remove_path := n + e;
   end;
end;

{$ENDIF}


(*
 * path_only - return pathname prefix from a filename
 *             (does NOT include trailing \!)
 *)

function path_only(name: filenames): filenames;

{$IFDEF TP40}

var
   n: filenames;
   i: integer;

begin

   {scan backwards looking for the last : or \ in the pathname}
   n := name;
   i := length(n);
   while (i > 0) and (name[i] <> ':') and (name[i] <> '\') do
      dec(i);

   n[0] := chr(i);

   {add a trailing "\" if needed}
   if (length(n) > 2) and (n[length(n)] <> '\') then
   begin
      inc(n[0]);
      n[length(n)] := '\';
   end;

   path_only := n;
end;

{$ELSE}  {TP 5.0}

var
   d,n,e:   filenames;

begin
   FSplit(name,d,n,e);
   if d[length(d)] = '\' then
      dec(d[0]);
   path_only := d;
end;

{$ENDIF}


(*
 * name_only - return name prefix from a filename (without path or .ext)
 *)

function name_only(name: filenames): filenames;
var
   d,n,e:  filenames;
begin
   FSplit(name,d,n,e);
   name_only := n;
end;


(*
 * remove_ext - remove filename .ext
 *
 *)

function remove_ext(name: filenames): filenames;
var
   n: filenames;
   i: integer;
begin
   n := name;
   i := length(n);
   while (i > 0) and (name[i] <> '.') do
      dec(i);

   if name[i] = '.' then
      n[0] := chr(i-1);

   remove_ext := n;
end;


(*
 * ext_only - return only the ext portion of a filename
 *
 *)

function ext_only(name: filenames): filenames;

{$IFDEF TP40}
var
   i: integer;
begin
   i := length(name);
   while (i > 0) and (name[i] <> '.') do
      dec(i);

   if name[i] = '.' then
      ext_only := copy(name,i,99)
   else
      ext_only := '';
end;

{$ELSE}  {TP 5.0}

var
   d,n,e: filenames;
begin
   FSplit(name,d,n,e);
   ext_only := e;
end;

{$ENDIF}


(*
 * cons_path - construct a pathname from a directory and a filename
 *
 *)
procedure cons_path(var path: filenames;
                    dir,name: filenames);
begin
   if dir[length(dir)] <> '\' then
   begin
      inc(dir[0]);
      dir[length(dir)] := '\';
   end;

   path := dir + name;
   stoupper(path);
end;


(*
 * cons_name - construct a filename from three parts
 *
 *)
procedure cons_name(var resu:          filenames;
                    name1,name2,ext:   filenames);
begin
   resu := name1 + name2 + ext;
   stoupper(resu);
end;


