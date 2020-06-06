@echo off
rem - LMAIL - local download-by-mail entry

if not '%PCBDRIVE%' == '' goto online
set PCBDRIVE=J:
set PCBDIR=\pcb3

:online
u:
cd \pcb\dbmail
dbmail dbmail.cnf %PCBDRIVE%%PCBDIR% LOCAL
