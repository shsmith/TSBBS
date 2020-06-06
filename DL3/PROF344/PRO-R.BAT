@echo off
rem -- pro-r.bat - process "relist" archive contents - for ProDOOR 3.4
rem -- %1-comport, %2-minutes, %3-resultfile, %4 sourcefile

prosm /chkpath testfile %0 >>%3
if errorlevel 1 goto end
testfile %4 arc zip lzh gif
if errorlevel == 98 goto cant_handle
if errorlevel == 4 goto gif
if errorlevel == 3 goto lzh
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

:gif
giftest %4 /p:%1
goto end

:arc
arctv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:zip
ziptv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:lzh
lzhtv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:error
echo. >>%1
echo %0: Error processing %4 ! >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %4 ! >>%3

:end
