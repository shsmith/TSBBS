@echo off
echo off
rem -- pro-t.bat - process "test" archive request - for ProDOOR 3.4
rem -- %1-resultfile, %2 sourcefile

prosm /chkpath testfile %0 >>%1
if errorlevel 1 goto end
testfile %2 arc zip pak lzh zoo
if errorlevel == 98 goto cant_handle
if errorlevel == 5 goto zoo
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

:zoo
prosm /chkpath zoo %0 >>%1
if errorlevel 1 goto end
zoo -test >>%1 %2
if errorlevel 1 goto error
goto end

:arc
prosm /chkpath pkunpak %0 >>%1
if errorlevel 1 goto end
pkunpak -t >>%1 %2
if errorlevel 1 goto error
goto end

:zip
:prosm /chkpath zipds %0 >>%1
:if errorlevel 1 goto end
:zipds >>%1 %2
prosm /chkpath pkunzip %0 >>%1
if errorlevel 1 goto end
pkunzip -t >>%1 %2
if errorlevel 1 goto error
goto end

:pak
prosm /chkpath pak %0 >>%1
if errorlevel 1 goto end
pak t >>%1 %2
if errorlevel 1 goto error
goto end

:lzh
prosm /chkpath lharc %0 >>%1
if errorlevel 1 goto end
rem lharc 1.12 or later required for test function to work
lharc t /v >>%1 %2
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
