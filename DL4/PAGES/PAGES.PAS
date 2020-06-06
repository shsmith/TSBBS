

PROGRAM ppage (Input,
               Output);


{msdos filter to extract a list of pages from a text file}

{typical usage: pages INFILE >prn 5 7 25}

{created: 10/11/85 shs}

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
   page:            Integer;
   filename:        anystring;
   infile:          Text;
   code:            integer;
   i:               integer;


BEGIN                         {MAIN}


   IF ParamCount < 2 THEN
   BEGIN
      WriteLn(Con, 'usage:  pages FILENAME >OUTFILE  page1 page2 ... pagen');
      Halt;
   END;

   filename := ParamStr (1);

   Assign(infile, filename);

{$I-}
   Reset(infile);
{$I+}


   IF IOResult <> 0 THEN
   BEGIN
      WriteLn(Con, 'pages:  can''t open ', filename);
      Halt;
   END;

   lineno := 0;
   pageno := 0;


   WHILE NOT EoF (infile) DO
   BEGIN

      IF (lineno = 0) THEN
      BEGIN
         pageno := pageno + 1;
         Write(Con,'page ',pageno,#13);
         lineno := 1;
      END;

      ReadLn(infile, buffer);

      for i := 2 to paramcount do
      begin
         Val(ParamStr (i), page, code);
         if pageno = page then
            WriteLn(Output, buffer);
      end;

      lineno := lineno + 1;

      IF (lineno = pagelines) THEN
         lineno := 0;

      IF POS(formfeed,buffer) > 0 THEN
         lineno := 0;
   END;

   IF LINENO <> 0 THEN
      WRITELN(OUTPUT,FORMFEED);

   writeln(con);

END.
