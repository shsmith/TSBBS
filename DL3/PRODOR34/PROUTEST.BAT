echo off
rem -- process test uploads request - for ProDOOR 3.5à
rem -- %1-logfile, %2-testdir, %3-comport, %4-conference number

rem -- keep a permanent copy of all DSZLOG transfer log files
goto skipperm
rem if exist %DSZLOG% type %DSZLOG% >>L:\pcb\perm.log
:skipperm

rem -- exit quietly if no files were uploaded
if not exist %2\*.* goto end

rem -- test each uploaded file individually
proecho %3 ~~Testing uploads.  Please wait...~
for %%f in (%2\*.*) do %COMSPEC% /c prout1 %1 %%f %3

:end
