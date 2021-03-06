@echo off

prosm /chkpath testfile %0 >>%3
if errorlevel 1 goto end
testfile %4 arj zip pak lzh zoo arc dms
if errorlevel == 98 goto cant_handle
if errorlevel == 7 goto dms
if errorlevel == 6 goto arc
if errorlevel == 5 goto zoo
if errorlevel == 4 goto lzh
if errorlevel == 3 goto pak
if errorlevel == 2 goto zip
if errorlevel == 1 goto arj
goto end

:zoo
prosm /chkpath zoo %0 >>%3
if errorlevel 1 goto end
zoo -list >>%3 %4
if errorlevel 1 goto error
goto end

:arj
prosm /chkpath arj %0 >>%3
if errorlevel 1 goto end
CD%PCBDIR%
COPY PCBOARD.SYS PCBFV.SYS > nul
PROD2PCB
c:\pcb\pcbfv\pcbfv pcbfv.cnf %4
COPY PCbFV.SYS PCBOARD.SYS > nul
goto end

:zip
prosm /chkpath ziptv %0 >>%3
if errorlevel 1 goto end
CD%PCBDIR%
COPY PCBOARD.SYS PCBFV.SYS > nul
PROD2PCB
c:\pcb\pcbfv\pcbfv pcbfv.cnf %4
COPY PCbFV.SYS PCBOARD.SYS > nul
goto end

:pak
prosm /chkpath pak %0 >>%3
if errorlevel 1 goto end
pak v >>%3 %4
if errorlevel 1 goto error
goto end

:lzh
prosm /chkpath lzhtv %0 >>%3
if errorlevel 1 goto end
CD%PCBDIR%
COPY PCBOARD.SYS PCBFV.SYS > nul
PROD2PCB
c:\pcb\pcbfv\pcbfv pcbfv.cnf %4
COPY PCbFV.SYS PCBOARD.SYS > nul
goto end

:dms
prosm /chkpath viewdms %0 >>%3
if errorlevel 1 goto end
viewdms >>%3 %4
if errorlevel 1 goto error
goto end

:arc
prosm /chkpath arctv %0 >>%3
if errorlevel 1 goto end
arctv -p%1 -t%2 >>%3 %4
if errorlevel 1 goto error
goto end

:error
echo. >>%1
echo %0: Error processing %4 ! >>%1
goto end

:cant_handle
echo Sorry, %0 does not know how to process %4 ! >>%3

:end
CD\PRODOOR



