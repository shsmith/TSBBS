@echo off
rem -- process a single upload file - for ProDOOR 3.44 dated 12/31/91
rem -- %1-logfile, %2-testfile,  %3 -comport, %4-conference
rem -- determing file type and branch to proper test case
rem -- using 4DOS commands

proecho %3 ~Testing:%@NAME[%2] -- to get upload credit, please wait~

if %@ext[%2] == zip goto ZIP
if %@ext[%2] == ARJ goto ARCVTEST
if %@ext[%2] == GIF goto GIF
if %@ext[%2] == lzh goto ARCVTEST
if %@ext[%2] == pak goto ARCVTEST
if %@ext[%2] == arc goto ARCVTEST
if %@ext[%2] == zoo goto ARCVTEST
IF %2 == Z:\E\PLAY1\VERIFY.ULP GOTO VALIDATE

rem -- Catch wrong file types from bidirectional uploads
proecho %3 Files not in one of the standard file formats: %@ext[%2]~
proecho %3 Moving offline for sysop revue...~Leave note with description to get upload credit!~~
move %2 r:\hold
goto end

rem -- Check GIF, delete if invalid or incomplete GIF file and
rem -- add resolution to description
:GIF
    giftest %2 /E/A/P:1/L/D/B:3/F:Z:\C\BBS\$DOOR.NAM %2
    copy z:\c\bbs\$door.nam z:\c\$door.GIF
    goto end

rem -- give caller info about proposed upload
:VALIDATE
     p:\ulp\ULPTEST -cp:\ulp\ULP.CFG -i4 -a3F8 -mupload -pp:\bbs\ -fZ:\E\PLAY1\VERIFY.ULP >>p:\bbs\$door.res
     DEL Z:\E\PLAY1\VERIFY.ULP
     goto end

rem -- remove/save/replace any header to look at later
:ZIP
     recom -o -lr:\comment.lst -sP:\bin\ziphdr. %2

rem -- test any of the standard archive formats for validity, age, dups
rem -- update description from .DIZ .SDI files where possible

:ARCVTEST
     addbidir Z:\C\bbs\$DOOR.NAM %2
     p:\bin\prodiz %2 Z:\C\bbs\$door.nam
     p:\ulp\ULPTEST -cp:\ulp\ULP.CFG -i4 -a3F8 -mupload -pp:\bbs\ -f%2

rem %? used instead of errorlevel for IFF constructs benefit
rem PROECHO returns an errorlevel too--after executing it's cleared ULPTEST's value~

IFF %? GT 99 THEN
    echo ULPTEST Error: %? >>r:\ULP.ERR
    REM Mv2Call moves a comment/file into my CALLER1 file and deletes file
    echo         ULP configuration error: %? >foo
    Mv2Call Foo CALLER1
    goto End
ENDIFF

IFF %? == 9 THEN
    ren %2 r:\hold\*.bad
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- Archive contained defective GIF~
    echo %@NAME[%2] -- UPLOAD DENIED -- Archive contained defective GIF>foo
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 7 THEN
    ren %2 r:\hold\*.old
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- File age exceeded 18 months~
    echo %@NAME[%2] -- UPLOAD DENIED -- File age exceeded 18 months>foo
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 5 THEN
    ren %2 r:\hold\*.dup
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- Duplicate Percentage
    echo %@NAME[%2] -- UPLOAD DENIED -- Duplicate Percentage>foo
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 4 THEN
    ren %2 r:\hold\*.vrs
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- VIRUS FOUND!!!!!!!!!~
    echo %@NAME[%2] -- UPLOAD DENIED -- VIRUS FOUND!!!!!!!!!
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 3 THEN
    ren %2 r:\hold\*.bad
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- Failed archive testing~
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 2 THEN
    ren %2 r:\hold\*.DOS
    proecho %3 ~%@NAME[%2] -- UPLOAD DENIED -- DOS Keyword part of archive names~
    echo %@NAME[%2] -- UPLOAD DENIED -- DOS Keyword part of archive names>foo
    mv2call foo p:\bbs\gen\caller1
    GOTO End
ENDIFF

IFF %? == 0 THEN
    proecho %3 ~%@NAME[%2] -- Testing was sucessful in all respects!~
ELSE
    BEEP
ENDIFF

:end
