
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
 * ProSM - ProDoor System Manager - Main Module (3-1-89)
 *
 *)

{$i prodef.inc}
{$DEFINE IN_PROCONF}
{$M 16000,12000,12000}  {Stack(min=12), minheap(min=40), maxheap}
{$l+,d+}

program ProSM;

uses Dos,Crt,DosMem,MdosIO,OpenShare,Bufio,Qread,Tools,DispEdit {,Helpme};
     
const
   copyright:        string[80] = 'ProDoor System Manager v3.1 (C) 1989 Samuel H. Smith; ALL RIGHTS RESERVED';

   message_capture = false;
   local = false;
   bios_comm:  boolean = true;  {use bios for com port i/o}
   bios_echo:  boolean = true;  {echo com port to screen in bios mode?}

   { i prosmhlp.inc}

   {$i \tinc\readbas.dcl}
   {$i \tinc\ansicolr.dcl}

   {$I proconf.dcl}     {configuration file declarations}
   {$I extuser.dcl}     {extended user file declarations}
   {$I proint.dcl}      {pcboard 14.0 interface declarations}

type
   msgs_header = record
      himsg:    single;    {highest message on file}
      lowmsg:   single;    {low msg number in message base}
      msgcnt:   single;    {number of active messages}
      callers:  single;    {number of callers on system}
      lockflag: char6;     {LOCKED if file being updated}
      fill1:    array[1..106] of char; {reserved for future use}
   end;

   index_block = array[1..1024] of single;

var
   ok:            boolean;
   par:           string;
   par3:          string;
   cnf:           config_rec;
   pcbsetup:      pcbsetup_rec;
   sys_dir:       string65;
   home_dir:      string65;
   config_file:   string65;
   control:       control_table;
   curctl:        sysop_control_rec;
   curfun:        char;

{used by prosm2}
   confd:         file of pcbconf_rec;
   conf:          pcbconf_rec;
   maxcn:         integer;
   needcls:       boolean;
   fname:         filenames;
   editor:        filenames;

{used by prosm3}
   usrfd:         buffered_file;
   user:          pcb_user_rec;
   usern:         integer;
   maxuser:       integer;
   user_file:     filenames;
   cnames_file:   filenames;
   extuser_file:  filenames;
   confinfo_file: filenames;
   extfd:         dos_handle;
   extuser:       extuser_rec;
   extcount:      byte;
   extsize:       word;
   extn:          integer;
   basecn:        integer;
   pcbsys:        pcb_sys_rec;



(* -------------------------------------------------- *)
procedure usage(why: string);
begin
   clear_screen;
   dispnl;
   displn('Error: '+why);
   dispnl;
   displn('Usage:   ProSM <configfile> <userfile>');
   dispnl;
   displn('  <configfile> defaults to '+config_file);
   displn('  <userfile>   defaults to '+user_file);
   dispnl;
   displn('Example: ProSM PROD.CNF C:\PCB\MAIN\USERS');
   dispnl;
   displn('This program must be run from your ProDoor directory.');
   dispnl;
   displn('Use "SET EXTUSER=path\name"  to locate EXTUSER  data file.');
   displn('Use "SET CONFINFO=path\name" to locate CONFINFO data file.');
   halt(99);
end;

procedure file_missing;
begin
   usage('Missing data file');
end;

procedure make_log_entry(message: string; echo: boolean);
begin
   usage(message);
end;

procedure pause;
begin
   dispnl;
   disp(^G'Press (Enter) to continue: ');
   readln;
   writeln;
end;


(* -------------------------------------------------- *)
procedure initialize;
begin
   config_file := 'PROD.CNF';
   user_file := '\PCB\MAIN\USERS';

   extuser_file := GetEnv('EXTUSER');
   if extuser_file = '' then
      extuser_file := 'EXTUSER';

   confinfo_file := GetEnv('CONFINFO');
   if confinfo_file = '' then
      confinfo_file := 'CONFINFO';

   if paramcount > 0 then
      config_file := paramstr(1);
   if paramcount > 1 then
      user_file := paramstr(2);

   cnames_file := path_only(user_file)+'\CNAMES';
   sys_dir := '';

   editor := GetEnv('EDITOR');
   if editor = '' then
      editor := 'Q';

   fillchar(pcbsetup,sizeof(pcbsetup),0);
   fillchar(cnf,sizeof(cnf),0);
   fillchar(control,sizeof(control),0);
end;


