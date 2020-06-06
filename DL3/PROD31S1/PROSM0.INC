
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
 * ProSM0 - ProDoor System Manager - Initial installation (3-1-89)
 *
 *)

const
   destdir:     string[40] = '';
   sysdir:      string[40] = '';
   maindir:     string[40] = '';
   prodir:      string[40] = '';
   dosdir:      string[40] = '';
   holddir:     string[40] = '';
   holdlist:    string[40] = '';
   playdir:     string[40] = '';
   scrdir:      string[40] = '';
   doornum:     string[40] = '';
   dospath:     string[40] = '';
   boardcmd:    string[40] = '';
   

   {table of files to be installed into PROD directory}
   num_prod_inst = 34;
   prod_inst:  array[1..num_prod_inst] of string[12] = (
      'PROARCM',
      'PROCHAT',
      'PROCLOS',
      'PRODUMP',
      'PROENTR',
      'PROFREE',
      'PROHELP',
      'PROMAIL',
      'PROMAIL.XLT',
      'PROMAIN.XLT',
      'PROMENU',
      'PROMENUG',
      'PRONEW',
      'PRONEWG',
      'PROREAD',
      'PROREADG',
      'PROREQ',
      'PROSTRT',
      'PROUSER',
      'PROVIS',
      'CONFIG.BAT',
      'PRO-P.BAT',
      'PRO-R.BAT',
      'PRO-T.BAT',
      'PRO-V.BAT',
      'PRO-X.BAT',
      'PROARCM.BAT',
      'PROUTEST.BAT',
      'PROD.CNF',
      'CHKPATH.EXE',
      'PRODOOR.EXE',
      'PROECHO.COM',
      'PRONS.COM',
      'PROSM.EXE');

   {table of files to be installed into DOS directory}
   num_DOS_inst = 9;
   DOS_inst:  array[1..num_DOS_inst] of string[12] = (
      'DSZ.COM',
      'PCKERMIT.EXE',
      'WXFER.COM',
      'ZIPTV.EXE',
      'ARCTV.EXE',
      'LZHTV.EXE',
      'ZIPDS.EXE',
      'PROXTRA.EXE',
      'PROXZIP.EXE');


const
   setup_entries = 150;
   s_cnames = 31;
   s_network = 90;
var
   setup:    array[1..setup_entries] of string[40];

const
   cnames_entries = 33;
   c_dir = 30;
   c_doors = 21;
   c_doorsdat = 22;
var
   cnames:   array[1..cnames_entries] of string[40];


(* --------------------------------------------------------- *)
procedure load_pcboard_dat;

var
   fd:   text;
   i:    integer;
   str:  string;
   c:    char;

   procedure getline;
   begin
      if eof(fd) then
         str := ^Z
      else
         readln(fd,str);
   end;
   
begin
   str := sysdir + '\PCBOARD.DAT';
   assign(fd,str);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      displn('Can''t open '+str);
      halt(99);
   end;

   for i := 1 to setup_entries do
   begin
      getline;
      setup[i] := str;
   end;
   close(fd);

   if (setup[1][21] <> '1') or (setup[1][22] <> '4') then
   begin
      displn('Only v14.0 PCBOARD.DAT format is supported');
      displn(setup[1]);
      halt(99);
   end;

   assign(fd,setup[s_cnames]);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      displn('Can''t open CNAMES file');
      halt(99);
   end;

   for i := 1 to cnames_entries do
   begin
      getline;
      cnames[i] := str;
   end;
   close(fd);
end;


(* ------------------------------------------------------------ *)
procedure dashes;
begin
   textcolor(LightGreen);
   displn('----------------------------------------------------------');
   textcolor(White);
end;


(* ------------------------------------------------------------ *)
procedure indef(prompt:    string;
                default:   string;
                var out:   string);
   {prompt for input with default answer}
