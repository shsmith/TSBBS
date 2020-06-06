uses dos;

var
   fname:   string;
   ofname:  string;
   line:    string;
   ifd,ofd: text;

begin
   fname := getenv('DSZLOG');
   ofname := fname;
   inc(ofname[length(ofname)]);

   assign(ifd,fname);
   {$i-} reset(ifd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('cannot open: ',fname);
      halt;
   end;

   assign(ofd,ofname);
   rewrite(ofd);

   while not eof(ifd) do
   begin
      readln(ifd,line);
      if (line[1] = 'h') or (line[1] = 'H') then
         writeln(ofd,line);
   end;

   close(ifd);
   close(ofd);
   erase(ifd);
   rename(ofd,fname);

end.



