
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
 * PCB ProDOOR display text / message files library (3-1-89)
 *
 *)


procedure popup_prompt(prompt:      string80;
                       var answer:  string;
                       maxlen:      integer);
   {prompt for an input and remove the prompt afterwards}
var
   pprompt: string80;
begin
   pprompt := current_line;
   dYELLOW(prompt);
   input(answer,maxlen);
   linenum := 1;
   stoupper(answer);
   erase_prompt(length(answer));
   current_line := pprompt;
end;


(* ------------------------------------------------------------------- *)
procedure popup_cmdline(prompt:      string80;
                        defalt:      string80);
   {prompt for a command line and remove the prompt afterwards}
var
   paltp: boolean;
   paltf: boolean;

begin
(*************
   paltp := alt_p;
   alt_p := false;
   paltf := setdebug;
   setdebug := false;
**************)

   prompt_def(prompt,defalt);
   get_cmdline_raw(length(prompt)+length(defalt)+12);
   linenum := 1;

(***********
   alt_p := paltp;
   setdebug := paltf;
************)
end;


(* ------------------------------------------------------------------- *)
procedure force_enter;
   {prompt for [enter] key and continue}
begin
   newline;
   popup_cmdline('Press (Enter) to continue:','');
   par := '';
   cmdline := '';
end;


(* ------------------------------------------------------------------- *)
procedure force_enter2;
   {prompt for [enter] if less than half of screen is left}
begin   
   if (linenum+12 >= user.pagelen) and (user.pagelen <> 0) then
      force_enter;
end;
      

(* ------------------------------------------------------------------- *)
procedure wait_for_enter;
   {prompt for [enter] key and continue - only in novice mode}
begin
   if (not expert) and (linenum >= 2) and (linenum < 1000) and (not auto_logoff) then
      force_enter;
 { par := '';
   cmdline := ''; }
end;


(* ------------------------------------------------------------------- *)
function nomore: boolean;
   {check for more output to user; returns true if user doesn't want more}
var
   pcmdline: longstring;
   ppar:     anystring;
label
   restore;

begin
   check_time_left;

   if dump_user or (linenum >= 2000) then
   begin
      nomore := true;
      exit;
   end;

   nomore := false;
   if auto_logoff then
      exit;


   {preserve command-line context since the following code "pops up" over
    what ever is running in the foreground}

   pcmdline := cmdline;
   ppar := par;

   if (linenum > user.pagelen) and (user.pagelen > 10) then
   repeat

      hotkeys_active := true;
{$IFNDEF IN_PROEDIT}
      if option <> o_logok then
         display_time(false);
      if allow_flagging then
         popup_cmdline('More:','(Enter) or (Y)es, (N)o, (F)lag, (NS)non-stop? ')
      else
         popup_cmdline('More:','(Enter) or (Y)es, (N)o, (NS)non-stop? ');
{$ELSE}
      popup_cmdline('More:','(Enter) or (Y)es, (N)o, (NS)non-stop? ');
{$ENDIF}

      linenum := 1;
      get_nextpar;
      if (par[1] = 'N') or dump_user then
      begin
         if par[2] = 'S' then
         begin
            linenum := -30000;    {go 30000 lines before stopping again}
            goto restore;
         end;

         nomore := true;
         linenum := 2000;   {flag that nomore is in effect}
         goto restore;
      end;

      if (length(par) = 0) or (par[1] = 'Y') then
         goto restore;

{$IFNDEF IN_PROEDIT}
      if par[1] = 'F' then
         flag_files;
{$ENDIF}

   until false;

   {restore original command line and parameter context}
restore:
   cmdline := pcmdline;
   par := ppar;
end;

