
(*
 * RBBPROD - RBBS / ProDOOR gateway
 *
 * Samuel H. Smith, 12-Dec-87
 *
 * This program will read GT Power Host system files and write the
 * PCBoard files needed to run PCB ProDOOR.
 *
 *)

{$v-}
{$t+,d+}

uses Tools;

const
   whoami = 'RBBPROD';
   version = 'Version 1.1, 04/02/88';


procedure usage(s: string);
begin
   writeln;
   writeln('Error: ',s);
   writeln;
   halt(99);
end;

{$I pcbint.inc}          (* read and write pcboard files *)
{$I RBBint.inc}          (* read and write gt host files *)


(*
 * main program
 *
 *)

begin
   writeln;
   writeln(whoami,' ',version);
   writeln('Courtesy of:  S.H.Smith  and  The Tool Shop BBS,  (602) 279-2673.');
   writeln;

   write('Reading RBBS files...');
   get_rbuser;
   convert_to_pcb;

   write('Writing PCB files...');
   put_user_rec;
   put_pcbsys_file;

   writeln;
   writeln;
end.

