
(*
 * finderr - find tp4.0 error message and call up Q to edit the
 *           specified line.
 *
 * usage:    tpc file >err
 *           type err
 *           finderr >temp.bat
 *           temp
 *
 * S.H.Smith, 30-Dec-87 (17-Sep-91)
 *
 *)

var
   fd:          text;
   buf:         string;
   pbuf:        string;
   pfile:       string;


   procedure getbuf;
      {get next line from file; detects <cr> alone as line delimiter}
   var 
      i: integer;
      c: char;
   begin
      buf := '';
      repeat
         if eof(fd) then
            c := ^Z
         else
            read(fd,c);
         if (c >= ' ') then
            buf := buf + c;
      until (c = ^M) or (c = ^Z);

      if c = ^Z then
         buf := ^Z;
   end;


   procedure found_error;
      {found an error message; format editing commads into script}
   var
      i:        integer;
      col:      integer;
      name:     string;
      line:     string;
   begin

      i := pos('(',buf);
      name := copy(buf,1,i-1);
      if (i > 0) and (pos(' ',name) = 0) then
      begin
         pbuf := buf;

         getbuf;   {error text}
         getbuf;   {.....^}
         col := pos('^',buf);

         writeln('echo.');
         writeln('pause');

         {jump to the proper line}
         delete(pbuf,1,i);
         i := pos(')',pbuf);
         line := copy(pbuf,1,i-1);

(*****************
         write('keyahead ^J',line,'^M');
         if line > '30' then
            write('^W^W^W^W^W^W^W^W^W^W');

         {move cursor out to error column; use tabs first because
          of the 128 character line length limit}
         if col > 8 then
         begin
            write('^V');
            while col > 8 do
            begin
               write('^I');
               dec(col,8);
            end;
            write('^V');
         end;

         while col > 1 do
         begin
            write('^D');
            dec(col);
         end;

         {load the error file}
         write('^K^E',paramstr(1),'^M');

         {load the outer file, if present}
         if pfile <> '' then
         begin
            i := pos('(',pfile);
            write('^K^E',copy(pfile,1,i-1),'^M');
            delete(pfile,1,i);

            i := pos(')',pfile);
            line := copy(pfile,1,i-1);
            if line <> '0' then
            begin
               write('^J',line,'^M');
               if line > '30' then
                  write('^W^W^W^W^W^W^W^W^W^W');
            end;
         end;

         writeln('^K^N');
         writeln('q ',name);
************************)

         write('q ',name,' ',paramstr(1));

         {load the outer file, if present}
         if pfile <> '' then
         begin
            i := pos('(',pfile);
            write(' ',copy(pfile,1,i-1));
         end;

         writeln(' -N',line);
      end;
   end;


begin
   if paramcount <> 1 then
   begin
      writeln('usage:  finderr ERRORFILE >script');
      writeln;
      writeln('example:');
      writeln('  tpc file /m >err');
      writeln('  finderr err >fix.bat');
      writeln('  fix');
      writeln;
      writeln('use with Qedit 2.15 or newer');
      halt(99);
   end;

   assign(fd,paramstr(1));
   {$i-} reset(fd); {$i+}
   if ioresult <> 0 then
   begin
      writeln('echo finderr: can''t open ',paramstr(1));
      halt;
   end;

   pfile := '';
   pbuf := '';
   getbuf;

   while buf <> ^Z do
   begin
      if pos('(0)',buf) > 0 then
         pfile := pbuf;

      if pos(':',buf)   > 0 then
      begin
         found_error;
         close(fd);
         halt(0);
      end;

      pbuf := buf;
      getbuf;
   end;

   close(fd);
end.


