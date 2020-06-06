DEFINT A-Z
DECLARE SUB EnvOption (x%)
'this program is to get around the double processing involved if there's
'a single file in the upload directory

IF COMMAND$ = "" THEN
   PRINT "Command Syntax: ONLY1 D:\SUBDIR"
   PRINT "       Returns: ErrorCode 1 if there's only one file"
   PRINT "   Environment: ONLY1 contains the filename to process"
   PRINT " Be sure to clear the when done."
   END
END IF
PRINT "With regards, The Toolkit BBS 219-696-3415 HST"

f$ = COMMAND$ + "\*.*"
PRINT "Checking Directory: "; f$

t$ = DIR$(f$)
IF t$ > "" THEN 'at least one
    t$ = "ONLY1=" + t$
    IF LEN(DIR$) = 0 THEN
        EnvOption 1     'manipulate parrent option
        ENVIRON t$
        PRINT "[ErrLvl 1] Setting Environ: "; t$
        END 1
    ELSE
        'END 0
    END IF
ELSE            'no files
   'END 0
END IF

