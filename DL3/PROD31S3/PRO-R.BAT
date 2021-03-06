@echo off
echo off
rem -- pro-r.bat - process "relist" archive contents - for ProDOOR 3.1
rem -- %1-comport, %2-minutes, %3-resultfile, %4 sourcefile

chkpath testfile %0 >>%3
if errorlevel 1 goto end
testfile %4 arc zip pak lzh zoo
if errorlevel == 98 goto cant_handle
if errorlevel == 5 goto zoo
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

:zoo
chkpath zoo %0 >>%3
if errorlevel 1 goto end
zoo -list >>%3 %4
if errorlevel 1 goto error
goto end

:arc
chkpath arctv %0 >>%3
if errorlevel 1 goto end
arctv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:zip
chkpath ziptv %0 >>%3
if errorlevel 1 goto end
ziptv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:pak
chkpath pak %0 >>%3
if errorlevel 1 goto end
pak v >>%3 %4
if errorlevel 1 goto error
goto end

:lzh
chkpath lzhtv %0 >>%3
if errorlevel 1 goto end
lzhtv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:error
echo. >>%1
echo %0: Error processing %4 ! >>%1
echo The system is either low on disk space or memory. >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %4 ! >>%3

:end
