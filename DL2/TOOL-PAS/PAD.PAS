var
   fd: file of byte;
   b:  byte;

begin
   assign(fd,paramstr(1));
   reset(fd);
   seek(fd,filesize(fd)-1);
   b := 26;
   while (filesize(fd) mod 128) <> 0 do
      write(fd,b);
   close(fd);
end.
