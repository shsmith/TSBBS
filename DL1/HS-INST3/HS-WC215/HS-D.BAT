echo off
REM download from Wildcat 2.15
cd \wildcat\ep
if exist transfer.bad del transfer.bad
hslink -p%2 -HS -NU %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 copy hs-d.bat transfer.bad
