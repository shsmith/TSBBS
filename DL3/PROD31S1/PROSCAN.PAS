
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
 * PCB ProDOOR file directory scanning (3-1-89)
 *
 *)

{$i prodef.inc}
{$i proovr.inc}

unit ProScan;

interface

   Uses
     Tools,
     DosMem,
     MDosIO,
     Qread,
     ProData,
     ProRoot;


procedure dir_scan(mode:  scan_modes);


implementation


const
   scanlines = 30;

type
   blockrec = array[1..scanlines] of string;
   
var
   scanblock:  ^blockrec;
   dirmatch:   string;
   dirline:    string;
   dirkey:     anystring;
   scanmode:   scan_modes;

{$i \tinc\bline.inc}

var
   BMtable: Btable;
   

(* ------------------------------------------------------------ *)
function line_matches: boolean;
   (* see if the current dirline matches the dirkey.  return true if it does *)

begin
   case scanmode of

      by_date:
         (* verify that the dirline has a legal date *)
         if (length(dirline) < 32) or
            (dirline[29] <> '-') or
            (dirline[26] <> '-') then
            line_matches := false
         else

         (* format the date for string compare and compare dates *)
         begin
            {dirline in MM-DD-YY, dirkey in YYMMDD}
            dirmatch[0] := chr(6);
            dirmatch[1] := dirline[30];
            dirmatch[2] := dirline[31];
            dirmatch[3] := dirline[24];
            dirmatch[4] := dirline[25];
            dirmatch[5] := dirline[27];
            dirmatch[6] := dirline[28];
            line_matches := dirmatch >= dirkey;
         end;

      by_keyword:
         (* search for keywords, map to upper to ignore case *)
         begin
            line_matches := BMsearch(dirline[1],
                              length(dirline), BMtable, dirkey) > 0;
         end;

      by_name:
         (* search for wildcards *)
         line_matches := wildcard_match(dirkey,dirline);
   end;

end;


(* ------------------------------------------------------------ *)
procedure read_dirline;
begin
   qReadLn(curfd,dirline,sizeof(dirline));
   if length(dirline) = 0 then
      dirline[1] := #0;
end;

procedure scan_dirfile(n: integer);
   (* the directory file specified by PAR for the dirkey according
      to the specified scanmode *)
var
   name:     filenames;
   descr:    anystring;
   i:        integer;
   count:    integer;
   mincount: integer;

begin
   if nomore then
      exit;

   (* verify that the directory file exists *)
   get_dirn(n,name,descr);
   if not dos_exists(name) then
      exit;
   openfile(name);
   if not ok then 
      exit;

   par5 := n;
   dWHITE('Scanning Directory $5W$');
   dGREEN('  ('+descr+')');
   newline;

   (* scan each dirline in the file *)
   read_dirline;

   mincount := 2;
   count := 1;
   while (dirline[1] <> ^Z) and (linenum < 2000) do
   begin
      if (dirline[1] <> ' ') or (count > scanlines{maxlines}) then
         count := 1
      else
      if count < scanlines then
         inc(count);

      scanblock^[count] := dirline;

      (* see if the dirline matches the selection criteria *)
      if line_matches then
      begin

         (* display lines of the current scanblock that have already gone by *)
         dec(count);
         for i := 1 to count do
            if nomore = false then
               displn_dir(scanblock^[i]);

         (* process multi-dirline descriptions by listing all indented
            lines following the matching dirline *)
         repeat
            inc(count);
            if nomore = false then
               displn_dir(dirline);
            read_dirline;
         until dirline[1] <> ' ';

         if (count >= mincount) and (nomore=false) then
         begin
            newline;
(********************
            mincount := 1;    {space after single-line files also if}
*********************)
         end;                 {any multi-liners are found; otherwise don't}

         if nomore then
         begin
            closefile;
            exit;
         end;
      end
      else
         read_dirline;
   end;

   closefile;
end;


(* ------------------------------------------------------------ *)
function last_scanned_mmddyy: string8;
var
   ldate:  string8;
begin

   (* of last-scan date was today then use last-call date instead *)
   ldate := yymmdd_to_mmddyy(user.filedate);
   if ldate = todays_date_mmddyy then
      ldate := yymmdd_to_mmddyy(user.date);

   last_scanned_mmddyy := ldate;
end;


(* ------------------------------------------------------------ *)
procedure dir_scan(mode:  scan_modes);
var
   wild: boolean;
   i:    integer;

begin
   if not verify_level(par[1]) then exit;

   newline;
   scanmode := mode;

(* unstack the search dirkey, prompting when needed *)
   hotkeys_active := true;
   if length(cmdline) = 0 then
   begin
      par4 := last_scanned_mmddyy;
      if scanmode = by_date then
         get_def('Date as (mmddyy) to search from:','(S)ince or (Enter)=$4$? ')
      else
         get_defn('Enter the Text to Scan for:','(wildcards are OK) ');
      par := cmdline;   {allow multi-word if not stacked}
      dirline := cmdline;
      cmdline := '';
   end
   else
   begin
      dirline := cmdline;
      get_nextpar;
   end;

   if dump_user then exit;
   dirkey := par;


   (* automatically convert (L)ocate into (Z)ip and vice-versa *)
   wild := is_wild(dirkey);
   case scanmode of
      by_keyword:
         if wild then
            scanmode := by_name;

      by_name:
         if not wild then
            scanmode := by_keyword;
   end;


(* special processing for each kind of search specification *)
   case scanmode of
      by_date:          (* map scan dates 'S' into last-date-scanned (since) *)
         begin
            if (length(par) = 0) or (par = 'S') then       (* since? *)
               par := last_scanned_mmddyy;

            if (length(par) <> 6) then
            begin
               par := last_scanned_mmddyy;
               cmdline := dirline;
            end;

            dirkey := mmddyy_to_yymmdd(par);

            (* update last file-scan date *)
            fill_chars(user.filedate,
                       todays_date_yymmdd,
                       sizeof(user.filedate));
         end;

      by_name:          (* verify that wildcards are valid *)
         if length(dirkey) > 0 then
         begin
            if posc('.',dirkey) = 0 then
               dirkey := dirkey + dotpak;
            {if not valid_filename(dirkey) then
               dirkey := '';}
         end;

   end;

(* exit on cancel request *)
   if length(dirkey) = 0 then
      exit;


(* unstack or prompt for the directory to be selected *)
   if length(cmdline) = 0 then
   begin
      par5 := dir_count;
      get_defnh('Directories: (1-$5W$),','(A)ll, (U)pload, ');
      if (length(cmdline) = 0) then exit;
   end;

   par4 := dirkey;
   make_log_entry('Directory Scan for ($4$) ... (Ctrl-K) aborts',true);

(* prepare the key for boyer-moore search *)
   MakeTable(dirkey, BMtable);

(* scan each directory specified *)
   dos_getmem(scanblock,sizeof(scanblock^));

   while (cmdline <> '') and (not dump_user) do
   begin
      get_nextpar;

      if par[1] = 'U' then
         scan_dirfile(conf_dirs+1)
      else
      if par[1] = 'A' then
         for i := 1 to dir_count do
            scan_dirfile(i)
      else
         scan_dirfile( parn );
   end;

   dos_freemem(scanblock);

   wait_for_enter;
end;

end.

