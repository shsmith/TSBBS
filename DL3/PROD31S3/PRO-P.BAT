@echo off
echo off
rem -- pro-p.bat - process "repack" archive request - for ProDOOR 3.1
rem -- %1-resultfile, %2 sourcefile, %3 destfile, %4 playpen

rem verify proper command line
if .%4 == . goto usage
if .%5 == . goto pars_ok

:usage
echo ERROR! PRO-P.BAT CALLED WITH IMPROPER COMMAND-LINE.
echo P0=%0 P1=%1 P2=%2 P3=%3 P4=%4 P5=%5 >>%1
goto end

:pars_ok
rem verify that destination format is known
chkpath testfile %0 >>%1
if errorlevel 1 goto end
testfile %3 arc zip pak lzh zoo
if errorlevel == 98 goto dest_error
if errorlevel == 5 goto destok
if errorlevel == 4 goto destok
if errorlevel == 3 goto destok
if errorlevel == 2 goto destok
if errorlevel == 1 goto destok
goto dest_error

:destok
rem verify that the playpen is empty; clean it out if needed
if not exist %4\*.* goto emptyplay
echo Y|del %4 >nul

:emptyplay
rem unpack file according to source format
testfile %2 arc zip pak lzh zoo
if errorlevel == 98 goto cant_handle
if errorlevel == 5 goto zoo
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arc
goto cant_handle

:zoo
chkpath zoo %0 >>%1
if errorlevel 1 goto unpack_error
zoo -extract >>%1 %2 %4
goto repack

:arc
chkpath pkunpak %0 >>%1
if errorlevel 1 goto unpack_error
pkunpak >>%1 %2 %4
goto repack

:zip
chkpath pkunzip %0 >>%1
if errorlevel 1 goto unpack_error
pkunzip >>%1 %2 %4
goto repack

:pak
chkpath pak %0 >>%1
if errorlevel 1 goto unpack_error
pak e >>%1 %2 %4
goto repack

:lzh
chkpath lharc %0 >>%1
if errorlevel 1 goto unpack_error
lharc e /v >>%1 %2 %4\
goto repack

:repack
if errorlevel 1 goto unpack_error

rem file is unpacked, now repack in destination format
testfile %3 arc zip pak lzh zoo
if errorlevel == 98 goto dest_error
if errorlevel == 5 goto tozoo
if errorlevel == 4 goto tolzh
if errorlevel == 3 goto topak
if errorlevel == 2 goto tozip
if errorlevel == 1 goto toarc
goto cant_handle

:tozoo
chkpath zoo %0 >>%1
if errorlevel 1 goto pack_error
zoo -move >>%1 %3 %4\*
goto done

:toarc
chkpath pkpakjr %0 >>%1
if errorlevel 1 goto pack_error
pkpakjr -m >>%1 %3 %4\*.*
goto done

:tozip
chkpath pkzip %0 >>%1
if errorlevel 1 goto pack_error
pkzip -m -es >>%1 %3 %4\*.*
goto done

:topak
chkpath pak %0 >>%1
if errorlevel 1 goto pack_error
pak m >>%1 %3 %4\*.*
goto done

:tolzh
chkpath lharc %0 >>%1
if errorlevel 1 goto pack_error
lharc m /v >>%1 %3 %4\*.*
goto done

:done
if errorlevel 1 goto pack_error
echo. >>%1
echo %3 created.  Download it before leaving ProDoor. >>%1

rem -- remove source file if it has the same name as destination
rem -- (usually happens when repacking ZIPM packets)
chkpath -N %2 %3
if errorlevel 1 goto end
del %2
goto end

:dest_error
echo Sorry, %0 does not know how to create %3 ! >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %2 ! >>%1
goto end

:pack_error
echo Y|del %4 >nul
echo. >>%1
echo %0: Error creating %3. >>%1
echo The system is either low on disk space or memory. >>%1
goto end

:unpack_error
echo Y|del %4 >nul
echo. >>%1
echo %0: Error unpacking %2. >>%1
echo The system is either low on disk space or memory. >>%1
goto end

:end
