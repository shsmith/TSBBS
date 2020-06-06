rem Run the BBSLIST nightly event
CD \PCB\DOOR\BBSLIST

rem Bypass sort/update when no changes have been made since last update
rem IF NOT EXIST BBSLIST.BAK GOTO EXIT
rem DEL BBSLIST.BAK

rem Sort the BBS list by phone number.
rem Add /+15 to sort by Name, /+38 to sort by Location or /+58 to sort
rem by Sysop name.  Any text sort program can be used in place of QSORT,
rem but QSORT is good because it can handle any size file with ease.
QSORT BBSLIST.DAT

rem Purge outdated entries from the BBSLIST and generate updated (and sorted)
rem bulletin files.
SET EXTUSER=U:\PROD\EXTUSER
SET CONFINFO=U:\PROD\CONFINFO
BBSLIST BBSLIST.CFG U:\PCB%PCBNODE% PURGE LOCAL

rem ZIP up the bbs list bulletins for downloading by callers
PKZIP1 -! -U U:\DL1\HSBBSLST U:\PCB\GEN\BLT20 U:\PCB\GEN\BLT19

:EXIT
CD \PCB
