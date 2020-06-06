
(*
 * Copyright 1987, 1992 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

{!!!IMPORTANT!!! F5 WON'T WORK WITHOUT THE FOLLOWING LINE}
{$M 20000,20000,20000}  {Stack, minheap, maxheap}
{$S-,R-}
{$L+,D+}
{$V-}

Program beta_door;

Uses
   Dos,
   MiniCrt,    {BIOS-only crt functions}
   OpenShare,  {Shared text files}
   MdosIO,     {Dos-level random access files}
   BufIO,      {Buffered record i/o}
   Tools,      {Various utilities}
   ProBye,
   ProData,    {ProDoor/pcboard data}
   ProRoot,    {ProKit main support library}
   ProSysf,    {ProKit Status display, function keys, system functions}
   ProScan,    {File display and colorization}
   ProUtil,    {ProKit utility library #1}
   ProUtil2,   {proKit utility library #2}
   KitInit;    {ProKit initialization/deinit}

const
   door_version = 'Automatic Beta Distribution DOOR v1.6 (07-13-93)';
   max_proto = 10;
   max_file_count = 20;
   protocol_count:  integer = 0;
   file_count:  integer = 0;
   logfile = 'PROBETA.LOG';

var
   protocol_name: array[1..max_proto] of string[40];
   protocol_cmd:  array[1..max_proto] of string[128];

   file_descr:    array[1..max_file_count] of string[255];
   file_path:     array[1..max_file_count] of string[64];

   sel_prot:      byte;
   sel_file:      byte;

   user_name:     anystring;
   user_city:     anystring;


(* ---------------------------------------------------------------- *)
procedure load_config;
var
   fd:   text;
   i:    integer;
   temp: string;

begin
   assignText(fd,config_file);
   reset(fd);

   readln(fd);   {interrupt}

   readln(fd,protocol_count);
   for i := 1 to protocol_count do
   begin
      readln(fd,protocol_name[i]);
      readln(fd,protocol_cmd[i]);
   end;

   readln(fd,file_count);
   for i := 1 to file_count do
   begin
      readln(fd,file_descr[i]);
      repeat
         readln(fd,temp);
         if temp[1]='|' then
            file_descr[i] := file_descr[i] + temp;
      until temp[1] <> '|';

      file_path[i] := temp;
   end;

   close(fd);
end;



(* ---------------------------------------------------------------- *)
function itoa2(i: integer): anystring;
var
   s: anystring;
begin
   str(i,s);
   if length(s) = 1 then
      s := '0' + s;
   itoa2 := s;
end;


(* ------------------------------------------------------------ *)
procedure log_download(entry: anystring);
   (* make an entry in the download log file *)
var
   fd:    text;
begin
   assignText(fd,'PROBETA.LOG');
   {$i-} append(fd); {$i+}
   if ioresult = 0 then
   begin
      writeln(fd,entry);
      close(fd);
   end;

   if pcbsetup.tranlog_path^= '' then exit;
   assignText(fd,pcbsetup.tranlog_path^);
   {$i-} append(fd); {$i+}
   if ioresult = 0 then
   begin
      writeln(fd,entry);
      close(fd);
   end;
end;


(* ---------------------------------------------------------------- *)
procedure report_dszlog;
var
   tail:    anystring;
   fd:      text;
   code:    char;
   size:    real;
   speed:   real;
   errors:  real;
   p:       integer;
   name:    anystring;

begin
   newline;

   if dos_exists(GetEnv('DSZLOG')) then
   begin
      assign(fd,GetEnv('DSZLOG'));
      reset(fd);
      while not eof(fd) do
      begin
         readln(fd,tail);
         {make_log_entry(tail,false);}
         cmdline := tail;

         code := cmdline[1];   {upper case=receive, lower case=transmit}
         delete(cmdline,1,2);
         stoupper(cmdline);

         get_nextpar;   size := atol(par);
         get_nextpar;   {nnn}
         get_nextpar;   {'bps'}
         get_nextpar;   speed  := atof(par);
         get_nextpar;   {'cps'}
         get_nextpar;   errors := parn;
         get_nextpar;   {'errors'}
         get_nextpar;   {flow count}
         get_nextpar;   {block size}

         get_nextpar;   delete_trailing_spaces(par);
                        name := '';
                        for p := 1 to length(par) do
                           case par[p] of
                              '/','\':
                                 name := '';
                              else
                                 name := name + upcase(par[p]);
                           end;

         get_nextpar;   {serial number}

         par3 := name;
         par4 := copy(protocol_name[sel_prot],1,1);
         par5 := trunc(errors);
         par6 := trunc(speed) and $FFFF;

         case code of
            'e','E','l','L','U':
               make_log_entry('(D) $3$ Aborted using $4$  T/E=$5W$', true)
            else

            begin
               make_log_entry('(D) $3$ Completed using $4$  T/E=$5W$  CPS=$6W$', true);

               log_download('(D),'+user_name+','+
                           system_mm+'-'+system_dd+'-19'+system_yy+
                           ','+system_time+ ','+par3+','+ par4+
                           ', '+ftoa(errors,0,0)+' , '+ftoa(speed,0,0));
            end;
         end;
      end;

      close(fd);
      erase(fd);
   end;

end;

(* ---------------------------------------------------------------- *)
function execute(cmd: anystring): integer;
var
   exe:     anystring;
   key:     anystring;
   tail:    anystring;
   i:       integer;

   function try(ext: anystring): boolean;
   begin
      exe := FSearch(key+ext,GetEnv('PATH'));
      try := exe = '';
   end;

begin
   prepare_line(cmd);

   i := pos(' ',cmd);
   key := copy(cmd,1,i-1);
   tail := copy(cmd,i+1,255);

   if try('.com') then
   if try('.exe') then
   begin
      tail := '/c '+tail;
      exe := GetEnv('COMSPEC');
   end;

   writeln('Command: ',exe,' ',tail);
   writeln;

   dos_unlink(GetEnv('DSZLOG'));

   linenum := 1;
   update_status_display(normal_format);

   flush_com;
   exec(exe,tail);
   execute := DosExitCode;

   linenum := 1;
   update_status_display(normal_format);
   newline;
end;

(* ---------------------------------------------------------------- *)
procedure main;
var
   i,j:     integer;
   DirInfo: SearchRec;
   Date:    DateTime;
   fnames:  anystring;
   fpaths:  anystring;
   temp:    string;

begin
   display_file('PROBETA.TXT');

   if copy(username,1,5) <> 'OPEN ' then
   begin
      user_name := username;
      user_city := user.city;
      delete_trailing_spaces(user_name);
      delete_trailing_spaces(user_city);
      force_enter;
   end

   else
   begin
      repeat
         pdisp('$YELLOW$Please enter your first AND last name: ');
         user_name := '';
         input(user_name,30);
         newline;

         if dump_user then exit;
         stoupper(user_name);
      until (length(user_name) > 3) and (pos(' ',user_name) > 1);

      repeat
         pdisp('$YELLOW$Please enter your city AND state or country: ');
         user_city := '';
         input(user_city,30);
         newline;

         if dump_user then exit;
         stoupper(user_city);
      until (length(user_city) > 3) and (pos(',',user_city)+pos(' ',user_city) > 1);

      username := user_name;
      fill_chars(user.city,user_city,sizeof(user.city));

      make_log_entry('User: ' + user_name + ' ('+user_city+')',false);

      set_node_info(node_in_door,user_name,user_city,'Running ProBeta');
   end;

   newline;
   cmdline := '';
   pdispln('$DEFAULT$Files available:');
   newline;
   displn(' #    File Name   Updated                   Description');
   displn('---  ------------ -------- --------------------------------------------');

   for i := 1 to file_count do
   begin
      FindFirst(file_path[i],$21,DirInfo);
      if DosError = 0 then
      begin
         file_path[i] := path_only(file_path[i])+'\'+DirInfo.name;
         UnpackTime(DirInfo.Time, Date);

         disp( aGREEN+  rjust(itoa(i),2)+'   '+
               aWHITE+  ljust(DirInfo.name,13)+
               aRED+    itoa2(Date.Month)+'-'+
                        itoa2(Date.Day)+'-'+
                        itoa2(Date.Year-1900)+' '+
               aWHITE);

         temp := file_descr[i];
         repeat
            j := pos('|',temp);
            if j = 0 then
               displn(temp)
            else
            begin
               displn(copy(temp,1,j-1));
               disp('                           '+aGRAY);
               temp := copy(temp,j+1,255);
            end;
         until j = 0;
      end;
   end;

   newline;
   fpaths := '';
   fnames := '';
   repeat
      sel_file := 1;
      get_int('Please select the file NUMBER(s) to download:',sel_file);
      if dump_user or (sel_file = 0) then
         exit;
      if (sel_file < 1) or (sel_file > file_count) then
         displn('Invalid file number! '+itoa(sel_file))
      else
      begin
         fpaths := fpaths + ' ' + file_path[sel_file];
         fnames := fnames + ' ' + remove_path(file_path[sel_file]);
      end;
   until (cmdline = '') and (fnames <> '');
   newline;

   repeat
      cmdline := '';
      displn('Protocols available:');
      newline;
      displn(' #                  Description');
      displn('---  -----------------------------------------');

      for i := 1 to protocol_count do
         displn(aGREEN+' '+itoa(i)+'     '+aWHITE+protocol_name[i]);

      newline;
      sel_prot := 1;
      get_int('Please select the protocol NUMBER you wish to use:',sel_prot);
      newline;
      if dump_user or (par = '0') then exit;

      if par <> '' then
      begin
         sel_prot := atoi(par);

         if sel_prot = 0 then
            for i := 1 to protocol_count do
               if upcase(par[1]) = upcase(protocol_name[i][1]) then
                  sel_prot := i;
      end;

   until (sel_prot > 0) and (sel_prot <= protocol_count);

   par2 := fnames;
   par3 := protocol_name[sel_prot];
   pdispln('$WHITE$Begin your download of$2$ using $3$ NOW ...');
   newline;

   clrscr;
   writeln('User: ',user_name,' (',user_city,')');

   {set_node_info(node_in_door,user_name,user_city,'Downloading'+fnames);}
   i := execute(protocol_cmd[sel_prot] + ' ' + fpaths);

   newline;
   if i = 0 then
      pdispln('$GREEN$File transfer completed successfully.')
   else
      pdispln('$RED$File transfer ABORTED!');

   report_dszlog;
end;

(* ---------------------------------------------------------------- *)

begin  {main block}
   init;     {must be first - opens com port, loads setup and user data}
   progname := 'ProBeta';        {program name on status line}

   if minutes_left < 5 then
      adjust_time_allowed(5*60);  {give 5 free minutes for entering this door}

   {auto_detect_ansi;}

   load_config;

   newline;
   pdispln('$YELLOW$'+door_version);
   displn('Copyright 1993 Samuel H. Smith');
   newline;

   main;

   {prevent user file updates}
   pcbsys_changed := false;
   user_changed := false;

   uninit;   {must be last - closes com port and updates database}
end.


