@echo off
rem -- process test uploads request - for ProDOOR 3.4
rem -- %1-logfile, %2-testdir, %3-comport

IF NOT EXIST Z:\E\play1\*.* exit

rem -- test each uploaded file individually
p:\bin\proecho %3 ~~Testing uploads.  Please wait...~

rem test if single file.  DOS double processes %%f where only 1 file exists
P:\BIN\ONLY1 Z:\E\play1

IF ERRORLEVEL == 1 GOTO JUST1
  for %%f in (Z:\E\play1\*.*) do  call p:\prod\prout1 %1 %f 1 0
GOTO MORETHAN1

:JUST1
  rem %COMSPEC% /c P:\prod\PTEST %1 z:\e\play1\%only1% p:\prod\ptest.CFG
  call p:\prod\prout1.bat %1 Z:\E\play1\%Only1%  1 0
  SET ONLY1=

:MORETHAN1
  IF EXIST Z:\E\play1\*.arj  cmntsome -hp:\bin\ziphdr -dZ:\E\play1
rem    IF EXIST Z:\E\play1\*.VIR move Z:\E\play1\*.VIR Z:\E\hold
rem    IF EXIST Z:\E\play1\*.OLD move Z:\E\play1\*.OLD Z:\E\hold
rem    IF EXIST Z:\E\play1\*.BAD move Z:\E\play1\*.BAD Z:\E\hold
rem    IF EXIST Z:\E\play1\*.DUP move Z:\E\play1\*.DUP Z:\E\hold
rem    IF EXIST Z:\E\play1\*.PCK move Z:\E\play1\*.PCK Z:\E\hold
rem    IF EXIST Z:\E\play1\*.DOS move Z:\E\play1\*.DOS Z:\E\hold
:END
