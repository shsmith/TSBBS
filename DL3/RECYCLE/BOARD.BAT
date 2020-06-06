@echo off
if .%PROMPT% == .Node-2 goto othernode
if exist event.bat rename event.bat event.sys
if exist remote.bat rename remote.bat remote.sys
if exist door.bat del door.bat
if exist endpcb del endpcb

recycle >NUL
if errorlevel 1 goto runpcb
copy prodoor door.bat >nul
door N
:runpcb
if exist $door.bat del $door.bat

pcboard

if exist door.bat door
if exist remote.bat remote
if exist event.bat event
if exist endpcb goto end
board

:end
del endpcb
set PRODEBUG=
hstreset 1
echo Type BOARD to restart PCBoard
goto exit

:othernode
cd \pcb2
board

:exit
