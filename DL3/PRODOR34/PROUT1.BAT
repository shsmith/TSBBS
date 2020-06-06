echo off
rem -- process a single upload file - for ProDOOR 3.4
rem -- %1-logfile, %2-testfile, %3-comport

rem -- determing file type and branch to proper test case
testfile %2 arc zip pak lzh zoo gif
if errorlevel == 98 goto end
if errorlevel == 6 goto gif
if errorlevel == 5 goto zoo
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

rem -- test ARC files -- first convert them to ZIP files
:arc
proecho %3 ~Converting ARC file to ZIP format ...~

rem -- I recommend you add ",*.ARC,999," to your UPSEC to lock out ARC
rem -- uploads if you are converting to ZIP.  If you accept ARC files
rem -- you should delete the next two commands

rem -- convert ARC files to ZIP files; TOZIP is from ZIPKIT43.ZIP or newer.
prosm /chkpath tozip %0 >>%1
if errorlevel 1 goto end
tozip %2 >>%1

rem -- dsz's $door.log is no longer valid after conversion, delete it.
if exist %DSZLOG% del %DSZLOG%
goto zip


rem -- test ZIP files
:zip
proecho %3 ~Testing ZIP file ...~

rem -- remove ansi comments from uploads; STRIPZIP is from STRIPZIP.ZIP
prosm /chkpath stripzip %0 >>%1
if errorlevel 1 goto end
stripzip %2 >>%1

rem -- finally use PKUNZIP to test for correct crcs in new files.
prosm /chkpath pkunzip %0 >>%1
if errorlevel 1 goto end
pkunZIP -t %2 >>%1
if errorlevel 1 echo %2 has errors! >>%1
goto end

rem -- test GIF files
:gif
proecho %3 ~Testing GIF file ...~

prosm /chkpath giftest %0 >>%1
if errorlevel 1 goto end
giftest %2 >>%1
if errorlevel == 2 echo %2 has errors! >>%1
goto end

rem -- test ZOO files
:zoo
proecho %3 ~Testing ZOO file ...~

prosm /chkpath zoo %0 >>%1
if errorlevel 1 goto end
zoo -test >>%1 %2
if errorlevel 1 echo %2 has errors! >>%1
goto end

rem -- test LZH files
:lzh
proecho %3 ~Testing LZH file ...~

prosm /chkpath lharc %0 >>%1
if errorlevel 1 goto end
rem lha 2.0 or later required for test function to work
lha t /v >>%1 %2
if errorlevel 1 echo %2 has errors! >>%1
goto end

rem -- test PAK files
:pak
proecho %3 ~Testing PAK file ...~

prosm /chkpath pak %0 >>%1
if errorlevel 1 goto end
pak t >>%1 %2
if errorlevel 1 echo %2 has errors! >>%1
goto end


:end
