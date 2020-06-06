@echo off
if .%2 == . goto usage
if not exist %1 goto usage

finfo %2 <%1 >%TMP%\t
copy %TMP%\t %1
del %TMP%\t
bac c:\pcb\gen\dir* i:\gen
goto end

:usage
echo Usage:    ufdir FILE_LISTING FILE_DIRECTORY
echo Example:  ufdir c:\pcb\gen\dir1 c:\shsbox

:end
