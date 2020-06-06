@echo off
goto starttest

rem -- Process test uploads request - for ProDOOR 3.44
rem -- Prodoor passes the following parameters to PROUTEST
rem -- * %1  Log file
rem -- * %2  Location of uploaded Files (PLAY directory)
rem -- * %3  COM Port
rem -- * %4  Current Conference Number

:starttest
rem -- Keep a permanant log of all DSZ transfers
if exist %DSZLOG% type %DSZLOG% >> perm.log

rem -- If there are no uploaded files, then exit
if not exist %2\*.* goto end

rem -- Keep a log of all descriptions before and after they are
rem -- changed.
echo -----------------[ BEFORE ]------------- >> des.log
type %pcbdrive%%pcbdir%\$door.nam >> des.log

goto testeach
rem -- Test each uploaded file individually by calling PROUT1.BAT for
rem -- each file in the play directory.
rem -- Pass the following parameters to PROUT1
rem -- %1  Log File
rem -- %2  File Name to test
rem -- %3  COM Port
rem -- %4  Current Conference
rem -- %5  PLAY directory
rem -- %6  PCB Directory (from environment as %PCBDRIVE%%PCBDIR%)
:testeach
proecho %3 ~~Testing uploads.  Please wait...~
for %%f in (%2\*.*) do call prout1 %1 %%f %3 %4 %2 %pcbdrive%%pcbdir%

echo -----------------[ AFTER ]------------- >> des.log
type %pcbdrive%%pcbdir%\$door.nam >> des.log
:end

