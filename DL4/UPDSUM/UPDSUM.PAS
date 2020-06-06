
(*
 * updsum - update the procedure summary in a source file
 *
 *  procedure summary is generated with 'cmttosum' utility
 *
 *
 * usage:  updsum <infile >outfile sumfile
 *
 * shs 26-sep-85
 *
 *)

{$g512,p10240,d-}

type
   anystring = string[132];

var
   buf:        anystring;
   nextsect:   anystring;
   sumfile:    text[512];
   histseen:   boolean;


begin
   if paramcount <> 1 then
   begin
      writeln(con,'Usage:  updsum <INFILE SUMFILE >OUTFILE');
      halt;
   end;

   assign(sumfile,paramstr(1));
   histseen := false;


   while not eof do
   begin

      readln(buf);
      if (copy(buf,1,13) = ' * Revision H') then
         histseen := true;

      if (copy(buf,1,13) = ' * Procedures') then
      begin

         writeln(buf);
         readln(buf);
         writeln(buf);
         writeln(' *');


         (* throw away the old procedure summary *)
         repeat

            readln(nextsect);

         until (copy(nextsect,1,8)  = ' * Test ') or
               (copy(nextsect,1,15) = ' * Declarations') or
               (copy(nextsect,1,3)  = ' *)');


         reset(sumfile);
         while not eof(sumfile) do
         begin
            readln(sumfile,buf);
            if buf <> '' then
               writeln(buf);
         end;
         close(sumfile);

         if copy(nextsect,1,3) <> ' *)' then
         begin
            writeln(' *');
            writeln(' *');
         end;

         writeln(nextsect);
         histseen := false;
      end

      else
      if (histseen and (copy(buf,1,3) = ' *)')) then
      begin
         writeln(' *');
         writeln(' * Procedures');
         writeln(' * ----------');
         writeln(' *');

         reset(sumfile);
         while not eof(sumfile) do
         begin
            readln(sumfile,buf);
            if buf <> '' then
               writeln(buf);
         end;
         close(sumfile);

         writeln(' *)');
         histseen := false;
      end

      else
         writeln(buf);

      if copy(buf,1,3) = ' *)' then
         histseen := false;
   end;

end.

