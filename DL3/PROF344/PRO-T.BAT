@echo off
echo off
rem -- pro-t.bat - process "test" archive request - for ProDOOR 3.4
rem -- %1-resultfile, %2 sourcefile

testfile %2 arc zip pak lzh gif
if errorlevel == 98 goto cant_handle
if errorlevel == 5 goto gif
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

:gif
giftest %2 >>%1
goto end

:arc
pkunpak -t >>%1 %2
if errorlevel 1 goto error
goto end

:zip
ptest %2 \prolon%pcbnode%\ptest.cfg
if not exist %2 goto error
goto end

:pak
pak t >>%1 %2
if errorlevel 1 goto error
goto end

:lzh
lha t /v >>%1 %2
if errorlevel 1 goto error
goto end

:pack_error
echo Y|del $$$$ >nul
rmdir $$$$
goto error

:error
echo. >>%1
echo %2 has errors! >>%1
echo %0: Error were detected while processing %2 ! >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %2 ! >>%1

:end
