@echo off
if .%2 == . goto usage
if not exist %1 goto usage

finfo %2 %1 %TMP%\t
copy %TMP%\t %1
del %TMP%\t
goto end

:usage
echo Usage:    ufdir FILE_LISTING FILE_DIRECTORY
echo Example:  ufdir U:\pcb\gen\dir1 U:\shsbox
echo Par1=%1 Par2=%2 Par3=%3

:end
