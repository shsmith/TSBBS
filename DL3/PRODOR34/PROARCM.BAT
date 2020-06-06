echo off
rem. process message ZIPM request - for ProDOOR 3.4
rem. %1-logfile, %2-mailarc, %3-mailtext
prosm /chkpath pkzip %0 >>%1
pkZIP -es -m %2 %3 >>%1
pkZIP -v %2 >>%1
