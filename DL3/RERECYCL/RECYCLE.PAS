
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
 * Recycle - determine if PCBoard should be recycled (3-1-89)
 *
 *)

{$v-}
{$l+,d+}

uses dos;

const
   version  = 'ProDoor Recycle Utility  Version 1.5, 07-29-89 S.H.Smith';

type
   pcbsys_rec = array[0..127] of char;
   
var
   port: string;
   code: integer;
   fd:   text;
   line: string;
   sys:  file of pcbsys_rec;
   rec:  pcbsys_rec;


(*
 * main program
 *
 *)

begin
   assign(output,'');
   rewrite(output);

   writeln;
   writeln(version);

(* load pcboard.sys file to see if user is logged in *)
   assign(sys,'pcboard.sys');
   {$i-} reset(sys); {$i+}
   if ioresult = 0 then
   begin
      read(sys,rec);
      close(sys);
   end
   else
   begin
      writeln('!CAN''T OPEN PCBOARD.SYS!');
      rec[14] := ' ';
   end;
      
(* do not recycle prodoor empty pcboard.sys was found *)

(* changed code to 2 if pcboard.sys is empty by Don Cheeks & Lana Fox *)
(* on 07-22-89                                                        *)

   if (rec[14] <= ' ') or (rec[11] <= ' ') then
   begin
      code := 2;  {load pcboard}
      write('<logoff>');
   end
   else
   
(* possible return from other doors; examine $door.bat *)

   begin
      assign(fd,'$door.bat');
      {$i-} reset(fd); {$i+}
      if ioresult <> 0 then
      begin
         code := 1;  {load pcboard}
         write('<no $door.bat>');
      end
      else

      begin
         {$i-}
         readln(fd,line);  {c:}
         readln(fd,line);  {cd ...}
         readln(fd,line);  {copy...}
         close(fd);
         {$i+}

         if (ioresult = 0) and (copy(line,1,4) = 'copy') then
         begin
            code := 0;  {return to prodoor}
            write('<return from subdoor>');
         end 
         else     
         begin
            code := 1;  {return to pcboard}
            write('<close prodoor>');
         end
      end;
   end;

   writeln(' - errorlevel set to ',code);
   halt(code);
end.
