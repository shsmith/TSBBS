@echo off
echo off
rem -- pro-x.bat - process "extract member" archive request - for ProDOOR 3.1
rem -- %1-resultfile, %2 sourcefile, %3 destfile, %4..%9 memberfiles

chkpath testfile %0 >>%1
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
chkpath zoo %0 >>%1
if errorlevel 1 goto end
mkdir $$$$
cd $$$$
zoo -extract >>%1 %2 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
cd $$$$
zoo -move >>%1 %3 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
echo Y|del $$$$ >nul
rmdir $$$$
goto end

:arc
chkpath proxtra %0 >>%1
if errorlevel 1 goto end
proxtra >>%1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto error
goto end

:zip
chkpath proxzip %0 >>%1
if errorlevel 1 goto end
proxzip >>%1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto error
goto end

:pak
chkpath pak %0 >>%1
if errorlevel 1 goto end
mkdir $$$$
cd $$$$
pak e /wn >>%1 %2 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
cd $$$$
pak m >>%1 %3 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
echo Y|del $$$$ >nul
rmdir $$$$
goto end

:lzh
chkpath lharc %0 >>%1
if errorlevel 1 goto end
mkdir $$$$
cd $$$$
lharc e /v /m >>%1 %2 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
cd $$$$
lharc m /v >>%1 %3 %4 %5 %6 %7 %8 %9
cd ..
if errorlevel 1 goto pack_error
echo Y|del $$$$ >nul
rmdir $$$$
goto end

:pack_error
echo Y|del $$$$ >nul
rmdir $$$$
goto error

:error
echo. >>%1
echo %0: Error creating %3 ! >>%1
echo The system is either low on disk space or memory. >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %2 ! >>%1

:end
