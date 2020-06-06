@echo off
if .%PROMPT% == .Node-4 goto node4
if .%PROMPT% == .Node-3 goto node3
if .%PROMPT% == .Node-2 goto node2
if .%PROMPT% == .Node-1 goto node1

set extuser=U:\PROD\extuser
set confinfo=U:\PROD\confinfo

if exist event.bat rename event.bat event.sys
if exist remote.bat rename remote.bat remote.sys
if exist door.bat del door.bat

recycle >NUL
if errorlevel 1 goto runpcb
copy prodoor door.bat >nul
door N

:runpcb
if exist $door.bat del $door.bat
if exist users.sys pcb145/key:open;prodoor^M
if exist door.sys pcb145/key:open;prodoor^M
prolon prolon.cnf J:\pcb3

if exist door.bat door
if exist remote.bat remote
if exist event.bat event
if exist endpcb goto end
board

:end
del endpcb

echo Type BOARD to restart System
goto exit

:node4
call pcb4
board

:node3
call pcb3
board

:node2
call pcb2
board

:node1
call pcb1
board

:exit
