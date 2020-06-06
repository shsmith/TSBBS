
(*
 * dlog2lst - filter reads dszlog file and returns selective file lists
 *
 * Copyright 1992 Samuel H. Smith (2-5-92)
 *
 *)

const
   version = 'DLOG2LST (2/5/92) - DSZLOG to File List Filter - Copyright 1992 Samuel H. Smith';

(* ------------------------------------------------------------ *)
function scan_nextpar(var line: string): string;
var
   i:      integer;
   par:    string;

begin
   fillchar(par,sizeof(par),0);
   while copy(line,1,1) = ' ' do
      delete(line,1,1);
   while line[length(line)] = ' ' do
      dec(line[0]);

   i := pos(' ',line);
   if i = 0 then
   begin
      par := line;
      line := '';
   end
   else
   begin
      par := copy(line,1,i-1);
      line := copy(line,i,255);
   end;

   scan_nextpar := par;
end;


(* ------------------------------------------------------------ *)
procedure usage;
begin
   writeln(version);
   writeln;
   writeln('This filter program scans a DSZLOG file and returns selected');
   writeln('information in the form of a file list.');
   writeln;
   writeln('Usage: DLOG2LST -I <DSZLOG >LISTING    ;list incoming files');
   writeln('       DLOG2LST -O <DSZLOG >LISTING    ;list outgoing files');
   writeln('       DLOG2LST -A <DSZLOG >LISTING    ;list all files');
   writeln;
   writeln('Examples:');
   writeln('  DLOG2LST -I <%DSZLOG% >UPLOAD.LST');
   writeln('      Creates a list of files uploaded');
   writeln('  DLOG2LST -O <%DSZLOG% >DOWNLD.LST');
   writeln('      Creates a list of files downloaded');
   halt(1);
end;


(* ------------------------------------------------------------ *)
var
   mode:    string;
   fsize:   string;
   ebps:    string;
   ecps:    string;
   errors:  string;
   flows:   string;
   lastsiz: string;
   fname:   string;
   serial:  string;

   line:    string;
   option:  string;
   temp:    string;

begin
   if paramcount <> 1 then
      usage;

   option := paramstr(1);
   if (option[1] = '/') or (option[1] = '-') then
      delete(option,1,1);

   option[1] := upcase(option[1]);
   case option[1] of
      'I','O','A':
         ;
      else
         usage;
   end;

   while not eof do
   begin
      readln(line);
      mode := scan_nextpar(line);
      fsize := scan_nextpar(line);
      ebps := scan_nextpar(line);
      temp := scan_nextpar(line);
      ecps := scan_nextpar(line);
      temp := scan_nextpar(line);
      errors := scan_nextpar(line);
      temp := scan_nextpar(line);
      flows := scan_nextpar(line);
      lastsiz := scan_nextpar(line);
      fname := scan_nextpar(line);
      serial := scan_nextpar(line);

      case mode[1] of
         'e','l','E','L':
            ;
         'a'..'z':
            if (option[1] = 'O') or (option[1] = 'A') then
               writeln(fname);
         'A'..'Z':
            if (option[1] = 'I') or (option[1] = 'A') then
               writeln(fname);
      end;
   end;
end.