begin
   textcolor(Cyan);
   displn(prompt+':');
   textcolor(Green);
   disp('  (Enter)='''+default+'''? ');
   textcolor(White);
   input(out,40);
   if length(out) = 0 then
   begin
      out := default;
      disp(out);
   end;
   dispnl;
   dispnl;
end;

procedure indefu(prompt:   string;
                 default:  string;
                 var out:  string);
   {prompt for input with default answer, map answer to upper case}
begin
   indef(prompt,default,out);
   stoupper(out);
end;


(* ------------------------------------------------------------ *)
function yesno(what: string): boolean;
   {ask a question and return true/false}
var
   ans:  string;
begin
   repeat
      textcolor(Cyan);
      disp(what+'? (y/n) ');
      textcolor(White);
      input(ans,1);
      dispnl;
      ans[1] := upcase(ans[1]);
   until (ans[1] = 'Y') or (ans[1] = 'N');

   yesno := ans[1] = 'Y';
end;


(* ------------------------------------------------------------ *)
procedure customize(inname,outname: string);
   {edit the specified setup file according to directory settings}
var
   infd,outfd:  text;
   line:        string;
   pline:       string;

begin
   displn('Customizing '+inname+' into '+outname+' for your system...');

   assign(infd,inname);
   {$i-} reset(infd); {$i+}
   if ioresult <> 0 then
   begin
      displn('Can''t open '+inname+' !!!'^G);
      exit;
   end;

   assign(outfd,outname);
   {$i-} rewrite(outfd); {$i+}
   if ioresult <> 0 then exit;

   while not eof(infd) do
   begin
      readln(infd,line);
      pline := line;

      replace_string(line,'{playdev}',  copy(playdir,1,2));
      replace_string(line,'{proddev}',  copy(prodir,1,2));
      replace_string(line,'{sysdev}',   copy(sysdir,1,2));
      replace_string(line,'{board}',    boardcmd);
      replace_string(line,'{doornum}',  doornum);
      replace_string(line,'{dos}',      dosdir);
      replace_string(line,'{holdlist}', holdlist);
      replace_string(line,'{hold}',     holddir);
      replace_string(line,'{play}',     playdir);
      replace_string(line,'{scratch}',  scrdir);
      replace_string(line,'{prod}',     prodir);
      replace_string(line,'{sys}',      sysdir);
      writeln(outfd,line);
   end;

   close(infd);
   close(outfd);
   dispnl;
end;


(* ------------------------------------------------------------ *)
procedure addto(name, keyword, what: string);
   {add a line to a data file}
var
   fd:          text;
   line:        string;

begin
   displn('Checking your '+name+' file:');
   replace_string(what,'{doornum}',  doornum);

   assign(fd,name);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      {$i-} rewrite(fd); {$i+}
      if ioresult <> 0 then
      begin
         displn('   Can''t open or create '+name+' !!!'^G);
         dispnl;
         exit;
      end;

      displn('   File created,');
      displn('   Adding "'+what+'"');
      dispnl;
      writeln(fd,what);
      close(fd);
      exit;
   end;

   while not eof(fd) do
   begin
      readln(fd,line);
      stoupper(line);
      if pos(keyword,line) > 0 then
      begin
         displn('   Already has "'+keyword+'" ... nothing changed.');
         dispnl;
         close(fd);
         exit;
      end;
   end;
   close(fd);

   dispnl;
   displn('Your '+name+' file needs an entry for '+keyword+'.');
   if yesno('  Add it now') then
   begin
      append(fd);
      writeln(fd,what);
      close(fd);
      displn('  Adding "'+what+'"');
      displn('You will probably want to manually edit this file.');
      dispnl;
   end;
end;


(* ------------------------------------------------------------ *)
procedure makedir(dir: string);
   {create a directory}
begin
   disp('Create directory '+dir);
   {$i-} mkdir(dir); {$i+}
   if ioresult = 0 then disp(' - OK');
   dispnl;
   dispnl;
end;


(* ------------------------------------------------------------ *)
procedure copyfile(from: string);
   {copy a file}
var
   fd:      text;
   here:    string;
   dest:    string;

begin
   disp(from+' ');

   dest := destdir+'\'+from;
   assign(fd,from);
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      assign(fd,dest);
      {$i-} reset(fd); {$i+}
      if ioresult = 0 then
      begin
         close(fd);
         displn('(already present)');
      end
      else
         displn('- Can''t open !!!'^G);
      dispnl;
      exit;
   end;
   close(fd);

   getdir(0,here);
   if here = destdir then
      writeln(' Cannot be copied to itself!!!'^G)
   else
   begin
      {$i-} rename(fd,dest); {$i+}
      if ioresult = 0 then
         displn(' moved to '+dest)
      else
      begin
         copy_file(from,dest);
         displn(' copied to '+dest);
      end;
   end;

   dispnl;
end;


(* ------------------------------------------------------------ *)
function dircheck(maxlen: integer; what: string): boolean;
begin
   dircheck := false;

   if length(what) < 3 then
   begin
      displn('Too short!  You must specify a SUBDIRECTORY. (example - F:\DIR)');
      dispnl;
   end
   else

   if length(what) > maxlen then
   begin
      displn('Too long!  "'+what+'"');
      displn('will make DOS command-lines overflow!');
      dispnl;
   end

   else
      dircheck := true;
end;


(* ------------------------------------------------------------ *)
procedure initial_installation;
var
   i: integer;

begin
   opentrace('INSTALL.LOG');
   boardcmd := 'BOARD';

   dispnl;
   dashes;
   displn('             Automatic Installation Procedure');
   dashes;
   textcolor(Yellow);
   dispnl;
   displn('This program will automatically install ProDoor in most standard');
   displn('PCBoard systems.   It will add to your PCBoard files and will');
   displn('customize the ProDoor setup files.');
   dispnl;
   textcolor(LightGreen);
   displn('Before running this program, you should EXTRACT the following archives');
   displn('into the current directory (NOT your final ProDoor directory!).');
   textcolor(White);
   displn('   PRODOR31.ZIP   (The main DOOR program and supporting files)');
   displn('   PKZ102.EXE     (Archive utilities)');
   displn('   DSZ0525.ZIP    (Ymodem, Zmodem)');
   displn('   WXFR0417.ZIP   (Window Xmodem)   \___');
   displn('   PCKERM21.ZIP   (Super Kermit)    /   optional protocol drivers');
   dispnl;
   dashes;
   textcolor(LightRed);
   displn('        Type ^C at any time to abort this program');
   dashes;
   dispnl;
   
   indefu('What is your PCBoard system directory','C:\PCB',sysdir);
   load_pcboard_dat;

   indefu('Install ProDoor as what door number','1',doornum);

   repeat
      repeat
         indefu('Where will ProDoor files be stored',
               copy(sysdir,1,2)+'\PROD',prodir);
      until dircheck(12,prodir);
      dispnl;

      displn('Specify SUBDIRECTORIES on a RAMDISK if one is available...');
      dispnl;

      repeat
         indefu('Where will UPLOADS/DOWNLOADS be routed',
                  copy(sysdir,1,2)+'\PLAY',playdir);
      until dircheck(12,playdir);
      dispnl;

      repeat
         indefu('Where will SCRATCH.ZIP be routed',
                  copy(sysdir,1,2)+'\SCR',scrdir);
         ok := scrdir <> playdir;
         if not ok then
            displn('This must NOT be '+playdir+'!!!!');
      until ok and dircheck(12,scrdir);

      dispnl;
      dashes;

   until dircheck(36,prodir+' '+scrdir+' '+playdir);

   dispnl;
   displn('ProDoor routes invalid uploads to a special "holding" directory.');
   dispnl;
   indefu('Where will HELD/DUPLICATE uploads be stored',
               copy(sysdir,1,2)+'\HOLD',holddir);
   indefu('Where will HELD/DUPLICATE uploads be listed',
               cnames[c_dir]+'99',holdlist);
   makedir(holddir);
   dashes;
   dispnl;

   displn('Here is your current PATH setting:');
   displn('   '+GetEnv('PATH'));
   dispnl;
   textcolor(Yellow);
   displn('The protocol driver .EXE and .COM files directory ');
   textcolor(LightRed+blink);
   displn('*MUST* be');
   textcolor(Yellow);
   displn('included in your PATH setting.');
   dispnl;

   dospath := GetEnv('PATH');
   dosdir := copy(dospath,1,pos(';',dospath)-1);
   if length(dosdir) = 0 then
      dosdir := dospath;
   indefu('Where are your utility .EXE and .COM files stored',dosdir,dosdir);
   dashes;
   dispnl;

   if yesno('Add standard ProDoor entries to PCBoard system files now') then
   begin
      dispnl;
      addto(cnames[c_doorsdat], 'PRODOOR','PRODOOR,,1');
      addto(cnames[c_doors],    'PRODOOR','  {doornum}   ProDoor - Extended Transfer, Archive and Mail Door');
      addto(cnames[c_doors]+'G','PRODOOR','  {doornum}   ProDoor - Extended Transfer, Archive and Mail Door');
   end;
   dashes;
   dispnl;

   displn('PCBoard will not allow a default protocol that is not listed in');
   displn('PCBPROT.DAT.  In a standard ProDoor installation, you will replace');
   displn('this file with one that lists all the protocols but says "Door 1 only".');
   dispnl;
   if yesno('Install the default PCBPROT.DAT file now') then
   begin
      dispnl;
      customize('PCBPROT.INS','PCBPROT.DAT');
      destdir := sysdir;
      copyfile('PCBPROT.DAT');
      dispnl;
      displn('PCBoard generates the error message "Missing SHELL file" when a user attempts');
      displn('to use a ProDoor protocol from PCBoard.  This is normal.  If you wish, you');
      displn('can use MKPCBTXT.EXE to change the message to "Protocol not available".');
      dispnl;
   end;
   dashes;
   dispnl;

   if yesno('Install standard ProDoor files now') then
   begin
      dispnl;
      makedir(prodir);
      customize('PRODOOR.INS','PRODOOR');
      customize('PROD.INS','PROD.CNF');
      customize('CONFIG.INS','CONFIG.BAT');

      dispnl;
      destdir := sysdir;
      copyfile('PRODOOR');

      destdir := prodir;
      for i := 1 to num_prod_inst do
         copyfile(prod_inst[i]);
   end;
   dashes;
   dispnl;

   if yesno('Install Utility / Driver .COM and .EXE files now') then
   begin
      dispnl;
      destdir := dosdir;
      for i := 1 to num_DOS_inst do
         copyfile(DOS_inst[i]);
   end;
   dashes;
   dispnl;

   if yesno('Do you want CD-ROM support') then
   begin
      dispnl;
      displn('Remember to edit LIBDEF and PROLIB for your CD configuration.');
      dispnl;
      destdir := prodir;
      copyfile('LIBDEF');
      copyfile('LIBHELP');
      copyfile('PROLIB');
      copyfile('PROLIB.BAT');
   end;
   dashes;
   dispnl;
   
   if setup[s_network] = '-1' then
   begin

      while yesno('Install any additional "nodes"') do
      begin
         dispnl;
         indefu('What is the PCBoard system directory for this node',
                  sysdir,sysdir);

         load_pcboard_dat;
      
         indefu('What command is used to recycle this node',
                  boardcmd,boardcmd);
         dispnl;

         customize('PRODOOR.INS','PRODOOR');
         destdir := sysdir;
         copyfile('PRODOOR');

         dispnl;
         dashes;
         dispnl;
      end;
   end;

   dispnl;
   dashes;
   textcolor(LightRed);
   displn('                 Installation Complete!');
   dashes;
   dispnl;
   textcolor(LightGreen);
   displn('NOTES:');
   textcolor(White);
   displn(' 1. The file INSTALL.LOG is a record of the installation dialog.');
   dispnl;
   displn(' 2. Use CONFIG.BAT to configure ProDoor and update PROD.CNF.');
   dispnl;
   disp(' 3. When reporting problems, ');
   textcolor(LightRed+blink);
   displn('PLEASE INCLUDE THE FOLLOWING FILES:');
   textcolor(White);
   displn('          INSTALL.LOG, PROD.CNF, PCBOARD.DAT, CNAMES.');
   textcolor(LightGreen);
   displn('    o  Describe the EXACT error message or problem.');
   displn('    o  Give instructions for how to reproduce the problem.');
   displn('    o  Report the date and time on the original PRODOOR.EXE file.');
   dispnl;
   textcolor(LightGray);
   closetrace;
end;


