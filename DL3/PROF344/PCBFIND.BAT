@echo off
rem -- Parameters passed to PCBFIND.BAT
rem -- %1-Port, %2-Result File, %3-Search Spec
rem -- Your PROXMAIN entry should be:
rem --    0,TEST,EXEC-PCBFIND.BAT $N$ $R$

rem -- The following is a 4DOS command to see if the third parameter
rem -- exists.  If not, it displays the error message.
if %@len[%3]==0 goto error

proecho %1 ~Searching for %3...
pcbfnd %3 > %2
proecho %1 ~
goto end

:error
proecho %1 ~Error:  You must include a filename or filespec~~

:end
