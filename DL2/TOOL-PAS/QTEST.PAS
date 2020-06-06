
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
 * test driver for Qread unit - reports speed increase of Qread.asm
 *                              versus normal readln
 * 11-20-88.
 *
 *)

{$d+,l+}
{$v-}

uses dos, qread;

{$i \tinc\gettime.inc}

var
   fn:      string;
   line:    string[255];
   fd:      text;
   buf:     array[1..$1000] of byte;
   time:    real;
   qtime:   real;
   ntime:   real;
   ln:      integer;

procedure quick;
begin
   assign(fd,fn);
   reset(fd);
   settextbuf(fd,buf);
   time := get_time;
   ln := 0;
   qreadln(fd,line,sizeof(line));
   while (line[1] <> ^Z) or (length(line) <> 1) do
   begin
      inc(ln);
      qreadln(fd,line,sizeof(line));
   end;

   qtime := get_time-time;
   write(' quick: ',qtime:0:2,' (',int(ln)/qtime:0:0,' lps)');
   close(fd);
end;

procedure normal;
begin
   assign(fd,fn);
   reset(fd);
   settextbuf(fd,buf);
   time := get_time;
   ln := 0;
   while not eof(fd) do
   begin
      readln(fd,line);
      inc(ln);
   end;
   ntime := get_time-time;
   write('  normal: ',ntime:0:2,' (',int(ln)/ntime:0:0,' lps)');
   writeln('  diff: ',(ntime-qtime)/ntime*100.0:0:1,' %');
   close(fd);
end;

begin
   fn := 'qtest.dat';
   quick; writeln;
   quick; normal;
   quick; normal;
   quick; normal;
   quick; normal;
end.



