@echo off
if exist event.bat rename event.bat event.sys
if exist remote.bat rename remote.bat remote.sys
if exist door.bat del door.bat

rem NOTE! the following statement must NOT removed if present in your BOARD.BAT
:if exist endpcb del endpcb

recycle >NUL
if errorlevel 1 goto runpcb
copy prodoor door.bat >nul
door N
:runpcb
if exist $door.bat del $door.bat

echo Reloading system ...
:$SYSTEM

set extuser=c:\prod\extuser
set confinfo=c:\prod\confinfo
prolon prolon.cnf c:\pcb1

if exist door.bat door
if exist remote.bat remote
if exist event.bat event
if exist endpcb goto end
board

:end
del endpcb
echo Type BOARD to restart system
goto exit

:exit
