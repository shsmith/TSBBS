@echo off
echo off
rem -- pro-v.bat - process "view text" archive request - for ProDOOR 3.4
rem -- %1-resultfile, %2 sourcefile, %3..%9 memberfiles

prosm /chkpath testfile %0 >>%1
if errorlevel 1 goto end
testfile %2 arc zip pak lzh
if errorlevel == 98 goto cant_handle
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto end

:arc
prosm /chkpath pkunpak %0 >>%1
if errorlevel 1 goto end
pkunpak -c >>%1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto error
goto end

:zip
prosm /chkpath pkunzip %0 >>%1
if errorlevel 1 goto end
pkunzip -c >>%1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto error
goto end

:pak
prosm /chkpath pak %0 >>%1
if errorlevel 1 goto end
pak p >>%1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto error
goto end

:lzh
echo. >>%1
echo. %0: The LHARC10 program is unreliable in this context. >>%1
echo. Please use the (R)elist command to view texts within LZH files. >>%1
goto end
:prosm /chkpath lharc %0 >>%1
:if errorlevel 1 goto end
:lharc p /v >>%1 %2 %3 %4 %5 %6 %7 %8 %9
:if errorlevel 1 goto error
:goto end

:error
echo. >>%1
echo %0: Error processing %2 ! >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %2 ! >>%1

:end
