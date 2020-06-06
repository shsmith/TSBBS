@echo off
if exist event.bat rename event.bat event.sys
if exist remote.bat rename remote.bat remote.sys
if exist door.bat del door.bat
if exist endpcb del endpcb

pcboard

if exist door.bat door
if exist remote.bat remote
if exist event.bat event
if exist endpcb goto end
board

:end
del endpcb
hstreset 1
if errorlevel 1 board

echo Type BOARD to restart PCBoard

