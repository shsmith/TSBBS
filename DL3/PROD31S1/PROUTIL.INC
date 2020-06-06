
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
 * PCB ProDOOR Utility procedures   (3-1-89)
 *
 *)

function expert: boolean;
   (* is this user an expert *)
begin
   expert := user.expert = 'Y'; {getflag(user.flags,flag_expert);}
end;


(* ------------------------------------------------------------ *)
function scan_nextpar(var cmdline: string): string;
   (* get the next space or ';' delimited part of a command line
      and return it (removing the string from the command line) *)
var
   i:      integer;
   par:    anystring;

begin
   fillchar(par,sizeof(par),0);
   delete_leading_spaces(cmdline);
   delete_trailing_spaces(cmdline);

   (* find the end of the next word *)
   i := 1;
   while (i <= length(cmdline)) and (cmdline[i] > ' ') and
         (cmdline[i] <> ';') and (cmdline[i] <> ',') do
      inc(i);

   (* copy the word to the next param and delete it from the command line *)
   par := copy(cmdline,1,i-1);
   delete(cmdline,1,i);

   scan_nextpar := par;
end;


(* ------------------------------------------------------------ *)
procedure get_nextpar;
   (* get the next space or ';' delimited part of the command line
      and move it to 'par' *)
begin
   fillchar(par,sizeof(par),0);
   par := scan_nextpar(cmdline);
   parn := atoi(par);
end;

(* ------------------------------------------------------------ *)
procedure unget_par;
   (* put par back into cmdline *)
begin
   if par <> '' then
      cmdline := par + ' ' + cmdline;
   delete_trailing_spaces(cmdline);
end;


(* ------------------------------------------------------------ *)
procedure not_understood;
begin
   newline;
   par3 := par;
   pdisp('($3$) not understood.  Type ');
   if expert then
      disp('(X) for menu, ');
   displn('(?) for help.');
   force_enter;
end;


(* ------------------------------------------------------------ *)
procedure not_available;
begin
   par3 := par;
   make_log_entry('Sorry, ($3$) is not available.',true);
   force_enter;
end;


(* ------------------------------------------------------------ *)
procedure file_not_found (name: anystring);
   (* display error about missing files *)
begin
   par3 := name;
   make_log_entry('($3$) not found on disk!',true);
end;


(* ------------------------------------------------------------ *)
procedure file_missing;
begin
   usage('Can''t open: '+dos_name);
end;


(* ------------------------------------------------------------ *)
procedure keypause;
var
   i: integer;
   c: char;

begin
   write('(15 second delay) Press (Enter): '^G^G);

   for i := 1 to 150 do   {15 second delay unless key pressed}
      if not keypressed then
         delay(100);
end;


(* ------------------------------------------------------------ *)
function pro_command: anystring;
begin
   pro_command := cnf.protocol_table[protocol].command^ ;
end;

function pro_title: anystring;
begin
   pro_title := cnf.protocol_table[protocol].title^ ;
end;

function pro_code: char;
begin
   pro_code := cnf.protocol_table[protocol].code ;
end;

function pro_files: integer;
begin
   if protocol < 1 then
      pro_files := 1
   else
      pro_files := cnf.protocol_table[protocol].files;
end;

function pro_mode: transfer_modes;
begin
   if protocol < 1 then
      pro_mode := TX
   else
      pro_mode := cnf.protocol_table[protocol].mode;
end;


function estimated_time(size: longint): real;
var
   effic: real;
begin

{$IFNDEF IN_PROEDIT}
   if protocol < 1 then
      effic := default_peffic
   else
      effic := cnf.protocol_table[protocol].peffic;
      
   if effic = 0 then
      estimated_time := 0  {special case for -resume}
   else
      estimated_time := int(size) / topcps / 60.0 / effic;
{$ENDIF}

end;


(* ------------------------------------------------------------ *)

procedure open_capture;
begin
   {writeln('[Output captured in ',journal_file,']');}
   assignText(dbfd,journal_file);
   {$i-} append(dbfd); {$i+}
   setdebug := ioresult = 0;
end;


procedure close_capture;
begin
   if setdebug then
   begin
      {$i-} close(dbfd); {$i+}
      setdebug := (ioresult = 0) and false;
      {writeln('[File output closed]');}
   end;
end;


(*-----------------------------------------------------------------*)
procedure clean_directory(dir: filenames; pattern: filenames);
var
   i: integer;
begin
   cons_path(dos_name,dir,pattern+'*.*');
   getfiles(dos_name, filetable, filecount);

{writeln('[clean directory, pattern=',dos_name,' count=',filecount,']');}
   for i := 1 to filecount do
      dos_unlink(filetable[i]^);
end;

(*-----------------------------------------------------------------*)
procedure clean_playpen;
   {clean out anything left in the playpen}
begin
   clean_directory(cnf.playpen_dir,'');
end;


(*-----------------------------------------------------------------*)
procedure clean_scratch;
   {remove all old scratch files}
begin
   clean_directory(cnf.scratch_dir,''{cnf.scratch_prefix});
   {clean_directory(cnf.scratch_dir,cnf.mail_prefix);}
   clean_directory(cnf.playpen_dir,cnf.mail_prefix);
