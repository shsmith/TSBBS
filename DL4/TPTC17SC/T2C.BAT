echo off
rem batch driver to translate pascal to c with include file post-processing

rem insert your desired "default options" here
:set tptc=-l -wj: -sc:\inc -i

rem check for proper command-line options
if .%2 == . goto usage
if exist %1 goto usage

tptc %1 %3 %4 %5 %6 %7 %8 %9 
if errorlevel 1 goto exit

uninc %1.c %2
goto exit

:usage
echo.
echo usage:  t2c SOURCEFILE DESTDIR
echo ex:     t2c tptc \dest
echo (do not specify input file extension)

:exit
echo.

