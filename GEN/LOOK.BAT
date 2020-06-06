@echo off
SET TARGET=dl* upload private
SET PAR=%1

:next
shift
if .%1 == . goto last
set PAR=%PAR% %1
goto next

:last
if %PAR%. == . goto usage

echo Searching for "%PAR%" in %TARGET% ...
grep -i "%PAR%" %TARGET% >t
q t
goto exit

:usage
echo Usage: LOOK {search keyword}
echo Searches for matching records in %TARGET% file.

:exit
echo.
set TARGET=
set PAR=
