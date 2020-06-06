echo off
REM upload to Wildcat 3.01
if exist transfer.bad del transfer.bad
hslink -P%2 -HS -NV
