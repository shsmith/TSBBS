@echo off
rem -- Process a single upload file - for prodoor 3.44
rem -- Passed parameters:
rem -- * %1  log file
rem -- * %2  file to test
rem -- * %3  com port
rem --
rem -- You will have to edit the following directories to match
rem -- your own system configuration:
rem --  u:\pcb\gen\dlpath.lst           Download path list
rem --  u:\prod                         Common prodoor directory
rem --  v:\hold                         Held uploads directory
rem --  t:\playXX                       Node playpen directory
rem --  t:\scrXX                        Node scratch directory
rem --  t:\ptestXX                      Node Ziplab working directory
rem --
rem -- This sample batch file uses the following programs:
rem --  PROGRAM         WHERE POSTED    PURPOSE
rem --
rem --  testfile        testfile.zip    Check file .ext
rem --
rem --  noext           prod344.zip     Remove .ext from filename
rem --
rem --  cdto            prod344.zip     Change to drive and directory
rem --
rem --  tm              tm10.zip        Echo line with time/date appended
rem --
rem --  dlfind          dlfind12.zip    Locate file in dlpath and check
rem --                                  for .ext duplication
rem --
rem --  ac              ac212.zip       Convert to .zip from other formats
rem --
rem --  jpg2gif                         Convert .jpg files to .gif format
rem --
rem --  ptest           zlab_19c.zip    Zip lab file test and description
rem --                                  utility (please register)
rem --
rem --  addbidir        addbidir.zip    Make new entries in $door.nam
rem --                                  prior to running ptest and after
rem --                                  format conversion.
rem --
rem --  timeboot        timeboot.zip    Reboots machine if Zip lab or anything
rem --                                  else here takes longer than expected.
rem --

rem -- Reboot machine if this process takes more than 10 minutes.  This should
rem -- keep the system from hanging when ziplab crashes, AC gives an error
rem -- or if something else goes wrong.
timeboot 10

rem -- Set TARGET environment variable to the original file to test.
rem -- Set NOEXT to the original name less the .ext.  %NOEXT% will then
rem -- be used if a file conversion takes place.
rem -- Also sets NOPATH to the original name less the drive and directory,
rem -- which can be used for display messages to the user.

set DLPATH=u:\pcb\gen\dlpath.lst
set TARGET=%2
noext %TARGET% >u:\prod\noext%PCBNODE%.bat
call u:\prod\noext%PCBNODE%.bat
del u:\prod\noext%PCBNODE%.bat

rem -- Check for sufficient environment space.  If this fails, you need to
rem -- increase the /E parameter in your config.sys SHELL statement.
set XXXX=XXXX
if (%XXXX%) == (XXXX) goto env_ok

tm /l OUT OF ENVIRONMENT! %2 >>u:\prod\test%PCBNODE%.log
proecho %3 ~SYSTEM ERROR: OUT OF ENVIRONMENT VARIABLE MEMORY IN %0
proecho %3 ~PLEASE ASK SYSOP TO INCREASE ENVIRONMENT ALLOCATION IN CONFIG.SYS!~

:env_ok
set XXXX=
rem -- Check for duplication based on file .ext in download directories.
dlfind -e %TARGET%
if errorlevel 1 goto duplicate
goto testext

:duplicate
tm /l Duplicate file! %TARGET% >>u:\prod\test%PCBNODE%.log
proecho %3 ~Duplicate file %NOPATH% ...
goto offline

:offline
proecho %3 ~Moving file offline for review ...~
copy %TARGET% v:\hold
del %TARGET%
goto end

rem -- determine file type and branch to proper test case using testfile.exe
:testext
rem -- test for archive extension using testfile.exe
testfile %TARGET% zip gif jpg arj lzh arc pak
if errorlevel 8 goto unknown
if errorlevel 7 goto tozip
if errorlevel 6 goto tozip
if errorlevel 5 goto tozip
if errorlevel 4 goto tozip
if errorlevel 3 goto jpgtogif
if errorlevel 2 goto testgif
if errorlevel 1 goto testzip
goto tozip

rem -- all unknown file types are moved to the hold directory for
rem -- review by the sysop.  if it's a "postable" file, the user
rem -- will be given credit.
:unknown
tm /l File type not allowed! %TARGET% >>u:\prod\test%PCBNODE%.log
proecho %3 ~File type %NOPATH% not allowed!
proecho %3 ~Please convert your files to ZIP format before uploading!
goto offline

