
(*
 * outline - a simple "outline" oriented document generator
 *
 * outmisc.inc - this module contains various support procedures
 *               used by the rest of the outline processor.
 *
 * Author:  Samuel H. Smith,  11-Jan-86
 *
 *)

procedure usage(why: anystring);
begin
   writeln(version);
   writeln;
   writeln(why);
   writeln;
   writeln('Usage:  outline');
   writeln('  or    outline -mono           ;use monochrome monitor');
   writeln('        outline -slowdisplay    ;use DOS for displays');
   writeln;
   halt;
end;


procedure initialize;
var
   i: integer;

begin
   if paramcount > 1 then
      usage('**Too many options');

   if paramcount = 1 then
   begin
      if paramstr(1) = '-mono' then
         default_disp_seg := $B000
      else
      if paramstr(1) = '-slowdisplay' then
         slowdisplay := true
      else
         usage('**Unknown option: '+paramstr(1));
   end;


   window(1,1,80,25);

   load_options;

   new(emptytext);
   for i := 1 to max_text do
      emptytext^[i] := '';

   document := new_section;    {initialize document to be empty}

   marksec := nil;
   marksub := 0;

   delsec  := nil;
   docfile := '';

   prnfile := 'PRN';
   assign(nullfd,'nul');
   rewrite(nullfd);

   saved := true;
   indent_mult := 1;
end;
