
(*
 * ProCRC - Quickly calculate and compare CRC's for a group of files.
 *
 * S.H.Smith, 26-sep-88
 * Copyright 1988 Samuel H. Smith, All Rights Reserved
 *
 *)

{$r-,s-}
{$L+,D+}

uses Crt,Dos,MdosIO;

const
   version =   'ProCRC: Quick CRC Checker v1.1 11-21-88  (C)1988 S.H.Smith';
   bufsize =   $4000;

   files:      integer = 0;
   errors:     integer = 0;
   update_crc: boolean = false;

type
   filename = string[64];

var
   stdout:     text;
   buf:        array[1..bufsize] of byte;
   sizes:      longint;

{$i \tinc\gettime.inc}
{$I \tinc\CRC16.INC}

(* ------------------------------------------------------------ *)
procedure usage;
begin
{$i-}
   writeln(output,'This utility scans a list of files and verifies that');
   writeln(output,'none have been modified.');
   writeln(output);
   writeln(output,'Usage: ProCRC CRCLIST       ;check crcs against CRCLIST');
   writeln(output,'       ProCRC CRCLIST -u    ;update CRCLIST with current file crcs');
   writeln(output);
   writeln(output,'Example:');
   writeln(output,'  where *.exe >file.lst         ;build list of files');
   writeln(output,'  procrc file.lst -U >file.crc  ;add crcs to the list');
   writeln(output,'  procrc file.crc               ;check all crcs and report changes');
{$i+}
   halt(99);
end;


(* ------------------------------------------------------------ *)
function calculate_crc(name: filename): word;
var
   fd:   dos_handle;
   i,n:  word;

begin
   inc(files);

   fd := dos_open(name,open_read);
   if fd = dos_error then
   begin
      {$i-} writeln(output,'Can''t open: ',name); {$i+}
      calculate_crc := 0;
      exit;
   end;

   {$i-} write(output,name); {$i+}

   crc_out := 0;
   n := dos_read(fd,buf,sizeof(buf));
   while n <> 0 do
   begin
      if wherex < 79 then
         {$i-} write(output,'+'); {$i+}

      crcstr(buf,n);
      sizes := sizes + n;
      n := dos_read(fd,buf,sizeof(buf));
   end;

   {$i-} write(output,^M); {$i+}
   clreol;

   dos_close(fd);
   calculate_crc := crc_out;
end;


(* ------------------------------------------------------------ *)
procedure report_crc(name: filename);
var
   crc:  word;
begin
   crc := calculate_crc(name);
   writeln(stdout,name,' ',crc);
end;


(* ------------------------------------------------------------ *)
procedure verify_crc(name: filename; ocrc: word);
var
   crc:  word;
begin
   crc := calculate_crc(name);
   if crc <> ocrc then
   begin
      writeln(stdout,'*** Caution: ',name,' is different! ***');
      writeln(stdout,'    Old crc=',ocrc,'  New crc=',crc,^G^G);
      writeln(stdout);
      inc(errors);
   end;
end;


(* ------------------------------------------------------------ *)
var
   ifd:           text;
   ifb:           array[1..2048] of char;
   line:          string;
   p:             integer;
   ifn:           filename;
   crc:           word;
   time:          real;
   speed:         real;

begin
   assign(stdout,'');
   rewrite(stdout);
   {$i-} writeln(output); writeln(output,version); writeln(output); {$i+}

   if paramcount < 1 then
      usage;

   assign(ifd,paramstr(1));
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      {$i-} writeln(output,'Can''t open CRCLIST file: ',paramstr(1)); {$i+}
      halt(99);
   end;

   setTextBuf(ifd,ifb);
   update_crc := (paramstr(2) = '-U') or (paramstr(2) = '-u');
   time := get_time;
   sizes := 0;

   while not eof(ifd) do
   begin
      readln(ifd,line);

      p := pos(' ',line);
      if p > 0 then
      begin
         ifn := copy(line,1,p-1);
         line := copy(line,p+1,10);
         val(line,crc,p);
      end
      else
      begin
         ifn := line;
         update_crc := true;
      end;

      if update_crc then
         report_crc(ifn)
      else
         verify_crc(ifn,crc);
   end;

   close(ifd);
   time := get_time - time;
   if time = 0 then
      time := 0.05;
   speed := int(sizes) / time;

   {$i-}
   writeln(output,files,' files, ',errors,' differences.');
   writeln(output,time:0:1,' seconds, ',sizes div 1024,'k bytes, ',speed:0:0,' bytes/sec.');
   {$i+}
   close(stdout);
   halt(errors);
end.


