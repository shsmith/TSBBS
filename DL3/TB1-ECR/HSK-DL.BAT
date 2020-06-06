@Echo Off
HSLINK  %1 %2 %3 %4 %5 %6 %7 %8 %9 -LF%PCBDRIVE%%PCBDIR%\$DOOR.LOG -NO%PCBDRIVE%\HSLINK.DUP 
for %%f in (G:\JUNK\TEMP%NODE%\*.*) do call hsktime %%f
