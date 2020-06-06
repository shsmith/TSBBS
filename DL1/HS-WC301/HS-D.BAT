echo off
REM download from Wildcat 3.01
if exist transfer.bad del transfer.bad
hslink -p%2 -HS -NU -NV %3 %4 %5 %6 %7 %8 %9
