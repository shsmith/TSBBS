
(*
 * cp - unix like file copy
 *
 * shs 8/5/85
 * version 2, shs 5/14/86
 * version 3, shs 8/10/87
 * version 4, shs 7/13/89
 *
 * Copyright (C) 1987, 1989 Samuel H. Smith, 8/5/85 (rev. 13-Jul-89)
 *
 *
 * Disclaimer
 * ----------
 *
 * I cannot be responsible for any damages resulting from the use or mis-
 * use of this program!
 *
 * If you have any questions, bugs, or suggestions, please contact me at
 * The Tool Shop,  (602) 279-2673.
 *
 * Enjoy!     Samuel H. Smith
 *
 *
 *)

{$v-,s-}

uses dos, mdosio, tools;

const
   version = 'CP - Unix-like file copy (v4.0, 07-15-89)';

   buf_size =        $F000;
   bufsiz:           word = buf_size;

   update_newer:     boolean = false;
   replace_readonly: boolean = false;
   require_existing: boolean = false;

type
   anystring = string[80];

var
   buf:      array[1..buf_size] of byte;
   cur_dir:  anystring;


(* -------------------------------------------------------- *)
procedure translate(var str: anystring; old, new: char);
var
   i: integer;
begin
   for i := 1 to length(str) do
      if str[i] = old then
         str[i] := new
      else
         str[i] := upcase(str[i]);
end;


