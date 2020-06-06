@echo off

rem -- process test uploads request - for prodoor 3.4
rem -- %1-logfile, %2-testdir, %3-comport

rem -- keep a permanent copy of all dszlog transfer log files
if exist %DSZLOG% type %DSZLOG% >>%PCBDRIVE%%PCBDIR%\PERM.LOG

rem -- exit quietly if no files were uploaded
if not exist %2\*.* goto end

proecho %3 ~~Testing uploads.  Please wait...~
rem -- make a list of all files so they can be tested individually.
rem -- * this method eliminates the problem of DOS sometimes returning
rem -- * the same filename multiple times in a 'for' statement.
rem >$$test%PCBNODE%.bat
for %%f in (%2\*.*) do echo call prout1 %1 %%f %3 >>$$test%PCBNODE%.bat

rem -- test each uploaded file individually
call $$test%PCBNODE%.bat
del $$test%PCBNODE%.bat

:end
