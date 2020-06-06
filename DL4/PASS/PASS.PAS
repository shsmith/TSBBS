
{$G20480,P1024,D-}

VAR
   C: CHAR;

BEGIN
   WHILE NOT EOF DO
   BEGIN
      READ(C);
      IF C=^J THEN
         WRITELN
      ELSE
      IF C<>^M THEN
         WRITE(C);
   END;

END.

