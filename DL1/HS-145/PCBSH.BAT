echo off
if exist pcberr.fil del pcberr.fil
if exist %DSZLOG% del %DSZLOG%
hslink -p%1 -e%5 -nu %3
