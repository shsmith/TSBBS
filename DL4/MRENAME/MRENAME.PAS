
(*
 * mrename - multiple rename
 *
 * s.h.smith, 5-mar-86
 *
 * usage: files *.xxx | mrename
 *
 *)

{$g1024}

var
   fd:      file;
   name:    string[64];
   newname: string[64];

begin
   while not eof do
   begin
      readln(name);
      write('Rename "',name,'" to: ');

      newname := '';
      readln(con,newname);

      if newname <> '' then
      begin
{$I-}
         assign(fd,name);
         rename(fd,newname);
{$I+}
         if ioresult <> 0 then
            writeln('*** could not rename ***')
         else
            writeln(name,' changed to ',newname);
      end;
   end;

end.