(* -------------------------------------------------------- *)
procedure addslash(var name: anystring);
begin
   if (name[length(name)] <> '\') and (name[length(name)] <> ':') then
   begin
      inc(name[0]);
      name[length(name)] := '\';
   end;
end;


(* -------------------------------------------------------- *)
procedure makepath(var name: anystring; dir: anystring);
var
   i:    integer;
   rest: anystring;

begin

(* make sure device is specified in pathname *)
   if name[1] = '\' then
      name := copy(dir,1,2) + name
   else

(* make sure pathname is absolute *)
   if name[2] <> ':' then
      name := dir + name;

(* remove references to current directory *)
   i := pos('\.\',name);
   while i > 0 do
   begin
      name := copy(name,1,i) + copy(name,i+3,length(name));
      i := pos('\.\',name);
   end;

(* remove references to parent directory *)
   i := pos('\..\',name);
   while i > 0 do
   begin
      rest := copy(name,i+4,length(name));
      i := i - 1;

      while (name[i] <> '\') and (i > 2) do
         i := i - 1;

      name := copy(name,1,i) + rest;

      i := pos('\..\',name);
   end;

(* change absolute into relative if possible *)
(*******
   if copy(name,1,length(cur_dir)) = cur_dir then
      name := copy(name,length(cur_dir)+1,length(name));
********)

end;


(* -------------------------------------------------------- *)
procedure copyfile(len: integer; inName, outName: anystring);
var
   infd:    dos_handle;
   outfd:   dos_handle;
   length:  longint;
   total:   longint;
   incnt:   word;
   time:    word;
   date:    word;
   attr:    word;
   otime:   word;
   odate:   word;
   oattr:   word;
   Info:    SearchRec;
   F:       file;

begin
   translate(inName,'\','/');
   stolower(inName);
   translate(outName,'\','/');
   stolower(outName);

   if inName = outName then
   begin
      write(^G'cp: Input and output names [',inName,'] must be different.');
      exit;
   end;

   infd := dos_open(inName, open_read);
   dos_file_times(infd, time_get, time, date);
   oattr := 0;

   if dos_exists(outName) then
   begin
      if update_newer then
      begin
         outfd := dos_open(outName, open_read);
         if outfd <> dos_error then
         begin
            dos_file_times(outfd, time_get, otime, odate);
            dos_close(outfd);

            if (date = odate) and (time = otime) then
            begin
               write(outName,' is up to date.');
               dos_close(infd);
               exit;
            end;

            if (date < odate) or ((date = odate) and (time <= otime)) then
            begin
               write(outName,' is newer.');
               dos_close(infd);
               exit;
            end;
         end;
      end;

      if replace_readonly then
      begin
         FindFirst(outName,AnyFile,Info);
         oattr := Info.attr and (ReadOnly or Hidden);
         if oattr <> 0 then
         begin
            assign(F,outName);
            SetFAttr(F, 0);
            if DosError <> 0 then
            begin
               write(^G'cp: Can''t clear attributes on [',outName,'].');
               dos_close(infd);
               exit;
            end;
         end;
      end;
   end
   else

   if require_existing then
   begin
      write(outName,' does not exist.');
      dos_close(infd);
      exit;
   end;

   dos_lseek(infd, 0, seek_end);
   length := dos_tell;

   dos_lseek(infd, 0, seek_start);

   write(inName,'':12-len,' -> ', outName,' ','':12-len);

   outfd := dos_create(outName);
   if outfd = dos_error then
   begin
      writeln;
      writeln(^G'cp: Can''t create output file [',outName,'].');
      halt(1);
   end;

   total := 0;
   repeat
      incnt := dos_read(infd, buf, bufsiz);

      if incnt <> 0 then
      begin
         dos_write(outfd, buf, incnt);
         total := total + longint(incnt);
         write('.');
      end;
   until (incnt <> bufsiz) or (dos_write_err);

   dos_close(infd);

   dos_file_times(outfd, time_set, time, date);
   dos_close(outfd);

   if dos_write_err then
   begin
      writeln;
      write(^G'cp: I/O error!  Destination [',outName,'] deleted.');
      dos_unlink(outName);
      exit;
   end;

   {restore original attributes if needed}
   if oattr <> 0 then
   begin
      if (oattr and ReadOnly) <> 0 then write(' R/O');
      if (oattr and Hidden)   <> 0 then write(' Hid');
      assign(F,outName);
      GetFAttr(F, attr);
      SetFAttr(F, oattr or attr);
      if DosError <> 0 then
         write(^G'cp: Can''t set attributes on [',outName,'].');
   end;

end;


(* -------------------------------------------------------- *)
procedure procfile(source:   anystring;
                   dest:     anystring);
var
   outname:    anystring;
   len:        integer;

begin
   makepath(source,cur_dir);
   outname := remove_path(source);
   len := length(outname);

   makepath(outname,dest);

   copyfile(len, source, outname);
   writeln;
end;


(* -------------------------------------------------------- *)
procedure procparam(pattern: anystring;
                    dest:    anystring);
var
   i:   integer;

begin
   translate(pattern,'/','\');
   translate(dest,'/','\');
   if pattern[1] = '-' then exit;

   addslash(dest);

   makepath(pattern,cur_dir);

   getfiles(pattern,filetable,filecount);
   for i := 1 to filecount do
      procfile(filetable[i]^,dest);
end;


(* -------------------------------------------------------- *)
procedure usage(why: string);
begin
   writeln(version);
   writeln('Copyright (C) 1987, 1989 Samuel H. Smith; All rights reserved.');
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
   writeln;
   writeln(^G'Error: ',why);
   writeln;
   writeln('Usage:');
   writeln('  cp {OPTIONS} SOURCE DEST');
   writeln('  cp SOURCE1 SOURCE2 ... SOURCEn DEST');
   writeln('  cp SOURCE');
   writeln;
   writeln('Options:');
   writeln('  -U updates destination only if source is newer');
   writeln('  -E copy only if destination file already exists');
   writeln('  -R allows read-only destination to be replaced');
   writeln('  -2 reduces buffering to 2k blocks (-6 = 6k, -8 = 8k)');
   writeln;
   writeln('Examples:');
   writeln('  cp a:*.arc             ;copies all .arc files into current dir');
   writeln('  cp /pcb/main/*.* /pcb/gen/*.* d:/backup');
   writeln('  cp *.exe c:\lib -eru   ;update newer existing read-only files');
   halt(1);
end;


(* -------------------------------------------------------- *)
var
   i,j:     integer;
   dest:    anystring;
   par:     anystring;
   first:   boolean;
   Info:    SearchRec;

begin
   SetIntVec($24,SaveInt24);    {restore normal critical error handler,
                                 allows 'FATAL' to work, if present}

   if paramcount = 0 then
      usage('Missing command parameters.');

   dest := '.';
   first := true;

   for i := 1 to paramcount do
   begin
      par := paramstr(i);
      translate(par,'/','\');

      if par[1] = '-' then
      begin
         for j := 2 to length(par) do
         case upcase(par[j]) of
            'U':  update_newer := true;
            'R':  replace_readonly := true;
            'E':  require_existing := true;
            '2':  bufsiz := 4*512;  {1 cluster}
            '6':  bufsiz := 9*512;  {1 track on 360k drive}
            '8':  bufsiz := 12*512; {1 track on 1.2meg drive}
            else  usage('Unknown option: '+par[j]);
         end;
      end
      else

      if first then
         first := false
      else
         dest := par;
   end;

   getdir(0,cur_dir);
   addslash(cur_dir);

   if (copy(dest,length(dest)-1,2) <> ':\') then
   begin
      addslash(dest);
      dest := path_only(dest);
      if dest = '' then
         dest := '@:';
      if (length(dest) = 2) and (dest[2] = ':') then
      begin
         getdir(ord(dest[1])-ord('@'),dest);
         addslash(dest);
      end;
      makepath(dest,cur_dir);
   end;

   if (copy(dest,length(dest)-1,2) <> ':\') and (dest[length(dest)] <> ':') then
   begin
      FindFirst(dest,AnyFile,Info);
      if (DosError <> 0) or ((Info.Attr and Directory) = 0) then
         usage('Not a device or directory: '+dest);
   end;


   for i := 1 to paramcount do
      if paramstr(i) <> dest then
         procparam(paramstr(i),dest);

   halt(0);
end.

