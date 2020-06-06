@echo off
rem -- GOTO 4TESTEXT if you are running 4DOS or NDOS
rem -- GOTO TESTEXT if you are running MSDOS, DR-DOS or PC-DOS
goto 4testext

rem -- Process a single upload file - for ProDOOR 3.44
rem -- Passed Parameters:
rem -- * %1  Log File
rem -- * %2  File to Test
rem -- * %3  COM Port
rem -- * %4  Conference Number
rem -- * %5  Play Directory
rem -- * %6  PCB Directory
rem -- ** See PROUTEST.BAT if you want to add new parameters or change the **
rem -- ** order of the current passed parameters.                          **

rem -- Determine file type and branch to proper test case using TESTFILE.EXE
:testext
testfile gif zip arj lzh
if errorlevel == 4 goto gif
if errorlevel == 3 goto zip
if errorlevel == 2 goto zip
if errorlevel == 1 goto zip
goto unknown

rem -- Determing file type and branch to proper test case using 4DOS commands
:4testext
if %@ext[%2] == gif goto gif
if %@ext[%2] == zip goto zip
if %@ext[%2] == arj goto zip
if %@ext[%2] == lzh goto zip
goto unknown

rem -- All unknown file types are moved to the HOLD directory for
rem -- review by the sysop.  If it's a "postable" file, the user
rem -- will be given credit.
:unknown
proecho %3 File type unknown!  Moving Offline for Review..~
mov %2 h:\hold
goto end

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
:gif
giftest %2 /A/B:3/D/E/F:%6\$DOOR.NAM/L/M:321x201x16/P:%3
goto end

rem -- Test Archives using ZipLab Plus by Jeffrey S. Morley
rem -- ZipLab Plus tests ZIP, ARJ, and LZH files
rem -- * The SET PCBDOOR=PRODOOR command let's ZPLUS know that we
rem -- * are running ProDoor instead of PCBoard.
rem -- * If any file is deleted, moved or renamed, you MUST delete
rem -- * the DSZLOG file in order for ProDoor to work properly.
:zip
SET PCBDOOR=PRODOOR
ptest %2 %6\ptest.cfg
SET PCBDOOR=
if not exist %2 del %dszlog%
if not exist %2 goto end
goto diz

rem -- Search for FILE_ID.DIZ using ProDIZ by Dave Navarro, Jr.
rem -- If one is found, import it as the description.
rem -- ProDIZ supports ZIP, ARJ, and LZH files
rem -- * /AV tells PRODIZ to add the AV serial number to the description
rem -- *     of any ZIP files that contain one.
rem -- * /D  tells PRODIZ to include the number of files in the archive
rem -- *     and the oldest/newst file dates.
rem -- * /U  tells PRODIZ to include the uncompressed size of the archive
rem -- * in the description.
:diz
proecho %3 ~Searching for FILE_ID.DIZ...~
prodiz %2 %6\$door.nam /d /u /av

rem -- GOTO 4ISZIP if you are running 4DOS or NDOS
rem -- GOTO ISZIP if you are running MSDOS, DR-DOS, or PC-DOS
goto 4iszip

rem -- test archive extension again using 4DOS commands
:4iszip
if %@ext[%2] == zip goto end
goto tozip

rem -- test archive extension using TESTFILE.EXE
:iszip
testfile zip
if errorlevel == 1 goto end
goto tozip

rem -- Convert any archive which is not a ZIP to ZIP format using
rem -- AC (Archive Convert) by Donald Langhorn.
rem -- Requires CDD command in 4DOS or CDTO.COM program (public domain)
:tozip
proecho %3 ~Converting to ZIP format...~
CDD %5
ac /z %2
cdd d:\prodoor
if exist %dszlog% del %dszlog%

:end