:jpgtogif
rem -- convert jpg files to gif files.
tm /l Converting %TARGET% to GIF format >>u:\prod\test%PCBNODE%.log
proecho %3 ~Converting %NOPATH% to GIF format ...~
jpg2gif %TARGET%
if not exist %NOEXT%.GIF goto unknown
del %TARGET%
set TARGET=%NOEXT%.GIF
addbidir %PCBDRIVE%%PCBDIR%\$door.nam %TARGET%
echo H 1000 9600 bps 960 cps 0 errors 0 0 %TARGET%>>%DSZLOG%
goto testgif

:testgif
rem -- Test GIF file using GIFTEST by Dave Navarro, Jr.
rem -- * /A   forces the GIF to be made a private upload, even in public
rem -- *      upload conferences.
rem -- * /B:3 tells GIFtest were running ProDoor 3.44 dated after 12/31/91
rem -- * /D   tells GIFtest to do CRC duplicate checking.
rem -- * /E   tells GIFtest to erase any GIF which is Invalid, a Duplicate,
rem -- *      or does not meet the minimum resolution.
rem -- * /F:  tells GIFtest where to find the description file to modify.
rem -- * /L   tells GIFtest to log all GIF information to GIFLOG in the
rem -- *      current directory
rem -- * /M:  tells GIFtest to invalidate any GIFs which are not at least
rem -- *      321x201x16 in resolution.
rem -- * /P:  tells GIFtest to send all output to the COM port as well as
rem -- *      to the screen.
rem -- ** There are other parameters available, see GIFtest for more info **
:testgif
proecho %3 ~Testing %NOPATH% file ...~
giftest %2 /B:3/D/E/F:%PCBDRIVE%%PCBDIR%\$DOOR.NAM/L
if errorlevel 255 goto badgif
if errorlevel 60 goto testdone
if errorlevel 25 goto duplicate
if errorlevel 20 goto badgif
if errorlevel 10 goto testdone
if errorlevel 5 goto badgif
if errorlevel 1 goto badgif
goto testdone

:badgif
tm /l Failed GIFTEST %TARGET% >>u:\prod\test%PCBNODE%.log
proecho %3 ~Error in GIF file!~
goto offline

rem -- convert any archive which is not a zip to zip format using
rem -- ac (archive convert) by donald langhorn.
:tozip
proecho %3 ~Converting %NOPATH% to ZIP format ...~
tm /l Converting %TARGET% to ZIP format >>u:\prod\test%PCBNODE%.log
cdto t:\play%PCBNODE%
ac /z %NOPATH%
cdto u:\prod
if not exist %NOEXT%.ZIP goto unknown
set TARGET=%NOEXT%.ZIP
echo H 1000 9600 bps 960 cps 0 errors 0 0 %TARGET%>>%DSZLOG%
goto testzip

rem -- test archives using ziplab plus by jeffrey s. morley
rem -- ziplab plus tests zip, arj, and lzh files
rem -- all files should have been converted to zip format before we get here.
:testzip
addbidir %PCBDRIVE%%PCBDIR%\$door.nam %TARGET%
pkunzip -t %TARGET%
if errorlevel 1 goto badzip

set PCBDOOR=PRODOOR
set ZIPLAB=T:\PTEST%PCBNODE%
cdto t:\scr%PCBNODE%
ptest %TARGET% u:\prod\ptest%PCBNODE%.cfg
cdto u:\prod
set PCBDOOR=
goto testdone

:badzip
tm /l Failed PKUNZIP -T! %TARGET% >>u:\prod\test%PCBNODE%.log
proecho %3 ~Failed PKUNZIP -T! %TARGET%~
goto offline

:testdone
if exist %TARGET% goto testok
tm /l Bad upload! %TARGET% >>u:\prod\test%PCBNODE%.log
goto end

:testok
tm /l Good upload! %TARGET% >>u:\prod\test%PCBNODE%.log

:end
rem -- Clear environment variables from memory.
SET TARGET=
SET NOEXT=
SET NOPATH=
SET ZIPLAB=
SET PCBDOOR=

rem -- Disable timeboot timer and remove timeboot from memory.
timeboot /r