(* -------------------------------------------------- *)
procedure title_screen(y1,y2: integer; title: string);
begin
   if needcls then
   begin
      needcls := false;
      clear_screen;
      textcolor(Green);
      display_border(1,y1,79,y2,mixed_border);

      textcolor(Yellow);
     {gotoxy(68,24);
      disp('F1  [help]');}

      gotoxy(68,25);
      disp('ESC [exit]');
   end;

   textcolor(Yellow);
   gotoxy(20,1);
   write('':15-length(title) div 2,'ProDoor: ',title);
   clreol;
   textcolor(White{LightCyan});
end;


(* -------------------------------------------------- *)
procedure disp_int(x,y,n: word);
var
   buf:  string[5];

begin
   str(n,buf);
   while length(buf) < 5 do
   begin
      inc(buf[0]);
      buf[length(buf)] := ' ';
   end;

   gotoxy(x,y);
   disp(buf);
end;


(* -------------------------------------------------- *)
procedure edit_bit(func:      edit_functions;
                   x,y:       integer;
                   prompt:    anystring;
                   bit:       integer;
                   var flags: byte;
                   var ex:    char);
var
   value:  boolean;
begin
   value := getflag(flags,bit);
   edit_yesno (func,x,y,prompt,value,ex);
   setflag(flags,bit,value);
end;


(* -------------------------------------------------- *)
procedure edit_text(fname: filenames; ex: char);
begin
   if (fname <> '') and (fname[length(fname)] = #0) then
      dec(fname[0]);
   if ex = F3 then
      fname := fname + 'G';
   exec(GetEnv('COMSPEC'),' /C '+editor+' '+fname);
   needcls := true;
end;

procedure list_dir(fname: filenames);
begin
   needcls := true;
end;


(* -------------------------------------------------- *)

{$i \tinc\readbas.inc}
{$i \tinc\movefile.inc}

{$i extuser.inc}

{$i proconf.inc}     {load config file}

{$i prosm0.inc}      {initial installation}

{$i prosm1.inc}      {edit config file}

{$i prosm2.inc}      {edit extconf file}

{$i prosm3.inc}      {edit extended user file}

{$i prosm4.inc}      {generate packall.bat}

{$i prosm5.inc}      {insert/remove group}

{$i prosm6.inc}      {pack extuser file}

{$i prosm7.inc}      {renumber conference}


(* -------------------------------------------------- *)
procedure main;
const
   maxent = 8;  {entries on screen}
var
   pentry:  integer;
   entry:   integer;
   ex:      char;

   procedure proc_entry(func:  edit_functions);
   begin
      case entry of
         1: edit_funkey (func, 24, 6, '  A - Edit Configuration File      ','A',ex);
         2: edit_funkey (func, 24, 8, '  B - Edit Conference Definitions  ','B',ex);
         3: edit_funkey (func, 24,10, '  C - Edit Extended User Data      ','C',ex);
         4: edit_funkey (func, 24,12, '  D - Generate ProPack Batch File  ','D',ex);
         5: edit_funkey (func, 24,14, '  E - Insert Group Conference      ','E',ex);
         6: edit_funkey (func, 24,16, '  F - Remove Group Conference      ','F',ex);
         7: edit_funkey (func, 24,18, '  G - Pack Extended User File      ','G',ex);
         8: edit_funkey (func, 24,20, '  H - Renumber Conferences         ','H',ex);
      end;

      select_next_entry(func,entry,maxent,ex);
   end;

begin
   pentry := 1;

   repeat
      needcls := true;
      title_screen(3,23,'System Manager - MAIN MENU  ProSm 3.1');
      gotoxy(2,25);
      disp('Enter [select function]');

      for entry := 1 to maxent do
         proc_entry(display);

      ex := DOWN;
      entry := pentry;
      repeat
         proc_entry(edit);
      until (ex <> UP) and (ex <> DOWN);
      pentry := entry;

      case upcase(ex) of
        {F1:   help(8,8,'Main Menu');}
         'A':  edit_config_file;       {prosm1.inc}
         'B':  edit_extconf_file;      {prosm2.inc}
         'C':  edit_extuser_file;      {prosm3.inc}
         'D':  generate_propack_batch; {prosm4.inc}
         'E':  insert_group(true);     {prosm5.inc}
         'F':  insert_group(false);    {prosm5.inc}
         'G':  pack_extuser_file;      {prosm6.inc}
         'H':  renumber_conference;    {prosm7.inc}
      end;
   until ex = ESC;
end;


(* -------------------------------------------------- *)
begin
   writeln(copyright);
   textbackground(black);
   textcolor(white);

   if paramstr(1) = '/INSTALL' then
      initial_installation
   else
   begin
      initialize;
      load_config_file;
      main;
      clear_screen;
      save_config_file;
   end;
end.


