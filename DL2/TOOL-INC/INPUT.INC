
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
 * input.inc - library for local input and display
 *             used when compiling parts of ProDOOR as local
 *             (command-line) utilities.
 *)

var
   linenum: integer;

{$IFDEF TRACEIO}
var
   tracefd: text;
const
   traceopen: boolean = false;
   tracefile: string[15] = 'install.log';
{$ENDIF}


(* ------------------------------------------------------------ *)
procedure disp(msg:  string);
begin
   write(output,msg);

{$IFDEF TRACEIO}
   if not traceopen then
   begin
      assign(tracefd,tracefile);
      rewrite(tracefd);
      traceopen := true;
   end;

   write(tracefd,msg);
{$ENDIF}

end;


procedure newline;
begin
   flush(output);
   disp(^M^J);
   inc(linenum);
end;

procedure displn(msg:  string);
begin
   disp(msg);
   newline;
end;


(* ------------------------------------------------------------ *)
procedure input(var line:  string;
                maxlen:    integer);
var
   c:     char;

begin
   linenum := 1;
   line := '';

   repeat
      flush(output);
      c := readkey;

      case c of
         ' '..#126:
            if maxlen = 0 then
            begin
               line := c;
               disp(c);
               c := ^M;    {automatic CR}
            end
            else

            if length(line) < maxlen then
            begin
               if (wherex > 78) then
                  newline;

               inc(line[0]);
               line[length(line)] := c;
               disp(c);
            end
            else
               disp(^G^X^H' '^H);

         ^H,#127:
            if length(line) > 0 then
            begin
               dec(line[0]);
               disp(^H' '^H);
            end;

         ^M:   ;

         ^C:   begin
                   displn('^C');
                   halt(99);
               end;
      end;

   until (c = ^M);

end;


(* ------------------------------------------------------------ *)
procedure make_log_entry(msg: string; echo: boolean);
begin
   displn(msg);
end;

procedure flush_com;
begin
end;