end;


(*-----------------------------------------------------------------*)
procedure disp_margin(left,width: integer);
var
   buf:  string80;
begin
   spaces(left);
   dWHITE('(');

   fillchar(buf[1],width,'-');
   buf[0] := chr(width);
   disp(buf);

   dispc(')');
   displn(YELLOW);
end;


(*-----------------------------------------------------------------*)
function expdate(yymmdd: string8): string8;     {convert yymmdd to mm-dd-yy}
const
   tmp:  string8 = '  -  -  ';
begin
   tmp[1] := yymmdd[3];
   tmp[2] := yymmdd[4];     {there MUST! be a better way!}
   tmp[4] := yymmdd[5];
   tmp[5] := yymmdd[6];
   tmp[7] := yymmdd[1];
   tmp[8] := yymmdd[2];
   expdate := tmp;
end;


(*-----------------------------------------------------------------*)
function mmddyy_to_yymmdd(mmddyy: string8): string8;
var
   yymmdd:  string8;
begin
   yymmdd[0] := chr(6);       {        123456      123456}
   yymmdd[1] := mmddyy[5];    {convert MMDDYY into YYMMDD}
   yymmdd[2] := mmddyy[6];
   yymmdd[3] := mmddyy[1];
   yymmdd[4] := mmddyy[2];
   yymmdd[5] := mmddyy[3];
   yymmdd[6] := mmddyy[4];
   mmddyy_to_yymmdd := yymmdd;
end;


(*-----------------------------------------------------------------*)
function yymmdd_to_mmddyy(yymmdd: string8): string8;
var
   mmddyy:  string8;
begin
   mmddyy[0] := chr(6);       {        123456      123456}
   mmddyy[1] := yymmdd[3];    {convert YYMMDD into MMDDYY}
   mmddyy[2] := yymmdd[4];
   mmddyy[3] := yymmdd[5];
   mmddyy[4] := yymmdd[6];
   mmddyy[5] := yymmdd[1];
   mmddyy[6] := yymmdd[2];
   yymmdd_to_mmddyy := mmddyy;
end;


(*-----------------------------------------------------------------*)
function todays_date_mmddyy: string8;
begin
   todays_date_mmddyy := system_mm + system_dd + system_yy;
end;

function todays_date_yymmdd: string8;
begin
   todays_date_yymmdd := system_yy + system_mm + system_dd;
end;


(*-----------------------------------------------------------------*)
function dtok(d: double): string8;
begin
   dtok := ltoa(dtol(d) div longint(1024));
end;

function stok(s: single): string8;
begin
   stok := ltoa(stol(s) div longint(1024));
end;


(* ------------------------------------------------------------- *)
function posc(c: char; var s: string): integer;
begin
   posc := pos(c,s);
end;


(* ------------------------------------------------------------- *)
procedure check_command_line(var command: string);
begin
   if length(command) > 125 then
   begin
      make_log_entry('WARNING: COMMAND LINE TOO LONG!',true);
      make_log_entry(command,true);
      make_log_entry('PLEASE RE-CONFIGURE TO USE SHORTER DIRECTORY NAMES.',true);
      command := '';
   end
end;


(* ------------------------------------------------------------- *)
procedure execute(command: string);
begin
   newline;
   dGREEN('Processing your request.  Please wait ...');
   newline;
   default_color;
   flush_com;

   prepare_line(command);
{   writeln(command); }

   command := '/c '+command;
   check_command_line(command);
   if command <> '' then
      exec(comspec,command);

   cmdline := '';
   update_status_display(normal_format);
   display_resultfile;
end;


(* ------------------------------------------------------------- *)
procedure disconnect_warning(left: integer);
begin
   if left < 0 then
      par5 := 0
   else
      par5 := left;
   dRED('Warning: Automatic disconnect in ($5W$) minute');

   if left = 1 then
      displn('! ')
   else
      displn('s! ');
end;


(* ------------------------------------------------------------- *)
procedure check_disconnect_warning;
var
   left: integer;
const
   pleft: integer = 99;
begin

{$IFNDEF IN_PROEDIT}
   (* display a warning if time is about to run out *)
   left := minutes_left;
   if (left <> pleft) and (option = o_none) then
   begin
      pleft := left;
      if left < 5 then
      begin
         erase_prompt(0);
         {newline;}
         disconnect_warning(left);
         beep;
         force_new_prompt;
      end;
   end;
{$ENDIF}

end;


(* ------------------------------------------------------------- *)
function file_is_new(name: dos_filename): boolean;
var
   DirInfo:     SearchRec;
   Stamp:       DateTime;
const
   fdate:       string8 = 'yymmdd';
   ftime:       string8 = 'hh:mm';

begin
   FindFirst(name,$21,DirInfo);
   if (DosError <> 0) then
      file_is_new := false
   else

   begin
      UnpackTime(DirInfo.time, Stamp);
      fdate := strval(Stamp.year-1900)+strval(Stamp.month)+strval(Stamp.day);
      ftime := strval(Stamp.hour)+':'+strval(Stamp.min);

      if fdate = user.date then
         file_is_new := ftime >= user.time
      else
         file_is_new := fdate >= user.date;
   end;

end;


