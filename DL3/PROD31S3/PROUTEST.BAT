echo off
rem -- process test uploads request - for ProDOOR 3.0
rem -- %1-logfile, %2-testdir, %3-comport

rem -- keep a permanent copy of all DSZLOG transfer log files
rem if exist %DSZLOG% type %DSZLOG% }}L:\pcb\perm.log

rem -- exit quietly if no files were uploaded
if not exist %2\*.* goto end

rem -- convert unwanted .arc files to .zip format
if not exist %2\*.arc goto testzip

:convert
chkpath proecho %0 >>%1
if errorlevel 1 goto end
proecho %3 ~~Converting ARC files to ZIP format.  Please wait...~

rem -- I recommend you add ",*.ARC,999," to your UPSEC to lock out ARC
rem -- uploads if you are converting to ZIP.  If you accept ARC files
rem -- you should delete the next two commands

rem -- convert ARC files to ZIP files; TOZIP is from ZIPKIT43.ZIP or newer.
chkpath tozip %0 >>%1
if errorlevel 1 goto testzip
tozip %2\* >>%1

rem -- dsz's $door.log is no longer valid after conversion, delete it.
if exist %DSZLOG% del %DSZLOG%


:testzip
rem -- test zipfiles
proecho %3 ~~Testing uploads.  Please wait...~

rem -- check for truncated uploads; ZIPDS is from ZIPDS11.ZIP or newer
chkpath zipds %0 >>%1
zipds %2\* >>%1

rem -- remove ansi comments from uploads; STRIPZIP is from STRIPZIP.ZIP
chkpath stripzip %0 >>%1
stripzip %2\* >>%1

rem -- finally use PKUNZIP to test for correct crcs in new files.
chkpath pkunzip %0 >>%1
pkunZIP -t %2\* >>%1

:end
