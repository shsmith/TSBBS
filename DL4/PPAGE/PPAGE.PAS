

PROGRAM ppage (Input,
               Output);    {msdos filter to add page numbers to a text file}

{typical usage: ppage INFILE >prn [first page number]}

{created: 7/26/85 shs}

{$g128,p128,u+}

{note to compiler to buffer input/output}

CONST
   formfeed =       ^L;
   pagelines =      66;

TYPE
   anystring =      STRING [132];

VAR
   buffer:          anystring;
   lineno:          Integer;
   pageno:          Integer;
   firstpage:       Integer;
   filename:        anystring;
   infile:          Text;
   code:            integer;



BEGIN                         {MAIN}

   
   IF ParamCount = 0 THEN
   BEGIN
      WriteLn(Con, 'usage:  ppage FILENAME >OUTFILE');
      WriteLn(Con, '  or    ppage FILENAME FIRST-PAGE-NUMBER >OUTFILE');
      Halt;
   END;

   filename := ParamStr (1);

   Assign(infile, filename);

{$I-}
   Reset(infile);
{$I+}


   IF IOResult <> 0 THEN
   BEGIN
      WriteLn(Con, 'ppage:  can''t open ', filename);
      Halt;
   END;

   lineno := 0;
   pageno := 0;
   firstpage := 0;            {get first-page parameter if present}


   IF (ParamCount = 2) THEN
      Val(ParamStr (2), firstpage, code);

   WHILE NOT EoF (infile) DO
   BEGIN

      IF (lineno = 0) THEN
      BEGIN
         pageno := pageno + 1;

         Write(Con,'Page ',pageno);
         if pageno = firstpage then write(con,' [copying]');
         Write(con,#13);

         lineno := 1;
      END;

      ReadLn(infile, buffer);

      IF (pageno >= firstpage) THEN
         WriteLn(Output, buffer);

      lineno := lineno + 1;

      IF (lineno = pagelines) THEN
         lineno := 0;

      IF pos(formfeed,buffer) > 0 then
         lineno := 0;
   END;

   IF LINENO <> 0 THEN
      WRITELN(OUTPUT,FORMFEED);

   writeln(con);

END.
