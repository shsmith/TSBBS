
(*
 * cdexec - cd to the directory of a file and execute a program
 *
 * s.h. smith, 2/21/92
 *
 *)

{$m 10000,10000,10000}

uses tools, dos;

var
   home: string;
   fn:   string;
   cmd:  string;
   i:    integer;

begin
   if paramcount < 2 then
   begin
      writeln('usage: cdexec filename program ... params ...');
      halt(1);
   end;

   getdir(0,home);
   fn := path_only(paramstr(1));
   chdir(fn);

   cmd := '';
   for i := 2 to paramcount do
      cmd := cmd + ' ' + paramstr(i);

   exec(getenv('COMSPEC'),'/c'+cmd);
   chdir(home);

end.

