
{$m 10000,10000,10000}

uses dos;

var
   line: string;
   fd:   text;
   cmd:  string[128];
   cp:   string;

begin
   if paramcount <> 2 then
   begin
      writeln('usage: atcp filelist dest');
      writeln('example: atcp $door.nam j:\tmp');
      halt;
   end;

   cp := fsearch('CP.EXE',getenv('PATH'));

   assign(fd,paramstr(1));
   reset(fd);
   while not eof(fd) do
   begin
      readln(fd,line);
      if line > ' ' then
      begin
         cmd := line+' '+paramstr(2);
         if cp > '' then
            exec(cp,cmd)
         else
            exec(getenv('COMSPEC'),'/c copy '+cmd);
      end;
   end;

   close(fd);
end.


