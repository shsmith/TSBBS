@echo off

c:
cd\pcb\doors
if exist pcboard.sys del pcboard.sys
if exist callinfo.bbs del callinfo.bbs
if exist door.sys del door.sys
cd\PCB
if exist event.bat rename event.bat event.sys
if exist remote.bat rename remote.bat remote.sys
if exist door.bat del door.bat
if exist endpcb del endpcb

recycle
if errorlevel 2 goto maint
if errorlevel 1 goto runpcb
copy prodoor door.bat >nul
door N

:maint
if exist sofar.bat call sofar.bat
if exist laston.bat call laston.bat
call logofftu.bat
call logontur.bat

:runpcb
if exist $door.bat del $door.bat
c:
cd\pcb
prolon prolon.cnf c:\pcb

rem. c:
rem. cd\pcb
rem. pcboard

if exist door.bat door
if exist remote.bat remote
if exist event.bat event
if exist endpcb goto end
board

:end
del endpcb
ask-yn3 -w4 -n -v Do you want to Drop to DOS ?
if errorlevel 1 goto B
if errorlevel 0 goto C
:B
board
:C
hstreset 1
echo   Type BOARD to restart PCBoard
