
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
 * readbas.inc - Library to read "basic" format data files (3-1-89)
 *
 *)

procedure openfile(name: string65);
   (* open a file for "basic" style parsing *)
begin
   if name = '' then
   begin
      ok := false;
      exit;
   end;

   if readbas_buf <> nil then
      make_log_entry('?READBAS: openfile '+name+' during '+readbas_name+'!',true);

   readbas_name := name;
   assignText(curfd,name);
   {$i-} reset(curfd); {$i+}
   ok := ioresult = 0;

   if ok then
   begin
      dos_getmem(readbas_buf,sizeof(readbas_buf^));
      setTextBuf(curfd,readbas_buf^);
      readbas_count := 1;
   end;

end;


(* --------------------------------------------------------- *)
function endfile: boolean;
   (* check for end of file on the current data file *)
begin
   endfile := {seek}eof(curfd);
end;



(* --------------------------------------------------------- *)
procedure closefile;
   (* close the data file *)
begin
   close(curfd);
   dos_freemem(readbas_buf);
   readbas_buf := nil;
end;


(* --------------------------------------------------------- *)
procedure getaline(var line: string;
                   len:      integer);
   (* get a full line from the "basic" file *)
var
   buf:  string;

begin
   if endfile then
      buf := ^Z
   else
   begin
      qReadln(curfd,buf,sizeof(buf));
      inc(readbas_count);
   end;
   line := copy(buf,1,len-1);
end;

(* --------------------------------------------------------- *)
procedure cleanline(var line: string);
   (* remove comments, returns blank lines and data lines only *)
var
   p: integer;

begin
   delete_leading_spaces(line);

   p := cpos(readbas_comment,line);
   if p > 0 then
   begin
      line[0] := chr(p-1);
      delete_trailing_spaces(line);
   end;
end;


(* --------------------------------------------------------- *)
procedure getline(var line: string;
                  len:      integer);
   (* get a full line from the "basic" file, skip comments *)
   (* returns blank lines and data lines only *)
begin
   getaline(line,len);
   if line <> ^Z then
      cleanline(line);
end;


(* --------------------------------------------------------- *)
procedure getstr(var str: string;
                 len:     integer);
   (* get a string of characters from the "basic" file.  a string ends in
      either "," or crlf *)
var
   c:       char;
label
   comment;

begin
   if endfile then
      str := ^Z
   else

   begin
comment:
      str := '';
      if endfile then
         c := #26
      else
         read(curfd,c);

      while (c = ' ') do
         read(curfd,c);

      if c = readbas_comment then
      begin
         readln(curfd);
         goto comment;
      end;

      while (c <> ',') and (c <> #13) and (c <> #26) do
      begin
         if length(str) < len then
            inc(str[0]);
         str[length(str)] := c;
         read(curfd,c);
      end;

      if c = #13 then      {consume linefeed}
         read(curfd,c);
   end;
end;


(* --------------------------------------------------------- *)
procedure skipstr;
   (* skip over a , delimited string *)
var
   buf:     string10;
begin
   getstr(buf,sizeof(buf)-1);
end;


(* --------------------------------------------------------- *)
procedure getstrd(var str: string);
   (* get a directory string from the "basic" file.  check special case
      for no trailing "\" in the root directory *)
begin
   getstr(str,65);
   stoupper(str);

   if str[length(str)] = '\' then
      dec(str[0]);       {remove trailing "\" from ramdisks and such}
end;


(* --------------------------------------------------------- *)
procedure getint(var i: integer);
   (* get a string and convert it into an integer *)
var
   buf:  string10;
begin
   getstr(buf,sizeof(buf)-1);
   i := atoi(buf);
end;

procedure readint(var i: integer);
   (* get a string and convert it into an integer *)
var
   buf:  string10;
   e:    integer;
begin
   getaline(buf,sizeof(buf)-1);
   val(buf,i,e);
end;


procedure readword(var i: word);
   (* get a string and convert it into a word *)
var
   buf:  string10;
   e:    integer;
begin
   getaline(buf,sizeof(buf)-1);
   val(buf,i,e);
end;


procedure readlong(var l: longint);
   (* get a string and convert it into a longint *)
var
   buf:  string10;
   e:    integer;
begin
   getaline(buf,sizeof(buf)-1);
   val(buf,l,e);
end;


(* --------------------------------------------------------- *)
procedure readflag(var f: boolean);
   (* get a string and convert it into a true/false flag *)
var
   buf:  string;
begin
   getaline(buf,sizeof(buf));
   f := (buf[1] = '-') or (buf[1] = 'Y');
end;


(* --------------------------------------------------------- *)
procedure vgetstr(var str: varstring);
   (* get a variable allocation string of characters from the "basic"
      file.  a string ends in either "," or crlf *)
var
   temp: string;
begin
   getstr(temp,sizeof(temp)-1);
   savestr(str,temp);
end;


(* --------------------------------------------------------- *)
procedure vgetline(var str: varstring);
   (* get a variable allocation string of characters from the "basic"
      file.  a string ends in either "," or crlf *)
var
   temp: string;
begin
   getaline(temp,sizeof(temp)-1);
   savestr(str,temp);
end;


(* --------------------------------------------------------- *)
procedure vgetstrd(var str: varstring);
   (* get a variable allocation string and format as a directory *)
var
   temp: string65;
begin
   getstr(temp,sizeof(temp)-1);
   if (length(temp) > 2) and (temp[length(temp)] = '\') then
      dec(temp[0]);       {remove trailing "\" from ramdisks and such}
   savestr(str,temp);
end;


(* --------------------------------------------------------- *)
procedure skipline;
begin
   getline(par,sizeof(par)-1);
end;

procedure skiplines(n: integer);   {skip(ignore) a number of lines, last in par}
begin
   while n > 0 do
   begin
      skipline;
      dec(n);
   end;
end;


(* --------------------------------------------------------- *)
procedure findlinenum(lnum: integer);
   (* skip lines to make next line read the indicated line number *)
begin
   while readbas_count < lnum do
      skipline;
end;


