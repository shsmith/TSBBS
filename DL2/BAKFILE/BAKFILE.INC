
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

{rename file.xxx to file.bak}

procedure backup_file(name: anystring);
var
   fd1,fd2: file;
   bakname: anystring;
begin
   bakname := remove_ext(name) + '.BAK';

{writeln('[backup_file: name=',name,' bakname=',bakname,']');}
   assign(fd1,bakname);
   {$i-} erase(fd1); {$i+}
   if ioresult <> 0 then ;
   assign(fd1,name);
   rename(fd1,bakname);
end;

