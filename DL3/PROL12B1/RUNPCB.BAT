rem find /C value corresponding to PCBSPEED value
if %PCBSPEED%==Local set PCBC=/LOCALON
if %PCBSPEED%==300 set PCBC=/C:0
if %PCBSPEED%==1200 set PCBC=/C:2
if %PCBSPEED%==2400 set PCBC=/C:3
if %PCBSPEED%==4800 set PCBC=/C:4
if %PCBSPEED%==9600 set PCBC=/C:5
if %PCBSPEED%==12000 set PCBC=/C:5
if %PCBSPEED%==14400 set PCBC=/C:5
if %PCBSPEED%==19200 set PCBC=/C:6
if %PCBSPEED%==57600 set PCBC=/C:8
if %PCBSPEED%==115200 set PCBC=/C:9

IF EXIST DOOR.BAT DEL DOOR.BAT
CLEARSYS
PCB145 %PCBC% %PCBERR%

if exist endpcb del endpcb
if exist door.bat door
if exist remote.bat remote
if exist event.bat event
board
