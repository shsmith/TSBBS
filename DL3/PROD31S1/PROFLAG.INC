
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
 * PCB ProDOOR flag files for processing (3-1-89)
 *
 *)


(* ----------------------------------------------------------- *)
procedure list_flags;
begin
   if pending_flags = '' then
      displn('No flags present.')
   else
   begin
      disp('Flagged files: ');
      displn(pending_flags);
   end;
end;


(* ----------------------------------------------------------- *)
procedure unflag_files;
var
   p: integer;

begin
   if cmdline = '' then
      get_defn('Filename(s) to UNflag:','(*)all, ');

   if cmdline = '*' then
      pending_flags := ''
   else

   begin
      p := pos(' '+cmdline,pending_flags);
      if p = 0 then
      begin
         disp('No such flag: ');
         displn(cmdline);
      end
      else
         delete(pending_flags,p,length(cmdline)+1);
   end;

   list_flags;
end;


(* ----------------------------------------------------------- *)
procedure flag_files;
begin

{$IFNDEF IN_PROEDIT}
{$IFNDEF IN_PROKIT}
   if length(cmdline) = 0 then
   begin
      list_flags;
      get_defn('Filename(s) to flag:','(U)nflag, ');
   end;

   stoupper(cmdline);
   get_nextpar;
   if par = '' then
      exit;

   if par = 'U' then
      unflag_files
   else

   begin
      if (pending_flags <> '') then
         pending_flags := pending_flags + ' ';

      unget_par;
      pending_flags := pending_flags + cmdline;
      replace_string(pending_flags,';',' ');
      delete_trailing_spaces(pending_flags);
   end;
{$ENDIF}
{$ENDIF}

   cmdline := '';
end;


(* ----------------------------------------------------------- *)
function manual_flags_present: boolean;
begin
   manual_flags_present := pending_flags[length(pending_flags)] > ' ';
end;


(* ----------------------------------------------------------- *)
procedure autoflag_check(name: dos_filename);
begin
   name := remove_ext(name)+'.*';
   if dos_exists(name) then
      cmdline := cmdline + remove_path(name) + ' ';
end;


(* ----------------------------------------------------------- *)
procedure autoflag_scratch;
begin
   if manual_flags_present then exit;
   cmdline := '';
   autoflag_check(scratcharc);
   autoflag_check(mailarc);
   pending_flags := cmdline;
end;


(* ----------------------------------------------------------- *)
function flag_warning(quit: boolean): boolean;
   {return true if ok to lose flags or no flags set}
   {when quit=true warn about autoflags; otherwise ignore them}

begin
   flag_warning := true;

   if manual_flags_present or ((pending_flags <> '') and quit) then
   begin
      beep;
      newline;
      dRED('Flags will be lost if you proceed: ');
      displn(pending_flags);

      get_defyn('Continue anyway:',false);
      if par[1] = 'N' then
         flag_warning := false;
   end;
end;

