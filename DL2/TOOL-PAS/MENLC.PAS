
TYPE
   SECTOR = ARRAY[1..128] OF CHAR;

VAR
   FD:   FILE OF SECTOR;
   SEC:  SECTOR;
   I,R:  INTEGER;

BEGIN
   ASSIGN(FD,PARAMSTR(1));
   RESET(FD);

   FOR R := 0 TO FILESIZE(FD)-1 DO
   BEGIN
      SEEK(FD,R);
      READ(FD,SEC);

      FOR I := 2 TO SIZEOF(SEC) DO
         IF (SEC[I] >= 'A') AND (SEC[I] <= 'Z') AND (SEC[I-1] <> '"') THEN
            SEC[I] := CHR(ORD(SEC[I]) + $20);

      SEEK(FD,R);
      WRITE(FD,SEC);
   END;

   CLOSE(FD);
END.

